# 노트북 이어가기 — 2026-04-26

> **첫 한 줄**: 이 파일 먼저 읽고 시작하세요. 데스크탑 → 노트북 핸드오프용.
> **마지막 작업**: 데스크탑 (2026-04-26 저녁), M1 3.1 TelegraphComponent 작성 + 커밋. **검증은 미완**.
> **다음 작업**: 3.1 검증 → 통과 시 커밋 → 3.2 진행.

---

## 1. 마지막 커밋 시점 상태

```
efb304b  M1: 3.1 TelegraphComponent — Angelscript Tick 기반 신호 시스템   ← HEAD
cb4952f  M1: 3.0 텔레그래프/가드/반격 GDD 작성
55387b5  M1: 2.4 플레이어 공격 입력 — IA_ComboAttack 재활용으로 흡수
bca0fff  M1: 2.3 보완 — NPC 인스턴스별 HP override (BP 변수 평탄화)
c2b2b9a  M1: 2.3 적 BP + 배치 — BP_SideScrolling_NPC 에 HealthComponent + NPC 3개 배치
a5a89d5  M1: 2.2 AttackComponent 완료
d76d7ee  M1: 0.1 보완 — EditorStartupMap 사이드 스크롤 동기화
71c2453  M1: 2.1 HealthComponent 검증
38ddf14  M1: 0.1 Config 전환
```

브랜치 `master`, 미커밋 변경 없음.

레벨 (`Lvl_SideScrolling`) 상태:
- `NPC_1` / `NPC_2` / `NPC_3` (BP_SideScrolling_NPC, MaxHealth 30/80/150 인스턴스 override)
- `TestDummy_A` (BP_TestDummy, MaxHealth 100)
- `BP_SideScrolling_NPC` 1개 (멀리 7678, 기존 NPC, 무관)

---

## 2. M1 진행 — 체크리스트

### 완료
- [x] 0.1 / 2.1 / 2.2 / 2.3 / 2.4 / 3.0
- [x] 3.1 코드 작성 + 커밋 (efb304b) — **검증 미완**

### 다음 (우선순위 순)
1. **3.1 검증** — Angelscript 컴파일 확인 + Play 로그 검증
2. 3.2 WBP_TelegraphIndicator (머리 위 ! 아이콘 UI)
3. 3.3 GuardComponent
4. 3.4 가드 입력 + 반격
5. 4.1~4.2 처형
6. 5.0~5.4 토큰 AI

---

## 3. 노트북 시작 시 절차

### Step 1. Claude 호출 + 컨텍스트 복구

```
1. ProjectFreeHero 디렉토리에서 Claude 시작
2. 첫 메시지: "/help-resume" 또는 "노트북에서 이어가는 중. handoff 파일 읽고 다음 단계 알려줘"
3. Claude 가 이 파일 + M1.md + 마지막 커밋 자동 확인
```

### Step 2. 에디터 켜기 + Angelscript 컴파일 확인

```
ProjectFreeHero.uproject 더블클릭
   ↓
"Angelscript Compile Errors" 다이얼로그?
```

| 결과 | 다음 행동 |
|---|---|
| 다이얼로그 없음 (에디터 정상 진입) | Step 3 진행 |
| 다이얼로그 뜸 | 에러 메시지 캡처 → Claude 에 전달 → fix |

가능성 있는 에러 + fallback (Claude 에 알려주면 자동 적용):
- `UDELEGATE void FTelegraphEvent();` 안 되면 → `delegate void FTelegraphEvent();` 변경
- `default PrimaryComponentTick.bCanEverTick = true;` 안 되면 → `BeginPlay()` 안에서 `SetComponentTickEnabled(true)` 호출
- `UFUNCTION(BlueprintOverride) void Tick(...)` 안 되면 → Timer 기반으로 변경 (`System::SetTimer` 또는 `World::GetTimerManager()`)

### Step 3. 검증 환경 만들기

Claude 에 "3.1 검증 환경 자동 셋업해줘" 요청 → 자동으로:
1. `BP_TestDummy` 에 `TelegraphComponent` 추가
2. EventGraph 에 `BeginPlay → StartTelegraph(0.8)` 와이어링
3. 컴파일

또는 직접 BP 에디터에서:
```
BP_TestDummy 열기
  ↓
Components → "+추가" → "Telegraph Component" 검색해 추가
  ↓
EventGraph → 우클릭 → "BeginPlay" 추가
  ↓
EventGraph → 우클릭 → "Start Telegraph" 검색 → Health 카테고리 흰색 헤더 항목
  ↓
연결: BeginPlay.then → StartTelegraph.execute
      Get TelegraphComponent → StartTelegraph.Target
  ↓
컴파일 → Ctrl+S
```

### Step 4. Play 검증 (AC1 + AC2)

```
Play 버튼
Output Log 확인:
  Angelscript: Telegraph: Start (duration=0.8)   ← AC1 통과
  ... (정확히 0.8초 대기) ...
  Angelscript: Telegraph: Fire                    ← AC2 통과
```

**통과 조건**:
- 두 줄 1쌍 정확히 (BeginPlay 시점에 한 번)
- 다른 빨간 에러 없음

### Step 5. 통과 후 커밋

Claude 에 "3.1 검증 통과 커밋해줘" 요청. 자동으로:
1. M1.md 의 3.1 항목 [x] 마킹
2. `git commit -m "M1: 3.1 검증 통과 — Tick 기반 신호 시스템 동작 확인"`
3. `git push origin master`

### Step 6. 3.2 진행 결정

3.1 통과 후 옵션:
- A) 즉시 3.2 진행 (UI 위젯)
- B) Physics Warning 별개 이슈 정리 후 3.2
- C) 휴식

---

## 4. 환경 + 핫키 정보

### 입력 매핑 (IMC_SideScroller)

| 키 | 액션 |
|---|---|
| W/A/S/D / Gamepad Left Stick | IA_Move |
| Space / Gamepad A | IA_Jump |
| F / Gamepad X | IA_Interact |
| S / Gamepad Down Stick | IA_Drop |
| **LMB / Gamepad LB** | **IA_ComboAttack** (= 공격) |
| (미구현) | IA_Guard (3.4 항목) |

### Play 시 NPC 위치 (PlayerStart 기준)

```
NPC_2 (-1294.7) ← [PlayerStart -794.7] → TestDummy_A (-494.7) → NPC_1 (-294.7)
                                ↑
                        NPC_3 (위 +400Z)
```

플레이어가 가만히 LB 누르면 안 닿음 (AttackRange 300 < 거리). **이동 후 LB**.

### AttackComponent 튜닝 default

- AttackRange = 300 cm (전방 트레이스 거리)
- AttackRadius = 80 cm (구 반지름)
- Damage = 20 HP
- TraceProfileName = "Pawn"

---

## 5. 알려진 함정 (실수 방지)

### Angelscript
- `static` 키워드 **미지원** — instance method만
- `const` 메서드는 OK (IsDead, IsExecutable 등)
- Hot-reload 후 클래스 ID `_REPLACED_N` 발생 가능 → 에디터 재시작으로 회복

### MCP (Unreal_Engine_Pro_Tools)
- `add_component` "Internal error" 응답이 **false-negative** — 실제로 추가됨. 호출 후 `get_components` 로 재확인 필수
- `add_variable` 의 `instance_editable` / `category` 인자 **적용 안 됨** — BP 에디터에서 직접 public 토글 + Category 설정
- `set_actor_property` 가 BP 변수에 set 시 — 변수가 instance_editable 아니면 메모리만, 디스크 저장 안 됨
- `connect_pins` 의 self/Target 핀 — 자동 와이어링 약함. instance method 호출 시 명시적 wire 필요
- `place_node` "Incomplete or empty response" 응답도 **false-negative** 가능 — `get_detailed_blueprint_summary` 로 재확인

### 레벨 저장
- 인스턴스 변경 (set_actor_property, 액터 spawn/delete) 후 **반드시 Ctrl+S**
- 안 하면 Play 시 디스크 상태로 복귀 → 변경 사항 사라짐

### Physics Warning (별개)
- `NPC.CollisionCylinder Simulate Physics` warning — 무시해도 게임 동작 OK. M1 후속 정리.

---

## 6. 미해결 질문 (3.2 진입 시 결정 필요)

| 질문 | 옵션 | 추천 |
|---|---|---|
| 3.2 위젯 형태 | Sprite / Material / UMG Widget | UMG Widget (CommonUI 호환) |
| 3.3 GuardComponent 부착 위치 | 별도 Component / PlayerController 확장 | 별도 Component (재사용성) |
| 3.4 IA_Guard 입력 | 신설 / 기존 IA 재활용 | 신설 (RMB + Gamepad RB) |

3.2 진입할 때 Claude 에 "3.2 GDD 보고 위젯 옵션 선택지 줘" 식으로 물어보면 됨.

---

## 7. 핵심 파일 위치

```
Script/Core/HealthComponent.as              — UHealth (MaxHealth, ApplyDamage, IsDead, ...)
Script/Gameplay/AttackComponent.as          — UAttack (Range/Radius/Damage, Attack())
Script/Gameplay/TelegraphComponent.as       — UTelegraph (Duration, Start/Cancel, OnFire 등)  ★ 검증 대상

Content/Variant_SideScroller/Blueprints/BP_SideScrollingCharacter.uasset  — 플레이어 BP
Content/Variant_SideScroller/Blueprints/AI/BP_SideScrolling_NPC.uasset    — 적 BP (HC 60→인스턴스 override)
Content/Variant_Combat/Blueprints/BP_TestDummy.uasset                     — 순수 더미 (HC 100)

design/gdd/telegraph-system.md              — 3.0 GDD (8섹션)
design/gdd/systems-index.md                 — 인덱스 (#7 telegraph 등록됨)
production/milestones/M1.md                 — 체크리스트 (3.1 미체크 상태)
production/milestones/M1-tests.md           — 디자이너용 2.2 테스트 가이드

.claude/skills/bp-combat-test/SKILL.md      — BP 전투 테스트 자동화 스킬
```

---

## 8. 빠른 sanity check (노트북 시작 직후)

```bash
cd C:/DEV/UE5/ProjectFreeHero
git status                                 # working tree clean 인지
git log --oneline -5                       # 마지막 커밋 efb304b 인지
git pull origin master                     # 데스크탑 → 노트북 동기화
ls Script/Gameplay/TelegraphComponent.as   # 파일 존재 확인
```

이상 OK면 → 에디터 켜고 Step 2 부터.

---

**막혔을 때**: Claude 에 "이 파일 (`production/handoff/laptop-resume.md`) 다시 읽고 어디까지 진행됐는지 + 다음 단계 알려줘" 라고 하세요. Claude 가 자동으로 컨텍스트 회복.
