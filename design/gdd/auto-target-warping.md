# Auto-Target Warping System

> **Phase:** 0 — Foundation
> **Priority:** P0 (프리플로우 존재 이유)
> **Status:** Draft
> **Owner:** Gameplay (BP) — `ue-blueprint-specialist`
> **Author:** 김다훈 · Drafted 2026-04-21

## 1. Overview

`Auto-Target Warping System` 은 플레이어의 탭 입력에 반응하여 현재 전장에서
**가장 가까운 유효 적**을 자동 선택하고, 해당 적 근처로 캐릭터를 **고속 대시 이동**
시키는 시스템이다. 한 번 선택된 적은 죽거나 사거리 이탈 전까지 **락온 유지**
되며, 락온 해제 시점에 다음 적으로 자동 체인된다. 프리플로우 전투 루프의
축이 되는 시스템이며, 탭 연타만으로 "적 사이를 날아다니는 체감"을 만들어낸다.

## 2. Player Fantasy

> "탭 연타 한 번만으로 5명이 내 주위에 있을 때 하나씩 정확히 꺼꾸러뜨리고,
>  다음 적으로 순식간에 날아가는 감각."

- **흐름 유지**: 대상 선택을 플레이어가 의식하지 않음. 탭 리듬에만 집중.
- **체인 감**: 적 A 사망 순간 B로 자동 워프 → "내가 학살자처럼 돌아다닌다" 체감.
- **위협 감**: 락이 걸리면 그 적을 끝장낸다는 확신 → 수동 조준 스트레스 제거.
- **레퍼런스 감각**: 배트맨 아캄(체인 느낌) + REPLACED(루트 이동 시각) + 샤오샤오(스피드감).

## 3. Detailed Rules

### 3.1 상태 머신 (TargetLockState)

```
NoTarget  ──[탭 입력]──▶  Acquiring  ──[후보 있음]──▶  Locked(T)
   ▲                       │                             │
   │                       └──[후보 없음]─▶ NoTarget      │
   │                                                      │
   │◀──[T 사망]──────────────────────────────────────────┤
   │◀──[거리(T) > MaxLockDistance]──────────────────────┤
   │◀──[LockIdleTimeout 초과]────────────────────────────┘
```

- `Acquiring` 은 1프레임 내 완료. 사실상 즉시 상태.
- `Locked` 상태에서 **추가 탭**은 T에 대한 공격 (워프 필요 여부는 거리 판단).

### 3.2 탭 입력 처리 플로우

1. 탭 입력 감지 → `CombatInputHandler` 가 이 시스템에 쿼리.
2. 현재 `TargetLockState` 확인:
   - `NoTarget` → `FindCandidate()` 호출 → 후보 있으면 `Locked(T)` 전이.
   - `Locked(T)` → T가 **플레이어 공격 사거리(`AttackReach`) 밖** 인지 체크.
     - 밖이면 `Warp(T)` → 도착 후 공격 모션.
     - 안이면 `Warp` 없이 그 자리 공격 모션.
3. 공격 모션 종료 → `TargetLockState` 유지 → 다음 탭 대기.

### 3.3 후보 탐색 (FindCandidate)

1. 플레이어 위치 기준 **반경 `MaxWarpDistance`** 내 모든 Pawn 수집.
2. `GameplayTag: Enemy.Alive` 태그 보유만 필터링.
3. Line Trace (`ECC_Visibility`) 로 벽 차단 검사 — 막힌 적 제외.
4. 낭떠러지 검사 — 적 발 밑에 Ground 콜리전 없으면 제외.
5. 각 후보의 **스코어** 계산 (§4.1 수식).
6. 최저 스코어 적 = `T`. 동점 시 `FindCandidate()` 호출 프레임의 Actor ID 순.

### 3.4 워프 이동 (Warp)

- 이동 시간: `WarpDurationSeconds` (기본 0.08s).
- 이동 경로: 플레이어 현재 위치 → T의 `AttackReach` 경계 (T 몸에 박지 않음).
- 이동 곡선: `Easing: EaseOutQuad` (시작 빠름, 도착 감속).
- **입력 잠금**: 워프 중 다른 입력은 큐잉 (버림 없음). 도착 시 큐의 첫 입력 소비.
- **물리**: 충돌 무시 (Ghost Mode). 벽은 §3.3에서 이미 필터링됨.
- **시각**: `WarpVFX_Dash` 재생. B랭크 이상이면 잔상 프레임 추가
  (구현 경계는 `StyleRankSystem` 소관, 본 시스템은 이벤트만 발행).

### 3.5 락 해제 (Lock Invalidation)

다음 **세 조건 중 하나**만 만족해도 즉시 `NoTarget` 전이:

| 조건 | 체크 주기 | 비고 |
|---|---|---|
| `T` Pawn 이 `GameplayTag: Enemy.Alive` 상실 | T의 OnTagChange 이벤트 | 즉시 재탐색. 체인 워프 포인트. |
| `Distance(Player, T) > MaxLockDistance` | 매 탭 입력 시 + 0.1s Timer | 일반 플레이에선 거의 발생 X |
| 마지막 탭으로부터 `LockIdleTimeout` 초 경과 | 0.5s Timer | 전투 이탈 판정 |

### 3.6 홀드(넉백) 입력과의 경계

**본 시스템은 탭 전용**. 홀드(넉백)는 `CombatInputHandler` 가 다른 경로로 처리.
홀드 발동 시 **락 상태는 유지**되되 타겟 재선정은 하지 않음. 홀드 후 탭으로
복귀하면 이전 T에게 계속 공격.

### 3.7 동시 공격 대상 수 (MaxAttackTargets)

`MaxAttackTargets = 1` (기본). 이 값은 `DA_AutoTargetConfig` 데이터 에셋에서
변경 가능. 예: 2 이상으로 설정 시 워프 도착 시점에 T 반경 내 추가 적에게
동시 히트박스 발사 (향후 AoE 패시브를 위한 확장점).

## 4. Formulas

### 4.1 타겟 스코어 (Score)

```
Score(enemy) = DistanceScore(enemy) + AngleTiebreaker(enemy)

DistanceScore(e)     = Distance(Player, e)               // 0 ~ MaxWarpDistance
AngleTiebreaker(e)   = AngleFromFacing(e) * ε            // ε = 0.001
                       // 단, 최저 스코어와 |ΔScore| < 1.0 인 후보들끼리만 적용
                       // (순수 최단거리 동점일 때만 각도가 개입)
```

- 단위: Unreal Units (uu). 1 uu = 1 cm.
- `AngleFromFacing(e)` 는 degree, 0° = 정면, 180° = 후방.
- ε 덕분에 거리 차이가 1uu 이상이면 **각도 무시**. 동점일 때만 정면 우선.

### 4.2 사거리 속성 보너스

```
EffectiveMaxWarpDistance = MaxWarpDistance * ElementRangeMultiplier

ElementRangeMultiplier:
  전기(Electric) = 1.3    // +30% (광클 강화 빌드)
  아이스(Ice)     = 1.0
  파이어(Fire)    = 1.0
```

`EffectiveMaxLockDistance = EffectiveMaxWarpDistance * 1.5`

### 4.3 워프 도착 위치

```
ArrivalPos = T.Location - (DirectionFromPlayerToT_Normalized * AttackReach)
```

`AttackReach` 는 플레이어 기본 공격 사거리 상수 (150 uu 제안, `PlayerCombat` 소관).

## 5. Edge Cases

| 상황 | 처리 |
|---|---|
| 사거리 내 적 0명 | 탭 입력 → 제자리 공격 모션 (워프 없음). `CombatInputHandler` 가 `NullSwing` 이벤트 발행. |
| 모든 후보가 벽에 가려짐 | `FindCandidate()` 실패 → 제자리 공격 (위와 동일). |
| 모든 후보가 낭떠러지 너머 | 동일 처리. 2D 사이드스크롤에서 실수 낙사 방지 최우선. |
| 워프 중 플레이어 피격 | `HitReactionSystem` 이 락 상태 **유지한 채** Hit 상태 삽입. 워프는 중단되지 않음 (0.08s 이므로 무시 가능). 단 `Launch` 판정이면 락 해제. |
| 워프 도착 순간 T 사망 (다른 적이 공중 공격 등) | `Locked → NoTarget` 즉시 전이. 다음 탭에서 재탐색. |
| T가 동결(아이스 히어로) 상태 | 락 유지. 동결 적도 타겟으로 정상 기능. |
| T가 아머형 (넉백 강제) | 탭 연타로 워프는 되지만 **공격 데미지 0**. `EnemyArmor` 컴포넌트가 차단. 플레이어는 홀드로 전환 필요. |
| 플레이어가 점프/낙하 중 | 워프 허용. Y축 성분 포함하여 `ArrivalPos` 계산. |
| 멀티프레임 탭 (60fps 기준 2프레임 내 2회) | 2회째 입력은 큐잉. 워프 완료 후 즉시 소비. |
| 락된 T가 보스 페이즈 전환으로 무적 | 락 유지되지만 공격 무효. 플레이어 입력은 정상. (보스가 `Invulnerable` 태그). |

## 6. Dependencies

### 6.1 의존 시스템 (Incoming)

- `CombatInputHandler` (P0) — 탭 입력 수신처, `NullSwing` 이벤트 발행.
- `PlayerStateMachine` (P0) — `Warp` / `Attack` / `Idle` 상태 트리거.
- `HitReactionSystem` (P0) — 락 해제 조건(`Launch`) 공유.

### 6.2 독립 시스템 (Peer, 상호 간섭 없음)

- `GroupTokenManager` (P0) — **독립**. 본 시스템의 타겟 선택은 토큰 상태를
  참조하지 않는다. 토큰은 "누가 공격 가능" 을, 본 시스템은 "플레이어가
  어디로 워프" 를 결정. 두 시스템은 `PlayerStateMachine` 에서만 합류.
- `GameFeelManager` (P0) — 워프 도착 시 히트스톱/셰이크 요청만 발행.

### 6.3 후행 시스템 (Outgoing, 본 시스템이 이벤트만 내보냄)

- `StyleRankSystem` (P1) — 워프 체인 발생 시 `OnWarpChain` 이벤트로 랭크 게이지 입력.
- `PostProcessController` (P1) — B랭크+ 에서 잔상 요청.
- `HeroAssistSystem` (P2) — 연쇄 처치 조건 판정에 이벤트 사용.

### 6.4 데이터

- `DA_AutoTargetConfig` (PrimaryDataAsset) — 아래 Tuning Knobs 전부 저장.
- `UHeroData` — `ElementRangeMultiplier` 조회용.
- `GameplayTag: Enemy.Alive`, `Enemy.Armor`, `Enemy.Frozen`, `Invulnerable`.

## 7. Tuning Knobs

`DA_AutoTargetConfig` 에서 노출:

| 변수 | 초기값 | 범위 | 설명 |
|---|---|---|---|
| `MaxWarpDistance` | 1000 uu | 200~3000 | 워프 가능한 기본 사거리. |
| `MaxLockDistance` | 1500 uu (= `MaxWarpDistance` × 1.5) | 자동 연동 또는 수동 | 락 유지 사거리. 넘으면 해제. |
| `WarpDurationSeconds` | 0.08 | 0.0~0.3 | 대시 이동 시간. 0이면 순간이동. |
| `WarpEasing` | `EaseOutQuad` | enum | 곡선. Linear/EaseIn/EaseOut/EaseInOut. |
| `MaxCandidateCount` | 5 | 1~20 | FindCandidate 가 스코어 계산할 최대 후보 수. 성능 안전장치. |
| `AngleTiebreakerEpsilon` | 0.001 | 0.0001~0.01 | 각도 가중치. 0 이면 순수 거리. |
| `MaxAttackTargets` | 1 | 1~∞ | 도착 시점 동시 히트 적 수. 데이터로 드리블 가능. |
| `LockIdleTimeout` | 2.0s | -1 (무한) ~ 10 | 탭 끊김 타임아웃. |
| `AttackReach` | 150 uu | 50~500 | 도착 시 T와의 간격. `PlayerCombat` 과 동기화. |
| `ElementRangeMultiplier.Electric` | 1.3 | 1.0~2.0 | 전기 히어로 보너스. |
| `ElementRangeMultiplier.Ice` | 1.0 | 1.0~2.0 | 아이스. |
| `ElementRangeMultiplier.Fire` | 1.0 | 1.0~2.0 | 파이어. |

## 8. Acceptance Criteria

### 8.1 자동 (유닛 / 기능 테스트, BLOCKING)

- [ ] **AC-1**: 반경 1000uu 내 적 1명이 있을 때 탭 입력 → 0.08s 내 해당 적 근처 도착.
- [ ] **AC-2**: 반경 내 적 3명(거리 300/500/800) 배치 → 탭 → 거리 300 적에 락.
- [ ] **AC-3**: 락된 적 사망 → 다음 탭에서 자동 재탐색, 다음 후보로 체인 워프.
- [ ] **AC-4**: 락된 적이 플레이어로부터 1500uu 초과 이동 → 락 자동 해제.
- [ ] **AC-5**: 마지막 탭 후 2.1s 동안 입력 없음 → 락 자동 해제.
- [ ] **AC-6**: 사거리 내 적 0명 → 탭 입력이 제자리 공격 모션만 발동 (`NullSwing` 이벤트 1회).
- [ ] **AC-7**: 벽 뒤의 적 1명, 개활지 적 1명 동시 존재 → 개활지 적 락 (더 가까운 벽 뒤 적 무시).
- [ ] **AC-8**: 낭떠러지 너머 적 1명, 같은 층 적 1명 → 같은 층 적 락.
- [ ] **AC-9**: `MaxAttackTargets = 3` 설정 → 도착 시점 T 반경 내 최대 3명에 히트박스 전달.
- [ ] **AC-10**: 전기 히어로 장착 → `EffectiveMaxWarpDistance = 1300uu` 로 확장 확인.

### 8.2 수동 (체감, ADVISORY)

- [ ] **AC-F1**: 탭 연타 10회로 잡몹 5명 1스테이지 완주 → 흐름 끊김 없는 느낌.
- [ ] **AC-F2**: 워프 체인이 "날아다닌다" 처럼 보이는가 (REPLACED 레퍼런스 대조).
- [ ] **AC-F3**: 락된 적 사망 순간 다음 워프까지의 지연이 자연스러운가 (0.08s + 0 대기).
- [ ] **AC-F4**: 플레이어가 "내가 조준 안 했는데 맞게 가네" 체감하는가.

### 8.3 데이터 검증

- [ ] `DA_AutoTargetConfig` 의 12개 노브 값 변경 시 플레이 중 핫리로드 반영
  (단, 에디터 전용 Dev 플래그 켰을 때만).

---

## 구현 메모 (BP 레이아웃, 정보성)

| 자산 | 경로 | 역할 |
|---|---|---|
| `BP_AutoTargetComponent` | `Content/Blueprints/Core/Combat/` | 이 시스템의 메인 액터 컴포넌트. 플레이어에 부착. |
| `DA_AutoTargetConfig` | `Content/DataAssets/Combat/` | §7 튜닝 노브 저장. |
| `BPI_Targetable` | `Content/Blueprints/Interfaces/` | 적 Pawn 이 구현. `GetTargetPriorityTag()` 제공. |
| `BP_WarpMoveTask` | `Content/Blueprints/Core/Combat/Tasks/` | 0.08s 이징 이동 처리. `AbilityComponent` 태스크 호환. |

> **C++ 미사용**. 위 자산은 전부 BP. `ue-blueprint-specialist` 리뷰 대상.

## References

- 원본 GDD §3.1, §3.2 Warp 슬롯, §3.5 P0 목록.
- 레퍼런스 게임: 배트맨 아캄, REPLACED, 샤오샤오.
- 관련: `player-state-machine.md` (다음 GDD), `group-token-ai.md` (P0 병행).

## Changelog

- 2026-04-21 · v0.1 · 초안 · 김다훈
