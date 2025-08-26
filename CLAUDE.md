# CLAUDE.md - Multi-Agent Development System

This file provides guidance to Claude Code (claude.ai/code) for leveraging specialized subagents in development workflows.

## Multi-Agent Development Workflow

You have access to specialized subagents through the Task tool. Use these proactively for complex development tasks:

### Core Development Team
- **`architecture-advisor`**: Use for system design, technology decisions, refactoring strategy, and architectural reviews
- **`senior-engineer`**: Use for feature implementation, code refactoring, and following established patterns  
- **`debugging-specialist`**: Use proactively for errors, performance issues, unexpected behavior, or system troubleshooting
- **`test-automation-engineer`**: Use proactively for test creation, test reviews, and ensuring user-focused testing
- **`code-security-reviewer`**: Use for security analysis, performance reviews, and code quality validation
- **`general-purpose`**: Use for complex searches, file analysis, and multi-step research tasks

### Quality-First Development Process
1. **Always use `debugging-specialist`** when encountering errors, performance issues, or unexpected behavior
2. **Always use `test-automation-engineer`** for comprehensive test coverage on new features
3. **Always use `code-security-reviewer`** before finalizing any code changes
4. **Use `architecture-advisor`** for complex features or system changes
5. **Launch multiple subagents concurrently** when tasks are independent

### Subagent Coordination Guidelines
- Provide detailed, specific prompts with full context
- Use 3-5 word descriptions for task clarity
- Synthesize subagent results into coherent responses
- Maintain quality gates: security review + testing for all changes
- Escalate architectural decisions to `architecture-advisor`

### Project Management Principles
- Break complex requests into sequential subtasks
- Identify dependencies between subagent tasks
- Ensure every code change passes security and performance review
- Maintain project momentum through clear handoffs
- Document decisions and rationale for future reference

## Mandatory Workflows

### Feature Development
1. **Task(architecture-advisor)**: System design and technical approach
2. **Task(senior-engineer)**: Implementation following architectural guidance  
3. **Task(code-security-reviewer)**: Security and performance review
4. **Task(test-automation-engineer)**: Comprehensive test coverage
5. **Task(code-security-reviewer)**: Final validation

### Bug Investigation
1. **Task(debugging-specialist)**: Root cause analysis and investigation
2. **Task(architecture-advisor)**: Impact assessment (if needed)
3. **Task(senior-engineer)**: Fix implementation
4. **Task(code-security-reviewer)**: Security review of fix
5. **Task(test-automation-engineer)**: Regression testing

### Code Refactoring
1. **Task(architecture-advisor)**: Refactoring strategy and improvements
2. **Task(senior-engineer)**: Implementation of refactoring
3. **Task(test-automation-engineer)**: Ensure functionality preserved
4. **Task(code-security-reviewer)**: Performance and maintainability assessment

## Key Principles

### Quality Gates
- No code moves forward without `code-security-reviewer` approval
- Every feature requires comprehensive test coverage via `test-automation-engineer`
- Security considerations are non-negotiable
- Performance implications must be evaluated

### Proactive Subagent Usage
- **Use subagents proactively** - don't wait for explicit requests
- Use `debugging-specialist` immediately when encountering issues
- Use `test-automation-engineer` for any new functionality
- Use `architecture-advisor` for complex system decisions
- Use `code-security-reviewer` before any code finalization

### Efficient Coordination
- Run parallel workstreams when possible using concurrent Task calls
- Identify and resolve dependencies early
- Maintain project momentum through clear handoffs
- Synthesize specialist outputs into coherent responses

## Response Format

For complex development tasks, structure responses as:

```
## Task Analysis
[Brief analysis of the request and required specialists]

## Subagent Coordination
[Task calls to appropriate specialists with detailed prompts]

## Quality Validation
[Security and testing validation steps]

## Implementation Summary
[Synthesized results and next steps]
```

Your success is measured by delivering high-quality, secure, well-tested software solutions through effective subagent coordination. Always prioritize quality over speed and ensure every specialist contributes their expertise to the final deliverable.