# Telegraph / Guard / Counter System — 간이 GDD (M1)

> **상태**: M1 코어 전투 루프의 시각적 신호 + 타이밍 가드 + 보상 반격
> **명세 범위**: 의식 모드(M1.md 3.0) 5섹션 — 본 문서가 3.1~3.4 구현의 단일 출처
> **작성일**: 2026-04-26
> **튜닝 정책**: 모든 수치는 BP/Angelscript UPROPERTY(EditAnywhere) 로 인스턴스 편집 가능. 디자이너가 Details 패널에서 즉시 조정.

---

## 1. Overview

적이 강한 공격 직전, **머리 위 빨간 ! 아이콘** 으로 "지금 공격 시작!" 신호를 0.8초간 표시한다.
플레이어는 그 0.8초 안에 **가드(우클릭/RB)** 를 누르면 일반 가드 → 데미지 감소.
신호의 마지막 0.15초 윈도우에 가드 시작하면 **Perfect Guard** → 다음 공격에 **반격 ×1.5** 보너스.

> **게임 톤**: 인왕(Nioh) 스타일 도전적 액션. "보고 → 판단 → 정확히 누르기" 루프가 핵심 재미.

---

## 2. Detailed Rules

### 2.1 텔레그래프 사이클 (적 입장)

1. 적의 AI 가 강한 공격을 결정하면 `TelegraphComponent.StartTelegraph()` 호출
2. `OnTelegraphStart` 델리게이트 broadcast → 머리 위 ! 아이콘 표시 (`bShowHeadIcon=true`)
3. 내부 타이머 `TelegraphDuration`(0.8s) 카운트다운
4. 종료 시 `OnTelegraphFire` broadcast → 적의 실제 `AttackComponent.Attack()` 호출
5. 도중 외부 이벤트(피격, 사망, 이탈)로 `CancelTelegraph()` 호출 시 `OnTelegraphCancelled` broadcast → 공격 안 함

### 2.2 가드 사이클 (플레이어 입장)

1. 플레이어가 IA_Guard (RMB / Gamepad RB) 를 **누름** → `GuardComponent.StartGuard()` → `bIsGuarding=true`, `GuardStartTime` 기록
2. **뗌** → `EndGuard()` → `bIsGuarding=false`
3. 적의 `OnTelegraphFire` 이벤트가 발생할 때:
   - `bIsGuarding == false` → 막 못 함, 풀 데미지
   - `bIsGuarding == true` 이고 `(Now - GuardStartTime) > PerfectGuardWindow` → **일반 가드** → 데미지 50% 감소 + `OnHitBlocked` broadcast
   - `bIsGuarding == true` 이고 `(Now - GuardStartTime) <= PerfectGuardWindow` → **Perfect Guard** → 데미지 0 + `OnPerfectGuard` broadcast

### 2.3 Perfect 반격

1. `OnPerfectGuard` 델리게이트 → 플레이어 BP 에서 자동 카운터어택 발사
2. 카운터어택은 `AttackComponent.Attack()` 의 변형 — `CounterDamageMultiplier` 만큼 데미지 강화 (BaseDamage × 1.5 = 30)
3. **M1 단계 단순화**: 카운터 모션·이펙트 없이 즉시 발사. 추후 Polish 단계에 모션·VFX 추가.

### 2.4 텔레그래프 큐 (M1 단순화)

- 적 한 명당 동시에 1개 텔레그래프만 활성. 진행 중 또 호출되면 무시.
- 여러 적이 동시에 텔레그래프 → 각자 독립 (=토큰 시스템 5.x 에서 동시성 제한)

---

## 3. Formulas

| 수식 | 표현 |
|---|---|
| Perfect 판정 | `(Now − GuardStartTime) ≤ PerfectGuardWindow` |
| 일반 가드 데미지 | `IncomingDamage × (1 − GuardDamageReduction)` (M1 default 50% 감소 = 0.5 곱) |
| Perfect 가드 데미지 | `0` (완전 무효) |
| 반격 데미지 | `BaseAttackDamage × CounterDamageMultiplier` |
| 텔레그래프 잔여시간 | `TelegraphDuration − (Now − TelegraphStartTime)` |

기본값 적용 시 예시:
- 적 일반 공격(20) → 가드 미스: 20 데미지
- 적 일반 공격(20) → 일반 가드: `20 × (1−0.5) = 10` 데미지
- 적 일반 공격(20) → Perfect 가드: `0` 데미지 + 반격 `20 × 1.5 = 30` 데미지

---

## 4. Tuning Knobs (= EditAnywhere 퍼블릭 변수)

> 모든 값은 Component 의 UPROPERTY(EditAnywhere, BlueprintReadWrite) 로 노출. 인스턴스별 override 가능.

### 4.1 `UTelegraphComponent` (적에 부착)

| 변수 | 타입 | Default | Category | 의미 | 늘리면? |
|---|---|---|---|---|---|
| `TelegraphDuration` | float | **0.8** | Telegraph | 신호 ~ 발사 시간 (초) | 가드 쉬움, 느린 게임 |
| `bShowHeadIcon` | bool | **true** | Telegraph\|UI | 머리 위 ! 아이콘 표시 | OFF 시 시각 신호 없음 (오디오만) |
| `bShowGroundRing` | bool | **false** | Telegraph\|UI | 바닥 빨간 링 표시 | true 시 둘 다 표시 (정보 풍부) |
| `OnTelegraphStart` | Delegate | — | Telegraph\|Events | UI 활성화 트리거 | — |
| `OnTelegraphFire` | Delegate | — | Telegraph\|Events | 실제 공격 발사 트리거 | — |
| `OnTelegraphCancelled` | Delegate | — | Telegraph\|Events | UI 비활성화 트리거 | — |

### 4.2 `UGuardComponent` (플레이어에 부착)

| 변수 | 타입 | Default | Category | 의미 | 늘리면? |
|---|---|---|---|---|---|
| `PerfectGuardWindow` | float | **0.15** | Guard | Perfect 판정 윈도우 (초) | Perfect 쉬움 |
| `GuardDamageReduction` | float | **0.5** | Guard | 일반 가드 데미지 감소율 (0~1) | 가드 안전 ↑ |
| `CounterDamageMultiplier` | float | **1.5** | Guard | Perfect 시 반격 배율 | Perfect 보상 ↑ |
| `bIsGuarding` | bool (read-only at runtime) | false | Guard\|State | 현재 가드 중 여부 | — |
| `OnPerfectGuard` | Delegate | — | Guard\|Events | 반격 트리거 | — |
| `OnHitBlocked` | Delegate | — | Guard\|Events | 일반 가드 시 효과음/VFX 트리거 | — |

### 4.3 적 BP 의 인스턴스별 텔레그래프 시간

같은 적 클래스라도 인스턴스별 다른 시간으로 만들고 싶으면 — 적 BP 의 `TelegraphDuration` 인스턴스 override (예: 보스는 1.2s, 졸병은 0.6s).

---

## 5. Acceptance Criteria (AC)

| ID | 조건 | 검증 방법 |
|---|---|---|
| **AC1** | 적 BP 에서 `StartTelegraph()` 호출 시 `OnTelegraphStart` 발행 + 0.8초간 머리 위 아이콘 표시 | Play 로그 `Telegraph: Start (duration=0.8)` + 화면에 ! 아이콘 |
| **AC2** | 0.8초 후 `OnTelegraphFire` 1회 발행 + 적이 실제 공격 | 로그 `Telegraph: Fire` + `Hit:` 로그 1회 |
| **AC3** | `OnTelegraphFire` 도중 `CancelTelegraph()` 호출 → `OnTelegraphCancelled` 발행 + 공격 안 함 | 로그 `Telegraph: Cancelled`, 이후 `Hit:` 로그 없음 |
| **AC4** | 플레이어가 텔레그래프 외 시점 가드 → `OnHitBlocked` 발행, 데미지 50% 감소 | 로그 `Guard: Blocked`, HP 감소량이 정상의 절반 |
| **AC5** | 플레이어가 마지막 0.15s 윈도우 가드 → `OnPerfectGuard` 발행, 데미지 0 | 로그 `Guard: Perfect`, HP 변동 없음 |
| **AC6** | Perfect 가드 후 자동 반격 → 적 HP `BaseDamage × 1.5` 감소 | 로그 `Counter: -30 HP` 또는 `Hit: enemy -30 HP` |
| **AC7** | 모든 Tuning Knobs 가 인스턴스 Details 패널에서 편집 가능 (검색 "Telegraph" / "Guard" 시 카테고리 노출) | 에디터에서 적/플레이어 액터 클릭 → Details 검색 |

---

## 6. Dependencies

- **2.2 AttackComponent**: `OnTelegraphFire` 후 `Attack()` 호출. 반격 시 `Damage × CounterDamageMultiplier` 사용
- **2.1 HealthComponent**: 가드 시 `ApplyDamage(Reduced)` 호출
- **3.2 WBP_TelegraphIndicator**: `OnTelegraphStart`/`OnTelegraphFire`/`OnTelegraphCancelled` 구독, 머리 위 아이콘 토글
- **5.x 토큰 AI**: 같은 그룹의 토큰 보유자만 `StartTelegraph` 호출 → 동시 공격자 1명 제한

---

## 7. Out of Scope (M1 단순화)

- 카운터 모션/애니메이션 — Polish 단계
- Perfect 가드 VFX/사운드 — Polish 단계
- 장시간 가드 시 스태미나 소모 — M2+
- 가드 방향 (좌/우/위) 구분 — M2+
- 텔레그래프 큐잉 (여러 신호 대기열) — M2+

---

## 8. 변경 이력

| 날짜 | 변경 | 사유 |
|---|---|---|
| 2026-04-26 | 초안 작성 (의식 모드 결정: 0.8s/0.15s/HeadIcon/×1.5) | M1 3.0 항목 |
