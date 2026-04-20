# FREEFLOW HERO — 프로젝트 개요

> **역할:** 본 문서는 FREEFLOW HERO 프로젝트의 최상위 비전 요약이다.
> 시스템 단위 상세는 `design/gdd/` 에 개별 파일로 기록한다.
> **원본 GDD:** `freeflow_hero_gdd_kr.docx` (2026-04-20, v1.0, 작성자 김다훈)
> **번역 기준일:** 2026-04-20 — Unity 기반 원문을 UE5.7 기준으로 치환하여 재기록.

## 1. 한 줄 요약

초능력 없는 체술형 사이드킥이 서포트 기어로 속성 전투를 펼치는
**2D 사이드스크롤 프리플로우 액션 로그라이크**. 배트맨 아캄의 프리플로우 코어 +
하데스의 빌드 구조 + 픽셀아트 비주얼 톤.

## 2. 장르 & 플랫폼

| 항목 | 값 |
|---|---|
| 장르 | 2D 사이드스크롤 프리플로우 액션 로그라이크 |
| 플랫폼 | PC (Steam Early Access) |
| 카메라 | 2D 사이드스크롤 (단층 이동 구조 포함) |
| 타겟 플레이타임 (EA) | 3~5시간 |

## 3. 레퍼런스 게임

- **배트맨 아캄 시리즈** — 프리플로우 코어
- **하이파이 러쉬** — 리듬 피드백
- **하데스** — 로그라이크 빌드 구조
- **나인솔즈** — 영구 해금 스킬 진행
- **샤오샤오** — 2D 무술 감성
- **예지격자전** — 2D 사이드스크롤 전투
- **REPLACED** — 픽셀아트 비주얼 톤

## 4. 개발 체계

| 항목 | 값 |
|---|---|
| 엔진 | **Unreal Engine 5.7** (2025-11 고정) |
| 렌더링 파이프라인 | Lumen + Substrate, 3D→2D 픽셀 스타일 변환 (Post Process Material + SceneCapture2D) |
| 주 언어 | **Blueprint 전용** — C++ 작성 금지 (BP-only 정책) |
| 데이터 드리븐 | **PrimaryDataAsset / UDataAsset** (구 Unity `ScriptableObject` 역할) |
| 이벤트 버스 | **GameplayMessageSubsystem** (구 Unity `Static EventBus` 역할) |
| 어빌리티 프레임워크 | **커스텀 BP 스택** — `UAttributeComponent` / `UAbilityComponent` / `UAbilityDataAsset` / `UEffectDataAsset` (GAS 미사용, `FGameplayTag` 는 유지) |
| UI 프레임워크 | **CommonUI** (멀티 입력 대응) |
| AI 코파일럿 | **UBG (Ultimate Engine CoPilot)** — 에디터 내부에서 Claude Code 실행 |
| 버전 관리 | Git, 트렁크 기반 (origin: GitHub 공개 저장소) |

> **주의:** 원문 GDD의 `SO_HeroData`, `SO_PassiveData[]`, `SO_EnvironmentData` 등은
> 본 프로젝트에서 모두 **`UDataAsset` 파생 클래스**로 번역된다 (예: `UHeroData`, `UPassiveData`).
> 원문의 `[SerializeField]`, `MonoBehaviour`, `GetComponent<>` 는 존재하지 않으며,
> 각각 `UPROPERTY`, `UActorComponent / AActor`, `GetComponentByClass` 로 대응한다.

## 5. 스토리 기둥 (요약)

- **성장**: "나도 히어로가 되겠다" — 플레이어 감정 드라이브.
- **부조리**: 사이드킥이 느끼는 체계적 불공정을 플레이 과정에서 체감.
- **부패**: 부패한 히어로가 감염원 유통에 관여 — 런 진행 중 드러남.
- **페이오프**: 부패 히어로 대결 시 기어 몰수 → 영구 해금 체술만으로 전투 승리 = 진정한 히어로화.

세계관/캐릭터 상세는 `design/gdd/narrative-system.md` (예정)에 기록.

## 6. 개발 원칙

- **1인 개발**, ~10-12개월 → Steam EA 출시 → 퍼블리셔 컨택.
- **바이브 코딩** — AI (Claude Code + UBG) 에 구현을 위임, 사람은 판단/승인.
- **Blueprint 전용** — **C++ 작성 금지**. 콘텐츠·프레임워크·성능 모두 BP 내에서 해결. `Source/` 미생성.
- **GAS 미사용** — `UAttributeSet` 이 C++ 상속을 요구하므로 GAS 전체 비활성.
  어빌리티는 커스텀 BP 스택 (`UAttributeComponent` / `UAbilityComponent` / `UAbilityDataAsset` / `UEffectDataAsset`) 으로 구현. 단, `FGameplayTag` 시스템은 유지.
- **데이터 주도** — 게임플레이 값 하드코딩 금지, `UDataAsset` / `UDataTable` 사용.
- **검증 주도** — P0 시스템은 유닛/자동 테스트, 비주얼은 스크린샷 + 사인오프.

## 7. 관련 문서

- 상세 시스템 GDD: `design/gdd/` (추후 추가)
- 시스템 인덱스: `design/gdd/systems-index.md` (다음 태스크)
- UE 버전 레퍼런스: `docs/engine-reference/unreal/VERSION.md`
- UE 플러그인 가이드: `docs/engine-reference/unreal/PLUGINS.md`
- 마스터 협업 프로토콜: `CLAUDE.md`
- 원본 GDD (외부, 참고용): `C:\Users\sk992\Downloads\freeflow_hero_gdd_kr.docx`
