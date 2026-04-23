# 기술 선호 사항

<!-- /setup-engine으로 채워짐. 개발 과정에서 사용자의 결정에 따라 갱신됨. -->
<!-- 모든 에이전트는 프로젝트별 표준과 컨벤션을 이 파일에서 참조함. -->

## 엔진 & 언어

- **엔진**: Unreal Engine 5.7 (2025년 11월 고정)
- **언어**: **Blueprint + Angelscript** — 사용자 게임 코드에서 C++ 작성 금지(플러그인 내부 C++는 예외). BP는 콘텐츠/튜닝, Angelscript는 시스템 레이어(UObject/Component/AttributeSet 상속). `Script/` 디렉터리 하위에 `.as` 파일 배치
- **렌더링**: Lumen + Nanite (UE5 기본 파이프라인); 신규 머티리얼은 Substrate (5.7 프로덕션 준비 완료)
- **물리**: Chaos (기본)
- **AI CoPilot 플러그인**: UBG — Ultimate Engine CoPilot (에디터 내에서 Claude Code 실행)

## 입력 & 플랫폼

- **타겟 플랫폼**: PC (Windows 주력)
- **입력 방식**: [설정 예정 — Keyboard/Mouse + Gamepad 유력]
- **주 입력**: [설정 예정]
- **Gamepad 지원**: [설정 예정]
- **터치 지원**: 없음 (PC 타이틀)
- **플랫폼 노트**: [설정 예정]

## 네이밍 컨벤션 (UE5 표준)

- **C++ 클래스 (참조용)**: `UPrefix` (`A`는 Actor, `U`는 UObject, `F`는 struct, `E`는 enum, `I`는 interface)
  → **사용자 C++ 작성 금지.** 엔진/플러그인 소스를 **읽을 때**와 Angelscript 동일 네이밍 적용에 참조
- **Angelscript 클래스 (`Script/**/*.as`)**: C++ 네이밍 규칙 그대로 적용 (`class UHealthComponent : UActorComponent` 등). 파일명은 클래스명과 일치 (`HealthComponent.as`)
- **Blueprints**: `BP_<Name>` (Blueprint 클래스), `WBP_<Name>` (Widget), `ABP_<Name>` (AnimBP)
- **변수**: `CamelCase` — boolean은 `b` 접두사 (`bIsAlive`)
- **함수/이벤트**: `PascalCase`
- **Delegates/Events**: `On<Event>` 접두사 (`OnHealthChanged`)
- **에셋**: 타입 접두사 (`SM_`, `SK_`, `T_`, `M_`, `MI_`, `MF_`, `AS_`, `MM_` 등)
- **Content/ 내 폴더**: `PascalCase`

## 성능 예산

- **목표 프레임레이트**: 60 FPS
- **프레임 예산**: 16.6 ms
- **Draw Calls**: [설정 예정 — 타겟 하드웨어 티어에 의존]
- **메모리 상한**: [설정 예정]

## 테스팅

- **프레임워크**: Unreal Automation Test framework + Functional Tests (Blueprint)
- **CI 러너**: Headless Unreal with `-nullrhi` 플래그
- **최소 커버리지**: [설정 예정 — 게임플레이 공식 + 핵심 시스템부터 시작]
- **필수 테스트**: 밸런스 공식, 게임플레이 시스템, 복제 (멀티플레이어인 경우)

## 금지 패턴

- **게임 로직 C++ 금지** — 시스템 레이어는 Angelscript, 콘텐츠는 BP. `Source/` 는 **빌드 인프라 보일러플레이트 전용**(Target.cs, Build.cs, IMPLEMENT_PRIMARY_GAME_MODULE — 수정 금지). 플러그인 C++ 빌드도 예외(UBG, Angelscript 런타임)
- **Blueprint/Angelscript 내 하드코딩된 게임플레이 값** — `DataAsset`, `PrimaryDataAsset`, `DataTable` 사용
- **예산 없는 Tick 사용** — Timers, Timeline, 이벤트 기반 패턴 선호
- **핫 패스에서 Pawn 하위 클래스로의 하드 캐스트** — 하드 레퍼런스 유발, 로딩 느려짐
- **핫 패스에서 UObject 할당** — 오브젝트 풀 사용
- **GAS 직접 C++ 사용** — 반드시 Angelscript의 `UAngelscriptAttributeSet` 래퍼 경유(PoC 통과 전까지는 커스텀 BP 스택 유지)

## 허용 라이브러리 / 애드온

- **UBG (Ultimate Engine CoPilot)** — BlueprintsLab, FAB Marketplace — AI 코딩 어시스턴트 플러그인
- **Angelscript** — `UnrealEngine-Angelscript-ZH/AngelscriptProject` 기반 커뮤니티 플러그인 (UE 5.7). `Plugins/Angelscript/` 로컬 배치. `UAngelscriptAttributeSet` 래퍼로 GAS 재활성 기술 전제 충족
- **GameplayAbilities (GAS)** — **조건부** (Angelscript PoC Plan §6 통과 시 재활성). 통과 전까지는 커스텀 `UAttributeComponent` / `UAbilityComponent` / `UEffectDataAsset` 사용
- **GameplayTags** — 내장, 태그 시스템만 사용 (BP 완전 지원)
- **CommonUI** — 내장, 다중 입력(gamepad + KBM) 타겟팅 시 활성화
- **GameplayCameras** — 내장 (UE5.5+), 실험적이지만 3인칭에 유용
- [승인 시 추가]

## 아키텍처 결정 로그

- [아직 ADR 없음 — `/architecture-decision`으로 생성]

## 엔진 스페셜리스트

- **BP 주력**: `ue-blueprint-specialist` (BP graph/콘텐츠/함수 라이브러리)
- **Angelscript**: `ue-angelscript-specialist` (`.as` 시스템 레이어, UObject/Component/AttributeSet 상속, hot-reload)
- **서브**: `unreal-specialist` (Config / Plugin / Editor 설정 / 크로스 시스템 리뷰만 담당. 사용자 C++ 작성 금지)
- **UI**: `ue-umg-specialist` (UMG 위젯, CommonUI, 레이아웃, 입력 라우팅)
- **네트워킹**: `ue-replication-specialist` (BP + `.as` 복제, RPC, Iris, 서버 권한)
- **조건부**: `ue-gas-specialist` — Angelscript PoC(Plan §6) 통과 시 재활성, `ue-angelscript-specialist`와 공동 작업
- **라우팅 노트**: BP 콘텐츠 → `ue-blueprint-specialist`. Angelscript 시스템 → `ue-angelscript-specialist`. UBG 생성 Blueprint → `ue-blueprint-specialist` 리뷰.

### 파일 확장자 라우팅

| 파일 확장자 / 타입                  | 스폰할 스페셜리스트          |
|-------------------------------------|------------------------------|
| `.uasset` (Blueprint Class BP_*)    | `ue-blueprint-specialist`    |
| `.uasset` (Widget Blueprint WBP_*)  | `ue-umg-specialist`          |
| `.uasset` (AbilityDA / EffectDA / AttributeComp BP) | `ue-blueprint-specialist` |
| `.as` (Angelscript — 시스템 레이어) | `ue-angelscript-specialist`  |
| `.as` (UAngelscriptAttributeSet 상속) | `ue-angelscript-specialist` + `ue-gas-specialist` (재활성 시 공동) |
| ~~`.cpp` / `.h` (Source/)~~         | — **사용자 작성 금지, Source/ 미사용** |
| `.uasset` (Material / Shader)       | `technical-artist`           |
| `.ini` (Config/)                    | `unreal-specialist`          |
| `.uplugin` / `.uproject`            | `unreal-specialist`          |
| 일반 아키텍처 리뷰                  | `unreal-specialist`          |
