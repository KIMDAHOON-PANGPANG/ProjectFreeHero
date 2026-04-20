# Unreal Engine 5.7 — 선택적 플러그인 및 시스템

**최종 검증일:** 2026-02-13

본 문서는 Unreal Engine 5.7 에서 사용 가능한 **선택적 플러그인 및 시스템**을 색인화한 것입니다.
이들은 코어 엔진의 일부가 아니지만 특정 장르 게임에서 흔히 사용됩니다.

---

## 본 가이드 사용 방법

**✅ 상세 문서 제공** - 포괄적인 가이드는 `plugins/` 디렉터리 참조
**🟡 간략 개요만 제공** - 공식 문서 링크 제공, 상세 내용은 WebSearch 사용
**⚠️ 실험적** - 향후 버전에서 호환성 파괴 변경 가능
**📦 플러그인 필수** - `Edit > Plugins` 에서 활성화 필요

---

## 프로덕션 준비된 시스템 (상세 문서 제공)

### ❌ Gameplay Ability System (GAS) — **본 프로젝트(ProjectFreeHero) 미사용**

> **⛔ ProjectFreeHero 미사용 사유:** 본 프로젝트는 **BP-only 정책**입니다.
> GAS 의 `UAttributeSet` 은 C++ 상속을 요구하며, UBG(Ultimate Engine CoPilot)
> 플러그인도 C++/GAS 워크플로를 주 타겟으로 하지 않습니다.
> 어빌리티/어트리뷰트/이펙트 관련 작업은 `ue-blueprint-specialist` 의
> 커스텀 BP 대체 시스템(`UAttributeComponent`, `UAbilityComponent`,
> `UAbilityDataAsset`, `UEffectDataAsset`)을 사용합니다.
> 단, `FGameplayTag` / `FGameplayTagContainer` 는 BP 완전 지원이므로 태그 시스템만 계속 사용합니다.
> 자세한 맵핑은 `.claude/agents/ue-blueprint-specialist.md` 참조.

- **목적:** 모듈식 어빌리티 시스템 (어빌리티, 어트리뷰트, 이펙트, 쿨다운, 코스트)
- **사용 시점:** RPG, MOBA, 어빌리티가 있는 슈터 등, 어빌리티 기반 게임플레이 전반 — **단, ProjectFreeHero 에서는 미사용**
- **지식 격차:** GAS 는 UE4 부터 안정화, UE5 개선 사항은 컷오프 이후
- **상태:** 프로덕션 준비됨 (일반 프로젝트 기준) / ❌ 본 프로젝트 **비활성**
- **플러그인:** `GameplayAbilities` (내장, Plugins 에서 활성화) — **본 프로젝트 비활성화 유지**
- **상세 문서:** [plugins/gameplay-ability-system.md](plugins/gameplay-ability-system.md) (참고용 보존)
- **공식:** https://docs.unrealengine.com/5.7/en-US/gameplay-ability-system-for-unreal-engine/

---

### ✅ CommonUI
- **목적:** 크로스 플랫폼 UI 프레임워크 (게임패드/마우스/터치 입력 자동 라우팅)
- **사용 시점:** 멀티 플랫폼 게임 (콘솔 + PC), 입력 방식에 독립적인 UI
- **지식 격차:** UE5+ 에서 프로덕션 준비됨, 컷오프 이후 주요 개선
- **상태:** 프로덕션 준비됨
- **플러그인:** `CommonUI` (내장, Plugins 에서 활성화)
- **상세 문서:** [plugins/common-ui.md](plugins/common-ui.md)
- **공식:** https://docs.unrealengine.com/5.7/en-US/commonui-plugin-for-advanced-user-interfaces-in-unreal-engine/

---

### ✅ Gameplay Camera System
- **목적:** 모듈식 카메라 관리 (카메라 모드, 블렌딩, 컨텍스트 인식 카메라)
- **사용 시점:** 동적 카메라 동작이 필요한 게임 (3인칭, 조준, 차량)
- **지식 격차:** UE 5.5 에서 신규 도입, 전적으로 컷오프 이후 내용
- **상태:** ⚠️ 실험적 (UE 5.5-5.7)
- **플러그인:** `GameplayCameras` (내장, Plugins 에서 활성화)
- **상세 문서:** [plugins/gameplay-camera-system.md](plugins/gameplay-camera-system.md)
- **공식:** https://docs.unrealengine.com/5.7/en-US/gameplay-cameras-in-unreal-engine/

---

### ✅ PCG (Procedural Content Generation)
- **목적:** 노드 기반 절차적 월드 생성 (Foliage, 소품, Terrain 디테일)
- **사용 시점:** 오픈 월드, 절차적 Level, 대규모 환경 배치
- **지식 격차:** UE 5.0-5.6 에서 실험적, 5.7 에서 프로덕션 준비됨
- **상태:** 프로덕션 준비됨 (UE 5.7 기준)
- **플러그인:** `PCG` (내장, Plugins 에서 활성화)
- **상세 문서:** [plugins/pcg.md](plugins/pcg.md)
- **공식:** https://docs.unrealengine.com/5.7/en-US/procedural-content-generation-in-unreal-engine/

---

## 기타 프로덕션 준비된 플러그인 (간략 개요)

### 🟡 Mass Entity
- **목적:** 대규모 AI/군중 처리를 위한 고성능 ECS (10,000+ 엔티티)
- **사용 시점:** RTS, 도시 시뮬레이터, 대규모 군중, 대규모 AI
- **상태:** 프로덕션 준비됨 (UE 5.1+)
- **플러그인:** `MassEntity`, `MassGameplay`, `MassCrowd`
- **공식:** https://docs.unrealengine.com/5.7/en-US/mass-entity-in-unreal-engine/

---

### 🟡 Niagara Fluids
- **목적:** GPU 유체 시뮬레이션 (연기, 불, 액체)
- **사용 시점:** 사실적인 화염/연기 효과, 물 시뮬레이션
- **상태:** 실험적 → 프로덕션 준비됨 (UE 5.4+)
- **플러그인:** `NiagaraFluids` (내장)
- **공식:** https://docs.unrealengine.com/5.7/en-US/niagara-fluids-in-unreal-engine/

---

### 🟡 Water Plugin
- **목적:** 부력을 포함한 바다, 강, 호수 렌더링
- **사용 시점:** 수역, 보트, 수영이 포함된 게임
- **상태:** 프로덕션 준비됨 (UE 5.0+)
- **플러그인:** `Water` (내장)
- **공식:** https://docs.unrealengine.com/5.7/en-US/water-system-in-unreal-engine/

---

### 🟡 Landmass Plugin
- **목적:** Terrain 조각 및 Landscape 편집
- **사용 시점:** 대규모 지형 수정, 절차적 Landscape
- **상태:** 프로덕션 준비됨
- **플러그인:** `Landmass` (내장)
- **공식:** https://docs.unrealengine.com/5.7/en-US/landmass-plugin-in-unreal-engine/

---

### 🟡 Chaos Destruction
- **목적:** 실시간 파괴 및 파쇄
- **사용 시점:** 파괴 가능한 환경 (벽, 건물, 오브젝트)
- **상태:** 프로덕션 준비됨 (UE 5.0+)
- **플러그인:** `ChaosDestruction` (내장)
- **공식:** https://docs.unrealengine.com/5.7/en-US/destruction-in-unreal-engine/

---

### 🟡 Chaos Vehicle
- **목적:** 고급 차량 물리 (휠 차량, 서스펜션)
- **사용 시점:** 레이싱 게임, 차량 중심의 게임플레이
- **상태:** 프로덕션 준비됨 (PhysX Vehicles 대체)
- **플러그인:** `ChaosVehicles` (내장)
- **공식:** https://docs.unrealengine.com/5.7/en-US/chaos-vehicles-overview-in-unreal-engine/

---

### 🟡 Geometry Scripting
- **목적:** 런타임 절차적 Mesh 생성 및 편집
- **사용 시점:** 동적 Mesh 생성, 절차적 모델링
- **상태:** 프로덕션 준비됨 (UE 5.1+)
- **플러그인:** `GeometryScripting` (내장)
- **공식:** https://docs.unrealengine.com/5.7/en-US/geometry-scripting-in-unreal-engine/

---

### 🟡 Motion Design Tools
- **목적:** 모션 그래픽, 절차적 애니메이션, 키프레임 애니메이션
- **사용 시점:** UI 애니메이션, 절차적 모션, 키프레임 시퀀스
- **상태:** 실험적 → 프로덕션 준비됨 (UE 5.4+)
- **플러그인:** `MotionDesign` (내장)
- **공식:** https://docs.unrealengine.com/5.7/en-US/motion-design-mode-in-unreal-engine/

---

## 실험적 플러그인 (주의하여 사용)

### ⚠️ AI Assistant (UE 5.7+)
- **목적:** 에디터 내장 AI 가이드 및 도움말
- **상태:** 실험적
- **플러그인:** UE 5.7 설정에서 활성화
- **공식:** UE 5.7 릴리스에서 발표

---

### ⚠️ OpenXR (VR/AR)
- **목적:** 크로스 플랫폼 VR/AR 지원
- **사용 시점:** VR/AR 게임
- **상태:** VR 프로덕션 준비됨, AR 실험적
- **플러그인:** `OpenXR` (내장)
- **공식:** https://docs.unrealengine.com/5.7/en-US/openxr-in-unreal-engine/

---

### ⚠️ Online Subsystem (EOS, Steam 등)
- **목적:** 플랫폼에 독립적인 온라인 서비스 (매치메이킹, 친구, 업적)
- **사용 시점:** 온라인 기능을 갖춘 멀티플레이어 게임
- **상태:** 프로덕션 준비됨
- **플러그인:** `OnlineSubsystem`, `OnlineSubsystemEOS`, `OnlineSubsystemSteam`
- **공식:** https://docs.unrealengine.com/5.7/en-US/online-subsystem-in-unreal-engine/

---

## 폐기된 플러그인 (신규 프로젝트에서는 사용 금지)

### ❌ PhysX Vehicles
- **폐기됨:** Chaos Vehicles 를 대신 사용
- **상태:** 레거시, 권장되지 않음

---

### ❌ Old Replication Graph
- **폐기됨:** Iris 로 대체됨 (UE 5.1+)
- **상태:** 최신 네트워킹에는 Iris 사용

---

## 온디맨드 WebSearch 전략

위 목록에 없는 플러그인에 대해 사용자가 질문할 경우 다음 방식을 따릅니다:

1. 최신 문서를 위해 **WebSearch** 실행: `"Unreal Engine 5.7 [plugin name]"`
2. 다음 사항을 확인:
   - 컷오프 이후인지 (2025년 5월 학습 데이터 이후)
   - 실험적 vs 프로덕션 준비됨
   - UE 5.7 에서 여전히 지원되는지
3. 향후 참조를 위해 `plugins/[plugin-name].md` 에 발견 사항을 선택적으로 캐시

---

## 빠른 의사결정 가이드

**어빌리티/스킬/버프가 필요하다** → **Gameplay Ability System (GAS)** *(❌ ProjectFreeHero 미사용 — `ue-blueprint-specialist` 의 커스텀 BP 시스템 사용)*
**크로스 플랫폼 UI 가 필요하다 (콘솔 + PC)** → **CommonUI**
**동적 카메라가 필요하다** → **Gameplay Camera System**
**절차적 월드가 필요하다** → **PCG**
**대규모 군중이 필요하다 (AI 수천 개)** → **Mass Entity**
**파괴 가능한 환경이 필요하다** → **Chaos Destruction**
**차량이 필요하다** → **Chaos Vehicles**
**물/바다가 필요하다** → **Water Plugin**
**VR/AR 이 필요하다** → **OpenXR**

---

**최종 업데이트:** 2026-02-13
**엔진 버전:** Unreal Engine 5.7
**LLM 지식 컷오프:** 2025년 5월
