# Director Gates — 공유 리뷰 패턴

이 문서는 모든 워크플로 단계에 걸쳐 모든 디렉터 및 리드 리뷰에 대한 표준
게이트 프롬프트를 정의합니다. 스킬은 프롬프트를 인라인으로 내장하지 않고
이 문서의 게이트 ID 를 참조합니다 — 프롬프트 업데이트 시 드리프트 제거.

**범위**: 전체 7개 프로덕션 단계 (Concept → Release), 3명의 Tier 1 디렉터,
주요 Tier 2 리드. 모든 스킬, 팀 오케스트레이터, 워크플로가 이 게이트를 호출할 수 있습니다.

---

## 이 문서 사용 방법

모든 스킬에서 인라인 디렉터 프롬프트를 참조로 대체하세요:

```
`.claude/docs/director-gates.md` 의 게이트 **CD-PILLARS** 를 사용해
Task 경유로 `creative-director` 스폰.
```

해당 게이트의 **Context to pass** 필드에 나열된 컨텍스트를 전달한 후,
아래의 **Verdict handling** 규칙을 사용해 판정을 처리하세요.

---

## 리뷰 모드

리뷰 강도는 디렉터 게이트 실행 여부를 제어합니다. 전역으로 설정할 수 있으며
(세션 간 지속) 스킬 실행당 오버라이드도 가능합니다.

**전역 설정**: `production/review-mode.txt` — 단어 하나: `full`, `lean`, 또는 `solo`.
`/start` 중 한 번 설정. 언제든 파일을 직접 편집해 변경 가능.

**실행별 오버라이드**: 게이트를 사용하는 모든 스킬은 인자로
`--review [full|lean|solo]` 를 받습니다. 이는 해당 실행에 한해 전역 설정을 오버라이드합니다.

예시:
```
/brainstorm space horror           → 전역 모드 사용
/brainstorm space horror --review full   → 이 실행은 full 모드 강제
/architecture-decision --review solo     → 이 실행은 모든 게이트 스킵
```

| 모드 | 실행되는 것 | 적합한 대상 |
|------|-----------|----------|
| `full` | 모든 게이트 활성 — 모든 워크플로 단계 리뷰 | 팀, 학습 중인 사용자, 또는 매 단계마다 철저한 디렉터 피드백을 원할 때 |
| `lean` | PHASE-GATE 만 (`/gate-check`) — 스킬별 게이트는 스킵 | **기본값** — 솔로 개발자와 소규모 팀; 디렉터는 마일스톤에서만 리뷰 |
| `solo` | 어느 곳에서도 디렉터 게이트 없음 | 게임 잼, 프로토타입, 최대 속도 |

**체크 패턴 — 모든 게이트 스폰 전에 적용:**

```
게이트 [GATE-ID] 스폰 전:
1. 스킬이 --review [mode] 로 호출되었다면 그것 사용
2. 아니면 production/review-mode.txt 읽기
3. 아니면 full 기본값
해결된 모드 적용:
- solo → 모든 게이트 스킵. 노트: "[GATE-ID] 스킵됨 — Solo 모드"
- lean → PHASE-GATE (CD-PHASE-GATE, TD-PHASE-GATE, PR-PHASE-GATE) 가
         아니면 스킵. 노트: "[GATE-ID] 스킵됨 — Lean 모드"
- full → 평소대로 스폰
```

---

## 호출 패턴 (모든 스킬에 복사)

**필수: 모든 게이트 스폰 전 리뷰 모드를 해결하세요.** 확인 없이 게이트를 스폰하지 마세요.
해결된 모드는 스킬 실행당 한 번 결정됩니다:
1. 스킬이 `--review [mode]` 로 호출되었다면 그것 사용
2. 아니면 `production/review-mode.txt` 읽기
3. 아니면 `lean` 기본값

해결된 모드 적용:
- `solo` → **모든 게이트 스킵**. 출력 노트: `[GATE-ID] 스킵됨 — Solo 모드`
- `lean` → **PHASE-GATE (CD-PHASE-GATE, TD-PHASE-GATE, PR-PHASE-GATE, AD-PHASE-GATE) 가 아니면 스킵**. 노트: `[GATE-ID] 스킵됨 — Lean 모드`
- `full` → 평소대로 스폰

```
# 모드 체크 적용 후:
Task 경유로 `[agent-name]` 스폰:
- Gate: [GATE-ID] (.claude/docs/director-gates.md 참조)
- Context: [해당 게이트 아래 나열된 필드]
- 진행 전 판정 대기.
```

병렬 스폰 (같은 게이트 지점에 여러 디렉터):

```
# 각 게이트에 대해 먼저 모드 체크 적용 후, 살아남은 것 모두 스폰:
Task 경유로 모든 [N] 에이전트 동시 스폰 — 결과를 기다리기 전에
모든 Task 호출을 발행. 진행 전 모든 판정 수집.
```

---

## 표준 판정 포맷

모든 게이트는 세 가지 판정 중 하나를 반환합니다. 스킬은 세 가지 모두 처리해야 합니다:

| 판정 | 의미 | 기본 동작 |
|---------|---------|----------------|
| **APPROVE / READY** | 이슈 없음. 진행. | 워크플로 계속 |
| **CONCERNS [list]** | 이슈 존재하지만 블로킹 아님. | `AskUserQuestion` 으로 사용자에게 표면화 — 옵션: `플래그된 항목 수정` / `수용 및 진행` / `더 논의` |
| **REJECT / NOT READY [blockers]** | 블로킹 이슈. 진행 금지. | 블로커를 사용자에게 표면화. 해결될 때까지 파일 기록이나 단계 진행 금지. |

**에스컬레이션 룰**: 여러 디렉터가 병렬로 스폰될 때, 가장 엄격한 판정 적용 —
한 개의 NOT READY 는 모든 READY 판정을 오버라이드합니다.

---

## 게이트 결과 기록

게이트가 해결되면 관련 문서의 상태 헤더에 판정을 기록:

```markdown
> **[Director] Review ([GATE-ID])**: APPROVED [date] / CONCERNS (accepted) [date] / REVISED [date]
```

페이즈 게이트의 경우, `docs/architecture/architecture.md` 또는
`production/session-state/active.md` 에 적절히 기록.

---

## Tier 1 — Creative Director Gates

에이전트: `creative-director` | 모델 티어: Opus | 도메인: 비전, 필러, 플레이어 경험

---

### CD-PILLARS — 필러 스트레스 테스트

**트리거**: 게임 필러와 안티 필러가 정의된 후 (brainstorm Phase 4,
또는 필러가 수정된 모든 시점)

**전달할 컨텍스트**:
- 이름, 정의, 디자인 테스트를 포함한 전체 필러 세트
- 안티 필러 목록
- 코어 판타지 선언
- 고유한 훅 ("Like X, AND ALSO Y")

**프롬프트**:
> "이 게임 필러를 리뷰하세요. 반증 가능한가 — 실제 디자인 결정이
> 이 필러를 실제로 실패시킬 수 있는가? 서로에게 의미 있는 긴장을 만드는가?
> 가장 가까운 비교 작품들과 이 게임을 차별화하는가? 실전에서 디자인 분쟁을
> 해결하는 데 도움이 되는가, 아니면 유용하기엔 너무 모호한가? 각 필러에
> 대한 구체적 피드백과 종합 판정 반환: APPROVE (강함), CONCERNS [list]
> (날카롭게 다듬어야 함), 또는 REJECT (약함 — 필러가 무게를 지니지 못함)."

**판정**: APPROVE / CONCERNS / REJECT

---

### CD-GDD-ALIGN — GDD 필러 정합 체크

**트리거**: 시스템 GDD 저작 후 (design-system, quick-design, 또는 GDD 를
산출하는 모든 워크플로)

**전달할 컨텍스트**:
- GDD 파일 경로
- 게임 필러 (`design/gdd/game-concept.md` 또는 `design/gdd/game-pillars.md` 에서)
- 이 게임의 MDA aesthetics 타겟
- 시스템의 명시된 Player Fantasy 섹션

**프롬프트**:
> "이 시스템 GDD 의 필러 정합을 리뷰하세요. 모든 섹션이 명시된 필러를
> 지원하는가? 필러와 모순되거나 필러를 약화시키는 메커닉이나 룰이 있는가?
> Player Fantasy 섹션이 게임의 코어 판타지와 일치하는가? APPROVE, CONCERNS
> [이슈가 있는 특정 섹션], 또는 REJECT [이 시스템이 구현 가능해지기 전에
> 반드시 재설계해야 할 필러 위반] 반환."

**판정**: APPROVE / CONCERNS / REJECT

---

### CD-SYSTEMS — 시스템 분해 비전 체크

**트리거**: `/map-systems` 가 시스템 인덱스를 작성한 후 — GDD 저작이
시작되기 전 완전한 시스템 세트를 검증

**전달할 컨텍스트**:
- 시스템 인덱스 경로 (`design/gdd/systems-index.md`)
- 게임 필러와 코어 판타지 (`design/gdd/game-concept.md` 에서)
- 우선순위 티어 할당 (MVP / Vertical Slice / Alpha / Full Vision)
- 의존성 맵에서 식별된 고위험 또는 병목 시스템

**프롬프트**:
> "게임의 디자인 필러에 대비해 이 시스템 분해를 리뷰하세요. MVP 티어
> 시스템 전체 세트가 집합적으로 코어 판타지를 전달하는가? 명시된 필러를
> 지원하지 않는 메커닉을 가진 시스템이 있는가 — 스코프 크립을 나타낼 수
> 있는가? 코어 루프가 요구하는 필러 결정적 플레이어 경험 중 이를 전달할
> 시스템이 할당되지 않은 것이 있는가? 누락된 시스템이 있는가? APPROVE
> (시스템이 비전에 기여), CONCERNS [필러 함의를 가진 특정 갭 또는 불일치],
> 또는 REJECT [근본적 갭 — 분해가 중요한 디자인 의도를 놓치고 있으며
> GDD 저작 시작 전 수정 필요] 반환."

**판정**: APPROVE / CONCERNS / REJECT

---

### CD-NARRATIVE — 내러티브 일관성 체크

**트리거**: 내러티브 GDD, 로어 문서, 대사 스펙, 또는 월드빌딩 문서 저작 후
(team-narrative, 스토리 시스템의 design-system, writer 산출물)

**전달할 컨텍스트**:
- 문서 파일 경로
- 게임 필러
- 내러티브 방향 브리프 또는 톤 가이드 (`design/narrative/` 에 존재시)
- 새 문서가 참조하는 기존 로어

**프롬프트**:
> "이 내러티브 콘텐츠의 게임 필러 및 확립된 세계 룰과의 일관성을 리뷰하세요.
> 톤이 게임의 확립된 보이스와 일치하는가? 기존 로어 또는 월드빌딩과의
> 모순이 있는가? 콘텐츠가 플레이어 경험 필러를 지원하는가? APPROVE,
> CONCERNS [특정 불일치], 또는 REJECT [세계 일관성을 깨는 모순] 반환."

**판정**: APPROVE / CONCERNS / REJECT

---

### CD-PLAYTEST — 플레이어 경험 검증

**트리거**: 플레이테스트 리포트 생성 후 (`/playtest-report`), 또는 플레이어
피드백을 산출하는 모든 세션 후

**전달할 컨텍스트**:
- 플레이테스트 리포트 파일 경로
- 게임 필러와 코어 판타지 선언
- 테스트 중인 특정 가설

**프롬프트**:
> "이 플레이테스트 리포트를 게임의 디자인 필러 및 코어 판타지에 대비해
> 리뷰하세요. 플레이어 경험이 의도된 판타지와 일치하는가? 필러 드리프트를
> 나타내는 체계적 이슈가 있는가 — 고립 상태에서는 괜찮지만 의도된 경험을
> 훼손하는 메커닉? APPROVE (코어 판타지가 전달됨), CONCERNS [의도와
> 실제 경험 사이의 갭], 또는 REJECT [코어 판타지가 없음 — 추가
> 플레이테스트 전 재설계 필요] 반환."

**판정**: APPROVE / CONCERNS / REJECT

---

### CD-PHASE-GATE — 페이즈 전환 시 창의적 준비도

**트리거**: 항상 `/gate-check` 에서 — TD-PHASE-GATE 및 PR-PHASE-GATE 와 병렬 스폰

**전달할 컨텍스트**:
- 타겟 페이즈 이름
- 존재하는 모든 아티팩트 목록 (파일 경로)
- 게임 필러와 코어 판타지

**프롬프트**:
> "현재 프로젝트 상태에 대해 [타겟 페이즈] 게이트 준비도를 창의적 방향
> 관점에서 리뷰하세요. 게임 필러가 모든 디자인 아티팩트에 충실히
> 반영되어 있는가? 현재 상태가 코어 판타지를 보존하는가? GDD 또는
> 아키텍처 전반에 의도된 플레이어 경험을 손상시키는 디자인 결정이 있는가?
> READY, CONCERNS [list], 또는 NOT READY [blockers] 반환."

**판정**: READY / CONCERNS / NOT READY

---

## Tier 1 — Technical Director Gates

에이전트: `technical-director` | 모델 티어: Opus | 도메인: 아키텍처, 엔진 리스크, 성능

---

### TD-SYSTEM-BOUNDARY — 시스템 경계 아키텍처 리뷰

**트리거**: `/map-systems` Phase 3 의존성 매핑이 합의된 후 GDD 저작
시작 전 — 시스템 구조가 아키텍처적으로 건전한지 검증하여 팀이 그에 대한
GDD 작성에 투자하기 전

**전달할 컨텍스트**:
- 시스템 인덱스 경로 (또는 인덱스가 아직 작성되지 않았다면 의존성 맵 요약)
- 레이어 할당 (Foundation / Core / Feature / Presentation / Polish)
- 전체 의존성 그래프 (각 시스템이 의존하는 것)
- 플래그된 병목 시스템 (많은 의존자)
- 발견된 순환 의존성 및 제안된 해결

**프롬프트**:
> "이 시스템 분해를 GDD 저작 시작 전 아키텍처 관점에서 리뷰하세요. 시스템
> 경계가 깔끔한가 — 각 시스템이 최소한의 오버랩으로 뚜렷한 관심사를
> 소유하는가? God Object 리스크가 있는가 (너무 많이 하는 시스템)? 의존성
> 순서가 구현 시퀀싱 문제를 만드는가? 제안된 경계에 구현 시 타이트한
> 커플링을 일으킬 암묵적 공유 상태 문제가 있는가? Foundation 레이어
> 시스템이 실제로 Feature 레이어 시스템에 의존하는가 (역전된 의존성)?
> APPROVE (경계가 아키텍처적으로 건전 — GDD 저작 진행), CONCERNS
> [GDD 자체에서 다룰 특정 경계 이슈], 또는 REJECT [근본적 경계 문제 —
> 시스템 구조가 아키텍처 이슈를 일으킬 것이며 GDD 작성 전 재구조화 필요] 반환."

**판정**: APPROVE / CONCERNS / REJECT

---

### TD-FEASIBILITY — 기술 타당성 평가

**트리거**: 스코프/타당성 중 가장 큰 기술 리스크가 식별된 후
(brainstorm Phase 6, quick-design, 또는 기술 미지수가 있는 초기 컨셉)

**전달할 컨텍스트**:
- 컨셉의 코어 루프 설명
- 플랫폼 타겟
- 엔진 선택 (또는 "미정")
- 식별된 기술 리스크 목록

**프롬프트**:
> "[엔진 또는 '미정 엔진'] 을 사용하는 [플랫폼] 타겟 [장르] 게임을 위한
> 이 기술 리스크를 리뷰하세요. 설명된 대로의 컨셉을 무효화할 수 있는
> HIGH 리스크 항목, 엔진별이며 엔진 선택에 영향을 미쳐야 하는 리스크,
> 솔로 개발자에 의해 흔히 과소평가되는 리스크를 플래그하세요. VIABLE
> (리스크 관리 가능), CONCERNS [완화 제안이 있는 list], 또는 HIGH RISK
> [컨셉 또는 스코프 수정이 필요한 블로커] 반환."

**판정**: VIABLE / CONCERNS / HIGH RISK

---

### TD-ARCHITECTURE — 아키텍처 사인오프

**트리거**: 마스터 아키텍처 문서 초안 작성 후 (`/create-architecture`
Phase 7), 그리고 주요 아키텍처 수정 후

**전달할 컨텍스트**:
- 아키텍처 문서 경로 (`docs/architecture/architecture.md`)
- 기술 요구사항 베이스라인 (TR-ID 및 개수)
- 상태가 있는 ADR 목록
- 엔진 지식 갭 인벤토리

**프롬프트**:
> "이 마스터 아키텍처 문서의 기술적 건전성을 리뷰하세요. 체크: (1) 베이스라인의
> 모든 기술 요구사항이 아키텍처 결정으로 커버되는가? (2) 모든 HIGH
> 리스크 엔진 도메인이 명시적으로 다뤄지거나 오픈 질문으로 플래그되는가?
> (3) API 경계가 깔끔하고, 최소하며, 구현 가능한가? (4) 구현 시작 전
> Foundation 레이어 ADR 갭이 해결되었는가? APPROVE, CONCERNS [list],
> 또는 REJECT [코딩 시작 전 반드시 해결되어야 할 블로커] 반환."

**판정**: APPROVE / CONCERNS / REJECT

---

### TD-ADR — 아키텍처 결정 리뷰

**트리거**: 개별 ADR 저작 후 (`/architecture-decision`), Accepted 로
표시되기 전

**전달할 컨텍스트**:
- ADR 파일 경로
- 엔진 버전 및 도메인의 지식 갭 리스크 수준
- 관련 ADR (있다면)

**프롬프트**:
> "이 Architecture Decision Record 를 리뷰하세요. 명확한 문제 선언과
> 근거가 있는가? 거부된 대안이 진정으로 고려되었는가? Consequences 섹션이
> 트레이드오프를 정직하게 인정하는가? 엔진 버전이 스탬프되어 있는가? 컷오프
> 이후 API 리스크가 플래그되어 있는가? 커버하는 GDD 요구사항에 링크되어
> 있는가? APPROVE, CONCERNS [특정 갭], 또는 REJECT [결정이 불충분히
> 명시되었거나 건전하지 않은 기술 가정을 함] 반환."

**판정**: APPROVE / CONCERNS / REJECT

---

### TD-ENGINE-RISK — 엔진 버전 리스크 리뷰

**트리거**: 컷오프 이후 엔진 API 를 건드리는 아키텍처 결정을 내릴 때,
또는 엔진별 구현 접근 방식을 확정하기 전

**전달할 컨텍스트**:
- 사용되는 특정 API 또는 기능
- 엔진 버전과 LLM 지식 컷오프 (`docs/engine-reference/[engine]/VERSION.md` 에서)
- breaking-changes 또는 deprecated-apis 문서의 관련 발췌

**프롬프트**:
> "이 엔진 API 사용을 버전 레퍼런스에 대비해 리뷰하세요. 이 API 가 [엔진
> 버전] 에 존재하는가? LLM 지식 컷오프 이후 시그니처, 동작, 또는 네임스페이스가
> 변경되었는가? 알려진 deprecation 또는 컷오프 이후 대안이 있는가?
> APPROVE (설명된 대로 사용 안전), CONCERNS [구현 전 검증], 또는
> REJECT [API 가 변경됨 — 수정된 접근 제공] 반환."

**판정**: APPROVE / CONCERNS / REJECT

---

### TD-PHASE-GATE — 페이즈 전환 시 기술 준비도

**트리거**: 항상 `/gate-check` 에서 — CD-PHASE-GATE 및 PR-PHASE-GATE 와 병렬 스폰

**전달할 컨텍스트**:
- 타겟 페이즈 이름
- 아키텍처 문서 경로 (존재시)
- 엔진 레퍼런스 경로
- ADR 목록

**프롬프트**:
> "현재 프로젝트 상태에 대해 [타겟 페이즈] 게이트 준비도를 기술 방향 관점에서
> 리뷰하세요. 이 페이즈에 대해 아키텍처가 건전한가? 모든 고위험 엔진
> 도메인이 다뤄졌는가? 성능 예산이 현실적이고 문서화되었는가? Foundation
> 레이어 결정이 구현을 시작할 수 있을 만큼 완전한가? READY, CONCERNS
> [list], 또는 NOT READY [blockers] 반환."

**판정**: READY / CONCERNS / NOT READY

---

## Tier 1 — Producer Gates

에이전트: `producer` | 모델 티어: Opus | 도메인: 스코프, 타임라인, 의존성, 프로덕션 리스크

---

### PR-SCOPE — 스코프 및 타임라인 검증

**트리거**: 스코프 티어가 정의된 후 (brainstorm Phase 6, quick-design,
또는 MVP 정의 및 타임라인 추정을 산출하는 모든 워크플로)

**전달할 컨텍스트**:
- 전체 비전 스코프 설명
- MVP 정의
- 타임라인 추정
- 팀 크기 (솔로 / 소규모 팀 / 등)
- 스코프 티어 (시간이 부족할 때 출시되는 것)

**프롬프트**:
> "이 스코프 추정을 리뷰하세요. MVP 가 명시된 팀 크기에 대한 명시된 타임라인에서
> 달성 가능한가? 스코프 티어가 리스크에 따라 올바르게 정렬되어 있는가 —
> 각 티어가 작업이 거기서 멈출 경우 출시 가능한 제품을 전달하는가?
> 시간 압박 하에서 가장 가능성 있는 컷 포인트는 무엇이며, 그것이 graceful
> fallback 인가 아니면 망가진 제품인가? REALISTIC (스코프가 캐파시티와
> 일치), OPTIMISTIC [권장되는 특정 조정], 또는 UNREALISTIC [블로커 —
> 타임라인 또는 MVP 수정 필요] 반환."

**판정**: REALISTIC / OPTIMISTIC / UNREALISTIC

---

### PR-SPRINT — 스프린트 타당성 리뷰

**트리거**: 스프린트 계획 (`/sprint-plan`) 확정 전, 그리고 스프린트 중간
스코프 변경 후

**전달할 컨텍스트**:
- 제안된 스프린트 스토리 목록 (제목, 추정치, 의존성)
- 팀 캐파시티 (가용 시간)
- 현재 스프린트 백로그 부채 (있다면)
- 마일스톤 제약

**프롬프트**:
> "이 스프린트 계획의 타당성을 리뷰하세요. 가용 캐파시티에 대해 스토리
> 부하가 현실적인가? 스토리가 의존성에 따라 올바르게 정렬되어 있는가?
> 스프린트를 중간에 블로킹할 수 있는 스토리 간 숨은 의존성이 있는가? 기술
> 복잡도를 고려할 때 과소평가된 스토리가 있는가? REALISTIC (계획
> 달성 가능), CONCERNS [특정 리스크], 또는 UNREALISTIC [스프린트가
> 디스코프되어야 함 — 지연할 스토리 식별] 반환."

**판정**: REALISTIC / CONCERNS / UNREALISTIC

---

### PR-MILESTONE — 마일스톤 리스크 평가

**트리거**: 마일스톤 리뷰 (`/milestone-review`), 스프린트 중간 회고, 또는
마일스톤에 영향을 미치는 스코프 변경이 제안될 때

**전달할 컨텍스트**:
- 마일스톤 정의 및 타겟 날짜
- 현재 완료율
- 블록된 스토리 수
- 스프린트 속도 데이터 (가용시)

**프롬프트**:
> "이 마일스톤 상태를 리뷰하세요. 현재 속도와 블록된 스토리 수를 기반으로,
> 이 마일스톤이 타겟 날짜를 달성할 것인가? 지금부터 마일스톤까지의 상위 3가지
> 프로덕션 리스크는? 마일스톤 날짜를 보호하기 위해 컷해야 하는 스코프
> 항목 vs 협상 불가능한 항목이 있는가? ON TRACK, AT RISK [특정 완화책],
> 또는 OFF TRACK [날짜가 슬립해야 하거나 스코프가 컷되어야 함 — 양쪽
> 옵션 제공] 반환."

**판정**: ON TRACK / AT RISK / OFF TRACK

---

### PR-EPIC — 에픽 구조 타당성 리뷰

**트리거**: `/create-epics` 에 의해 에픽이 정의된 후, 스토리가 분해되기 전 —
`/create-stories` 가 호출되기 전 에픽 구조가 생산 가능한지 검증

**전달할 컨텍스트**:
- 에픽 정의 파일 경로 (방금 생성된 모든 에픽)
- 에픽 인덱스 경로 (`production/epics/index.md`)
- 마일스톤 타임라인 및 타겟 날짜
- 팀 캐파시티 (솔로 / 소규모 팀 / 크기)
- 에픽화되는 레이어 (Foundation / Core / Feature / 등)

**프롬프트**:
> "스토리 분해가 시작되기 전 이 에픽 구조의 프로덕션 타당성을 리뷰하세요.
> 에픽 경계가 적절히 스코프되어 있는가 — 각 에픽이 마일스톤 데드라인 전에
> 현실적으로 완료될 수 있는가? 에픽이 시스템 의존성에 따라 올바르게 정렬되어
> 있는가 — 어떤 에픽이라도 시작하기 전에 다른 에픽의 출력이 필요한가?
> 언더스코프된 에픽 (너무 작음, 병합 필요) 또는 오버스코프된 에픽 (너무 큼,
> 2-3개의 집중된 에픽으로 분할 필요) 이 있는가? Foundation 레이어 에픽이
> Foundation 완료 후 다음 스프린트 시작에 Core 레이어 에픽이 시작될 수
> 있도록 스코프되어 있는가? REALISTIC (에픽 구조 생산 가능), CONCERNS
> [스토리 작성 전 특정 구조적 조정], 또는 UNREALISTIC [에픽이 분할,
> 병합, 또는 재정렬되어야 함 — 해결될 때까지 스토리 분해를 시작할 수
> 없음] 반환."

**판정**: REALISTIC / CONCERNS / UNREALISTIC

---

### PR-PHASE-GATE — 페이즈 전환 시 프로덕션 준비도

**트리거**: 항상 `/gate-check` 에서 — CD-PHASE-GATE 및 TD-PHASE-GATE 와 병렬 스폰

**전달할 컨텍스트**:
- 타겟 페이즈 이름
- 존재하는 스프린트 및 마일스톤 아티팩트
- 팀 크기와 캐파시티
- 현재 블록된 스토리 수

**프롬프트**:
> "현재 프로젝트 상태에 대해 [타겟 페이즈] 게이트 준비도를 프로덕션 관점에서
> 리뷰하세요. 명시된 타임라인과 팀 크기에 대해 스코프가 현실적인가? 의존성이
> 올바르게 정렬되어 팀이 실제로 순서대로 실행할 수 있는가? 첫 두 스프린트
> 내에 페이즈를 탈선시킬 수 있는 마일스톤 또는 스프린트 리스크가 있는가?
> READY, CONCERNS [list], 또는 NOT READY [blockers] 반환."

**판정**: READY / CONCERNS / NOT READY

---

## Tier 1 — Art Director Gates

에이전트: `art-director` | 모델 티어: Sonnet | 도메인: 비주얼 정체성, 아트 바이블, 비주얼 프로덕션 준비도

---

### AD-CONCEPT-VISUAL — 비주얼 정체성 앵커

**트리거**: 게임 필러가 확정된 후 (brainstorm Phase 4), CD-PILLARS 와 병렬

**전달할 컨텍스트**:
- 게임 컨셉 (엘리베이터 피치, 코어 판타지, 고유 훅)
- 이름, 정의, 디자인 테스트를 포함한 전체 필러 세트
- 타겟 플랫폼 (알려진 경우)
- 사용자가 언급한 참고 게임 또는 비주얼 터치스톤

**프롬프트**:
> "이 게임 필러와 코어 컨셉을 기반으로, 2-3개의 뚜렷한 비주얼 정체성
> 방향을 제안하세요. 각 방향에 대해 제공: (1) 모든 비주얼 결정을 가이드할 수
> 있는 한 줄 비주얼 룰 (예: '모든 것이 움직여야 함', '아름다움은 쇠퇴 속에
> 있음'), (2) 무드와 분위기 타겟, (3) 모양 언어 (sharp/rounded/organic/geometric
> 강조), (4) 컬러 철학 (팔레트 방향, 이 세계에서 색이 의미하는 것).
> 구체적이세요 — 일반적 설명을 피하세요. 한 방향은 주 디자인 필러를
> 직접 지원해야 합니다. 각 방향에 이름을 붙이세요. 명시된 필러에 가장
> 잘 기여하는 것을 추천하고 이유를 설명하세요."

**판정**: CONCEPTS (여러 유효한 옵션 — 사용자 선택) / STRONG (한 방향이 명확히 우세) / CONCERNS (필러가 비주얼 정체성을 차별화할 만큼 충분한 방향을 제공하지 않음)

---

### AD-ART-BIBLE — 아트 바이블 사인오프

**트리거**: 아트 바이블 초안 작성 후 (`/art-bible`), 에셋 프로덕션 시작 전

**전달할 컨텍스트**:
- 아트 바이블 경로 (`design/art/art-bible.md`)
- 게임 필러와 코어 판타지
- 플랫폼 및 성능 제약 (`.claude/docs/technical-preferences.md` 에서, 구성된 경우)
- brainstorm 중 선택된 비주얼 정체성 앵커 (`design/gdd/game-concept.md` 에서)

**프롬프트**:
> "이 아트 바이블의 완전성과 내부 일관성을 리뷰하세요. 컬러 시스템이
> 무드 타겟과 일치하는가? 모양 언어가 비주얼 정체성 선언에서 따라 나오는가?
> 에셋 표준이 플랫폼 제약 내에서 달성 가능한가? 캐릭터 디자인 방향이
> 아티스트가 작업할 충분한 것을 과도한 명시 없이 제공하는가? 섹션 간
> 모순이 있는가? 외주 팀이 추가 브리핑 없이 이 문서로부터 에셋을 생산할
> 수 있을까? APPROVE (아트 바이블 프로덕션 준비됨), CONCERNS [명확화가
> 필요한 특정 섹션], 또는 REJECT [에셋 프로덕션 시작 전 반드시 해결되어야
> 할 근본적 불일치] 반환."

**판정**: APPROVE / CONCERNS / REJECT

---

### AD-PHASE-GATE — 페이즈 전환 시 비주얼 준비도

**트리거**: 항상 `/gate-check` 에서 — CD-PHASE-GATE, TD-PHASE-GATE, PR-PHASE-GATE 와 병렬 스폰

**전달할 컨텍스트**:
- 타겟 페이즈 이름
- 존재하는 모든 아트/비주얼 아티팩트 목록 (파일 경로)
- `design/gdd/game-concept.md` 에서의 비주얼 정체성 앵커 (존재시)
- 존재시 아트 바이블 경로 (`design/art/art-bible.md`)

**프롬프트**:
> "현재 프로젝트 상태에 대해 [타겟 페이즈] 게이트 준비도를 비주얼 방향
> 관점에서 리뷰하세요. 비주얼 정체성이 이 페이즈가 요구하는 수준에서
> 확립되고 문서화되었는가? 올바른 비주얼 아티팩트가 제자리에 있는가?
> 비주얼 팀이 나중에 비싼 재작업을 유발하는 비주얼 방향 갭 없이 작업을
> 시작할 수 있는가? 가장 늦은 책임 있는 순간을 넘어 연기되는 비주얼
> 결정이 있는가? READY, CONCERNS [프로덕션 재작업을 유발할 수 있는 특정
> 비주얼 방향 갭], 또는 NOT READY [이 페이즈가 성공하기 위해 반드시
> 존재해야 할 비주얼 블로커 — 어떤 아티팩트가 누락되었고 이 단계에서
> 왜 중요한지 명시] 반환."

**판정**: READY / CONCERNS / NOT READY

---

## Tier 2 — Lead Gates

이 게이트는 도메인 스페셜리스트의 타당성 사인오프가 필요할 때
오케스트레이션 스킬과 시니어 스킬에 의해 호출됩니다. Tier 2 리드는
Sonnet 을 사용합니다 (기본).

---

### LP-FEASIBILITY — Lead Programmer 구현 타당성

**트리거**: 마스터 아키텍처 문서 작성 후 (`/create-architecture`
Phase 7b), 또는 새 아키텍처 패턴이 제안될 때

**전달할 컨텍스트**:
- 아키텍처 문서 경로
- 기술 요구사항 베이스라인 요약
- 상태가 있는 ADR 목록

**프롬프트**:
> "이 아키텍처의 구현 타당성을 리뷰하세요. 플래그: (a) 명시된 엔진 및
> 언어로 구현하기 어렵거나 불가능한 결정, (b) 프로그래머가 스스로 발명해야
> 할 누락된 인터페이스 정의, (c) 회피 가능한 기술 부채를 만들거나 표준
> [엔진] 관용구와 모순되는 패턴. FEASIBLE, CONCERNS [list], 또는
> INFEASIBLE [작성된 대로 이 아키텍처를 구현 불가능하게 만드는 블로커] 반환."

**판정**: FEASIBLE / CONCERNS / INFEASIBLE

---

### LP-CODE-REVIEW — Lead Programmer 코드 리뷰

**트리거**: dev 스토리가 구현된 후 (`/dev-story`, `/story-done`), 또는
`/code-review` 의 일부로서

**전달할 컨텍스트**:
- 구현 파일 경로
- 스토리 파일 경로 (승인 기준용)
- 관련 GDD 섹션
- 이 시스템을 관장하는 ADR

**프롬프트**:
> "이 구현을 스토리 승인 기준 및 관장 ADR 에 대비해 리뷰하세요. 코드가
> 아키텍처 경계 정의와 일치하는가? 코딩 표준 또는 금지 패턴 위반이 있는가?
> public API 가 테스트 가능하고 문서화되어 있는가? GDD 룰에 대한 정확성
> 이슈가 있는가? APPROVE, CONCERNS [특정 이슈], 또는 REJECT [머지 전 수정 필요] 반환."

**판정**: APPROVE / CONCERNS / REJECT

---

### QL-STORY-READY — QA Lead 스토리 준비도 체크

**트리거**: 스토리가 스프린트에 수용되기 전 — 스토리 선택 중 `/create-stories`,
`/story-readiness`, `/sprint-plan` 에 의해 호출

**전달할 컨텍스트**:
- 스토리 파일 경로
- 스토리 타입 (Logic / Integration / Visual/Feel / UI / Config/Data)
- 승인 기준 목록 (스토리에서 그대로)
- 스토리가 커버하는 GDD 요구사항 (TR-ID 와 텍스트)

**프롬프트**:
> "이 스토리의 승인 기준 테스트 가능성을 스프린트 진입 전에 리뷰하세요.
> 모든 기준이 개발자가 완료를 명확히 알 만큼 구체적인가? Logic 타입
> 스토리의 경우: 모든 기준이 자동화 테스트로 검증 가능한가? Integration
> 스토리의 경우: 각 기준이 통제된 테스트 환경에서 관찰 가능한가? 구현하기에
> 너무 모호한 기준을 플래그하고, 테스트에 전체 게임 빌드가 필요한 기준을
> 플래그하세요 (BLOCKED 가 아닌 DEFERRED 로 표시). ADEQUATE (기준이
> 작성된 대로 구현 가능), GAPS [리파인이 필요한 특정 기준], 또는
> INADEQUATE [기준이 너무 모호 — 스프린트 포함 전 스토리 수정 필요] 반환."

**판정**: ADEQUATE / GAPS / INADEQUATE

---

### QL-TEST-COVERAGE — QA Lead 테스트 커버리지 리뷰

**트리거**: 구현 스토리가 완료된 후, 에픽을 done 으로 표시하기 전, 또는
`/gate-check` Production → Polish 에서

**전달할 컨텍스트**:
- 스토리 타입이 있는 구현된 스토리 목록 (Logic / Integration / Visual / UI / Config)
- `tests/` 의 테스트 파일 경로
- 시스템의 GDD 승인 기준

**프롬프트**:
> "이 구현 스토리의 테스트 커버리지를 리뷰하세요. 모든 Logic 스토리가
> 통과하는 유닛 테스트로 커버되는가? Integration 스토리가 통합 테스트
> 또는 문서화된 플레이테스트로 커버되는가? GDD 승인 기준 각각이 최소 하나의
> 테스트에 매핑되는가? GDD Edge Cases 섹션의 테스트되지 않은 엣지 케이스가
> 있는가? ADEQUATE (커버리지 표준 충족), GAPS [특정 누락 테스트], 또는
> INADEQUATE [중요한 로직이 테스트되지 않음 — 진행하지 말 것] 반환."

**판정**: ADEQUATE / GAPS / INADEQUATE

---

### ND-CONSISTENCY — Narrative Director 일관성 체크

**트리거**: writer 산출물 (대사, 로어, 아이템 설명) 저작 후, 또는 디자인
결정이 내러티브 함의를 가질 때

**전달할 컨텍스트**:
- 문서 또는 콘텐츠 파일 경로
- 내러티브 바이블 또는 톤 가이드 경로 (존재시)
- 관련 월드빌딩 룰
- 영향받는 캐릭터 또는 팩션 프로필

**프롬프트**:
> "이 내러티브 콘텐츠의 내부 일관성과 확립된 세계 룰 준수를 리뷰하세요.
> 캐릭터 보이스가 확립된 프로필과 일관적인가? 로어가 확립된 사실과
> 모순되는가? 톤이 게임의 내러티브 방향과 일관적인가? APPROVE, CONCERNS
> [수정할 특정 불일치], 또는 REJECT [내러티브 기반을 깨는 모순] 반환."

**판정**: APPROVE / CONCERNS / REJECT

---

### AD-VISUAL — Art Director 비주얼 일관성 리뷰

**트리거**: 아트 방향 결정이 내려진 후, 새 에셋 타입이 도입될 때, 또는
테크 아트 결정이 비주얼 스타일에 영향을 미칠 때

**전달할 컨텍스트**:
- 아트 바이블 경로 (`design/art-bible.md` 에 존재시)
- 리뷰되는 특정 에셋 타입, 스타일 결정, 또는 비주얼 방향
- 참고 이미지 또는 스타일 설명
- 플랫폼 및 성능 제약

**프롬프트**:
> "이 비주얼 방향 결정을 확립된 아트 스타일 및 프로덕션 제약과의 일관성에
> 대해 리뷰하세요. 아트 바이블과 일치하는가? 플랫폼의 성능 예산 내에서
> 달성 가능한가? 기술 리스크를 만드는 에셋 파이프라인 함의가 있는가?
> APPROVE, CONCERNS [특정 조정], 또는 REJECT [먼저 해결되어야 할
> 스타일 위반 또는 프로덕션 리스크] 반환."

**판정**: APPROVE / CONCERNS / REJECT

---

## 병렬 게이트 프로토콜

워크플로가 같은 체크포인트에서 여러 디렉터를 필요로 할 때 (`/gate-check`
에서 가장 일반적), 모든 에이전트를 동시에 스폰:

```
병렬 스폰 (결과를 기다리기 전에 모든 Task 호출 발행):
1. creative-director  → 게이트 CD-PHASE-GATE
2. technical-director → 게이트 TD-PHASE-GATE
3. producer           → 게이트 PR-PHASE-GATE
4. art-director       → 게이트 AD-PHASE-GATE

네 개의 판정 모두 수집 후, 에스컬레이션 룰 적용:
- 어떤 NOT READY / REJECT → 전체 판정 최소 FAIL
- 어떤 CONCERNS → 전체 판정 최소 CONCERNS
- 모두 READY / APPROVE → PASS 자격 (여전히 아티팩트 체크 대상)
```

---

## 새 게이트 추가

새 스킬이나 워크플로에 새 게이트가 필요할 때:

1. 게이트 ID 할당: `[DIRECTOR-PREFIX]-[DESCRIPTIVE-SLUG]`
   - 프리픽스: `CD-` `TD-` `PR-` `LP-` `QL-` `ND-` `AD-`
   - 새 에이전트에 새 프리픽스 추가: `AudioDirector` → `AU-`, `UX` → `UX-`
2. 적절한 디렉터 섹션 아래에 게이트를 다섯 개 필드 모두와 함께 추가:
   Trigger, Context to pass, Prompt, Verdicts, 특수 처리 노트 (있다면)
3. 스킬에서 ID 만으로 참조 — 프롬프트 텍스트를 스킬에 복사하지 말 것

---

## 단계별 게이트 커버리지

| 단계 | 필수 게이트 | 선택 게이트 |
|-------|---------------|----------------|
| **Concept** | CD-PILLARS, AD-CONCEPT-VISUAL | TD-FEASIBILITY, PR-SCOPE |
| **Systems Design** | TD-SYSTEM-BOUNDARY, CD-SYSTEMS, PR-SCOPE, CD-GDD-ALIGN (GDD 별) | ND-CONSISTENCY, AD-VISUAL |
| **Technical Setup** | TD-ARCHITECTURE, TD-ADR (ADR 별), LP-FEASIBILITY, AD-ART-BIBLE | TD-ENGINE-RISK |
| **Pre-Production** | PR-EPIC, QL-STORY-READY (스토리 별), PR-SPRINT, gate-check 경유 네 개의 PHASE-GATE 모두 | CD-PLAYTEST |
| **Production** | LP-CODE-REVIEW (스토리 별), QL-STORY-READY, PR-SPRINT (스프린트 별) | PR-MILESTONE, QL-TEST-COVERAGE, AD-VISUAL |
| **Polish** | QL-TEST-COVERAGE, CD-PLAYTEST, PR-MILESTONE | AD-VISUAL |
| **Release** | gate-check 경유 네 개의 PHASE-GATE 모두 | QL-TEST-COVERAGE |
