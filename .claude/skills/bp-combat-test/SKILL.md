---
name: bp-combat-test
description: "BP 전투 테스트 시나리오 자동 세팅 — 공격자 BP 에 Health/Attack 컴포넌트 추가 + BeginPlay→Attack() 와이어링 + 레벨에 더미 액터 스폰 + 컴파일 검증 + Play 체크리스트. 바이브 모드 5분 루프용. Content Browser·레벨 에디터 수동 조작 없이 M1 2.2 류 테스트 세팅 완료."
argument-hint: "[attacker-bp-path] [dummy-count?] [forward-offset?]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Task
---

## 이 스킬이 하는 일

"공격자 BP + 맞는 더미 + 자동 공격 트리거" 3종 세트를 한 번에 세팅합니다.
M1 체크리스트 2.2 ("AttackComponent 휘두르면 맞은 애한테 데미지 들어가는지") 같은
**BP 셀프 검증 시나리오**에 특화. 에디터에서 BP 열고 / 컴포넌트 드래그 / 그래프
와이어링 / Content Browser 에서 레벨로 드래그 / Save — 이 전체 손작업을 MCP 호출
4~6개로 대체.

**전제**: 언리얼 에디터가 실행 중이고 MCP (`Unreal Engine Pro Tools`) 연결됨.
대상 레벨이 에디터에 열려 있어야 함 (기본 맵이면 자동).

---

## Phase 0: 인자 파싱

`$ARGUMENTS` 파싱:
- `[attacker-bp-path]` (필수) — 예: `/Game/Variant_SideScroller/Blueprints/BP_SideScrollingCharacter`
- `[dummy-count]` (선택, 기본 1) — 1 이면 테스트 1 용, 2 이면 테스트 2 (중복 차단) 용
- `[forward-offset]` (선택, 기본 200) — PlayerStart 기준 X 오프셋 (cm)

**인자 부족 시**: AskUserQuestion 으로 누락된 것만 1회에 묶어 질문. 3개 다 비면
"어떤 BP 를 공격자로 세팅할까요? (예: /Game/.../BP_MyChar)" 1문장만 던지고 나머지는 기본값.

---

## Phase 1: 사전 점검 (읽기 전용, 빠름)

다음 3가지를 **병렬** 로 호출:

1. `mcp__Unreal_Engine_Pro_Tools__blueprint action=get_components blueprint_path=<attacker>`
2. `mcp__Unreal_Engine_Pro_Tools__level_actor action=get_level_info`
3. `mcp__Unreal_Engine_Pro_Tools__level_actor action=get_actors_by_class class_filter="PlayerStart"`

**판정**:
- (1) 결과에서 `UHealthComponent`, `UAttackComponent` 존재 여부 → Phase 2 스킵 가능 판단
- (2) `world_name` 이 `Config/DefaultEngine.ini` 의 `EditorStartupMap` 과 다르면
  사용자에게 "현재 열린 맵은 {world_name} 입니다. 계속할까요?" 1회 확인 후 진행
- (3) PlayerStart 목록 비어있으면 fallback location `[0, 0, 0]` + 경고 로그

---

## Phase 2: 컴포넌트 추가 & BeginPlay 와이어링 (Step 1 자동화)

**이미 세팅된 BP 면 이 Phase 전체 스킵**.

### 2.1 누락 컴포넌트 추가

`get_components` 결과 기준:
- `UHealthComponent` 없으면 → `action=add_component component_class="UHealth" component_name="HealthComponent"`
- `UAttackComponent` 없으면 → `action=add_component component_class="UAttack" component_name="AttackComponent"`

> **노트**: `UHealthComponent` 풀네임 대신 `UHealth` 를 쓰는 건 현재 MCP 구현의 관찰된
> 동작 (fuzzy match + `Component` 자동 접미). 풀네임은 "Internal error" 반환.

### 2.2 Attack 노드 배치 & 와이어링

1. `discover_nodes query="Attack"` → `fn.UAttackComponent.Attack` 핸들 확보
2. `discover_nodes query="AttackComponent"` → `var.get.AttackComponent` 핸들 확보
3. `place_node handle="fn.UAttackComponent.Attack" x=800 y=0`
4. `place_node handle="var.get.AttackComponent" x=560 y=80`
5. **BeginPlay 체인 끝 탐색**:
   - `get_detailed_blueprint_summary graph_name="EventGraph"` 호출
   - 출력에서 `BeginPlay` 이벤트 (한국어 로캘은 `BeginPlay 이벤트`) 찾기
   - `-> (then) ->` 따라 체인 끝까지 이동. 마지막 impure 노드의 이름을 추출
   - 로컬라이즈된 이름이면 영문명도 같이 시도 (예: `Bind Event to Movement Mode Changed Delegate`)
6. `connect_pins from_node="<체인 끝 노드 이름>" from_pin="then" to_node="Attack" to_pin="execute"`
7. `connect_pins_bulk` 로 `Get AttackComponent.AttackComponent → Attack.self` 연결
8. `compile_blueprint with_validation=true` 호출
   - `error_count > 0` 이면 에러 메시지 원문 출력하고 **즉시 중단**. 사용자 보고.

---

## Phase 3: 더미 스폰 (Step 2 자동화)

PlayerStart 위치 `[px, py, pz]` 기준:

```
for i in 1..dummy_count:
    label  = "Dummy_" + chr(ord('B') + i - 1)   # Dummy_B, Dummy_C, ...
    loc    = [px + forward_offset * i, py, pz]
    rot    = [0, 180, 0]                        # [Pitch, Yaw, Roll] — Yaw=180 플레이어 쪽 바라보게
    spawn_actor(actor_class=attacker_bp_path, actor_label=label, location=loc, rotation=rot)
```

> **주의 — 알려진 한계**:
> 같은 BP 를 복제하므로 **더미도 자기 BeginPlay 에서 Attack() 호출**.
> M1 테스트 1 (한 대 맞는지) 은 통과하지만, 더미는 "순수 맞는 쪽" 이 아님.
> 필요하면 추후 `BP_TestDummy` (Health 만 붙은 별도 BP) 만들어 주입. 이 스킬은
> "M1 가장 빠른 방법" 지침만 구현.

**actor_class 경로**: `_C` 접미사 **없이** 순수 BP 경로 전달.
`/Game/.../BP_SideScrollingCharacter.BP_SideScrollingCharacter_C` 는 실패함.

**검증**: 각 스폰 후 `get_actor_details actor_label=<label>` 로 location 확인.
스폰 실패 시 부분 리포트 (성공 N개, 실패 M개).

---

## Phase 4: 보고 (vibe 스타일)

```
✅ 완료: {BP 이름} 전투 테스트 세팅
📁 변경:
   - {BP 이름} (컴파일됨, 0 errors)
   - {레벨 이름} (Dummy_B ... 스폰, Dirty — 저장 필요)
🔍 검증: compile 0 errors / dummy N개 스폰 완료
🎯 다음: 에디터에서 Ctrl+S 로 레벨 저장 후 Play → Output Log 확인:
   Hit: Dummy_B -{Damage} HP
   HealthComponent: -{Damage} → {Cur}/{Max}
```

---

## Phase 5: 알려진 한계 & 회피책

| 한계 | 회피 |
|---|---|
| 복제 더미도 공격함 | 순수 더미 필요 시 별도 `BP_TestDummy` 생성 후 `attacker` 인자를 그걸로 지정 |
| 레벨 자동 저장 불가 | 사용자 Ctrl+S 필요. MCP 범위 밖 |
| BeginPlay 체인 끝 탐색 로캘 의존 | 영/한 양쪽 이름 순차 시도. 실패 시 사용자에게 "체인 끝 노드 이름 알려주세요" 질문 |
| Angelscript 클래스 이름 fuzzy | `UHealthComponent` 대신 `UHealth`, `UAttackComponent` 대신 `UAttack` 사용 (현 MCP 관찰 동작) |
| 같은 공격자 BP 를 여러 번 호출 | Phase 1 의 `get_components` 로 중복 감지 후 스킵 |

---

## Phase 6: 바이브 모드와의 관계

이 스킬은 **바이브 모드 기본 규칙 준수**:
- CCGS 의식 5단계 생략 — 바로 실행
- 서브에이전트 자동 스폰 없음 (Read/Glob/Grep/Task 만 허용)
- 사용자 확인은 "인자 누락 1회" 와 "컴파일 에러 시" 만
- 실행 후 자동 검증 (`compile_blueprint with_validation=true`, `get_actor_details`)

"바이브 모드 활성" 상태에서 사용자가 아래 뉘앙스로 요청하면 자동 제안 대상:
- "전투 테스트 세팅"
- "공격 더미 배치"
- "BeginPlay 에서 Attack 호출되게 해줘"
- "Step 1+2 해줘" (M1 컨텍스트)

제안 형식: "`/bp-combat-test <BP경로>` 로 한 번에 할 수 있어요. 쓸까요?"
사용자 "ㅇ" 류 짧은 승인이면 바로 실행.

---

## 검증 방법 (스킬 자체)

1. **Dry-run 감지**: 이미 세팅된 BP 에 재실행 → Phase 2 스킵 + Phase 3 만 실행되는지
2. **신규 BP**: 컴포넌트 없는 Character 상속 BP 만들어 돌려보고 Phase 2 정상 작동
3. **로그 검증**: Play 후 Output Log 에 `Hit:` + `HealthComponent:` 두 줄 1쌍 이상

---

## Verdict

정상 종료: `DONE — bp-combat-test: {BP} 세팅 완료, {N}개 더미 배치, 저장 대기`
부분 실패: `PARTIAL — Phase X 중단, 에러: {요약}`
