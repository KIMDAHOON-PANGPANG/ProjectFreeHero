# settings.local.json 템플릿

버전 관리에 커밋하지 **않아야** 할 개인 오버라이드를 위해
`.claude/settings.local.json` 을 생성하세요. `.gitignore` 에 추가합니다.

## settings.local.json 예시

```json
{
  "permissions": {
    "allow": [
      "Bash(git *)",
      "Bash(npm *)",
      "Read",
      "Glob",
      "Grep"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(git push --force *)"
    ]
  }
}
```

## 권한 모드

Claude Code 는 여러 권한 모드를 지원합니다. 게임 개발 권장 사항:

### 개발 중 (기본)
**normal 모드** 사용 — Claude 가 대부분의 커맨드 실행 전에 질문합니다. 프로덕션 코드에 가장 안전합니다.

### 프로토타이핑 중
제한된 스코프로 **auto-accept 모드** 사용 — 일회성 코드에서 더 빠른 이터레이션.
`prototypes/` 디렉터리에서 작업할 때만 사용하세요.

### 코드 리뷰 중
**read-only** 권한 사용 — Claude 는 파일을 읽고 검색할 수 있지만 수정할 수 없습니다.

## 로컬에서 훅 커스터마이징

프로젝트 훅을 오버라이드하지 않고 확장하는 개인 훅을 `settings.local.json` 에 추가할 수 있습니다.
예를 들어 빌드 완료 시 알림을 추가하는 경우:

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'echo Session ended at $(date)'",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```
