# Angelscript + UBG MCP 수동 검증 가이드

> **목적:** 에디터에서 직접 하나씩 눌러보면서 "Angelscript가 BP와 연동되고, MCP가 이걸 알아본다"를 체감 확인.
> **소요 시간:** 5–10분
> **전제:** UE 에디터 이미 실행 중, 이 저장소(`cb9b65c` 이후 master) 동기화 완료.

---

## 0. 체크리스트 한눈에

| 단계 | 확인할 것 | 정상이면 |
|---|---|---|
| ① BP 그래프 열기 | `/Game/BP_TestActor` EventGraph에 5개 노드 배치됨 | Angelscript 함수가 BP에서 호출 가능 |
| ② Details 패널 | Health 컴포넌트 → MaxHealth/CurrentHealth 숫자 편집 가능 | Angelscript `UPROPERTY` 노출 |
| ③ PIE 실행 | Output Log + 화면에 메시지 2종 표시 | Angelscript 코드가 실제로 게임에서 돈다 |
| ④ Hot-reload | `.as` 저장만 해도 2초 안에 반영 | 이터레이션 빠름 (C++ 재빌드 불필요) |
| ⑤ MCP로 변경 | Claude Code가 BP/컴포넌트 만지는 거 재현 | UBG MCP가 Angelscript 인식 |

---

## ① BP 그래프 확인

1. **Content Browser** → `Content/BP_TestActor` 더블클릭
2. 상단 탭에서 **Event Graph** 선택
3. 보이는 것:
   ```
   [Event BeginPlay] ─► [Apply Damage] ─► [Print String]
                            ▲                  ▲
                       [Health ─ Get]          │
                            ▲                  │
                            └─► [Get Health Percent] ─► [Conv Double To String]
   ```
   - `Apply Damage` 노드 우측: `Damage Amount = 25.0`
   - `Get Health Percent` 노드: 초록색(Pure)
4. **좌측 My Blueprint 패널** → Components → `Health (UHealthComponent)` 확인

**✅ 성공 기준**: "Apply Damage", "Heal", "Get Health Percent", "Is Dead" 네 함수 전부 우클릭 컨텍스트 메뉴에서 Health 카테고리로 검색됨.

---

## ② Details 패널에서 Angelscript 프로퍼티 편집

1. Components 패널에서 `Health` 선택
2. 우측 **Details** 패널 → **Health** 섹션 확장
3. 보이는 것:
   - `Max Health`: `100.0` (편집 가능)
   - `Current Health`: `100.0` (편집 가능)
4. `Max Health`를 `200.0`으로 변경해보기 → 입력창에 반영됨
5. **컴파일(F7)** → 0 errors

**✅ 성공 기준**: Angelscript에서 정의한 `UPROPERTY`가 C++ 클래스처럼 Details에 나타남.

---

## ③ PIE(Play In Editor) 실행

1. 에디터 상단 Toolbar → **Play** (▶, 단축키 Alt+P)
   - 현재 열린 레벨이 비어있으면 `BP_TestActor`를 Content Browser에서 Viewport로 드래그해서 배치한 후 Play
2. Play 직후 관찰:
   - **Viewport 상단 왼쪽** (화면 프린트): `0.75` (숫자 4–5초간 표시)
   - **Output Log** (Window → Output Log): `LogScript: HealthComponent: -25 → 75/100`
     - 노란색 `LogScript:` 접두어가 곧 Angelscript `Log(f"...")` 출력

**✅ 성공 기준**: 두 메시지 다 뜸. 이 시점에서 **"Angelscript 코드가 UE 런타임에서 실행된다"**가 증명됨.

---

## ④ Hot-reload 검증 (Angelscript의 핵심 장점)

1. PIE 종료(Esc)
2. **외부 에디터**(VS Code 등)에서 `Script/Core/HealthComponent.as` 열기
3. `ApplyDamage` 함수 내부 Log 메시지 변경:
   ```angelscript
   Log(f"[DAMAGE] Component took {DamageAmount}! Remaining: {CurrentHealth}/{MaxHealth}");
   ```
4. 저장(Ctrl+S)
5. UE 에디터로 돌아오기 → **Output Log에서 자동 확인**:
   ```
   Angelscript: Compiling (structural): Core.HealthComponent
   Angelscript: ==script reload total == took XXX ms
   ```
6. 다시 **Play** → 바뀐 메시지 출력 확인

**✅ 성공 기준**: UE 재시작 없이 2초 내에 스크립트가 반영됨. C++라면 수 분 걸릴 작업.

---

## ⑤ UBG MCP 경로 확인 (이게 오늘 핵심 질문)

### 5-1. UBG 실행 확인
- Edit → Plugins → "BP Generator Ultimate" 활성화 상태
- Output Log에 `LogUnrealHandshake: ...` 또는 유사 로그 시작 시점에 출력됨
- (이미 활성이라면 아래 5-2 바로)

### 5-2. Claude Code에서 MCP 핸드셰이크 확인
새 대화에서 이렇게 요청:
```
내 현재 레벨에 있는 actor 목록 보여줘
```
Claude Code가 `mcp__unreal-handshake__level_actor(action="list_actors")` 식으로 호출하고 리스트 반환하면 ✅.

### 5-3. Angelscript 클래스를 MCP로 조작
```
BP_TestActor 에 UHealthComponent 하나 더 추가해줘 (이름: SecondHealth)
```
Claude Code가 `mcp__unreal-handshake__blueprint(action="add_component", component_class="UHealthComponent", component_name="SecondHealth")` 호출 → 에디터에서 즉시 반영.

### 5-4. 직접 증명 로그
오늘 세션에서 이미 실행한 MCP 호출들:
- `create_blueprint` → `/Game/BP_TestActor` 생성
- `add_component` (component_class="UHealthComponent") → Angelscript 클래스 부착
- `discover_nodes` → `fn.UHealthComponent.ApplyDamage` 등 검색
- `build_blueprint_graph` → EventGraph 5개 노드 + 6개 연결 생성
- `compile_blueprint` → 0 errors

즉 **MCP → UE → Angelscript** 왕복이 이미 한 바퀴 돈 셈.

---

## 6. 다음에 시도해볼 것들

| 원하는 것 | 방법 |
|---|---|
| 새 Angelscript 클래스 | `Script/Core/InventoryComponent.as` 작성 → 자동 hot-reload → BP에서 Add Component |
| MCP로 BP 생성 자동화 | Claude Code에 "`BP_Enemy` 만들고 UHealthComponent 붙여줘" 요청 |
| Delegate 사용 | `class UHealthComponent`에 `FHealthChangedSignature OnHealthChanged;` 추가 → BP에서 Bind Event |
| Replication | `Script/Core/HealthComponent.as`의 `CurrentHealth`에 `, Replicated` 플래그 추가 |
| 테스트 자동화 | `Script/Tests/TestHealthComponent.as`에 Unreal Automation Test 작성 |

---

## 문제 생기면

- **PIE 에서 아무 메시지 없음**: Output Log 필터에서 `LogScript`, `LogAngelscript` 활성화 확인
- **Details 에 프로퍼티 안 보임**: 스크립트 reload 안 된 상태 — 에디터 `Angelscript → Reload Scripts` 메뉴 또는 `.as` 파일 저장 한 번 더
- **Apply Damage 노드 우클릭에서 안 찾아짐**: BP 컴파일(F7) 한 번 → 캐시 갱신
- **화면 Print String 안 보임**: Play 모드 진입 직후 4–5초 안에 사라짐 — 너무 빨리 놓친 것. 다시 Play.
- **MCP 호출 "from previous session" 거절**: 에디터 재시작 후 Claude Code도 새 대화 필요 (handshake 토큰 만료)

---

## TL;DR

오늘 파일들:
- `Script/Core/HealthComponent.as` — 테스트용 컴포넌트
- `Content/BP_TestActor.uasset` — MCP로 만든 샘플 BP

한 사이클 돌기:
1. Play → 메시지 2종 확인
2. `.as` 파일 수정 → 저장 → 다시 Play → 바뀐 메시지 확인
3. Claude Code에 뭔가 요청 → 에디터에 반영되는지 확인

이 세 단계 전부 통과하면, **"Angelscript + UBG MCP 스택이 이 프로젝트에서 사용 가능하다"**가 실사용 수준으로 확정.
