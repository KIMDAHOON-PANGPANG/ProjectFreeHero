# CLAUDE.local.md 템플릿

개인 오버라이드를 위해 이 파일을 프로젝트 루트에 `CLAUDE.local.md` 로 복사하세요.
이 파일은 gitignore 되며 커밋되지 않습니다.

```markdown
# Personal Preferences

## Model Preferences
- Prefer Opus for complex design tasks
- Use Haiku for quick lookups and simple edits

## Workflow Preferences
- Always run tests after code changes
- Compact context proactively at 60% usage
- Use /clear between unrelated tasks

## Local Environment
- Python command: python (or py / python3)
- Shell: Git Bash on Windows
- IDE: VS Code with Claude Code extension

## Communication Style
- Keep responses concise
- Show file paths in all code references
- Explain architectural decisions briefly

## Personal Shortcuts
- When I say "review", run /code-review on the last changed files
- When I say "status", show git status + sprint progress
```

## 셋업

1. 본 템플릿을 프로젝트 루트로 복사: `cp .claude/docs/CLAUDE-local-template.md CLAUDE.local.md`
2. 본인 선호에 맞게 편집
3. `CLAUDE.local.md` 가 `.gitignore` 에 포함되어 있는지 확인 (Claude Code 는 프로젝트 루트에서 읽음)
