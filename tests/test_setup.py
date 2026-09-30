import os
from pathlib import Path
import subprocess
import tempfile
import unittest


SETUP = Path(__file__).resolve().parents[1] / "setup.sh"
MOCKS = r"""
OP_INSTALLED=${OP_INSTALLED:-false}
PARU_INSTALLED=${PARU_INSTALLED:-true}
DESKTOP_INSTALLED=${DESKTOP_INSTALLED:-true}

record() {
    printf 'CALL:' >&2
    printf ' %s' "$@" >&2
    printf '\n' >&2
}
consume_input() {
    while IFS= read -r line; do
        printf 'INPUT: %s\n' "$line" >&2
    done
}
command() {
    if [[ "$*" == "-v op" ]]; then
        [[ "$OP_INSTALLED" == "true" ]]
    else
        builtin command "$@"
    fi
}
sudo() {
    record sudo "$@"
    [[ "$*" != "${FAIL_COMMAND:-}" ]] || return 7
    case "$1" in
        tee|gpg) consume_input ;;
        apt-get|dnf)
            if [[ "$*" == *"install -y 1password-cli" ]]; then
                [[ "${INSTALL_NOOP:-false}" == "true" ]] || OP_INSTALLED=true
            fi ;;
        rpm-ostree|rpm|install) ;;
        *) printf 'Unexpected sudo command\n' >&2; return 99 ;;
    esac
}
curl() {
    record curl "$@"
    [[ "${CURL_FAIL:-false}" != "true" ]] || return 7
    printf 'mock signing key or policy\n'
}
gpg() {
    record gpg "$@"
    case "$1" in
        --import) consume_input; : > "$BUILD_DIR/key-imported" ;;
        --list-keys)
            [[ "${GPG_KEY_FAIL:-false}" != "true" ]] &&
                { [[ "${GPG_KEY_INSTALLED:-true}" == "true" ]] || [[ -f "$BUILD_DIR/key-imported" ]]; } ;;
        *) return 99 ;;
    esac
}
dpkg() { record dpkg "$@"; printf '%s\n' "${TEST_ARCH:-amd64}"; }
rpm() { record rpm "$@"; [[ "$DESKTOP_INSTALLED" == "true" ]]; }
pacman() { record pacman "$@"; [[ "$PARU_INSTALLED" == "true" ]]; }
paru() {
    record paru "$@"
    [[ "${PARU_FAIL:-false}" != "true" ]] || return 7
    [[ "$*" != "-S --needed 1password-cli" ]] || OP_INSTALLED=true
}
op() { record op "$@"; [[ "${OP_FAIL:-false}" != "true" ]]; }
id() { printf '%s\n' "${TEST_UID:-1000}"; }
mktemp() { printf '%s\n' "$BUILD_DIR"; }
rm() { record rm "$@"; }
git() {
    record git "$@"
    [[ "${GIT_FAIL:-false}" != "true" ]] || return 7
    [[ "$*" != *"show HEAD:PKGBUILD" ]] || printf 'pkgname=paru-bin\n'
}
makepkg() { record makepkg "$@"; [[ "${MAKEPKG_FAIL:-false}" != "true" ]]; }
"""


class SetupTests(unittest.TestCase):
    def run_setup(self, body, *, stdin="", **env):
        with tempfile.TemporaryDirectory() as directory:
            build_dir = Path(directory) / "build"
            (build_dir / "paru-bin").mkdir(parents=True)
            return subprocess.run(
                ["bash", "--noprofile", "--norc", "-c",
                 'source "$1"\n' + MOCKS + "\n" + body, "test", str(SETUP)],
                input=stdin,
                text=True,
                capture_output=True,
                env={**os.environ, "BUILD_DIR": str(build_dir), **env},
                timeout=10,
            )

    def assert_success(self, result):
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_sourcing_does_not_run_setup(self):
        result = self.run_setup("true")
        self.assert_success(result)
        self.assertEqual(result.stdout, "")
        self.assertEqual(result.stderr, "")

    def test_existing_op_skips_native_installation(self):
        for system in ("macos", "debian", "fedora", "immutable"):
            with self.subTest(system=system):
                result = self.run_setup(f"install_1password {system}", OP_INSTALLED="true")
                self.assert_success(result)
                self.assertIn("CALL: op --version", result.stderr)
                self.assertNotIn("CALL: sudo", result.stderr)

    def test_debian_signed_repository_and_repeat_install(self):
        result = self.run_setup("install_1password debian\ninstall_1password debian", TEST_ARCH="arm64")
        self.assert_success(result)
        self.assertIn("signed-by=/usr/share/keyrings/1password-archive-keyring.gpg", result.stderr)
        self.assertIn("linux/debian/arm64 stable main", result.stderr)
        self.assertIn("/etc/debsig/policies/AC2D62742012EA22/1password.pol", result.stderr)
        self.assertIn("gpg --dearmor --yes", result.stderr)
        self.assertEqual(result.stderr.count("CALL: sudo apt-get install -y 1password-cli"), 1)
        self.assertEqual(result.stderr.count("CALL: op --version"), 2)

    def test_fedora_signed_repository(self):
        result = self.run_setup("install_1password fedora")
        self.assert_success(result)
        self.assertIn("baseurl=https://downloads.1password.com/linux/rpm/stable/$basearch", result.stderr)
        self.assertIn("INPUT: gpgcheck=1", result.stderr)
        self.assertIn("INPUT: repo_gpgcheck=1", result.stderr)
        self.assertIn("gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-1password", result.stderr)
        self.assertIn("CALL: sudo rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-1password", result.stderr)
        self.assertIn("CALL: sudo dnf install -y 1password-cli", result.stderr)
        self.assertIn("CALL: op --version", result.stderr)

    def test_immutable_queues_both_packages_without_rpm_import(self):
        result = self.run_setup(
            'install_1password immutable\nprintf "reboot=%s\\n" "$ONEPASSWORD_REBOOT_REQUIRED"',
            DESKTOP_INSTALLED="false",
        )
        self.assert_success(result)
        self.assertIn("CALL: sudo rpm-ostree install --idempotent 1password-cli 1password", result.stderr)
        self.assertNotIn("rpm --import", result.stderr)
        self.assertNotIn("CALL: op --version", result.stderr)
        self.assertIn("reboot=true", result.stdout)

    def test_immutable_cli_only(self):
        result = self.run_setup("install_1password immutable")
        self.assert_success(result)
        self.assertIn("CALL: sudo rpm-ostree install --idempotent 1password-cli\n", result.stderr)

    def test_immutable_desktop_only_keeps_existing_cli(self):
        result = self.run_setup("install_1password immutable", OP_INSTALLED="true", DESKTOP_INSTALLED="false")
        self.assert_success(result)
        self.assertIn("CALL: sudo rpm-ostree install --idempotent 1password\n", result.stderr)
        self.assertIn("CALL: op --version", result.stderr)

    def test_package_failures_are_not_reported_as_queued(self):
        for system, command in (
            ("debian", "apt-get install -y 1password-cli"),
            ("fedora", "dnf install -y 1password-cli"),
            ("immutable", "rpm-ostree install --idempotent 1password-cli"),
        ):
            with self.subTest(system=system):
                result = self.run_setup(f"install_1password {system}", FAIL_COMMAND=command)
                self.assertNotEqual(result.returncode, 0)
                self.assertNotIn("packages queued", result.stdout)
                self.assertNotIn("CALL: op --version", result.stderr)

    def test_failed_download_stops_before_package_install(self):
        for system in ("debian", "fedora", "immutable"):
            with self.subTest(system=system):
                result = self.run_setup(f"install_1password {system}", CURL_FAIL="true")
                self.assertNotEqual(result.returncode, 0)
                self.assertNotIn("CALL: sudo apt-get install -y 1password-cli", result.stderr)
                self.assertNotIn("CALL: sudo dnf install", result.stderr)
                self.assertNotIn("CALL: sudo rpm-ostree install", result.stderr)

    def test_arch_uses_existing_paru_bin(self):
        result = self.run_setup("install_1password arch")
        self.assert_success(result)
        self.assertIn("CALL: paru --version", result.stderr)
        self.assertIn("CALL: paru -S --needed 1password-cli", result.stderr)
        self.assertIn("CALL: op --version", result.stderr)
        self.assertNotIn("CALL: git", result.stderr)

    def test_arch_imports_missing_vendor_signing_key(self):
        result = self.run_setup("install_1password arch", GPG_KEY_INSTALLED="false")
        self.assert_success(result)
        self.assertIn("CALL: gpg --import", result.stderr)
        self.assertIn("CALL: gpg --list-keys 3FEF9748469ADBE15DA7CA80AC2D62742012EA22", result.stderr)
        self.assertIn("CALL: paru -S --needed 1password-cli", result.stderr)

    def test_arch_rejects_unexpected_vendor_signing_key(self):
        result = self.run_setup("install_1password arch", GPG_KEY_FAIL="true")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("CALL: gpg --import", result.stderr)
        self.assertNotIn("CALL: paru -S", result.stderr)

    def test_arch_provisions_paru_even_when_op_exists(self):
        result = self.run_setup("install_1password arch", stdin="y\n", PARU_INSTALLED="false", OP_INSTALLED="true")
        self.assert_success(result)
        self.assertIn("https://aur.archlinux.org/paru-bin.git", result.stderr)
        self.assertIn("show HEAD:PKGBUILD", result.stderr)
        self.assertIn("CALL: makepkg -si", result.stderr)
        self.assertIn("CALL: paru --version", result.stderr)
        self.assertNotIn("CALL: paru -S", result.stderr)
        self.assertIn("CALL: rm -rf", result.stderr)

    def test_arch_rejects_root_and_preserves_review(self):
        result = self.run_setup("install_1password arch", TEST_UID="0")
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn("CALL: makepkg", result.stderr)
        for answer in ("n\n", ""):
            with self.subTest(answer=answer):
                result = self.run_setup("install_1password arch", stdin=answer, PARU_INSTALLED="false")
                self.assertNotEqual(result.returncode, 0)
                self.assertNotIn("CALL: makepkg", result.stderr)
                self.assertIn("CALL: rm -rf", result.stderr)

    def test_arch_bootstrap_and_compatibility_failures_stop_install(self):
        for variable in ("GIT_FAIL", "MAKEPKG_FAIL", "PARU_FAIL"):
            with self.subTest(variable=variable):
                result = self.run_setup("install_1password arch", stdin="y\n", PARU_INSTALLED="false", **{variable: "true"})
                self.assertNotEqual(result.returncode, 0)
                self.assertNotIn("CALL: paru -S", result.stderr)
                self.assertNotIn("CALL: op --version", result.stderr)
                self.assertIn("CALL: rm -rf", result.stderr)

    def test_missing_or_broken_op_fails_verification(self):
        result = self.run_setup("install_1password macos")
        self.assertNotEqual(result.returncode, 0)
        result = self.run_setup("install_1password fedora", INSTALL_NOOP="true")
        self.assertNotEqual(result.returncode, 0)
        result = self.run_setup("install_1password debian", OP_INSTALLED="true", OP_FAIL="true")
        self.assertNotEqual(result.returncode, 0)

    def test_main_reports_pending_reboot(self):
        result = self.run_setup(r"""
detect_system() { printf 'immutable\n'; }
install_packages() { install_1password "$1"; }
set_default_shell() { :; }
cleanup_legacy_links() { :; }
cleanup_macos_shadows() { :; }
apply_dotfiles() { :; }
main
""")
        self.assert_success(result)
        self.assertIn("Setup complete — reboot to activate", result.stdout)

    def test_macos_keeps_brew_as_cli_owner(self):
        result = self.run_setup(r"""
install_brew_prereqs() { :; }
install_brew() { :; }
brew() { record brew "$@"; OP_INSTALLED=true; }
install_packages macos
""")
        self.assert_success(result)
        self.assertIn("CALL: brew bundle --file", result.stderr)
        self.assertIn("CALL: op --version", result.stderr)
        self.assertNotIn("CALL: sudo", result.stderr)


if __name__ == "__main__":
    unittest.main()
