# 게임 스튜디오 에이전트 아키텍처 — 빠른 시작 가이드

## 이것은 무엇인가?

본 프로젝트는 Unreal Engine 5.7 게임 개발을 위한 Claude Code 에이전트 아키텍처입니다.
48명의 전문 AI 에이전트를 실제 게임 개발 팀을 반영한 스튜디오 계층 구조로 조직하며,
정의된 책임, 위임 규칙, 그리고 조율 프로토콜을 갖추고 있습니다. UE5.7 전용 엔진
스페셜리스트 에이전트 (Blueprint, UMG/CommonUI, Replication) 를 포함합니다. **본 프로젝트는 BP-only 정책이므로 GAS 는 비활성**입니다.
모든 디자인 에이전트와 템플릿은 검증된 게임 디자인 이론 (MDA Framework,
Self-Determination Theory, Flow State, Bartle Player Types) 에 기반합니다.

## 사용 방법

### 1. 계층 구조 이해하기

에이전트에는 세 개의 티어가 있습니다:

- **Tier 1 (Opus)**: 하이 레벨 결정을 내리는 디렉터
  - `creative-director` — 비전 및 창의적 충돌 해결
  - `technical-director` — 아키텍처 및 기술 결정
  - `producer` — 스케줄링, 조율, 리스크 관리

- **Tier 2 (Sonnet)**: 자신의 도메인을 소유한 부서 리드
  - `game-designer`, `lead-programmer`, `art-director`, `audio-director`,
    `narrative-director`, `qa-lead`, `release-manager`, `localization-lead`

- **Tier 3 (Sonnet/Haiku)**: 도메인 내에서 실행하는 스페셜리스트
  - 디자이너, 프로그래머, 아티스트, 라이터, 테스터, 엔지니어

### 2. 작업에 맞는 에이전트 선택하기

스스로에게 질문하세요: "실제 스튜디오라면 어느 부서가 이 일을 처리할까?"

| 내가 해야 하는 일... | 사용할 에이전트 |
|-------------|---------------|
| 새 메커닉 디자인 | `game-designer` |
| 전투 코드 작성 | `gameplay-programmer` |
| 셰이더 생성 | `technical-artist` |
| 대사 작성 | `writer` |
| 다음 스프린트 계획 | `producer` |
| 코드 품질 리뷰 | `lead-programmer` |
| 테스트 케이스 작성 | `qa-tester` |
| 레벨 디자인 | `level-designer` |
| 성능 문제 해결 | `performance-analyst` |
| CI/CD 셋업 | `devops-engineer` |
| 루트 테이블 디자인 | `economy-designer` |
| 창의적 충돌 해결 | `creative-director` |
| 아키텍처 결정 | `technical-director` |
| 릴리스 관리 | `release-manager` |
| 번역용 문자열 준비 | `localization-lead` |
| 메커닉 아이디어 빠른 테스트 | `prototyper` |
| 보안 이슈 코드 리뷰 | `security-engineer` |
| 접근성 준수 확인 | `accessibility-specialist` |
| Unreal Engine Config / Plugin / Editor 조언 | `unreal-specialist` (본 프로젝트 서브, C++ 금지) |
| ~~GAS 어빌리티/이펙트 디자인~~ | ❌ **본 프로젝트 미사용** → `ue-blueprint-specialist` 로 라우팅 (커스텀 BP 어빌리티 스택) |
| BP 아키텍처·어빌리티·어트리뷰트 (엔진 리드) | `ue-blueprint-specialist` (**본 프로젝트 주력**) |
| UE 복제 구현 | `ue-replication-specialist` |
| UMG/CommonUI 위젯 구축 | `ue-umg-specialist` |
| 라이브 이벤트와 시즌 계획 | `live-ops-designer` |
| 플레이어용 패치 노트 작성 | `community-manager` |
| 새 게임 아이디어 브레인스토밍 | `/brainstorm` 스킬 사용 |

### 3. 일반적인 작업에 슬래시 커맨드 사용하기

| 커맨드 | 용도 |
|---------|-------------|
| `/start` | 첫 온보딩 — 현재 위치를 묻고 적절한 워크플로로 안내 |
| `/help` | 컨텍스트 인식 "다음 무엇을 해야 할까?" — 현재 페이즈와 아티팩트를 읽음 |
| `/project-stage-detect` | 프로젝트 상태 분석, 페이즈 감지, 갭 식별 |
| `/setup-engine` | 엔진 + 버전 구성, 레퍼런스 문서 채움 |
| `/adopt` | 기존 프로젝트에 대한 브라운필드 감사 및 마이그레이션 계획 |
| `/brainstorm` | 가이드 기반 게임 컨셉 아이디에이션 (처음부터) |
| `/map-systems` | 컨셉을 시스템으로 분해, 의존성 맵핑, 시스템별 GDD 가이드 |
| `/design-system` | 단일 게임 시스템에 대한 섹션별 가이드 GDD 저작 |
| `/quick-design` | 작은 변경용 경량 스펙 — 튜닝, 조정, 소소한 추가 |
| `/review-all-gdds` | 크로스 GDD 일관성 및 게임 디자인 이론 리뷰 |
| `/propagate-design-change` | GDD 변경의 영향을 받는 ADR 과 스토리 찾기 |
| `/ux-design` | UX 스펙 저작 (화면/플로우, HUD, 인터랙션 패턴) |
| `/ux-review` | 접근성과 GDD 정합성에 대한 UX 스펙 검증 |
| `/create-architecture` | 게임을 위한 마스터 아키텍처 문서 |
| `/architecture-decision` | ADR 생성 |
| `/architecture-review` | 모든 ADR, 의존성 순서, GDD 추적성 검증 |
| `/create-control-manifest` | 승인된 ADR 에서 플랫한 프로그래머 룰 시트 생성 |
| `/create-epics` | GDD + ADR 을 에픽으로 변환 (아키텍처 모듈당 하나) |
| `/create-stories` | 단일 에픽을 구현 가능한 스토리 파일로 분해 |
| `/dev-story` | 스토리를 읽고 구현 — 올바른 프로그래머 에이전트로 라우팅 |
| `/sprint-plan` | 스프린트 계획 생성 또는 갱신 |
| `/sprint-status` | 빠른 30줄 스프린트 스냅샷 |
| `/story-readiness` | 픽업 전 스토리가 구현 가능한지 검증 |
| `/story-done` | 스토리 완료 리뷰 — 승인 기준 검증 |
| `/estimate` | 구조화된 공수 추정 산출 |
| `/design-review` | 디자인 문서 리뷰 |
| `/code-review` | 품질과 아키텍처에 대한 코드 리뷰 |
| `/balance-check` | 게임 밸런스 데이터 분석 |
| `/asset-audit` | 에셋 준수 감사 |
| `/content-audit` | GDD 명시 콘텐츠 vs 구현된 콘텐츠 — 갭 찾기 |
| `/scope-check` | 계획 대비 스코프 크립 감지 |
| `/perf-profile` | 성능 프로파일링 및 병목 ID |
| `/tech-debt` | 기술 부채 스캔, 추적, 우선순위화 |
| `/gate-check` | 페이즈 준비도 검증 (PASS/CONCERNS/FAIL) |
| `/consistency-check` | 모든 GDD 를 크로스 문서 불일치 (충돌하는 스탯, 이름, 룰) 스캔 |
| `/reverse-document` | 기존 코드에서 디자인/아키텍처 문서 생성 |
| `/milestone-review` | 마일스톤 진행 리뷰 |
| `/retrospective` | 스프린트/마일스톤 회고 실행 |
| `/bug-report` | 구조화된 버그 리포트 생성 |
| `/playtest-report` | 플레이테스트 피드백 생성 또는 분석 |
| `/onboard` | 역할별 온보딩 문서 생성 |
| `/release-checklist` | 릴리스 전 체크리스트 검증 |
| `/launch-checklist` | 완전한 런치 준비도 검증 |
| `/changelog` | git 이력에서 체인지로그 생성 |
| `/patch-notes` | 플레이어용 패치 노트 생성 |
| `/hotfix` | 감사 기록이 있는 긴급 수정 |
| `/prototype` | 일회성 프로토타입 스캐폴드 |
| `/localize` | 로컬라이제이션 스캔, 추출, 검증 |
| `/team-combat` | 전체 전투 팀 파이프라인 오케스트레이션 |
| `/team-narrative` | 전체 내러티브 팀 파이프라인 오케스트레이션 |
| `/team-ui` | 전체 UI 팀 파이프라인 오케스트레이션 |
| `/team-release` | 전체 릴리스 팀 파이프라인 오케스트레이션 |
| `/team-polish` | 전체 폴리시 팀 파이프라인 오케스트레이션 |
| `/team-audio` | 전체 오디오 팀 파이프라인 오케스트레이션 |
| `/team-level` | 전체 레벨 생성 파이프라인 오케스트레이션 |
| `/team-live-ops` | 시즌, 이벤트, 런치 후 콘텐츠를 위한 라이브 운영 팀 오케스트레이션 |
| `/team-qa` | 전체 QA 팀 사이클 — 테스트 계획, 테스트 케이스, 스모크 체크, 사인오프 |
| `/qa-plan` | 스프린트 또는 기능에 대한 QA 테스트 계획 생성 |
| `/bug-triage` | 열린 버그 재우선순위화, 스프린트에 할당, 체계적 트렌드 표면화 |
| `/smoke-check` | QA 핸드오프 전 크리티컬 패스 스모크 테스트 게이트 실행 (PASS/FAIL) |
| `/soak-test` | 장시간 플레이 세션용 소크 테스트 프로토콜 생성 |
| `/regression-suite` | 커버리지를 GDD 크리티컬 패스에 매핑, 갭 플래그, 리그레션 스위트 유지보수 |
| `/test-setup` | 프로젝트 엔진용 테스트 프레임워크 + CI 파이프라인 스캐폴드 (한 번 실행) |
| `/test-helpers` | 엔진별 테스트 헬퍼 라이브러리 및 팩토리 함수 생성 |
| `/test-flakiness` | CI 이력에서 플래키 테스트 감지, 격리 또는 수정 플래그 |
| `/test-evidence-review` | 테스트 파일 및 수동 증거의 품질 리뷰 — ADEQUATE/INCOMPLETE/MISSING |
| `/skill-test` | 준수 및 정확성을 위한 스킬 파일 검증 (정적 / 스펙 / 감사) |

### 4. 신규 문서에 템플릿 사용하기

템플릿은 `.claude/docs/templates/` 에 있습니다:

- `game-design-document.md` — 새 메커닉과 시스템용
- `architecture-decision-record.md` — 기술 결정용
- `architecture-traceability.md` — GDD 요구사항을 ADR 과 스토리 ID 로 매핑
- `risk-register-entry.md` — 새 리스크용
- `narrative-character-sheet.md` — 새 캐릭터용
- `test-plan.md` — 기능 테스트 계획용
- `sprint-plan.md` — 스프린트 계획용
- `milestone-definition.md` — 새 마일스톤용
- `level-design-document.md` — 새 레벨용
- `game-pillars.md` — 핵심 디자인 필러용
- `art-bible.md` — 비주얼 스타일 레퍼런스용
- `technical-design-document.md` — 시스템별 기술 디자인용
- `post-mortem.md` — 프로젝트/마일스톤 회고용
- `sound-bible.md` — 오디오 스타일 레퍼런스용
- `release-checklist-template.md` — 플랫폼 릴리스 체크리스트용
- `changelog-template.md` — 플레이어용 패치 노트용
- `release-notes.md` — 플레이어용 릴리스 노트용
- `incident-response.md` — 라이브 인시던트 대응 플레이북용
- `game-concept.md` — 초기 게임 컨셉용 (MDA, SDT, Flow, Bartle)
- `pitch-document.md` — 스테이크홀더에게 게임을 피칭하기 위함
- `economy-model.md` — 가상 이코노미 디자인용 (sink/faucet 모델)
- `faction-design.md` — 팩션 정체성, 로어, 게임플레이 역할용
- `systems-index.md` — 시스템 분해 및 의존성 맵핑용
- `project-stage-report.md` — 프로젝트 페이즈 감지 출력용
- `design-doc-from-implementation.md` — 기존 코드를 GDD 로 리버스 문서화
- `architecture-doc-from-code.md` — 코드를 아키텍처 문서로 리버스 문서화
- `concept-doc-from-prototype.md` — 프로토타입을 컨셉 문서로 리버스 문서화
- `ux-spec.md` — 화면별 UX 스펙용 (레이아웃 존, 상태, 이벤트)
- `hud-design.md` — 전체 게임 HUD 철학, 존, 엘리먼트 스펙용
- `accessibility-requirements.md` — 프로젝트 전체 접근성 티어 및 기능 매트릭스용
- `interaction-pattern-library.md` — 표준 UI 컨트롤 및 게임 특화 패턴용
- `player-journey.md` — 6단계 감정 아크 및 시간 척도별 리텐션 훅용
- `difficulty-curve.md` — 난이도 축, 온보딩 램프, 크로스 시스템 인터랙션용
- `test-evidence.md` — 수동 테스트 증거 기록용 템플릿 (스크린샷, 워크스루 노트)

또한 `.claude/docs/templates/collaborative-protocols/` 에 있음 (에이전트가 사용, 일반적으로 직접 편집하지 않음):

- `design-agent-protocol.md` — 디자인 에이전트용 질문-선택지-초안-승인 사이클
- `implementation-agent-protocol.md` — 프로그래밍 에이전트용 스토리 픽업부터 /story-done 사이클
- `leadership-agent-protocol.md` — 디렉터 티어 에이전트용 크로스 부서 위임 및 에스컬레이션

### 5. 조율 규칙 따르기

1. 작업은 계층 아래로 흐름: 디렉터 -> 리드 -> 스페셜리스트
2. 충돌은 계층 위로 에스컬레이션
3. 크로스 부서 작업은 `producer` 가 조율
4. 에이전트는 위임 없이 자신의 도메인 밖 파일을 수정하지 않음
5. 모든 결정은 문서화됨

## 신규 프로젝트 첫 단계

**어디서 시작해야 할지 모르겠나요?** `/start` 를 실행하세요. 현재 위치를 묻고
적절한 워크플로로 안내합니다. 게임, 엔진, 경험 수준에 대한 가정을 하지 않습니다.

이미 무엇이 필요한지 안다면, 해당 경로로 바로 이동하세요:

### 경로 A: "무엇을 만들지 전혀 모른다"

1. **`/start` 실행** (또는 `/brainstorm open`) — 가이드 기반 창의적 탐색:
   무엇에 흥미를 느끼는지, 어떤 게임을 플레이했는지, 제약 조건
   - 3개의 컨셉 생성, 하나를 선택 도움, 코어 루프와 필러 정의
   - 게임 컨셉 문서 생성 및 엔진 추천
2. **엔진 셋업** — `/setup-engine` 실행 (브레인스토밍 추천 사용)
   - CLAUDE.md 구성, 지식 갭 감지, 레퍼런스 문서 채움
   - 네이밍 컨벤션, 성능 예산, 엔진별 기본값을 포함한
     `.claude/docs/technical-preferences.md` 생성
   - 엔진 버전이 LLM 학습 데이터보다 최신이라면, 웹에서 현재 문서를 가져와
     에이전트가 올바른 API 를 제안하도록 함
3. **컨셉 검증** — `/design-review design/gdd/game-concept.md` 실행
4. **시스템으로 분해** — `/map-systems` 를 실행하여 모든 시스템과 의존성 매핑
5. **각 시스템 디자인** — 의존성 순서로 GDD 를 작성하기 위해
   `/design-system [system-name]` 실행 (또는 `/map-systems next`)
6. **코어 루프 테스트** — `/prototype [core-mechanic]` 실행
7. **플레이테스트** — 가설 검증을 위해 `/playtest-report` 실행
8. **첫 스프린트 계획** — `/sprint-plan new` 실행
9. 구축 시작

### 경로 B: "무엇을 만들고 싶은지 안다"

이미 게임 컨셉과 엔진 선택이 있다면:

1. **엔진 셋업** — `/setup-engine unreal 5.7` 실행 —
   기술 선호 사항도 생성
2. **게임 필러 작성** — `creative-director` 에게 위임
3. **시스템으로 분해** — 시스템과 의존성을 열거하기 위해 `/map-systems` 실행
4. **각 시스템 디자인** — 의존성 순서의 GDD 를 위해 `/design-system [system-name]` 실행
5. **초기 ADR 생성** — `/architecture-decision` 실행
6. `production/milestones/` 에 **첫 마일스톤 생성**
7. **첫 스프린트 계획** — `/sprint-plan new` 실행
8. 구축 시작

### 경로 C: "게임은 알지만 엔진은 모른다"

본 프로젝트는 Unreal Engine 5.7 로 이미 설정되어 있습니다.
경로 B 의 2단계부터 진행하세요.

### 경로 D: "기존 프로젝트가 있다"

이미 디자인 문서, 프로토타입, 또는 코드가 있다면:

1. **`/start` 실행** (또는 `/project-stage-detect`) — 존재하는 것을 분석,
   갭 식별, 다음 단계 추천
2. 기존 GDD, ADR, 또는 스토리가 있다면 **`/adopt` 실행** — 내부 포맷
   준수를 감사하고 기존 작업을 덮어쓰지 않고 갭을 메우는 번호가 매겨진
   마이그레이션 계획 구축
3. **필요시 엔진 구성** — 아직 구성되지 않았다면 `/setup-engine` 실행
4. **페이즈 준비도 검증** — 현재 위치를 보기 위해 `/gate-check` 실행
5. **다음 스프린트 계획** — `/sprint-plan new` 실행

## 파일 구조 레퍼런스

```
CLAUDE.md                          — 마스터 설정 (이것을 먼저 읽으세요, ~60 줄)
.claude/
  settings.json                    — Claude Code 훅 및 프로젝트 설정
  agents/                          — 48 에이전트 정의 (YAML frontmatter)
  skills/                          — 68 슬래시 커맨드 정의 (YAML frontmatter)
  hooks/                           — settings.json 에 연결된 12 훅 스크립트 (.sh)
  rules/                           — 11 경로별 룰 파일
  docs/
    quick-start.md                 — 이 파일
    technical-preferences.md       — 프로젝트별 표준 (/setup-engine 이 채움)
    coding-standards.md            — 코딩 및 디자인 문서 표준
    coordination-rules.md          — 에이전트 조율 룰
    context-management.md          — 컨텍스트 예산 및 압축 지시사항
    directory-structure.md         — 프로젝트 디렉터리 레이아웃
    workflow-catalog.yaml          — 7페이즈 파이프라인 정의 (/help 가 읽음)
    setup-requirements.md          — 시스템 선행 조건 (Git Bash, jq, Python)
    settings-local-template.md     — 개인 settings.local.json 가이드
    templates/                     — 37 문서 템플릿
```
