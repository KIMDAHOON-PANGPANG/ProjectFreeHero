# 기술 선호 사항

<!-- /setup-engine으로 채워짐. 개발 과정에서 사용자의 결정에 따라 갱신됨. -->
<!-- 모든 에이전트는 프로젝트별 표준과 컨벤션을 이 파일에서 참조함. -->

## 엔진 & 언어

- **엔진**: Unreal Engine 5.7 (2025년 11월 고정)
- **언어**: **Blueprint 전용** — C++ 작성 금지. 성능이 필요해도 BP 최적화로 해결하거나, UE 엔진 내장 기능으로 대체
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
  → **본 프로젝트는 C++ 작성 금지.** 이 네이밍은 엔진/플러그인 소스를 **읽을 때**만 참조
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

- **C++ 작성 자체가 금지** — 본 프로젝트는 BP-only. Source/ 디렉터리 생성·사용 금지
- **Blueprint 내 하드코딩된 게임플레이 값** — `DataAsset`, `PrimaryDataAsset`, `DataTable` 사용
- **예산 없는 Tick 사용** — Timers, Timeline, 이벤트 기반 패턴 선호
- **핫 패스에서 Pawn 하위 클래스로의 Blueprint 하드 캐스트** — 하드 레퍼런스 유발, 로딩 느려짐
- **핫 패스에서 UObject 할당** — 오브젝트 풀 사용
- **GAS (GameplayAbilities) 사용** — AttributeSet 이 C++ 요구. 커스텀 BP 어빌리티 시스템 사용

## 허용 라이브러리 / 애드온

- **UBG (Ultimate Engine CoPilot)** — BlueprintsLab, FAB Marketplace — AI 코딩 어시스턴트 플러그인
- ~~**GameplayAbilities (GAS)**~~ — **본 프로젝트 비활성화** (BP-only 정책, AttributeSet 이 C++ 요구).
  대체: 커스텀 `UAttributeComponent` / `UAbilityComponent` / `UEffectDataAsset` (BP).
- **GameplayTags** — 내장, 태그 시스템만 사용 (BP 완전 지원)
- **CommonUI** — 내장, 다중 입력(gamepad + KBM) 타겟팅 시 활성화
- **GameplayCameras** — 내장 (UE5.5+), 실험적이지만 3인칭에 유용
- [승인 시 추가]

## 아키텍처 결정 로그

- [아직 ADR 없음 — `/architecture-decision`으로 생성]

## 엔진 스페셜리스트

- **주력**: `ue-blueprint-specialist` (BP graph 설계·최적화·함수 라이브러리 — 본 프로젝트 **메인 스페셜리스트**)
- **서브**: `unreal-specialist` (Config / Plugin / Editor 설정 / 크로스 시스템 리뷰만 담당. C++ 작성 금지)
- **UI**: `ue-umg-specialist` (UMG 위젯, CommonUI, 레이아웃, 입력 라우팅)
- **네트워킹**: `ue-replication-specialist` (복제, RPC, Iris, 서버 권한)
- **비활성**: ~~`ue-gas-specialist`~~ — deprecated (BP-only 정책).
  어빌리티/어트리뷰트/이펙트 관련 변경은 전부 `ue-blueprint-specialist` 로.
- **라우팅 노트**: UBG 생성 Blueprint 작업 → `ue-blueprint-specialist` 가 리뷰.

### 파일 확장자 라우팅

| 파일 확장자 / 타입                  | 스폰할 스페셜리스트          |
|-------------------------------------|------------------------------|
| `.uasset` (Blueprint Class BP_*)    | `ue-blueprint-specialist`    |
| `.uasset` (Widget Blueprint WBP_*)  | `ue-umg-specialist`          |
| `.uasset` (AbilityDA / EffectDA / AttributeComp BP) | `ue-blueprint-specialist` |
| ~~`.cpp` / `.h` (Source/)~~         | ~~`unreal-specialist`~~ — **BP-only, Source/ 사용 금지** |
| `.uasset` (Material / Shader)       | `technical-artist`           |
| `.ini` (Config/)                    | `unreal-specialist`          |
| `.uplugin` / `.uproject`            | `unreal-specialist`          |
| 일반 아키텍처 리뷰                  | `unreal-specialist`          |
