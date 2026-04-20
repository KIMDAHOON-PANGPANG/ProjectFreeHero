# 활성 훅

훅은 `.claude/settings.json` 에 설정되며 자동으로 발화합니다:

| 훅 | 이벤트 | 트리거 | 동작 |
| ---- | ----- | ------- | ------ |
| `validate-commit.sh` | PreToolUse (Bash) | `git commit` 커맨드 | 디자인 문서 섹션, JSON 데이터 파일, 하드코딩된 값, TODO 포맷을 검증합니다 |
| `validate-push.sh` | PreToolUse (Bash) | `git push` 커맨드 | 보호된 브랜치(develop/main) 로의 푸시에 경고합니다 |
| `validate-assets.sh` | PostToolUse (Write/Edit) | 에셋 파일 변경 | `assets/` 내 파일의 네이밍 컨벤션과 JSON 유효성을 확인합니다 |
| `session-start.sh` | SessionStart | 세션 시작 | 스프린트 컨텍스트, 마일스톤, git 활동을 로드하고, 복구를 위해 활성 세션 상태 파일을 감지 및 미리보기 합니다 |
| `detect-gaps.sh` | SessionStart | 세션 시작 | 신규 프로젝트를 감지하고(/start 제안), 코드/프로토타입이 존재할 때 누락된 문서를 감지하여 /reverse-document 또는 /project-stage-detect 를 제안합니다 |
| `pre-compact.sh` | PreCompact | 컨텍스트 압축 | 압축 전에 세션 상태(active.md, 수정된 파일, 작업 중인 디자인 문서)를 대화에 덤프하여 요약 과정에서도 살아남도록 합니다 |
| `post-compact.sh` | PostCompact | 압축 완료 후 | Claude 에게 `active.md` 체크포인트로부터 세션 상태를 복원하도록 상기시킵니다 |
| `notify.sh` | Notification | 알림 이벤트 | PowerShell 을 통해 Windows 토스트 알림을 표시합니다 |
| `session-stop.sh` | Stop | 세션 종료 | 성과를 요약하고 세션 로그를 갱신합니다 |
| `log-agent.sh` | SubagentStart | 에이전트 스폰 | 감사 기록 시작 — 타임스탬프와 함께 서브에이전트 호출을 로깅합니다 |
| `log-agent-stop.sh` | SubagentStop | 에이전트 종료 | 감사 기록 종료 — 서브에이전트 레코드를 완료합니다 |
| `validate-skill-change.sh` | PostToolUse (Write/Edit) | 스킬 파일 변경 | `.claude/skills/` 내 파일이 작성/편집된 후 `/skill-test` 실행을 권고합니다 |

훅 레퍼런스 문서: `.claude/docs/hooks-reference/`
훅 입력 스키마 문서: `.claude/docs/hooks-reference/hook-input-schemas.md`
