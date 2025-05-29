## 🔑 Setting up your OpenAI API Key

### Quick Setup:

1. **Get your OpenAI API key** from: https://platform.openai.com/api-keys

2. **Add to your shell profile** (~/.zshrc):
   ```bash
   export OPENAI_API_KEY="your-api-key-here"
   ```

3. **Reload your shell**:
   ```bash
   source ~/.zshrc
   ```

4. **Test in a new terminal**:
   ```bash
   echo $OPENAI_API_KEY
   ```

### Alternative: Session-only setup:
```bash
export OPENAI_API_KEY="your-api-key-here"
nvim
```

Ready to use GPT-4 in Neovim! 🚀
