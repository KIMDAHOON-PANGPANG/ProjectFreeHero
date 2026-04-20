# FREEFLOW HERO — 시스템 GDD 인덱스

> **역할:** 이 파일은 `design/gdd/` 내 모든 시스템별 GDD 의 목차 겸 진행 대시보드다.
> 원본 GDD (`C:\Users\sk992\Downloads\freeflow_hero_gdd_kr.docx`) 를 UE5.7 + BP-only 정책 하에서
> **마이크로 시스템 단위 GDD 파일**로 분해해 둔 목록이며, 각 행은 `design/gdd/[slug].md` 로 링크된다.
> **설계 순서:** Foundation → Core → Feature → Presentation → Polish.
>
> **프로젝트 제약 요약:**
> - 엔진: Unreal Engine 5.7 (2025-11 고정)
> - **언어: Blueprint 전용 — C++ 작성 금지** (Source/ 미생성)
> - **GAS 미사용** — `UAttributeSet` 이 C++ 요구. 어빌리티/어트리뷰트/이펙트는 커스텀 BP 스택 사용
> - `FGameplayTag` / `FGameplayTagContainer` 는 유지 (BP 완전 지원)
> - 주력 엔진 스페셜리스트: `ue-blueprint-specialist`
>
> **원본 좌표:** 원본 Unity 기반 GDD 의 각 섹션 번호를 "원문 §" 컬럼에 보존하여 역추적 가능.

---

## 0. 이 인덱스 사용 방법

1. **새 시스템 GDD 를 쓸 때:** 아래 표의 해당 행을 찾아 `Status` 를 `Draft` → `Review` → `Locked` 로 전진시킨다.
   GDD 파일명은 `[slug].md` 컨벤션을 지킨다 (예: `auto-target-warping.md`).
2. **작성 후:** `/design-review [path]` 로 단건 검증, Phase 묶음 완료 시 `/review-all-gdds`.
3. **원문 참조 필요 시:** `docx` 덤프는 `C:\Users\sk992\AppData\Local\Temp\gdd_dump.txt` (세션 임시).
   정본은 항상 원본 `.docx`.
4. **GAS 용어가 남아있는 행:** "BP 대체" 컬럼의 지시를 따라 커스텀 BP 스택으로 번역한다.
   인덱스에서 GAS 원본 단어를 쓰는 이유는 **원문 추적**을 위해서이며, GDD 본문에는
   **대체 용어(`AttributeComponent` 등)만 써야 한다**.

### 상태 표기

| Status | 의미 |
|---|---|
| `—` | 아직 스켈레톤도 없음 |
| `Skeleton` | 8 섹션 헤더만 있는 뼈대 |
| `Draft` | 초안 본문 존재, 리뷰 전 |
| `Review` | `/design-review` 대기/진행 중 |
| `Locked` | 승인 완료, 변경 시 ADR 필요 |

### 우선순위 표기

| Priority | 의미 |
|---|---|
| **P0** | 수직 슬라이스에 필수. 이것 없으면 게임이 안 돌아감 |
| **P1** | 수직 슬라이스 확장용. P0 이후 즉시 필요 |
| **P2** | EA 이전에 필요하지만 수직 슬라이스엔 없어도 됨 |
| **P3** | EA 이후 / 선택적 |

---

## 1. Phase 0 — Foundation (P0 시스템, 수직 슬라이스 필수)

> 프리플로우 코어가 돌아가기 위해 **반드시 먼저 잠겨야** 하는 6개 시스템.
> 모두 `ue-blueprint-specialist` 가 구현을 담당하며, 복제는 단일 플레이어 스코프이므로 불필요.

| # | Slug (파일명) | 시스템명 | 원문 § | BP 대체 / 구현 힌트 | 핵심 에이전트 | Priority | Status |
|---|---|---|---|---|---|---|---|
| 1 | `auto-target-warping.md` | 오토타겟 & 와프 이동 | §4.1, §5.2 | `BP_AutoTargetComponent` (ActorComponent) + `BP_WarpMovementComponent`. 타겟 탐색은 GameplayMessageSubsystem 구독. | `ue-blueprint-specialist`, `systems-designer` | P0 | Draft |
| 2 | `combat-input-handler.md` | 전투 입력 핸들러 (Tap/Hold 분리) | §5.1 | Enhanced Input + BP `IA_Attack` / `IA_Counter` / `IA_Dodge` — Triggered / Completed 분리 처리 | `ue-blueprint-specialist` | P0 | — |
| 3 | `player-state-machine.md` | 플레이어 상태 머신 | §5.3 | UE5 **State Tree** (BP 전용) — Idle/Attack/Dodge/Counter/Hit/Down. `BP_PlayerStateTree` | `ue-blueprint-specialist`, `ai-programmer` | P0 | — |
| 4 | `hit-reaction.md` | 히트 리액션 & 히트스톱 | §5.4 | `BP_HitReactionComponent` + 글로벌 슬로우모(Custom Time Dilation) + Camera Shake | `ue-blueprint-specialist`, `technical-artist` | P0 | — |
| 5 | `group-token-ai.md` | 그룹 토큰 매니저 (군중 AI) | §5.5 | `BP_GroupTokenSubsystem` (WorldSubsystem) — 공격 토큰 N개 풀, 적 AI 가 토큰 요청/반환 | `ue-blueprint-specialist`, `ai-programmer` | P0 | — |
| 6 | `game-feel-layer.md` | 게임 필 레이어 (프리플로우 피드백) | §5.6 | `BP_GameFeelSubsystem` — 히트 프리즈, 카메라 셰이크, Chromatic Aberration PostProcess, SFX/VFX 큐 | `ue-blueprint-specialist`, `sound-designer`, `technical-artist` | P0 | — |

**Phase 0 게이트:** 위 6개 모두 `Locked` → 수직 슬라이스 프로토타입 착수 가능.

---

## 2. Phase 1 — Core (P0 확장 + 기본 빌드 루프)

> 하데스형 빌드 구조 + 2D 사이드스크롤 이동의 기반.

| # | Slug | 시스템명 | 원문 § | BP 대체 / 구현 힌트 | Priority | Status |
|---|---|---|---|---|---|---|
| 7 | `attribute-component.md` | 어트리뷰트 컴포넌트 (GAS 대체) | §6.1 | `BP_AttributeComponent` — HP/Stamina/공격력 등 float 변수 RepNotify. `UAttributeDataAsset` 로 초기값 주입 | P0 | — |
| 8 | `ability-component.md` | 어빌리티 컴포넌트 (GAS 대체) | §6.2 | `BP_AbilityComponent` — 활성 어빌리티 인벤토리. `UAbilityDataAsset` 배열 기반 | P0 | — |
| 9 | `effect-dataasset.md` | 이펙트 데이터 에셋 (GameplayEffect 대체) | §6.3 | `UEffectDataAsset (PrimaryDataAsset)` — Instant / Duration / Infinite 구분, Stack/Period 필드 | P0 | — |
| 10 | `gameplay-tag-usage.md` | GameplayTag 사용 규약 | §6.4 | **GAS 중 유일한 유지 항목.** 태그 네이밍 컨벤션, 태그 트리 정의 (Combat.State.*, Damage.Type.* 등) | P0 | — |
| 11 | `hero-data.md` | 히어로 데이터 (SO_HeroData → UDataAsset) | §3.1 | `UHeroData : UPrimaryDataAsset` — 이동속도/점프력/공격력 basestat | P0 | — |
| 12 | `passive-data.md` | 패시브 데이터 (SO_PassiveData → UDataAsset) | §3.2 | `UPassiveData` 배열. 런 시작 시 `BP_AbilityComponent` 에 주입 | P1 | — |
| 13 | `platformer-movement.md` | 2D 사이드스크롤 이동 | §4.2 | `BP_PlatformerPawn` — CharacterMovement 확장 BP. 단층 이동 포함 | P0 | — |
| 14 | `camera-2d-sidescroll.md` | 2D 사이드스크롤 카메라 | §4.3 | GameplayCameraSystem (실험적) BP 모드 or 커스텀 `BP_SideScrollCamera`. LookAhead/Deadzone | P1 | — |

---

## 3. Phase 2 — Feature (로그라이크 & 월드 시스템)

> 하데스형 런 구조, 영구 해금, 환경 상호작용.

| # | Slug | 시스템명 | 원문 § | BP 대체 / 구현 힌트 | Priority | Status |
|---|---|---|---|---|---|---|
| 15 | `run-structure.md` | 런 구조 (방/노드) | §7.1 | `BP_RunManager (GameInstance subsystem)` — 노드 그래프, 방 전환 로직 | P1 | — |
| 16 | `room-generator.md` | 방 생성 / 레이아웃 | §7.2 | Data-driven 레이아웃 `URoomLayoutData` + BP 스포너 | P1 | — |
| 17 | `passive-reward-system.md` | 패시브 리워드 선택 | §7.3 | 방 클리어 시 `UPassiveData` 3택 제시, `BP_RewardWidget` | P1 | — |
| 18 | `permanent-unlock.md` | 영구 해금 (나인솔즈형 스킬 진행) | §7.4 | `USaveGame` 파생 BP + 해금 트리 DataAsset | P1 | — |
| 19 | `environment-data.md` | 환경 데이터 (SO_EnvironmentData → UDataAsset) | §3.3 | `UEnvironmentData` — 테마별 타일셋/조명/SFX 프리셋 | P2 | — |
| 20 | `enemy-ai-base.md` | 적 AI 기반 (BehaviorTree or StateTree) | §8.1 | **State Tree 권장** (BP 완전 지원). BehaviorTree 는 BP Task 제한이 있어 2순위 | P1 | — |
| 21 | `enemy-archetypes.md` | 적 아키타입 카탈로그 | §8.2 | `UEnemyData` 배열 + 파생 BP (Grunt / Heavy / Ranged / Elite) | P1 | — |
| 22 | `boss-encounter-corrupt-hero.md` | 부패 히어로 보스전 (기어 몰수 페이오프) | §8.3 | 전용 `BP_Boss_CorruptHero` + Phase State Tree | P2 | — |

---

## 4. Phase 3 — Presentation (UI/피드백/오디오)

> CommonUI + Niagara + Audio 레이어.

| # | Slug | 시스템명 | 원문 § | BP 대체 / 구현 힌트 | Priority | Status |
|---|---|---|---|---|---|---|
| 23 | `hud-combat.md` | 전투 HUD (HP/스태미나/콤보) | §9.1 | CommonUI 기반 `WBP_CombatHUD`. GameplayMessageSubsystem 구독 | P0 | — |
| 24 | `menu-main.md` | 메인 메뉴 | §9.2 | `WBP_MainMenu` + CommonUI 입력 라우팅 | P1 | — |
| 25 | `menu-pause.md` | 일시정지 메뉴 | §9.2 | `WBP_PauseMenu` | P1 | — |
| 26 | `reward-ui.md` | 리워드 선택 UI | §9.3 | `WBP_RewardSelect` — 패시브 3택 카드 UI | P1 | — |
| 27 | `pixel-art-postprocess.md` | 3D→2D 픽셀아트 변환 | §10.1 | Post Process Material + SceneCapture2D 체인. REPLACED 톤 레퍼런스 | P1 | — |
| 28 | `vfx-combat-feedback.md` | 전투 VFX 피드백 | §10.2 | Niagara 시스템 — 히트 스파크, 와프 트레일, 속성 일루미네이션 | P1 | — |
| 29 | `audio-combat-rhythm.md` | 전투 오디오 리듬 레이어 (하이파이 러쉬 식) | §11.1 | MetaSound + `BP_CombatAudioLayer` — BGM 박자 동기 SFX | P2 | — |
| 30 | `audio-ambient.md` | 앰비언트 오디오 | §11.2 | MetaSound 기반 월드 앰비언스 큐 | P2 | — |

---

## 5. Phase 4 — Polish & Live (튜닝, 밸런스, 리텐션)

| # | Slug | 시스템명 | 원문 § | 핵심 에이전트 | Priority | Status |
|---|---|---|---|---|---|---|
| 31 | `balance-tuning-knobs.md` | 밸런스 튜닝 노브 카탈로그 | §12.1 | `economy-designer`, `systems-designer` | P1 | — |
| 32 | `difficulty-curve.md` | 난이도 커브 | §12.2 | `economy-designer`, `level-designer` | P1 | — |
| 33 | `telemetry-events.md` | 텔레메트리 이벤트 정의 | §12.3 | `analytics-engineer` | P2 | — |
| 34 | `accessibility-baseline.md` | 접근성 기본 | — | `accessibility-specialist`, `ux-designer` | P1 | — |
| 35 | `ea-scope-matrix.md` | EA 범위 매트릭스 (3-5h 플레이타임) | §1.4 | `producer`, `game-designer` | P0 | — |

---

## 6. 내러티브/월드 (병행)

> 시스템이 아닌 서사 문서군. `design/gdd/narrative-*` / `design/gdd/world-*` 슬러그 사용.

| # | Slug | 문서 | 원문 § | 담당 | Priority | Status |
|---|---|---|---|---|---|---|
| N1 | `narrative-system.md` | 내러티브 시스템 개관 | §2 | `narrative-director`, `writer` | P0 | — |
| N2 | `narrative-characters.md` | 캐릭터 프로필 (주인공/부패 히어로 등) | §2.2 | `writer`, `narrative-director` | P1 | — |
| N3 | `world-factions.md` | 팩션 / 히어로 조직 | §2.3 | `world-builder` | P1 | — |
| N4 | `world-corruption-lore.md` | 부패/감염원 로어 | §2.4 | `world-builder`, `writer` | P2 | — |

---

## 7. GAS → BP 용어 매핑 (본 인덱스 전역 치환 가이드)

원본 Unity GDD / 일반 UE 문서에서 GAS 용어를 만났을 때 본 프로젝트 번역:

| 원본 (Unity / GAS) | 본 프로젝트 (BP) | 파일 |
|---|---|---|
| `ScriptableObject`, `SO_HeroData` | `UPrimaryDataAsset`, `UHeroData` | `hero-data.md` |
| `MonoBehaviour` | `UActorComponent` / `AActor` BP 파생 | 전역 |
| `GetComponent<T>()` | `Get Component by Class` | 전역 |
| `UAttributeSet` | `BP_AttributeComponent` (ActorComponent) | `attribute-component.md` |
| `UGameplayAbility` | `BP_AbilityComponent` + `UAbilityDataAsset` | `ability-component.md` |
| `UGameplayEffect` | `UEffectDataAsset` | `effect-dataasset.md` |
| `UGameplayCueNotify` | Niagara + BP 이벤트 (GameplayMessageSubsystem) | `vfx-combat-feedback.md` 내 |
| `FGameplayAbilitySpec` | BP 구조체 `FAbilityGrantSpec` | `ability-component.md` 내부 |
| `UAbilityTask` | BP Latent Node / Timer / Timeline / State Tree | 필요 시점마다 |
| `FGameplayTag` / `FGameplayTagContainer` | **그대로 사용** (유일한 GAS 유지 항목) | `gameplay-tag-usage.md` |
| `Static EventBus` (Unity) | `GameplayMessageSubsystem` | 전역 |

---

## 8. 다음 액션

현재 표 기준 **모든 행이 `Status: —`** 이다. 진행 순서는:

1. **Phase 0 (#1~#6)** 스켈레톤 6개 생성 → Draft → Review → Locked
2. Phase 0 완료 후 **수직 슬라이스 프로토타입** (실제 UBG + BP 작업) 착수 권한 부여
3. 병행: **Phase 1 의 #7~#10 (GAS 대체 BP 스택)** 먼저 진행 — 어빌리티가 있어야 Phase 0 의 어트리뷰트/이펙트를 참조할 수 있음
4. 나머지는 Phase 순서대로

각 행의 GDD 파일을 쓸 때는 반드시 `design/CLAUDE.md` 의 **8개 필수 섹션** 표준을 따른다.

---

## 9. 관련 문서

- 프로젝트 개요: [`design/project-overview.md`](../project-overview.md)
- Design 디렉터리 표준: [`design/CLAUDE.md`](../CLAUDE.md)
- 기술 선호: [`.claude/docs/technical-preferences.md`](../../.claude/docs/technical-preferences.md)
- 엔진 버전 고정: [`docs/engine-reference/unreal/VERSION.md`](../../docs/engine-reference/unreal/VERSION.md)
- 플러그인 목록 (GAS 미사용 표기): [`docs/engine-reference/unreal/PLUGINS.md`](../../docs/engine-reference/unreal/PLUGINS.md)
- BP 엔진 리드 에이전트: [`.claude/agents/ue-blueprint-specialist.md`](../../.claude/agents/ue-blueprint-specialist.md)
- 원본 GDD (참고용, 외부 경로): `C:\Users\sk992\Downloads\freeflow_hero_gdd_kr.docx`
