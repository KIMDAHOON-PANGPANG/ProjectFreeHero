# Angelscript UE 5.7 Feasibility — 리서치 노트

> **상태**: 리서치 완료, CP2 결정 대기
> **작성일**: 2026-04-22
> **세션 브랜치**: `claude/interesting-clarke-b07ec3` (worktree)
> **연결 Plan**: `.claude/plans/ultimate-engine-sleepy-cook.md` (repo 내 사본). 원본 위치는 Claude Code `/plans/` 디렉터리.
> **대상 프로젝트**: ProjectFreeHero (UE 5.7, BP-only 정책 적용 중)

---

## 0. TL;DR

- **UE 5.7 + Angelscript + GAS 조합은 커뮤니티 플러그인 경로로 실행 가능**하다.
- **엔진 포크 불필요** — Hazelight 정품 Angelscript 코드가 **단일 플러그인**으로 재패키징되어 바닐라 UE 5.7 런처 빌드와 함께 사용할 수 있다.
- **R5 (AttributeSet 상속) PASS** — `UAngelscriptAttributeSet` 래퍼가 커뮤니티 포크에 이미 구현되어 있음. GAS 재활성 기술적 전제가 충족된다.
- **다음 결정 필요**:
  1. 정책 해석 — "C++ 작성 금지"가 (a) 사용자 코드 범위인지, (b) 빌드 파이프라인 전체인지
  2. PoC 진행 / 보류 / 추가 리서치 중 선택

---

## 1. 리서치 범위와 방법

Plan §2 (Research Phase) R1–R6 체크리스트에 대한 판정을 목표로 한 3라운드 리서치. 사용자 결정: **"설치 보류, 리서치 먼저"** + **"리서치 더 파고들기"** (2번 반복).

### 라운드별 발견 요약

| 라운드 | 주력 조사 | 핵심 발견 |
|---|---|---|
| **R1** | Hazelight 공식 저장소 / 플러그인 vs 엔진 포크 구분 | Hazelight 공식 UE-Angelscript는 **Epic GitHub 권한 필요**, 공개 저장소에 UE 5.7 브랜치 없음 |
| **R2** | UNREANGEL(WillGordon9999) 상태 | UE 5.4 고정, `AngelscriptCharacter.cpp`/`AngelscriptPawn.cpp` **0바이트 (미구현)** |
| **R3** | Hazelight Docs subdir / GAS 통합 흔적 | 공식 문서 0건 (`UAttributeSet` 검색 결과 없음) / 커뮤니티 포크 3건에서 **완전한 GAS 스택 확인** |

---

## 2. R1–R6 판정 테이블

| # | 항목 | 판정 | 근거 |
|---|---|---|---|
| **R1** | Hazelight 공식 UE 5.7 브랜치 | ❓ 공개 확인 불가 | `Hazelight/UnrealEngine-Angelscript` 저장소가 공개 repo 리스트에 없음 (Epic Org gated). Scenario A' 발견으로 불필요. |
| **R2** | UNREANGEL UE 5.7 지원 | ❌ FAIL | UE 5.4 고정, 유지 중단 상태. Actor/Component만 구현, Character/Pawn 미구현. |
| **R3** | UBG + 바닐라 UE 호환 | ⚠️ 미검증 | 논리적으로 가능 (FAB 플러그인은 독립), PoC 검증 필요. |
| **R4** | UBG + 엔진 포크 호환 | N/A | Scenario A' 채택 시 포크 경로 자체가 불필요. |
| **R5** | UAttributeSet 상속 | ✅ **PASS** | `UAngelscriptAttributeSet` 래퍼 클래스가 WillGordon9999/UE-Angelscript와 UnrealEngine-Angelscript-ZH 양쪽에 구현됨. `BP_PreGameplayEffectExecute` 등 `BlueprintImplementableEvent` 훅 제공. |
| **R6** | DDC / 한글 경로 | ✅ 유지 가능 | 현재 프로젝트 설정(`C:\Users\김다훈\`, FileSystem DDC) 그대로 유지. 엔진 포크 불필요하므로 재검증 대상 아님. |

---

## 3. 결정적 발견 — Scenario A' 신규 경로

### 3.1 UnrealEngine-Angelscript-ZH/AngelscriptProject

| 항목 | 값 |
|---|---|
| URL | https://github.com/UnrealEngine-Angelscript-ZH/AngelscriptProject |
| UE 버전 | **5.7** (`EngineAssociation: "5.7"` — ProjectFreeHero와 동일) |
| 최근 커밋 | **2026-04-21** (3일 전, 리서치 시점 기준) |
| Star | 15 |
| 라이선스 | (확인 필요 — LICENSE.md 존재) |
| 유형 | **단일 플러그인** (`Plugins/Angelscript/`) — 엔진 포크 아님 |
| 성숙도 | "no longer prototype, matured" (AGENTS.md 자체 기록) |
| 테스트 | 275/275 PASS 카탈로그 + 452+ 자동화 테스트 |
| 바인딩 | 123개 `Bind_*.cpp` 파일 (엔진 API 커버) |
| 인프라 | DebugServer V2, CodeCoverage, StaticJIT, BlueprintImpact Commandlet |

**핵심**: Angelscript.uplugin의 `"CreatedBy": "Hazelight Games"` — 이것은 Hazelight 정품 Angelscript 코드가 플러그인 형태로 재패키징된 것. 엔진 수정 불필요.

### 3.2 완전한 GAS 스택 (ZH 플러그인 `Core/` 디렉터리)

16개 파일:
- `AngelscriptAttributeSet.h / .cpp` (UAttributeSet 상속 래퍼 — **R5 근거**)
- `AngelscriptAbilitySystemComponent.h (18KB) / .cpp (20KB)` (주력 구현)
- `AngelscriptGASAbility.h / .cpp` (UGameplayAbility 상속)
- `AngelscriptGASActor.h / .cpp`
- `AngelscriptGASCharacter.h / .cpp`
- `AngelscriptGASPawn.h / .cpp`
- `AngelscriptAbilityTask.h / .cpp`
- `AngelscriptAbilityTaskLibrary.h (26KB)`
- `AngelscriptAbilityAsyncLibrary.h`

`UAngelscriptAttributeSet`가 제공하는 훅 (`BlueprintImplementableEvent`):
- `BP_PreGameplayEffectExecute`
- `BP_PostGameplayEffectExecute`
- `BP_PreAttributeChange` / `BP_PostAttributeChange`
- `BP_PreAttributeBaseChange` / `BP_PostAttributeBaseChange`
- `BP_OnInitFromMetaDataTable` (`BlueprintNativeEvent`)

헬퍼 함수: `TrySetAttributeBaseValue`, `TryGetAttributeCurrentValue`, `TryGetAttributeBaseValue`, `GetGameplayAttribute`, `TryGetGameplayAttribute`.

---

## 4. 커뮤니티 레퍼런스 3건

| 프로젝트 | UE 버전 | 특징 | 용도 |
|---|---|---|---|
| [UnrealEngine-Angelscript-ZH/AngelscriptProject](https://github.com/UnrealEngine-Angelscript-ZH/AngelscriptProject) | **5.7** | 주력 플러그인, 활발 유지 (2026-04-21) | **1순위 채택 후보** |
| [WillGordon9999/UE-Angelscript](https://github.com/WillGordon9999/UE-Angelscript) | 5.4.2 | "refactored to a single plugin compatible with vanilla UE" — ZH의 원형 | 참조용 (AttributeSet 헤더 동일) |
| [najoast/AngelscriptAura](https://github.com/najoast/AngelscriptAura) | GUID (source build) | GASP/Aura 튜토리얼을 Angelscript로 완전 이식 | **사용 예시 레퍼런스** (`.as` 파일 실전 코드) |

AngelscriptAura `Script/` 구조 (참고 권장):
```
Script/
├── AI/
├── Actor/
├── AnimNotify/
├── Character/
├── Define/
├── Documents/
├── GAS/          ← 핵심 레퍼런스
├── Game/
├── Global/
├── Module/
├── Player/
├── SData/
├── Subsystem/
└── UI/
```

---

## 5. Hazelight 공식 문서에서 추출한 핵심 규칙

### 5.1 Angelscript 상속 지원 베이스 클래스 (공식 문서 확인)
- ✅ `AActor`, `UActorComponent` — `class AMyActor : AActor` 형태로 직접 상속
- ✅ Subsystem: `UScriptWorldSubsystem`, `UScriptGameInstanceSubsystem`, `UScriptLocalPlayerSubsystem`, `UScriptEditorSubsystem`, `UScriptEngineSubsystem` 헬퍼 베이스
- ❓ `UAttributeSet` — 공식 문서에 **헬퍼 베이스 부재**. 그러나 커뮤니티 포크가 `UAngelscriptAttributeSet` 제공으로 간접 지원

### 5.2 자동 바인딩 원칙
> "**If it can be used from Blueprint, it should be usable from Angelscript.**"
> — Hazelight cpp-bindings/automatic-bindings

- `UCLASS(BlueprintType)` + `BlueprintCallable` 기반
- `NotInAngelscript` / `NoAutoAngelscriptBind` 메타데이터로 제외 가능
- Deprecated 함수는 자동 바인딩 안 됨

### 5.3 C++ vs Angelscript 주요 차이 (cpp-differences.md)
- 포인터 없음 (`->` 없고 모두 `.`)
- `UPROPERTY()` GC 자동 처리 (GC 탈락 걱정 없음)
- `UPROPERTY()` 기본값: `EditAnywhere + BlueprintReadWrite`
- `UFUNCTION()` 기본값: `BlueprintCallable`
- **`float` = 64-bit double** (UE 5.0+ 엔진 결정 따름). `float32` / `float64` 명시 가능
- 생성자 대신 `default` 키워드 사용

### 5.4 Fork 문법 제약 (ZH 플러그인 특화, ASSDK_Fork_Differences.md)
- ❌ 전역 변수는 `const`만 (`int GlobalVar = 42;` 컴파일 에러)
- ❌ `@` 핸들 문법 없음 (자동 참조 시맨틱)
- ❌ 스크립트 레벨 `interface` 없음 (UINTERFACE만)
- ❌ `mixin class` 없음 (mixin 함수만)
- AngelScript 2.33 기반 + 2.38 선택적 편입 (foreach, import traits 등)

### 5.5 네트워킹 지원
- RPC: `NetMulticast`, `Client`, `Server`, `BlueprintAuthorityOnly` 모두 지원
- 복제 프로퍼티: `Replicated`, `ReplicatedUsing` (OnRep 콜백)
- `ELifetimeCondition` 전체 지원 (OwnerOnly, SkipOwner, InitialOnly 등)
- **Iris 네트워킹 호환성은 문서화되지 않음** — PoC 필요

---

## 6. 남은 리스크 (5가지)

| # | 리스크 | 영향도 | 완화책 |
|---|---|---|---|
| **R-A** | 최초 빌드 비용: VS 2022 + Windows SDK + .NET, ~30분, ~10GB 디스크 | 중 | 1회성. 팀이 수용 가능 여부 확인 |
| **R-B** | 정책 해석: "C++ 작성 금지"와 "플러그인 C++ 빌드"의 양립 | 높음 | **CLAUDE.md L9 정책 재정의 필요** (§8 참조) |
| **R-C** | Angelscript 문법 제약: 전역 `const` 강제, `@` 없음 등 | 낮음 | 학습 곡선 존재하나 BP 사용자에게는 오히려 친숙 |
| **R-D** | 커뮤니티 언어: Wiki 중국어 우선, 영문 AGENTS.md 존재 | 중 | AGENTS.md + 원본 Hazelight 영문 문서 병행 참조 |
| **R-E** | UBG 공존 미검증: 두 플러그인 동시 로드 안정성 | 중 | Plan §6 PoC V5–V6 게이트로 커버 |

---

## 7. Plan 원안과의 차이 (변경된 전제들)

| Plan 원안 | 리서치 후 실제 |
|---|---|
| Scenario A (바닐라 + UNREANGEL) vs B (Hazelight 엔진 포크) | **Scenario A' (커뮤니티 UE 5.7 플러그인)** 신규 발견으로 A/B 모두 불필요 |
| R1 (Hazelight 5.7 브랜치) 확인 필요 | 불필요 (A'로 우회) |
| R2 UNREANGEL 5.7 지원 | FAIL 확정 — A' 채택 이유 |
| 엔진 포크 빌드 150GB+ 디스크 요구 | 불필요, 플러그인 ~10GB로 축소 |
| R5 통과 조건 | **즉시 PASS** — 커뮤니티 포크의 `UAngelscriptAttributeSet` 사용 |
| GAS 재활성 | 기술적 전제 충족, 정책 결정만 남음 |
| Plan §3 Installation Runbook A/B | **§3 재작성 필요** — Scenario A' 러너북 신규 |

---

## 8. 결정 지점 (CP2)

### 8.1 정책 해석 질문

현재 `CLAUDE.md` L9: "Blueprint 전용 (C++ 작성 금지 — 본 프로젝트는 BP-only 정책)"

두 가지 해석:
- **(a) 사용자 게임 코드 범위**: 우리가 C++를 쓰지 않음. 플러그인(UBG, Angelscript)은 이미 있는 C++를 쓸 뿐이고 우리가 편집하지 않음 → **ZH 플러그인 OK**
- **(b) 빌드 파이프라인 전체**: 빌드 과정에 C++ 컴파일 자체가 없어야 함 → ZH 플러그인 불가. (단, UBG도 C++ 플러그인이므로 이 해석은 현재 프로젝트와 모순)

**권장**: (a) 해석 + 정책 문구를 "**사용자 코드는 BP + Angelscript. C++ 작성 금지.** 플러그인 C++(UBG, Angelscript)의 빌드는 예외"로 명시화.

### 8.2 다음 단계 후보

| 옵션 | 설명 | 소요 | 권장 |
|---|---|---|---|
| **P1** PoC 진행 | ZH 플러그인 설치 + UBG 공존 + HealthComponent `.as` 1개 (Plan §6) | 4–8시간 | ✅ 1순위 |
| **P2** 추가 리서치 | Hazelight Discord 질의 / 한국 UE 커뮤니티 피드백 | 1–2일 | 2순위 |
| **P3** Plan 보류 | BP-only 유지, 현재 커스텀 스택으로 계속 | 0 | 3순위 (리스크 수용 거부 시) |

---

## 9. 다음 세션 재개 체크리스트

집에서 작업 재개 시 이 순서로:

### 9.1 환경 복구
- [ ] git pull 최신 브랜치
- [ ] `.claude/plans/ultimate-engine-sleepy-cook.md` 읽기 (repo 사본 Plan)
- [ ] 본 문서 (`docs/research/angelscript-ue57-feasibility.md`) 읽기
- [ ] `production/session-state/active.md` 있으면 읽기 (없으면 이 문서가 대체)

### 9.2 결정 지점 처리
- [ ] **CP2 결정 1**: 정책 해석 (a) vs (b) 선택 (§8.1)
- [ ] **CP2 결정 2**: P1 (PoC) / P2 (추가 리서치) / P3 (보류) 선택 (§8.2)

### 9.3 P1 선택 시 실행 순서 (Plan §3.1 재작성 필요)
1. [ ] Plan §3의 Scenario A 러너북을 **A' (ZH 플러그인)** 기준으로 재작성
2. [ ] 현재 `.uproject` 백업 (git 커밋)
3. [ ] VS 2022 + Windows SDK + .NET 설치 상태 확인
4. [ ] `git clone https://github.com/UnrealEngine-Angelscript-ZH/AngelscriptProject.git` 참조 저장소로
5. [ ] `Plugins/Angelscript/` 만 `ProjectFreeHero/Plugins/Angelscript/`로 복사
6. [ ] `.uproject`의 Plugins 배열에 `{"Name": "Angelscript", "Enabled": true}` 추가
7. [ ] Editor 첫 실행 → 플러그인 컴파일 (약 30분)
8. [ ] `Script/` 폴더 생성 (Angelscript 기본 경로)
9. [ ] HealthComponent `.as` 샘플 1개 작성
10. [ ] UBG MCP 5개 도구 응답 확인 (`mcp__unreal-handshake__get_tool_docs` 등)
11. [ ] Plan §6.3 V1–V8 게이트 체크
12. [ ] V8(한글 경로 빌드) 실패 시 롤백 프로토콜

### 9.4 정책 문서 수정 (P1 PASS 이후)
- Plan §4.2 테이블의 11개 파일 / 44개 항목 수정 (§7 내용 반영)
- 특히 `CLAUDE.md` L9, `.claude/docs/technical-preferences.md` L9/L50
- `.claude/agents/ue-gas-specialist.md` DEPRECATED 해제
- 신규 에이전트 `ue-angelscript-specialist.md` 작성 (Plan §4.3)

---

## 10. 원본 리서치 발견 로그 (추적용)

시간순 기록. 판정 뒤집기 발생 시 이 로그가 근거.

1. **UNREANGEL AngelscriptCharacter.cpp / AngelscriptPawn.cpp = 0 바이트** → Character/Pawn Angelscript 상속 미구현 확인 (R2 FAIL 결정타)
2. **Hazelight 공개 저장소에 UnrealEngine-Angelscript 엔진 포크 없음** → Epic Org private repo 확인 (R1 보류)
3. **Hazelight 공식 문서에 `UAttributeSet` 검색 결과 0건** → 공식 경로로는 GAS 불가 (초기 결론, 나중에 번복)
4. **"If it can be used from Blueprint, it should be usable from Angelscript"** → 바인딩 원칙 확인
5. **`UScript*` 헬퍼 베이스 패턴** — Subsystem에서 사용. AttributeSet용 헬퍼 없음 확인 (R5 초기 실패 판정)
6. **GitHub 코드 검색 "UAttributeSet angelscript" → 14개 결과** (판정 뒤집기 시작)
7. **WillGordon9999/UE-Angelscript에 `AngelscriptAttributeSet.h` 확인** → 완전한 UAttributeSet 상속 래퍼 (R5 PASS)
8. **UnrealEngine-Angelscript-ZH/AngelscriptProject EngineAssociation = "5.7"** (결정적)
9. **ZH 최근 커밋: "UE 5.7 migration repairs" (2026-04-21)** → 활발 유지 확인
10. **ZH `AGENTS.md`: "matured stage, standalone plugin"** → 프로덕션 수준 확인

---

## 11. 참조 자료

### 주요 저장소
- [UnrealEngine-Angelscript-ZH/AngelscriptProject](https://github.com/UnrealEngine-Angelscript-ZH/AngelscriptProject) — UE 5.7 플러그인
- [UnrealEngine-Angelscript-ZH/AngelscriptLab](https://github.com/UnrealEngine-Angelscript-ZH/AngelscriptLab) — 보조 실험 프로젝트
- [UnrealEngine-Angelscript-ZH/Wiki](https://github.com/UnrealEngine-Angelscript-ZH/Wiki) — 문서 저장소 (중국어)
- [UnrealEngine-Angelscript-ZH Wiki 사이트](https://unrealengine-angelscript-zh.github.io/Wiki/)
- [WillGordon9999/UE-Angelscript](https://github.com/WillGordon9999/UE-Angelscript) — 플러그인 원형 (UE 5.4.2)
- [WillGordon9999/UNREANGEL](https://github.com/WillGordon9999/UNREANGEL) — 참조용 (UE 5.4, 미유지)
- [najoast/AngelscriptAura](https://github.com/najoast/AngelscriptAura) — GAS+Angelscript 실전 코드

### 공식 문서
- [Hazelight Angelscript 공식 사이트](https://angelscript.hazelight.se/)
- [Hazelight 공식 문서 저장소](https://github.com/Hazelight/Docs-UnrealEngine-Angelscript)
- [scripting/actors-components](https://angelscript.hazelight.se/scripting/actors-components/)
- [scripting/cpp-differences](https://angelscript.hazelight.se/scripting/cpp-differences/)
- [scripting/subsystems](https://angelscript.hazelight.se/scripting/subsystems/)
- [scripting/networking-features](https://angelscript.hazelight.se/scripting/networking-features/)
- [cpp-bindings/automatic-bindings](https://angelscript.hazelight.se/cpp-bindings/automatic-bindings/)

### 툴링
- [Hazelight vscode-unreal-angelscript](https://github.com/Hazelight/vscode-unreal-angelscript) — VS Code Language Server + Debug Adapter
- [AngelScript for Unreal — IntelliJ 플러그인](https://plugins.jetbrains.com/plugin/28888-angelscript-for-unreal)
- [Hazelight EmmsUI](https://github.com/Hazelight/EmmsUI) — Angelscript용 immediate mode UMG

### 내부 참조
- Plan 원본: Claude Code `/plans/` 디렉터리 (사용자 홈)
- Plan repo 사본: `.claude/plans/ultimate-engine-sleepy-cook.md`
- 본 worktree: `C:\Dev\ProjectFreeHero\.claude\worktrees\interesting-clarke-b07ec3`
- MCP 설정: `.mcp.json` (UBG unreal-handshake 서버 포함)

---

**리서치 노트 끝.** 다음 작업은 §9.2 결정 지점 처리로 진행.
