# 셋업 요구사항

본 템플릿은 전체 기능을 사용하기 위해 몇 가지 도구 설치가 필요합니다.
모든 훅은 도구가 없어도 무해하게 실패합니다 — 아무것도 깨지지 않지만
검증 기능을 잃게 됩니다.

## 필수

| 도구 | 용도 | 설치 |
| ---- | ---- | ---- |
| **Git** | 버전 관리, 브랜치 관리 | [git-scm.com](https://git-scm.com/) |
| **Claude Code** | AI 에이전트 CLI | `npm install -g @anthropic-ai/claude-code` |

## 권장

| 도구 | 사용처 | 용도 | 설치 |
| ---- | ---- | ---- | ---- |
| **jq** | 훅 (8개 중 4개) | commit/push/asset/agent 훅의 JSON 파싱 | 아래 참조 |
| **Python 3** | 훅 (8개 중 2개) | 데이터 파일 JSON 검증 | [python.org](https://www.python.org/) |
| **Bash** | 모든 훅 | 셸 스크립트 실행 | Git for Windows 에 포함 |

### jq 설치

**Windows** (다음 중 하나):
```
winget install jqlang.jq
choco install jq
scoop install jq
```

**macOS**:
```
brew install jq
```

**Linux**:
```
sudo apt install jq     # Debian/Ubuntu
sudo dnf install jq     # Fedora
sudo pacman -S jq       # Arch
```

## 플랫폼 노트

### Windows
- Git for Windows 에는 `settings.json` 의 모든 훅이 사용하는 `bash` 커맨드를 제공하는
  **Git Bash** 가 포함되어 있습니다
- Git Bash 가 PATH 에 있는지 확인하세요 (Git 인스톨러로 설치 시 기본값)
- 훅은 `bash .claude/hooks/[name].sh` 를 사용합니다 — Claude Code 가 `bash.exe` 를 찾을 수 있는
  셸을 통해 커맨드를 호출하므로 Windows 에서 작동합니다

### macOS / Linux
- Bash 는 네이티브로 사용 가능합니다
- 전체 훅 지원을 위해 패키지 매니저로 `jq` 를 설치하세요

## 셋업 확인

다음 커맨드를 실행하여 사전 요구사항을 확인합니다:

```bash
git --version          # git 버전이 표시되어야 함
bash --version         # bash 버전이 표시되어야 함
jq --version           # jq 버전이 표시되어야 함 (선택)
python3 --version      # python 버전이 표시되어야 함 (선택)
```

## 선택 도구가 없을 때

| 누락 도구 | 영향 |
| ---- | ---- |
| **jq** | 커밋 검증, 푸시 보호, 에셋 검증, 에이전트 감사 훅이 조용히 체크를 건너뜁니다. 커밋과 푸시는 계속 작동합니다. |
| **Python 3** | 커밋 및 에셋 훅의 JSON 데이터 파일 검증이 건너뜁니다. 유효하지 않은 JSON 이 경고 없이 커밋될 수 있습니다. |
| **둘 다** | 모든 훅이 오류 없이 실행(exit 0)되지만 검증은 제공하지 않습니다. 안전망 없이 비행하는 상태입니다. |

## 권장 IDE

Claude Code 는 모든 에디터와 작동하지만, 템플릿은 다음에 최적화되어 있습니다:
- **VS Code** (Claude Code 확장)
- **Cursor** (Claude Code 호환)
- 터미널 기반 Claude Code CLI
