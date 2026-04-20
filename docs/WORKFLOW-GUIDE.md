# Claude Code Game Studios — 완전한 워크플로 가이드

> **에이전트 아키텍처를 사용해 0에서 출시된 게임까지 가는 방법.**
>
> 이 가이드는 48명 에이전트 시스템, 68개 슬래시 커맨드, 12개 자동화 훅을
> 사용해 게임 개발의 모든 페이즈를 안내합니다. Claude Code 가 설치되어
> 있고 프로젝트 루트에서 작업 중이라고 가정합니다.
>
> 파이프라인은 7개 페이즈를 가집니다. 각 페이즈는 진행 전 반드시 통과해야
> 하는 공식 게이트 (`/gate-check`) 를 가집니다. 권위 있는 페이즈 시퀀스는
> `.claude/docs/workflow-catalog.yaml` 에 정의되며 `/help` 에 의해 읽힙니다.
>
> **엔진 노트**: 이 프로젝트는 Unreal Engine 5.7 로 고정되어 있으며 **BP-only 정책**입니다.
> 활성 엔진 스페셜리스트: `ue-blueprint-specialist` (**주력**),
> `ue-umg-specialist`, `ue-replication-specialist`, `unreal-specialist` (Config/Plugin/Editor 서브).
> `ue-gas-specialist` 는 GAS 가 C++ 를 요구하므로 **본 프로젝트 비활성**입니다.

---

## 목차

1. [빠른 시작](#빠른-시작)
2. [Phase 1: Concept](#phase-1-concept)
3. [Phase 2: Systems Design](#phase-2-systems-design)
4. [Phase 3: Technical Setup](#phase-3-technical-setup)
5. [Phase 4: Pre-Production](#phase-4-pre-production)
6. [Phase 5: Production](#phase-5-production)
7. [Phase 6: Polish](#phase-6-polish)
8. [Phase 7: Release](#phase-7-release)
9. [크로스 컷팅 관심사](#크로스-컷팅-관심사)
10. [부록 A: 에이전트 빠른 레퍼런스](#부록-a-에이전트-빠른-레퍼런스)
11. [부록 B: 슬래시 커맨드 빠른 레퍼런스](#부록-b-슬래시-커맨드-빠른-레퍼런스)
12. [부록 C: 일반적 워크플로](#부록-c-일반적-워크플로)

---

## 빠른 시작

### 필요한 것

시작 전 다음을 확인하세요:

- **Claude Code** 설치 및 작동
- **Git** 과 Git Bash (Windows) 또는 표준 터미널 (Mac/Linux)
- **jq** (선택이지만 권장 — 훅이 없으면 `grep` 으로 폴백)
- **Python 3** (선택 — 일부 훅이 JSON 검증에 사용)

### 1단계: 클론 및 열기

```bash
git clone <repo-url> my-game
cd my-game
```

### 2단계: /start 실행

첫 세션이라면:

```
/start
```

이 가이드 온보딩은 현재 위치를 묻고 적절한 페이즈로 라우팅합니다:

- **Path A** — 아직 아이디어 없음: `/brainstorm` 으로 라우팅
- **Path B** — 모호한 아이디어: 시드와 함께 `/brainstorm` 으로 라우팅
- **Path C** — 명확한 컨셉: `/setup-engine` 과 `/map-systems` 로 라우팅
- **Path D1** — 기존 프로젝트, 아티팩트 적음: 정상 플로우
- **Path D2** — 기존 프로젝트, GDD/ADR 존재: `/project-stage-detect` 후
  브라운필드 마이그레이션을 위해 `/adopt` 실행

### 3단계: 훅이 작동하는지 확인

새 Claude Code 세션을 시작하세요. `session-start.sh` 훅의 출력을 보게 됩니다:

```
=== Claude Code Game Studios — Session Context ===
Branch: main
Recent commits:
  abc1234 Initial commit
===================================
```

이를 보면 훅이 작동합니다. 그렇지 않으면 `.claude/settings.json` 에서
훅 경로가 OS 에 맞는지 확인하세요.

### 4단계: 언제든 도움 요청

어떤 시점에서든 실행:

```
/help
```

`production/stage.txt` 에서 현재 페이즈를 읽고, 어떤 아티팩트가 존재하는지
확인하고, 다음에 무엇을 할지 정확히 알려줍니다. REQUIRED (필수) 다음 단계와
OPTIONAL (선택) 기회를 구분합니다.

### 5단계: 디렉터리 구조 생성

디렉터리는 필요에 따라 생성됩니다. 시스템은 이 레이아웃을 예상합니다
(UE5 프로젝트에 맞게 조정됨):

```
CLAUDE.md               # 마스터 설정
.claude/                # 에이전트, 스킬, 훅, 룰, 문서
ProjectFreeHero.uproject  # Unreal 프로젝트 디스크립터
Content/                # UE5 Blueprints, 메시, 텍스처, 에셋 (바이너리)
Config/                 # UE5 INI 설정
Source/                 # C++ 소스 (네이티브 코드 추가 시 생성됨)
Plugins/                # Marketplace / 로컬 플러그인
design/                 # 디자인 문서
  gdd/                  # Game design documents
  narrative/            # 스토리, 로어, 대사
  levels/               # 레벨 디자인 문서
  balance/              # 밸런스 스프레드시트 및 데이터
  ux/                   # UX 스펙
docs/                   # 기술 문서
  architecture/         # Architecture Decision Records
  engine-reference/     # UE5.7 고정 API 스냅샷
  postmortems/          # 포스트모템
tests/                  # 테스트 스위트
prototypes/             # 일회성 프로토타입
production/             # 스프린트 계획, 마일스톤, 릴리스
  sprints/
  milestones/
  releases/
  epics/                # 에픽 및 스토리 파일 (/create-epics + /create-stories 에서)
  playtests/            # 플레이테스트 리포트
  session-state/        # 일시적 세션 상태 (gitignored)
  session-logs/         # 세션 감사 기록 (gitignored)
```

> **팁**: 첫날에 이 모든 것이 필요하지는 않습니다. 필요한 페이즈에 도달하면
> 디렉터리를 생성하세요. 중요한 것은 그들을 생성할 때 이 구조를 따르는 것입니다.
> 왜냐하면 **룰 시스템**이 파일 경로 기반으로 표준을 강제하기 때문입니다.
> `Source/ProjectFreeHero/Gameplay/` 의 코드는 gameplay 룰을 받고,
> `Source/ProjectFreeHero/AI/` 의 코드는 AI 룰을 받는 식입니다.

---

## Phase 1: Concept

### 이 페이즈에서 일어나는 일

"아이디어 없음" 또는 "모호한 아이디어" 에서 정의된 필러와 플레이어 여정이
있는 구조화된 게임 컨셉 문서로 이동합니다. 여기서 당신이 **무엇**을 만들고
**왜**를 파악합니다.

### Phase 1 파이프라인

```
/brainstorm  -->  game-concept.md  -->  /design-review  -->  /setup-engine
     |                                        |                    |
     v                                        v                    v
  10개 컨셉      필러, MDA, 코어 루프,     컨셉 문서           엔진 고정
  MDA 분석       USP 를 포함한              검증              technical-preferences.md
  플레이어 동기  컨셉 문서
                                                                   |
                                                                   v
                                                             /map-systems
                                                                   |
                                                                   v
                                                            systems-index.md
                                                            (모든 시스템, 의존성,
                                                             우선순위 티어)
```

### Step 1.1: /brainstorm 으로 브레인스토밍

시작점입니다. brainstorm 스킬 실행:

```
/brainstorm
```

또는 장르 힌트와 함께:

```
/brainstorm roguelike deckbuilder
```

**어떤 일이 일어나는가**: brainstorm 스킬은 전문 스튜디오 기법을 사용해
협업 6페이즈 아이디에이션 프로세스를 안내합니다:

1. 관심사, 주제, 제약 조건을 묻습니다
2. MDA (Mechanics, Dynamics, Aesthetics) 분석과 함께 10개 컨셉 시드 생성
3. 심층 분석을 위해 2-3개 선호작을 선택
4. 플레이어 동기 매핑 및 오디언스 타겟팅 수행
5. 승리 컨셉 선택
6. `design/gdd/game-concept.md` 로 정식화

컨셉 문서는 다음을 포함합니다:

- 엘리베이터 피치 (한 문장)
- 코어 판타지 (플레이어가 자신을 상상하는 모습)
- MDA 분해
- 타겟 오디언스 (Bartle 유형, 인구통계)
- 코어 루프 다이어그램
- 고유 판매 제안
- 비교 가능한 타이틀 및 차별화
- 게임 필러 (3-5개 협상 불가 디자인 가치)
- 안티 필러 (게임이 의도적으로 피하는 것)

### Step 1.2: 컨셉 리뷰 (선택이지만 권장)

```
/design-review design/gdd/game-concept.md
```

진행 전 구조와 완전성을 검증합니다.

### Step 1.3: 엔진 확인

```
/setup-engine unreal 5.7
```

**/setup-engine 이 하는 일**:

- 네이밍 컨벤션, 성능 예산, 엔진별 기본값과 함께
  `.claude/docs/technical-preferences.md` 채움
- 지식 갭 감지 (엔진 버전이 LLM 학습 데이터보다 새로움) 및
  `docs/engine-reference/` 교차 참조 조언
- `docs/engine-reference/unreal/` 에 버전 고정 레퍼런스 문서 생성

**이것이 중요한 이유**: 엔진이 설정되면 시스템은 어떤 엔진 스페셜리스트
에이전트를 사용할지 압니다. 본 프로젝트는 UE5.7 + **BP-only 정책**으로 고정되어 있으므로
`ue-blueprint-specialist` (주력), `ue-umg-specialist`, `ue-replication-specialist`,
`unreal-specialist` (Config/Plugin/Editor 서브) 가 당신의 전문가입니다.
`ue-gas-specialist` 는 본 프로젝트 비활성입니다 (GAS 가 C++ 요구).

### Step 1.4: 컨셉을 시스템으로 분해

개별 GDD 를 작성하기 전에, 게임이 필요로 하는 모든 시스템을 열거하세요:

```
/map-systems
```

이는 `design/gdd/systems-index.md` 를 생성합니다 — 다음과 같은 마스터 추적 문서:

- 게임이 필요로 하는 모든 시스템 목록 (전투, 이동, UI 등)
- 시스템 간 의존성 매핑
- 우선순위 티어 할당 (MVP, Vertical Slice, Alpha, Full Vision)
- 디자인 순서 결정 (Foundation > Core > Feature > Presentation > Polish)

이 단계는 Phase 2 로 진행하기 전 **필수**입니다. 155개 게임 포스트모템의
연구는 시스템 열거를 건너뛰면 프로덕션에서 5-10배 더 비용이 든다는 것을 확인합니다.

### Phase 1 게이트

```
/gate-check concept
```

**통과 요구 사항**:

- `technical-preferences.md` 에 엔진 구성됨
- 필러가 있는 `design/gdd/game-concept.md` 존재
- 의존성 순서가 있는 `design/gdd/systems-index.md` 존재

**판정**: PASS / CONCERNS / FAIL. CONCERNS 는 인정된 리스크와 함께 통과 가능.
FAIL 은 진행을 차단.

---

## Phase 2: Systems Design

### 이 페이즈에서 일어나는 일

게임이 작동하는 방식을 정의하는 모든 디자인 문서를 생성합니다. 아직
코딩 없음 — 순수 디자인. 시스템 인덱스에서 식별된 각 시스템은 자체 GDD
를 받고, 섹션별로 저작되며, 개별적으로 리뷰된 후, 모든 GDD 가 크로스 체크됩니다.

### Phase 2 파이프라인

```
/map-systems next  -->  /design-system  -->  /design-review
       |                     |                     |
       v                     v                     v
  systems-index 에서    섹션별               8개 필수 섹션 검증
  다음 시스템 선택      GDD 저작             APPROVED/NEEDS REVISION
                       (증분 쓰기)
       |
       |  (각 MVP 시스템에 대해 반복)
       v
/review-all-gdds
       |
       v
  크로스 GDD 일관성 + 디자인 이론 리뷰
  PASS / CONCERNS / FAIL
```

### Step 2.1: 시스템 GDD 저작

가이드 워크플로를 사용해 의존성 순서로 각 시스템을 디자인:

```
/map-systems next
```

이는 디자인되지 않은 최고 우선순위 시스템을 선택하고 `/design-system` 에
핸드오프하며, 이는 GDD 를 섹션별로 생성하도록 안내합니다.

특정 시스템을 직접 디자인할 수도 있습니다:

```
/design-system combat-system
```

**/design-system 이 하는 일**:

1. 게임 컨셉, 시스템 인덱스, 그리고 상류/하류 GDD 를 읽음
2. 기술 타당성 사전 체크 실행 (도메인 매핑 + 타당성 브리프)
3. 8개 필수 GDD 섹션 각각을 한 번에 하나씩 안내
4. 각 섹션은 다음을 따름: Context > Questions > Options > Decision > Draft > Approval > Write
5. 각 섹션은 승인 직후 파일에 기록됨 (크래시에서 생존)
6. 기존 승인된 GDD 와의 충돌 플래그
7. 카테고리별로 스페셜리스트 에이전트에 라우팅 (수학은 systems-designer,
   이코노미는 economy-designer, 스토리 시스템은 narrative-director)

**8개 필수 GDD 섹션**:

| # | 섹션 | 여기에 들어가는 것 |
|---|---------|---------------|
| 1 | **Overview** | 시스템의 한 문단 요약 |
| 2 | **Player Fantasy** | 이 시스템을 사용할 때 플레이어가 상상/느끼는 것 |
| 3 | **Detailed Rules** | 명확한 메커니컬 룰 |
| 4 | **Formulas** | 모든 계산, 변수 정의 및 범위 |
| 5 | **Edge Cases** | 이상한 상황에서 무엇이 일어나는가? 명시적으로 해결. |
| 6 | **Dependencies** | 이것이 연결되는 다른 시스템 (양방향) |
| 7 | **Tuning Knobs** | 디자이너가 안전하게 변경할 수 있는 값과 안전 범위 |
| 8 | **Acceptance Criteria** | 이것이 작동함을 어떻게 테스트하는가? 구체적, 측정 가능. |

추가로 **Game Feel** 섹션: 느낌 레퍼런스, 입력 반응성 (ms/프레임),
애니메이션 느낌 타겟 (startup/active/recovery), 임팩트 순간, 무게 프로필.

### Step 2.2: 각 GDD 리뷰

다음 시스템이 시작되기 전, 현재의 것을 검증:

```
/design-review design/gdd/combat-system.md
```

8개 섹션 모두의 완전성, 공식 명확성, 엣지 케이스 해결, 양방향 의존성,
테스트 가능한 승인 기준을 체크.

**판정**: APPROVED / NEEDS REVISION / MAJOR REVISION. APPROVED 된 GDD 만 진행.

### Step 2.3: 전체 GDD 없는 작은 변경

전체 GDD 를 정당화하지 않는 튜닝 변경, 작은 추가, 조정에 대해:

```
/quick-design "측면 공격에 10% 데미지 보너스 추가"
```

이는 전체 8섹션 GDD 대신 `design/quick-specs/` 에 경량 스펙을 생성합니다.
튜닝, 숫자 변경, 작은 추가에 사용.

### Step 2.4: 크로스 GDD 일관성 리뷰

모든 MVP 시스템 GDD 가 개별적으로 승인된 후:

```
/review-all-gdds
```

이는 모든 GDD 를 동시에 읽고 두 개의 분석 페이즈를 실행:

**Phase 1 — 크로스 GDD 일관성**:
- 의존성 양방향성 (A가 B를 참조하면, B도 A를 참조하는가?)
- 시스템 간 룰 모순
- 이름이 변경되거나 제거된 시스템에 대한 오래된 참조
- 소유권 충돌 (두 시스템이 같은 책임을 주장)
- 공식 범위 호환성 (시스템 A의 출력이 시스템 B의 입력에 맞는가?)
- 승인 기준 크로스 체크

**Phase 2 — 디자인 이론 (Game Design Holism)**:
- 경쟁하는 프로그레션 루프 (두 시스템이 같은 보상 공간을 두고 싸우는가?)
- 인지 부하 (한 번에 4개 이상의 활성 시스템?)
- 지배적 전략 (다른 모든 것을 무관하게 만드는 하나의 접근)
- 이코노믹 루프 분석 (소스와 싱크가 균형?)
- 시스템 전반에 걸친 난이도 커브 일관성
- 필러 정합 및 안티 필러 위반
- 플레이어 판타지 일관성

**출력**: 판정이 있는 `design/gdd/gdd-cross-review-[date].md`.

### Step 2.5: 내러티브 디자인 (적용시)

게임에 스토리, 로어, 또는 대사가 있다면, 이때 구축합니다:

1. **월드빌딩** — `world-builder` 를 사용해 팩션, 역사, 지리, 세계의
   룰을 정의
2. **스토리 구조** — `narrative-director` 를 사용해 스토리 아크, 캐릭터
   아크, 내러티브 비트를 디자인
3. **캐릭터 시트** — `narrative-character-sheet.md` 템플릿 사용

### Phase 2 게이트

```
/gate-check systems-design
```

**통과 요구 사항**:

- `systems-index.md` 의 모든 MVP 시스템이 `Status: Approved`
- 각 MVP 시스템이 리뷰된 GDD 를 가짐
- 크로스 GDD 리뷰 리포트 존재 (`design/gdd/gdd-cross-review-*.md`)
  판정이 PASS 또는 CONCERNS (FAIL 아님)

---

## Phase 3: Technical Setup

### 이 페이즈에서 일어나는 일

핵심 기술 결정을 내리고, Architecture Decision Records (ADR) 로 문서화하고,
리뷰를 통해 검증하고, 프로그래머에게 플랫하고 실행 가능한 룰을 주는
control manifest 를 산출합니다. UX 기반도 확립합니다.

### Phase 3 파이프라인

```
/create-architecture  -->  /architecture-decision (x N)  -->  /architecture-review
        |                          |                                   |
        v                          v                                   v
  모든 시스템을 다루는     결정별 ADR                        완전성, 의존성 순서,
  마스터 아키텍처          docs/architecture/                엔진 호환성 검증
  문서                     adr-*.md
                                                                      |
                                                                      v
                                                         /create-control-manifest
                                                                      |
                                                                      v
                                                         플랫 프로그래머 룰
                                                         docs/architecture/
                                                         control-manifest.md
        또한 이 페이즈에서:
        -----------------
        /ux-design  -->  /ux-review
        접근성 요구사항 문서
        인터랙션 패턴 라이브러리
```

### Step 3.1: 마스터 아키텍처 문서

```
/create-architecture
```

시스템 경계, 데이터 흐름, 통합 지점을 다루는 `docs/architecture/architecture.md`
에 전반적 아키텍처 문서를 생성.

### Step 3.2: Architecture Decision Records (ADR)

각 중요한 기술 결정에 대해:

```
/architecture-decision "NPC AI 에 대한 State Machine vs Behavior Tree"
```

**어떤 일이 일어나는가**: 스킬은 다음과 함께 ADR 생성을 안내:
- Context 및 결정 드라이버
- pros/cons 및 엔진 호환성을 포함한 모든 옵션
- 근거와 함께 선택된 옵션
- Consequences (긍정적, 부정적, 리스크)
- Dependencies (Depends On, Enables, Blocks, Ordering Note)
- 커버되는 GDD 요구사항 (TR-ID 로 링크)

ADR 은 생명주기를 거침: Proposed > Accepted > Superseded/Deprecated.

**게이트 체크 전 최소 3개의 Foundation 레이어 ADR 필요**.

**기존 ADR 리트로핏**: 브라운필드 프로젝트에서 이미 ADR 이 있다면:

```
/architecture-decision retrofit docs/architecture/adr-005.md
```

이는 어떤 템플릿 섹션이 누락되었는지 감지하고 그것만 추가하며, 기존
콘텐츠를 덮어쓰지 않습니다.

### Step 3.3: 아키텍처 리뷰

```
/architecture-review
```

모든 ADR 을 함께 검증:
- ADR 의존성의 토폴로지컬 정렬 (사이클 감지)
- 엔진 호환성 검증
- GDD Revision Flag (ADR 선택에 따라 업데이트가 필요한 GDD 섹션 플래그)
- TR-ID 레지스트리 유지보수 (`docs/architecture/tr-registry.yaml`)

### Step 3.4: Control Manifest

```
/create-control-manifest
```

모든 Accepted ADR 을 가져와 플랫 프로그래머 룰 시트를 산출:

```
docs/architecture/control-manifest.md
```

코드 레이어별로 조직된 Required 패턴, Forbidden 패턴, Guardrails 를 포함.
나중에 생성되는 스토리는 매니페스트 버전 날짜를 내장하여 stalenss 를
감지할 수 있게 함.

### Step 3.5: 접근성 요구사항

템플릿을 사용해 `design/accessibility-requirements.md` 생성. 티어
(Basic / Standard / Comprehensive / Exemplary) 에 커밋하고 4축 기능
매트릭스 (시각, 운동, 인지, 청각) 를 채움.

이 문서는 Phase 3 에서 필수입니다 — Phase 4 에서 작성되는 UX 스펙이
이 티어를 참조하기 때문입니다. 이는 UX 산출물이 아닌 디자인 전제 조건입니다.

### Phase 3 게이트

```
/gate-check technical-setup
```

**통과 요구 사항**:

- `docs/architecture/architecture.md` 존재
- 최소 3개의 ADR 존재 및 Accepted
- 아키텍처 리뷰 리포트 존재
- `docs/architecture/control-manifest.md` 존재
- `design/accessibility-requirements.md` 존재

---

## Phase 4: Pre-Production

### 이 페이즈에서 일어나는 일

주요 화면에 대한 UX 스펙을 생성하고, 리스크 있는 메커닉을 프로토타입화하고,
디자인 문서를 구현 가능한 스토리로 전환하고, 첫 스프린트를 계획하고,
코어 루프가 재미있음을 증명하는 Vertical Slice 를 구축합니다.

### Phase 4 파이프라인

```
/ux-design  -->  /prototype  -->  /create-epics  -->  /create-stories  -->  /sprint-plan
    |                |                  |                   |                       |
    v                v                  v                   v                       v
  UX 스펙         일회성         production/         production/             우선순위화된
  design/ux/      프로토타입     epics/*/EPIC.md     epics/*/story-*.md      스토리를 가진
                  prototypes/    에픽 파일            스토리 파일              첫 스프린트
                                 (모듈당 하나)        (행동당 하나)           production/sprints/
                                                                                    sprint-*.md
    |                                                      |
    v                                                      v
 /ux-review                                          /story-readiness
 (에픽 전                                             (픽업 전 각 스토리
  스펙 검증)                                           검증)
                                                           |
                                                           v
                                                       /dev-story
                                                     (스토리 구현,
                                                      올바른 에이전트로 라우팅)
                         |
                         v
                   Vertical Slice
                   (플레이 가능한 빌드,
                    3개의 가이드 없는 세션)
```

### Step 4.1: 주요 화면에 대한 UX 스펙

에픽을 작성하기 전, 스토리 저자가 어떤 화면이 존재하고 어떤 플레이어
인터랙션을 지원해야 하는지 알 수 있도록 UX 스펙을 생성.

**UX 스펙**:

```
/ux-design main-menu
/ux-design core-gameplay-hud
```

세 가지 모드: screen/flow, HUD, interaction patterns. 출력은 `design/ux/`
로 감. 각 스펙은 다음을 포함: 플레이어 필요, 레이아웃 존, 상태, 인터랙션 맵,
데이터 요구사항, 발생 이벤트, 접근성, 로컬라이제이션.

접근성 및 입력 커버리지 체크를 구동하기 위해 (Phase 3 에서 작성된)
`accessibility-requirements.md` 와 `technical-preferences.md` 의 입력
방식 설정을 읽음 — 화면별로 다시 지정할 필요 없음.

> **팁**: `/design-system` 은 UI 요구사항이 있는 모든 시스템에 대해
> 📌 UX Flag 를 발행합니다. 어떤 화면이 스펙을 필요로 하는지에 대한
> 체크리스트로 해당 플래그를 사용하세요.

**인터랙션 패턴 라이브러리**:

```
/ux-design interaction-patterns
```

`design/ux/interaction-patterns.md` 생성 — 16개 표준 컨트롤과 게임 특화
패턴 (인벤토리 슬롯, 어빌리티 아이콘, HUD 바, 대사 상자 등) 을 애니메이션
및 사운드 표준과 함께.

**UX 리뷰**:

```
/ux-review all
```

GDD 정합 및 접근성 티어 준수를 위해 UX 스펙을 검증. APPROVED / NEEDS
REVISION / MAJOR REVISION NEEDED 판정 산출.

### Step 4.2: 리스크 있는 메커닉 프로토타입

모든 것이 프로토타입을 필요로 하지 않습니다. 프로토타입 시점:
- 메커닉이 새롭고 재미있을지 확신할 수 없음
- 기술 접근이 위험하고 실현 가능할지 확신할 수 없음
- 두 디자인 옵션이 모두 viable 해 보이고 차이를 느껴볼 필요가 있음

```
/prototype "모멘텀이 있는 grappling hook 이동"
```

**어떤 일이 일어나는가**: 스킬은 당신과 협업하여 가설, 성공 기준, 최소
스코프를 정의합니다. `prototyper` 에이전트는 격리된 git worktree
(`isolation: worktree`) 에서 작업하여 일회성 코드가 `Source/` 를 오염시키지 않도록 합니다.

**핵심 룰**: `prototype-code` 룰은 의도적으로 코딩 표준을 완화합니다 —
하드코딩된 값 OK, 테스트 불필요 — 하지만 가설과 발견을 포함한 README 는 필수입니다.

### Step 4.3: 디자인 아티팩트로부터 에픽과 스토리 생성

```
/create-epics layer: foundation
/create-stories [epic-slug]   # 각 에픽에 대해 반복
/create-epics layer: core
/create-stories [epic-slug]   # 각 core 에픽에 대해 반복
```

`/create-epics` 는 GDD, ADR, 아키텍처를 읽어 에픽 스코프를 정의 —
아키텍처 모듈당 에픽 하나. 그런 다음 `/create-stories` 는 각 에픽을
`production/epics/[slug]/` 의 구현 가능한 스토리 파일로 분해. 각 스토리는
내장:
- GDD 요구사항 참조 (TR-ID, 인용된 텍스트 아님 — 신선하게 유지)
- ADR 참조 (Accepted ADR 에서만; Proposed ADR 은 `Status: Blocked` 유발)
- Control manifest 버전 날짜 (staleness 감지용)
- 엔진별 구현 노트
- GDD 에서의 승인 기준

스토리가 존재하면 `/dev-story [story-path]` 실행으로 하나를 구현 —
올바른 프로그래머 에이전트로 자동 라우팅.

### Step 4.4: 픽업 전 스토리 검증

```
/story-readiness production/stories/combat-damage-calc.md
```

체크: 디자인 완전성, 아키텍처 커버리지, 스코프 명확성, Definition of Done.
판정: READY / NEEDS WORK / BLOCKED.

### Step 4.5: 공수 추정

```
/estimate production/stories/combat-damage-calc.md
```

리스크 평가와 함께 공수 추정 제공.

### Step 4.6: 첫 스프린트 계획

```
/sprint-plan new
```

**어떤 일이 일어나는가**: `producer` 에이전트가 스프린트 계획에 협업:
- 스프린트 목표와 가용 시간을 물음
- 목표를 Must Have / Should Have / Nice to Have 태스크로 분해
- 리스크와 블로커 식별
- `production/sprints/sprint-01.md` 생성
- `production/sprint-status.yaml` (머신 읽기 가능 스토리 추적) 채움

### Step 4.7: Vertical Slice (하드 게이트)

Production 으로 진행하기 전, Vertical Slice 를 구축하고 플레이테스트해야 합니다:

- 처음부터 끝까지 플레이 가능한 하나의 완전한 엔드 투 엔드 코어 루프
- 대표적 품질 (모든 것이 placeholder 가 아님)
- 최소 3개 세션에서 가이드 없이 플레이됨
- 플레이테스트 리포트 작성됨 (`/playtest-report`)

이는 **하드 게이트** — 인간이 가이드 없이 빌드를 플레이하지 않았다면
`/gate-check` 는 자동 FAIL.

### Phase 4 게이트

```
/gate-check pre-production
```

**통과 요구 사항**:

- `design/ux/` 에 최소 1개의 리뷰된 UX 스펙
- UX 리뷰 완료 (APPROVED 또는 문서화된 리스크가 있는 NEEDS REVISION)
- README 가 있는 최소 1개 프로토타입
- `production/stories/` 에 스토리 파일 존재
- 최소 1개 스프린트 계획 존재
- 최소 1개 플레이테스트 리포트 존재 (3+ 세션에서 플레이된 Vertical Slice)

---

## Phase 5: Production

### 이 페이즈에서 일어나는 일

이것은 코어 프로덕션 루프입니다. 스프린트 (일반적으로 1-2주) 단위로
작업하며, 스토리별로 기능을 구현하고, 진행 상황을 추적하고, 구조화된
완료 리뷰를 통해 스토리를 닫습니다. 이 페이즈는 게임이 콘텐츠 완성될
때까지 반복됩니다.

### Phase 5 파이프라인 (스프린트당)

```
/sprint-plan new  -->  /story-readiness  -->  구현  -->  /story-done
       |                     |                    |                |
       v                     v                    v                v
  스프린트 생성         스토리 검증           코드 작성        8페이즈 리뷰:
  sprint-status.yaml    READY 판정          테스트 통과      기준 검증,
  채워짐                                                      일탈 체크,
                                                              스토리 상태 갱신
       |
       |  (스프린트 완료까지 스토리별 반복)
       v
  /sprint-status  (언제든 빠른 30줄 스냅샷)
  /scope-check    (스코프가 커지면)
  /retrospective  (스프린트 끝에)
```

### Step 5.1: 스토리 생명주기

프로덕션 페이즈는 **스토리 생명주기** 를 중심으로:

```
/story-readiness  -->  구현  -->  /story-done  -->  다음 스토리
```

**1. 스토리 준비도**: 스토리를 픽업하기 전, 검증:

```
/story-readiness production/stories/combat-damage-calc.md
```

디자인 완전성, 아키텍처 커버리지, ADR 상태 (ADR 이 여전히 Proposed 이면
블록), control manifest 버전 (오래되었으면 경고), 스코프 명확성을 체크.
판정: READY / NEEDS WORK / BLOCKED.

**2. 구현**: 적절한 에이전트와 작업:

- 게임플레이 시스템에는 `gameplay-programmer`
- 코어 엔진 작업에는 `engine-programmer`
- AI 동작에는 `ai-programmer`
- 멀티플레이어에는 `network-programmer`
- UI 코드에는 `ui-programmer`
- 개발 도구에는 `tools-programmer`
- UE5 특화: `ue-blueprint-specialist` (주력, BP-only 정책으로 GAS 대체 스택 포함),
  `ue-umg-specialist`, `ue-replication-specialist`, `unreal-specialist` (Config/Plugin/Editor 서브).
  ~~`ue-gas-specialist`~~ 는 본 프로젝트 비활성.

모든 에이전트는 협업 프로토콜을 따릅니다: 디자인 문서를 읽고, 명확화
질문을 하고, 아키텍처 옵션을 제시하고, 승인을 받고, 그런 다음 구현.

**3. 스토리 완료**: 스토리가 완료되면:

```
/story-done production/stories/combat-damage-calc.md
```

이는 8페이즈 완료 리뷰를 실행:
1. 스토리 파일 찾기 및 읽기
2. 참조된 GDD, ADR, control manifest 로드
3. 승인 기준 검증 (자동 체크 가능, 수동, 연기됨)
4. GDD/ADR 일탈 체크 (BLOCKING / ADVISORY / OUT OF SCOPE)
5. 코드 리뷰 프롬프트
6. 완료 리포트 생성 (COMPLETE / COMPLETE WITH NOTES / BLOCKED)
7. 스토리 `Status: Complete` 와 완료 노트 갱신
8. 다음 준비된 스토리 표면화

리뷰 중 발견된 기술 부채는 `docs/tech-debt-register.md` 에 로깅됩니다.

### Step 5.2: 스프린트 추적

언제든 진행 상황 체크:

```
/sprint-status
```

`production/sprint-status.yaml` 에서 읽는 빠른 30줄 스냅샷.

스코프가 커지면:

```
/scope-check production/sprints/sprint-03.md
```

이는 현재 스코프를 원래 계획과 비교하고 스코프 증가를 플래그하며,
컷을 권장합니다.

### Step 5.3: 콘텐츠 추적

```
/content-audit
```

GDD 명시 콘텐츠와 구현된 것을 비교. 콘텐츠 갭을 조기에 포착.

### Step 5.4: 디자인 변경 전파

스토리가 생성된 후 GDD 가 변경되면:

```
/propagate-design-change design/gdd/combat-system.md
```

GDD 를 git-diff 하고, 영향받은 ADR 을 찾고, 영향 리포트를 생성하고,
Superseded/갱신/유지 결정을 안내합니다.

### Step 5.5: 다중 시스템 기능 (팀 오케스트레이션)

여러 도메인에 걸친 기능에는 팀 스킬을 사용:

```
/team-combat "HoT 와 cleanse 가 있는 힐링 어빌리티"
/team-narrative "Act 2 스토리 콘텐츠"
/team-ui "인벤토리 화면 재설계"
/team-level "숲 던전 레벨"
/team-audio "전투 오디오 패스"
```

각 팀 스킬은 6페이즈 협업 워크플로를 조율:
1. **Design** — game-designer 가 질문, 옵션 제시
2. **Architecture** — lead-programmer 가 코드 구조 제안
3. **Parallel Implementation** — 스페셜리스트가 동시에 작업
4. **Integration** — gameplay-programmer 가 모든 것을 엮음
5. **Validation** — qa-tester 가 승인 기준에 대해 실행
6. **Report** — 코디네이터가 상태 요약

오케스트레이션은 자동화되지만, **결정 지점은 당신에게 남아 있습니다**.

### Step 5.6: 스프린트 리뷰와 다음 스프린트

스프린트 끝에:

```
/retrospective
```

계획 vs 완료, 속도, 블로커, 실행 가능한 개선을 분석.

그런 다음 다음 스프린트 계획:

```
/sprint-plan new
```

### Step 5.7: 마일스톤 리뷰

마일스톤 체크포인트에서:

```
/milestone-review "alpha"
```

기능 완성도, 품질 메트릭, 리스크 평가, go/no-go 권장 사항 산출.

### Phase 5 게이트

```
/gate-check production
```

**통과 요구 사항**:

- 모든 MVP 스토리 완료
- 플레이테스트: 신규 플레이어, 미드 게임, 난이도 커브를 다루는 3개 세션
- 재미 가설 검증됨
- 플레이테스트 데이터에 혼란 루프 없음

---

## Phase 6: Polish

### 이 페이즈에서 일어나는 일

게임이 기능 완성됨. 이제 좋게 만듭니다. 이 페이즈는 성능, 밸런스,
접근성, 오디오, 비주얼 폴리시, 플레이테스팅에 집중합니다.

### Phase 6 파이프라인

```
/perf-profile  -->  /balance-check  -->  /asset-audit  -->  /playtest-report (x3)
       |                  |                    |                    |
       v                  v                    v                    v
  CPU/GPU 프로파일,    망가진 프로그레션     네이밍, 포맷,       커버: 신규 플레이어,
  메모리, 병목         을 위해 공식과        크기 검증            미드 게임, 난이도
  최적화               데이터 분석                                커브

  /tech-debt  -->  /team-polish
       |                |
       v                v
  부채 항목 추적     조율된 패스:
  및 우선순위화      성능 + 아트 +
                     오디오 + UX + QA
```

### Step 6.1: 성능 프로파일링

```
/perf-profile
```

구조화된 성능 프로파일링 안내:
- 타겟 확립 (FPS, 메모리, 플랫폼)
- 영향력에 따라 순위 매겨진 병목 식별
- 코드 위치 및 예상 이득과 함께 실행 가능한 최적화 태스크 생성

### Step 6.2: 밸런스 분석

```
/balance-check Content/Data/combat_damage.uasset
```

통계적 이상치, 망가진 프로그레션 커브, 퇴행 전략, 이코노미 불균형에
대해 밸런스 데이터 분석.

### Step 6.3: 에셋 감사

```
/asset-audit
```

모든 에셋 걸친 네이밍 컨벤션, 파일 포맷 표준, 크기 예산 검증.

### Step 6.4: 플레이테스팅 (필수: 3개 세션)

```
/playtest-report
```

구조화된 플레이테스트 리포트 생성. 3개 세션이 필요하며, 다음을 커버:
- 신규 플레이어 경험
- 미드 게임 시스템
- 난이도 커브

### Step 6.5: 기술 부채 평가

```
/tech-debt
```

TODO/FIXME/HACK 주석, 코드 중복, 지나치게 복잡한 함수, 누락된 테스트,
오래된 의존성을 스캔. 각 항목은 분류되고 우선순위화됨.

### Step 6.6: 조율된 폴리시 패스

```
/team-polish "전투 시스템"
```

4명의 스페셜리스트를 병렬 조율:
1. 성능 최적화 (performance-analyst)
2. 비주얼 폴리시 (technical-artist)
3. 오디오 폴리시 (sound-designer)
4. 느낌/주스 (gameplay-programmer + technical-artist)

우선순위를 설정하면, 팀이 각 단계에서 당신의 승인과 함께 실행.

### Step 6.7: 로컬라이제이션 및 접근성

```
/localize Source/
```

하드코딩된 문자열, 번역을 깨는 concatenation, 확장을 고려하지 않는
텍스트, 누락된 로케일 파일을 스캔.

접근성은 Phase 3 의 접근성 요구사항 문서에 커밋된 티어에 대비해
감사됩니다.

### Phase 6 게이트

```
/gate-check polish
```

**통과 요구 사항**:

- 최소 3개의 플레이테스트 리포트 존재
- 조율된 폴리시 패스 완료 (`/team-polish`)
- 블로킹 성능 이슈 없음
- 접근성 티어 요구사항 충족

---

## Phase 7: Release

### 이 페이즈에서 일어나는 일

게임이 폴리시되고, 테스트되고, 준비됨. 이제 출시합니다.

### Phase 7 파이프라인

```
/release-checklist  -->  /launch-checklist  -->  /team-release
        |                       |                      |
        v                       v                      v
  코드, 콘텐츠,          전체 크로스 부서          조율:
  스토어, 법적 걸친      검증 (부서별             빌드, QA 사인오프,
  릴리스 전 검증         Go/No-Go)               배포, 런치

                    또한: /changelog, /patch-notes, /hotfix
```

### Step 7.1: 릴리스 체크리스트

```
/release-checklist v1.0.0
```

다음을 다루는 포괄적 릴리스 전 체크리스트 생성:
- 빌드 검증 (모든 플랫폼 컴파일 및 실행)
- 인증 요구사항 (플랫폼별)
- 스토어 메타데이터 (설명, 스크린샷, 트레일러)
- 법적 준수 (EULA, 프라이버시 정책, 등급)
- 저장 게임 호환성
- 분석 검증

### Step 7.2: 런치 준비도 (전체 검증)

```
/launch-checklist
```

완전한 크로스 부서 검증:

| 부서 | 체크되는 것 |
|-----------|---------------|
| **엔지니어링** | 빌드 안정성, 크래시 비율, 메모리 누수, 로드 시간 |
| **디자인** | 기능 완성도, 튜토리얼 플로우, 난이도 커브 |
| **아트** | 에셋 품질, 누락 텍스처, LOD 레벨 |
| **오디오** | 누락 사운드, 믹싱 레벨, 공간 오디오 |
| **QA** | 심각도별 열린 버그 수, 회귀 스위트 통과율 |
| **내러티브** | 대사 완성도, 로어 일관성, 오탈자 |
| **로컬라이제이션** | 모든 문자열 번역, 잘림 없음, 로케일 테스트 |
| **접근성** | 준수 체크리스트, 지원 기능 테스트 |
| **스토어** | 메타데이터 완성, 스크린샷 승인, 가격 설정 |
| **마케팅** | 프레스 키트 준비, 런치 트레일러, 소셜 미디어 스케줄 |
| **커뮤니티** | 패치 노트 초안, FAQ 준비, 지원 채널 준비 |
| **인프라** | 서버 스케일, CDN 구성, 모니터링 활성 |
| **법적** | EULA 확정, 프라이버시 정책, COPPA/GDPR 준수 |

각 항목은 **Go / No-Go** 상태를 받음. 출시하려면 모두 Go 여야 함.

### Step 7.3: 플레이어용 콘텐츠 생성

```
/patch-notes v1.0.0
```

git 이력과 스프린트 데이터에서 플레이어 친화적 패치 노트 생성.
개발자 언어를 플레이어 언어로 번역.

```
/changelog v1.0.0
```

내부 체인지로그 생성 (더 기술적, 팀용).

### Step 7.4: 릴리스 조율

```
/team-release
```

다음을 통해 release-manager, QA, DevOps 조율:
1. 릴리스 전 검증
2. 빌드 관리
3. 최종 QA 사인오프
4. 배포 준비
5. Go/No-Go 결정

### Step 7.5: 출시

`validate-push` 훅은 `main` 또는 `develop` 으로 푸시할 때 경고합니다.
이는 의도적 — 릴리스 푸시는 신중해야 합니다:

```bash
git tag v1.0.0
git push origin main --tags
```

### Step 7.6: 런치 후

**Hotfix 워크플로** 중요한 프로덕션 버그용:

```
/hotfix "인벤토리가 99개 항목을 초과할 때 플레이어가 세이브 데이터를 잃음"
```

전체 감사 기록과 함께 정상 스프린트 프로세스 우회:
1. hotfix 브랜치 생성
2. 수정 구현
3. 개발 브랜치로 백포트 보장
4. 인시던트 문서화

**포스트모템** 런치 안정화 후:

```
.claude/docs/templates/post-mortem.md 의 템플릿을 사용해
포스트모템을 생성하도록 Claude 에 요청
```

---

## 크로스 컷팅 관심사

이 주제들은 모든 페이즈에 걸쳐 적용됩니다.

### 디렉터 리뷰 모드

디렉터 게이트는 주요 워크플로 단계에서 당신의 작업을 리뷰하는 스페셜리스트
에이전트입니다. 기본적으로 모든 체크포인트에서 실행됩니다. 얼마나 많은
리뷰를 받을지 제어할 수 있습니다.

**`/start` 중 리뷰 강도를 한 번 설정하세요.** `production/review-mode.txt` 에 저장됨.

| 모드 | 실행되는 것 | 적합한 대상 |
|------|-----------|----------|
| `full` | 매 단계마다 모든 디렉터 게이트 | 신규 프로젝트, 시스템 학습 중 |
| `lean` | 페이즈 전환에서만 디렉터 (`/gate-check`) | 경험 있는 개발자 |
| `solo` | 디렉터 리뷰 없음 | 게임 잼, 프로토타입, 최대 속도 |

**전역 설정을 변경하지 않고 단일 실행 오버라이드**:

```
/brainstorm space horror --review full
/architecture-decision --review solo
```

`--review` 플래그는 모든 게이트 사용 스킬에서 작동합니다. 언제든
`production/review-mode.txt` 를 직접 편집하거나 `/start` 를 다시 실행하여
전역 모드를 변경할 수 있습니다.

전체 게이트 정의와 체크 패턴: `.claude/docs/director-gates.md`

---

### 협업 프로토콜

이 시스템은 **사용자 주도 협업적** 이며, 자율적이지 않습니다.

**패턴**: Question > Options > Decision > Draft > Approval

모든 에이전트 상호작용은 이 패턴을 따름:
1. 에이전트가 명확화 질문을 함
2. 에이전트가 트레이드오프와 추론과 함께 2-4개 옵션 제시
3. 당신이 결정
4. 에이전트가 당신의 결정에 따라 초안 작성
5. 당신이 리뷰하고 다듬음
6. 에이전트가 쓰기 전 "[파일경로] 에 기록해도 될까요?" 를 물음

전체 프로토콜과 예시는 `docs/COLLABORATIVE-DESIGN-PRINCIPLE.md` 참조.

### AskUserQuestion 도구

에이전트는 구조화된 옵션 제시에 `AskUserQuestion` 도구를 사용합니다.
패턴은 Explain then Capture: 먼저 대화 텍스트에 전체 분석, 그런 다음
결정을 위한 깔끔한 UI 피커. 디자인 선택, 아키텍처 결정, 전략적 질문에
사용. 열린 탐색 질문이나 단순 yes/no 확인에는 사용하지 마세요.

### 에이전트 조율 (3-티어 계층)

```
Tier 1 (Directors):    creative-director, technical-director, producer
                                          |
Tier 2 (Leads):        game-designer, lead-programmer, art-director,
                       audio-director, narrative-director, qa-lead,
                       release-manager, localization-lead
                                          |
Tier 3 (Specialists):  gameplay-programmer, engine-programmer,
                       ai-programmer, network-programmer, ui-programmer,
                       tools-programmer, systems-designer, level-designer,
                       economy-designer, world-builder, writer,
                       technical-artist, sound-designer, ux-designer,
                       qa-tester, performance-analyst, devops-engineer,
                       analytics-engineer, accessibility-specialist,
                       live-ops-designer, prototyper, security-engineer,
                       community-manager,
                       unreal-specialist (서브: Config/Plugin/Editor),
                       ue-blueprint-specialist (주력, GAS 대체 BP 스택 포함),
                       ue-umg-specialist, ue-replication-specialist
                       [ue-gas-specialist: 본 프로젝트 비활성 — BP-only 정책]
```

**조율 룰**:
- 수직 위임: Directors > Leads > Specialists. 복잡한 결정에 티어를 건너뛰지 마세요.
- 수평 협의: 같은 티어의 에이전트는 서로 협의 가능하지만 자신의 도메인
  밖에서 구속력 있는 결정을 내릴 수 없습니다.
- 충돌 해결: 디자인 충돌은 `creative-director`. 기술 충돌은 `technical-director`.
  스코프 충돌은 `producer`.
- 일방적 크로스 도메인 변경 없음.

### 자동화 훅 (안전망)

시스템에는 자동으로 실행되는 12개 훅이 있습니다:

| 훅 | 트리거 | 하는 일 |
|------|---------|-------------|
| `session-start.sh` | 세션 시작 | 브랜치, 최근 커밋 표시, 복구용 active.md 감지 |
| `detect-gaps.sh` | 세션 시작 | 신규 프로젝트 (엔진 없음, 컨셉 없음) 감지 및 `/start` 제안 |
| `pre-compact.sh` | 압축 전 | 자동 복구용 세션 상태를 대화로 덤프 |
| `post-compact.sh` | 압축 후 | `active.md` 에서 세션 상태 복원을 Claude 에 상기 |
| `notify.sh` | 알림 이벤트 | PowerShell 경유 Windows 토스트 알림 표시 |
| `validate-commit.sh` | 커밋 전 | 디자인 문서 참조, 유효한 JSON, 하드코딩 값 없음 체크 |
| `validate-push.sh` | 푸시 전 | main/develop 으로 푸시 시 경고 |
| `validate-assets.sh` | 커밋 전 | 에셋 네이밍 및 크기 체크 |
| `validate-skill-change.sh` | 스킬 파일 작성됨 | `.claude/skills/` 변경 후 `/skill-test` 실행 권고 |
| `log-agent.sh` | 에이전트 시작 | 감사 기록용 에이전트 호출 로깅 |
| `log-agent-stop.sh` | 에이전트 종료 | 에이전트 감사 기록 완료 (시작 + 종료) |
| `session-stop.sh` | 세션 종료 | 최종 세션 로깅 |

### 컨텍스트 회복력

**세션 상태 파일**: `production/session-state/active.md` 는 살아있는
체크포인트입니다. 각 중요한 마일스톤 후에 갱신하세요. 모든 중단 후
(압축, 크래시, `/clear`), 먼저 이 파일을 읽으세요.

**증분 쓰기**: 다중 섹션 문서를 생성할 때 승인 직후 각 섹션을 파일에
씁니다. 이는 완료된 섹션이 크래시와 컨텍스트 압축을 견뎌낸다는 의미입니다.
작성된 섹션에 대한 이전 논의는 안전하게 압축될 수 있습니다.

**자동 복구**: `session-start.sh` 훅이 `active.md` 를 자동으로 감지하고
미리보기. `pre-compact.sh` 훅은 압축 전 상태를 대화로 덤프합니다.

**스프린트 상태 추적**: `production/sprint-status.yaml` 은 머신 읽기 가능
스토리 추적기. `/sprint-plan` (init) 과 `/story-done` (상태 갱신) 에 의해
작성됨. `/sprint-status`, `/help`, `/story-done` (다음 스토리) 에 의해 읽힘.
취약한 마크다운 스캐닝 제거.

### 브라운필드 채택

이미 일부 아티팩트가 있는 기존 프로젝트용:

```
/adopt
```

또는 타겟화:

```
/adopt gdds
/adopt adrs
/adopt stories
/adopt infra
```

이는 기존 아티팩트를 **포맷** (존재가 아닌) 에 대해 감사하고, 갭을
BLOCKING/HIGH/MEDIUM/LOW 로 분류하고, 순서가 있는 마이그레이션 계획을
구축하고, `docs/adoption-plan-[date].md` 를 작성합니다. 핵심 원칙:
MIGRATION not REPLACEMENT — 기존 작업을 절대 재생성하지 않고 갭만 채움.

개별 스킬도 retrofit 모드를 지원:

```
/design-system retrofit design/gdd/combat-system.md
/architecture-decision retrofit docs/architecture/adr-005.md
```

이들은 어떤 섹션이 존재하고 어떤 섹션이 누락되었는지 감지하고 갭만 채웁니다.

### 게이트 시스템

페이즈 게이트는 공식 체크포인트입니다. 전환 이름과 함께 `/gate-check` 실행:

```
/gate-check concept              # Concept -> Systems Design
/gate-check systems-design       # Systems Design -> Technical Setup
/gate-check technical-setup      # Technical Setup -> Pre-Production
/gate-check pre-production       # Pre-Production -> Production
/gate-check production           # Production -> Polish
/gate-check polish               # Polish -> Release
```

**판정**:
- **PASS** — 모든 요구사항 충족, 다음 페이즈로 진행
- **CONCERNS** — 인정된 리스크와 함께 요구사항 충족, 통과 가능
- **FAIL** — 요구사항 미충족, 특정 치료와 함께 진행 차단

게이트가 통과할 때, `production/stage.txt` 가 갱신됨 (그때만), 이는
스테이터스 라인과 `/help` 동작을 제어.

### 리버스 문서화

디자인 문서 없이 존재하는 코드용 (브라운필드 채택 후 일반적):

```
/reverse-document Source/ProjectFreeHero/Gameplay/Combat/
```

기존 코드를 읽고 그것으로부터 GDD 포맷 디자인 문서를 생성.

---

## 부록 A: 에이전트 빠른 레퍼런스

### "X 를 해야 하는데 — 어느 에이전트를 사용하지?"

| 해야 할 일... | 에이전트 | 티어 |
|-------------|-------|------|
| 게임 아이디어 떠올리기 | `/brainstorm` 스킬 | — |
| 게임 메커닉 디자인 | `game-designer` | 2 |
| 특정 공식/숫자 디자인 | `systems-designer` | 3 |
| 게임 레벨 디자인 | `level-designer` | 3 |
| 루트 테이블 / 이코노미 디자인 | `economy-designer` | 3 |
| 세계 로어 구축 | `world-builder` | 3 |
| 대사 작성 | `writer` | 3 |
| 스토리 계획 | `narrative-director` | 2 |
| 스프린트 계획 | `producer` | 1 |
| 창의적 결정 내리기 | `creative-director` | 1 |
| 기술 결정 내리기 | `technical-director` | 1 |
| 게임플레이 코드 구현 | `gameplay-programmer` | 3 |
| 코어 엔진 시스템 구현 | `engine-programmer` | 3 |
| AI 동작 구현 | `ai-programmer` | 3 |
| 멀티플레이어 구현 | `network-programmer` | 3 |
| UI 구현 | `ui-programmer` | 3 |
| 개발 도구 구축 | `tools-programmer` | 3 |
| 코드 아키텍처 리뷰 | `lead-programmer` | 2 |
| 셰이더 / VFX 생성 | `technical-artist` | 3 |
| 비주얼 스타일 정의 | `art-director` | 2 |
| 오디오 스타일 정의 | `audio-director` | 2 |
| 사운드 이펙트 디자인 | `sound-designer` | 3 |
| UX 플로우 디자인 | `ux-designer` | 3 |
| 테스트 케이스 작성 | `qa-tester` | 3 |
| 테스트 전략 계획 | `qa-lead` | 2 |
| 성능 프로파일 | `performance-analyst` | 3 |
| CI/CD 셋업 | `devops-engineer` | 3 |
| 분석 디자인 | `analytics-engineer` | 3 |
| 접근성 체크 | `accessibility-specialist` | 3 |
| 라이브 운영 계획 | `live-ops-designer` | 3 |
| 릴리스 관리 | `release-manager` | 2 |
| 로컬라이제이션 관리 | `localization-lead` | 2 |
| 빠르게 프로토타입 | `prototyper` | 3 |
| 보안 감사 | `security-engineer` | 3 |
| 플레이어와 소통 | `community-manager` | 3 |
| Unreal Config / Plugin / Editor (서브) | `unreal-specialist` | 3 |
| ~~Unreal GAS~~ | ❌ 본 프로젝트 비활성 (BP-only) → `ue-blueprint-specialist` | 3 |
| Unreal Blueprints (**주력** — 엔진 리드, GAS 대체 BP 스택 포함) | `ue-blueprint-specialist` | 3 |
| Unreal 복제 (BP-only) | `ue-replication-specialist` | 3 |
| Unreal UMG/CommonUI | `ue-umg-specialist` | 3 |

### 에이전트 계층

```
                    creative-director / technical-director / producer
                                         |
          ---------------------------------------------------------------
          |            |           |           |          |        |       |
    game-designer  lead-prog  art-dir  audio-dir  narr-dir  qa-lead  release-mgr
          |            |           |           |          |        |        |
     specialists  programmers  tech-art  snd-design  writer   qa-tester  devops
     (systems,    (gameplay,             (sound)     (world-  (perf,     (analytics,
      economy,     engine,                           builder)  access.)   security)
      level)       ai, net,
                   ui, tools)
```

**에스컬레이션 룰**: 두 에이전트가 의견이 다르면, 위로 가세요. 디자인 충돌은
`creative-director`. 기술 충돌은 `technical-director`. 스코프 충돌은
`producer`.

---

## 부록 B: 슬래시 커맨드 빠른 레퍼런스

### 카테고리별 전체 68 커맨드

#### 온보딩 및 내비게이션 (5)

| 커맨드 | 용도 | 페이즈 |
|---------|---------|-------|
| `/start` | 가이드 온보딩, 올바른 워크플로로 라우팅 | 모두 (첫 세션) |
| `/help` | 컨텍스트 인식 "다음에 무엇을 해야 할까?" | 모두 |
| `/project-stage-detect` | 현재 페이즈 결정을 위한 전체 프로젝트 감사 | 모두 |
| `/setup-engine` | 엔진 구성, 버전 고정, 선호 설정 | 1 |
| `/adopt` | 브라운필드 감사 및 마이그레이션 계획 | 모두 (기존 프로젝트) |

#### 게임 디자인 (6)

| 커맨드 | 용도 | 페이즈 |
|---------|---------|-------|
| `/brainstorm` | MDA 분석과 함께 협업 아이디에이션 | 1 |
| `/map-systems` | 컨셉을 시스템 인덱스로 분해 | 1-2 |
| `/design-system` | 가이드 섹션별 GDD 저작 | 2 |
| `/quick-design` | 작은 변경용 경량 스펙 | 2+ |
| `/review-all-gdds` | 크로스 GDD 일관성 및 디자인 이론 리뷰 | 2 |
| `/propagate-design-change` | GDD 변경에 영향받는 ADR/스토리 찾기 | 5 |

#### UX 및 인터페이스 (2)

| 커맨드 | 용도 | 페이즈 |
|---------|---------|-------|
| `/ux-design` | UX 스펙 저작 (화면/플로우, HUD, 패턴) | 4 |
| `/ux-review` | 접근성 및 GDD 정합을 위한 UX 스펙 검증 | 4 |

#### 아키텍처 (4)

| 커맨드 | 용도 | 페이즈 |
|---------|---------|-------|
| `/create-architecture` | 마스터 아키텍처 문서 | 3 |
| `/architecture-decision` | ADR 생성 또는 리트로핏 | 3 |
| `/architecture-review` | 모든 ADR, 의존성 순서 검증 | 3 |
| `/create-control-manifest` | Accepted ADR 에서 플랫 프로그래머 룰 | 3 |

#### 스토리 및 스프린트 (8)

| 커맨드 | 용도 | 페이즈 |
|---------|---------|-------|
| `/create-epics` | GDD + ADR 을 에픽으로 변환 (모듈당 하나) | 4 |
| `/create-stories` | 단일 에픽을 스토리 파일로 분해 | 4 |
| `/dev-story` | 스토리 구현 — 올바른 프로그래머 에이전트로 라우팅 | 5 |
| `/sprint-plan` | 스프린트 계획 생성 또는 관리 | 4-5 |
| `/sprint-status` | 빠른 30줄 스프린트 스냅샷 | 5 |
| `/story-readiness` | 스토리가 구현 준비됨 검증 | 4-5 |
| `/story-done` | 8페이즈 스토리 완료 리뷰 | 5 |
| `/estimate` | 리스크 평가와 함께 공수 추정 | 4-5 |

#### 리뷰 및 분석 (10)

| 커맨드 | 용도 | 페이즈 |
|---------|---------|-------|
| `/design-review` | 8섹션 표준에 대해 GDD 검증 | 1-2 |
| `/code-review` | 아키텍처 코드 리뷰 | 5+ |
| `/balance-check` | 게임 밸런스 공식 분석 | 5-6 |
| `/asset-audit` | 에셋 네이밍, 포맷, 크기 검증 | 6 |
| `/content-audit` | GDD 명시 콘텐츠 vs 구현됨 | 5 |
| `/scope-check` | 스코프 크립 감지 | 5 |
| `/perf-profile` | 성능 프로파일링 워크플로 | 6 |
| `/tech-debt` | 기술 부채 스캔 및 우선순위화 | 6 |
| `/gate-check` | PASS/CONCERNS/FAIL 과 함께 공식 페이즈 게이트 | 모든 전환 |
| `/reverse-document` | 기존 코드에서 디자인 문서 생성 | 모두 |

#### QA 및 테스팅 (9)

| 커맨드 | 용도 | 페이즈 |
|---------|---------|-------|
| `/qa-plan` | 스프린트 또는 기능에 대한 QA 테스트 계획 생성 | 5 |
| `/smoke-check` | QA 핸드오프 전 크리티컬 패스 스모크 테스트 게이트 | 5-6 |
| `/soak-test` | 장시간 플레이 세션용 소크 테스트 프로토콜 | 6 |
| `/regression-suite` | 테스트 커버리지 매핑, 회귀 테스트 없는 수정 버그 식별 | 5-6 |
| `/test-setup` | 테스트 프레임워크 및 CI/CD 파이프라인 스캐폴드 | 4 |
| `/test-helpers` | 엔진별 테스트 헬퍼 라이브러리 생성 | 4-5 |
| `/test-evidence-review` | 테스트 파일 및 수동 증거의 품질 리뷰 | 5 |
| `/test-flakiness` | CI 로그에서 비결정적 테스트 감지 | 5-6 |
| `/skill-test` | 구조 및 동작 정확성을 위한 스킬 파일 검증 | 모두 |

#### 프로덕션 관리 (6)

| 커맨드 | 용도 | 페이즈 |
|---------|---------|-------|
| `/milestone-review` | 마일스톤 진행 및 go/no-go | 5 |
| `/retrospective` | 스프린트 회고 분석 | 5 |
| `/bug-report` | 구조화된 버그 리포트 생성 | 5+ |
| `/bug-triage` | 우선순위, 심각도, 오너를 위해 열린 버그 재평가 | 5+ |
| `/playtest-report` | 구조화된 플레이테스트 세션 리포트 | 4-6 |
| `/onboard` | 새 팀 멤버 온보딩 | 모두 |

#### 릴리스 (5)

| 커맨드 | 용도 | 페이즈 |
|---------|---------|-------|
| `/release-checklist` | 릴리스 전 검증 | 7 |
| `/launch-checklist` | 전체 크로스 부서 런치 준비도 | 7 |
| `/changelog` | 내부 체인지로그 자동 생성 | 7 |
| `/patch-notes` | 플레이어용 패치 노트 | 7 |
| `/hotfix` | 긴급 수정 워크플로 | 7+ |

#### 창작 (2)

| 커맨드 | 용도 | 페이즈 |
|---------|---------|-------|
| `/prototype` | 격리된 worktree 의 일회성 프로토타입 | 4 |
| `/localize` | 문자열 추출 및 검증 | 6-7 |

#### 팀 오케스트레이션 (9)

| 커맨드 | 용도 | 페이즈 |
|---------|---------|-------|
| `/team-combat` | 전투 기능: 디자인부터 구현까지 | 5 |
| `/team-narrative` | 내러티브 콘텐츠: 구조부터 대사까지 | 5 |
| `/team-ui` | UI 기능: UX 스펙부터 폴리시된 구현까지 | 5 |
| `/team-level` | 레벨: 레이아웃부터 꾸며진 인카운터까지 | 5 |
| `/team-audio` | 오디오: 방향성부터 구현된 이벤트까지 | 5-6 |
| `/team-polish` | 조율된 폴리시: perf + art + audio + QA | 6 |
| `/team-release` | 릴리스 조율: 빌드 + QA + 배포 | 7 |
| `/team-live-ops` | 라이브 운영 계획: 시즌 이벤트, 배틀 패스, 리텐션 | 7+ |
| `/team-qa` | 전체 QA 사이클: 전략, 실행, 커버리지, 사인오프 | 6-7 |

---

## 부록 C: 일반적 워크플로

### 워크플로 1: "방금 시작했고 게임 아이디어가 없다"

```
1. /start (현재 위치 기반으로 라우팅)
2. /brainstorm (협업 아이디에이션, 컨셉 선택)
3. /setup-engine unreal 5.7 (엔진과 버전 확인)
4. /design-review (컨셉 문서에, 선택이지만 권장)
5. /map-systems (의존성과 우선순위가 있는 시스템으로 컨셉 분해)
6. /gate-check concept (Systems Design 준비 검증)
7. /design-system (시스템별, 가이드 GDD 저작)
```

### 워크플로 2: "디자인이 있고 코딩을 시작하고 싶다"

```
1. /design-review (각 GDD 에, 그들이 견고한지 확인)
2. /review-all-gdds (크로스 GDD 일관성)
3. /gate-check systems-design
4. /create-architecture + /architecture-decision (주요 결정별)
5. /architecture-review
6. /create-control-manifest
7. /gate-check technical-setup
8. /create-epics layer: foundation + /create-stories [slug] (에픽 정의, 스토리 분해)
9. /sprint-plan new
10. /story-readiness -> 구현 -> /story-done (스토리 생명주기)
```

### 워크플로 3: "프로덕션 중간에 복잡한 기능을 추가해야 한다"

```
1. /design-system 또는 /quick-design (스코프에 따라)
2. /design-review 로 검증
3. /propagate-design-change 기존 GDD 를 수정한다면
4. /estimate 공수와 리스크
5. /team-combat, /team-narrative, /team-ui 등 (적절한 팀 스킬)
6. /story-done 완료시
7. /balance-check 게임 밸런스에 영향을 준다면
```

### 워크플로 4: "프로덕션에서 무언가 망가졌다"

```
1. /hotfix "이슈 설명"
2. hotfix 브랜치에서 수정 구현
3. /code-review 수정을
4. 테스트 실행
5. /release-checklist hotfix 빌드용
6. 배포 및 백포트
```

### 워크플로 5: "기존 프로젝트가 있고 이 시스템을 사용하고 싶다"

```
1. /start (Path D 선택 — 기존 작업)
2. /project-stage-detect (현재 페이즈 결정)
3. /adopt (기존 아티팩트 감사, 마이그레이션 계획 구축)
4. /design-system retrofit [path] (GDD 갭 채움)
5. /architecture-decision retrofit [path] (ADR 갭 채움)
6. /gate-check 적절한 전환에서
```

### 워크플로 6: "새 스프린트 시작"

```
1. /retrospective (지난 스프린트 리뷰)
2. /sprint-plan new (다음 스프린트 생성)
3. /scope-check (스코프가 관리 가능한지 확인)
4. /story-readiness 픽업 전 스토리별
5. 스토리 구현
6. /story-done 완료된 스토리별
7. /sprint-status 빠른 진행 체크
```

### 워크플로 7: "게임 출시"

```
1. /gate-check polish (Polish 페이즈 완료 검증)
2. /tech-debt (런치에서 허용 가능한 것 결정)
3. /localize (최종 로컬라이제이션 패스)
4. /release-checklist v1.0.0
5. /launch-checklist (전체 크로스 부서 검증)
6. /team-release (릴리스 조율)
7. /patch-notes 와 /changelog
8. 출시!
9. /hotfix 런치 후 무언가 망가지면
10. 런치 안정화 후 포스트모템
```

### 워크플로 8: "길을 잃었다 / 다음에 무엇을 할지 모르겠다"

```
1. /help (페이즈를 읽고, 아티팩트를 체크하고, 다음을 알려줌)
2. /help 가 도움이 안 되면: /project-stage-detect (전체 감사)
3. 페이즈가 잘못된 것 같다면: /gate-check 있다고 생각하는 전환에서
```

---

## 시스템을 최대한 활용하기 위한 팁

1. **항상 디자인부터 시작하고, 그 다음 구현.** 에이전트 시스템은 코드
   작성 전 디자인 문서가 존재한다는 가정 위에 구축되어 있습니다. 에이전트는
   GDD 를 끊임없이 참조합니다.

2. **크로스 컷팅 기능에 팀 스킬 사용.** 스스로 4명 에이전트를 수동으로
   조율하려 하지 마세요 — `/team-combat`, `/team-narrative` 등이 오케스트레이션을
   처리하도록 하세요.

3. **룰 시스템을 신뢰하세요.** 룰이 당신의 코드에서 무언가 플래그하면,
   수정하세요. 룰은 어렵게 얻은 게임 개발 지혜 (데이터 주도 값, 델타
   타임, 접근성 등) 를 인코딩합니다.

4. **사전 대응적으로 압축.** ~65-70% 컨텍스트 사용에서 압축하거나
   `/clear`. pre-compact 훅이 진행을 저장합니다. 한계에 도달할 때까지
   기다리지 마세요.

5. **올바른 티어의 에이전트 사용.** `creative-director` 에게 셰이더를
   작성하도록 요청하지 마세요. `qa-tester` 에게 디자인 결정을 내리도록
   요청하지 마세요. 계층은 이유가 있어서 존재합니다.

6. **불확실할 때 /help 실행.** 실제 프로젝트 상태를 읽고 단 하나의
   가장 중요한 다음 단계를 알려줍니다.

7. **디자인을 프로그래머에게 핸드오프하기 전 `/design-review` 실행.**
   이는 불완전한 스펙을 조기에 포착하여 재작업을 절약합니다.

8. **모든 주요 기능 후 `/code-review` 실행.** 아키텍처 이슈가 전파되기
   전에 포착하세요.

9. **리스크 있는 메커닉을 먼저 프로토타입.** 하루의 프로토타이핑이
   작동하지 않는 메커닉에서 한 주의 프로덕션을 절약할 수 있습니다.

10. **스프린트 계획을 정직하게 유지하세요.** `/scope-check` 를 정기적으로
    사용하세요. 스코프 크립은 인디 게임의 1번 킬러입니다.

11. **ADR 로 결정을 문서화.** 미래의 당신은 현재의 당신에게 *왜* 그런
    방식으로 구축되었는지 기록한 것에 감사할 것입니다.

12. **스토리 생명주기를 종교적으로 사용.** 픽업 전 `/story-readiness`,
    완료 후 `/story-done`. 이는 일탈을 조기에 포착하고 파이프라인을
    정직하게 유지합니다.

13. **파일에 일찍 그리고 자주 써라.** 증분 섹션 쓰기는 디자인 결정이
    크래시와 압축에서 생존한다는 의미입니다. 파일이 기억이지, 대화가 아닙니다.
