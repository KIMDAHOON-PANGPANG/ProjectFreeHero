# UBG (Ultimate Engine CoPilot) 통합 가이드

## UBG란

**UBG / Ultimate Engine CoPilot** (BlueprintsLab, FAB Marketplace)는
**Claude Code**를 비롯한 AI 코딩 어시스턴트를 Unreal Editor 내부에서 직접
실행하는 UE5 플러그인입니다.

- 56개 카테고리에 걸친 1050개 이상의 네이티브 UE5 도구 (UE5 커버리지 약 95%)
- Claude Code, Codex, GitHub Copilot, Gemini CLI 지원
- AI 기반 Blueprint, 텍스처, PBR 머티리얼, 3D 모델, 사운드 생성
- 로컬 LLM 지원 (Ollama, LM Studio)
- Discord: https://discord.gg/w65xMuxEhb

## 왜 우리 셋업에 중요한가

UBG는 **프로젝트 루트를 작업 디렉터리로** 하여 Claude Code를 호출합니다.
즉, UBG는 기존 설정을 자동으로 읽어들입니다:

- `CLAUDE.md` — 마스터 설정
- `.claude/settings.json` — 훅, 권한, 룰
- `.claude/agents/` — 39개 에이전트 정의 전체 (UE5 스페셜리스트 5개 포함)
- `.claude/skills/` — 72개 슬래시 커맨드 (`/design-system`, `/dev-story` 등)
- `.claude/hooks/` — 자동 검증 훅 12개
- `.claude/rules/` — 경로 스코프 코딩 표준 11개

**추가 설정 불필요.** UBG + 우리의 CCGS 기반 에이전트 스튜디오 = UE Editor
내부에서 호출 가능한, 스튜디오급 구조의 Claude Code.

## 권장 워크플로

### 신규 기능 (GDD → 구현)

1. **터미널 (에디터 외부)** — 디자인 단계:
   - `/brainstorm` → `/design-system` → `/create-architecture`
   - `design/`에 디자인 문서, `docs/architecture/`에 ADR 생성

2. **UBG가 활성화된 UE Editor** — 구현 단계:
   - 작업 중인 Blueprint/Level 열기
   - UBG → Claude Code 호출
   - 특정 스토리 파일에 대해 `/dev-story` 실행
   - UBG가 Blueprint 생성 도구를 노출 — Claude가 계획하고 UBG가 BP 생성 실행

3. **다시 터미널** — 리뷰 단계:
   - `/story-done`으로 승인 검증
   - 생성된 C++에 대해 `/code-review`

### 빠른 Blueprint 생성

UBG가 활성화된 에디터 내부에서, 자연스럽게 요청하세요 ("오버랩 시 HP 25 회복하는 BP_HealthPickup 만들어줘").
UBG가 에셋을 생성하고, 우리 `.claude/agents/`에 정의된
`ue-blueprint-specialist` 에이전트가 `technical-preferences.md`의 프로젝트
컨벤션을 적용합니다.

## 훅 상호작용

우리 훅은 모든 도구 호출에서 실행됩니다. UBG에서 트리거된 도구 호출도 동일하게 다음을 발화합니다:

- `validate-commit.sh` — 커밋 메시지 검증 (UBG가 커밋하지 않을 때는 no-op)
- `validate-assets.sh` — `assets/` 또는 `Content/`에 기록되는 파일 검증
- `log-agent.sh` — 서브에이전트 스폰 감사 기록
- `notify.sh` — Windows 토스트 알림

UBG가 순간적으로 수백 개 에셋을 생성하면 로그에 훅 노이즈가 생길 수 있습니다.
정상입니다 — 경로가 매칭되지 않으면 훅은 조기 종료합니다.

## 주의 사항

1. **`.uasset` 파일은 바이너리입니다**. 에이전트가 텍스트 diff를 시도해서는 안 됩니다.
   Blueprint diff 도구에 의존하세요 (Content Browser에서 우클릭 → Asset Actions → Diff).

2. **UBG 자체의 도구 호출**. UBG가 이전에 본 적 없는 권한을 요구할 수 있습니다.
   `settings.json`이 아닌 `.claude/settings.local.json`에 머신별로 추가하세요.

3. **버전 드리프트**. UBG는 FAB을 통해 업데이트됩니다. 새 UBG 버전이 나오면:
   - 트렁크가 아닌 브랜치에서 테스트
   - 도구 API 변경 사항은 릴리스 노트 확인
   - 본 문서의 "최종 검증일"을 갱신

## 참고

- UBG 문서: https://www.gamedevcore.com/ko/docs/bpgenerator-ultimate/
- FAB 리스팅: FAB 마켓플레이스에서 "Ultimate Engine CoPilot" 검색
- UE5.7 엔진 레퍼런스: `docs/engine-reference/unreal/`

---

**최종 검증일:** 2026-04-20
