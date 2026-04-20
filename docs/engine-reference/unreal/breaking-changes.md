# Unreal Engine 5.7 — 호환성 파괴 변경 사항

**최종 검증일:** 2026-02-13

본 문서는 (모델 학습에 포함되었을 가능성이 높은) Unreal Engine 5.3 과 (현재 버전인) Unreal Engine 5.7
사이의 호환성 파괴 API 변경 사항 및 동작 차이를 추적합니다. 리스크 수준별로 정리되어 있습니다.

## HIGH RISK — 기존 코드를 깨뜨립니다

### Substrate Material System (5.7 에서 프로덕션 준비됨)
**버전:** UE 5.5+ (실험적), 5.7 (프로덕션 준비됨)

Substrate 는 기존 머티리얼 시스템을 모듈식, 물리적으로 정확한 프레임워크로 대체합니다.

```cpp
// ❌ OLD: Legacy material nodes (still work but deprecated)
// Standard material graph with Base Color, Metallic, Roughness, etc.

// ✅ NEW: Substrate material layers
// Use Substrate nodes: Substrate Slab, Substrate Blend, etc.
// Modular material authoring with true physical accuracy
```

**마이그레이션:** `Project Settings > Engine > Substrate` 에서 Substrate 를 활성화하고 Substrate 노드를 사용하여 머티리얼을 재구축하세요.

---

### PCG (Procedural Content Generation) API 전면 개편
**버전:** UE 5.7 (프로덕션 준비됨)

PCG 프레임워크가 프로덕션 준비 상태에 도달하면서 주요 API 변경이 이루어졌습니다.

```cpp
// ❌ OLD: Experimental PCG API (pre-5.7)
// Old node types, unstable API

// ✅ NEW: Production PCG API (5.7+)
// Use FPCGContext, IPCGElement, new node types
// Stable API, production-ready workflow
```

**마이그레이션:** 5.7 문서의 PCG 마이그레이션 가이드를 참조하세요. 실험적 PCG 코드의 경우 상당한 리팩토링이 필요합니다.

---

### Megalights 렌더링 시스템
**버전:** UE 5.5+

새로운 라이팅 시스템이 수백만 개의 동적 라이트를 지원합니다.

```cpp
// ❌ OLD: Limited dynamic lights (clustered forward shading)
// Max ~100-200 dynamic lights before performance degrades

// ✅ NEW: Megalights (5.5+)
// Millions of dynamic lights with minimal performance cost
// Enable: Project Settings > Engine > Rendering > Megalights
```

**마이그레이션:** 코드 변경은 필요 없지만 라이팅 동작이 달라질 수 있습니다. 활성화 후 Scene 을 테스트하세요.

---

## MEDIUM RISK — 동작 변경

### Enhanced Input System (이제 기본값)
**버전:** UE 5.1+ (권장), 5.7 (기본값)

Enhanced Input 이 이제 기본 입력 시스템입니다.

```cpp
// ❌ OLD: Legacy input bindings (deprecated)
InputComponent->BindAction("Jump", IE_Pressed, this, &ACharacter::Jump);

// ✅ NEW: Enhanced Input
SetupPlayerInputComponent(UInputComponent* PlayerInputComponent) {
    UEnhancedInputComponent* EIC = Cast<UEnhancedInputComponent>(PlayerInputComponent);
    EIC->BindAction(JumpAction, ETriggerEvent::Started, this, &ACharacter::Jump);
}
```

**마이그레이션:** 레거시 입력 바인딩을 Enhanced Input 액션으로 교체하세요.

---

### Nanite 기본 활성화
**버전:** UE 5.0+ (선택적), 5.7 (권장)

Nanite 가상화 지오메트리가 이제 Static Mesh 의 권장 워크플로우입니다.

```cpp
// Enable Nanite on static mesh:
// Static Mesh Editor > Details > Nanite Settings > Enable Nanite Support
```

**마이그레이션:** 하이폴리 Mesh 를 Nanite 로 변환하세요. 타깃 플랫폼에서 성능을 테스트하세요.

---

## LOW RISK — 폐기 (여전히 동작)

### Legacy Material System
**상태:** 폐기됨, 그러나 지원됨
**대체:** Substrate Material System

레거시 머티리얼은 여전히 동작하지만 신규 프로젝트에는 Substrate 가 권장됩니다.

---

### Old World Partition (UE4 방식)
**상태:** 폐기됨
**대체:** World Partition (UE5+)

대규모 월드에는 UE5 의 World Partition 시스템을 사용하세요.

---

## 플랫폼별 호환성 파괴 변경

### Windows
- **UE 5.7**: DirectX 12 가 이제 기본값 (이전 버전에서는 DX11 이었음)
- DX12 호환성을 위해 Shader 를 업데이트하세요

### macOS
- **UE 5.5+**: Metal 3 필수 (최소 macOS 13)

### Mobile
- **UE 5.7**: 최소 Android API 레벨이 26 (Android 8.0) 으로 상향됨
- 최소 iOS 배포 타깃이 iOS 14 로 상향됨

---

## 마이그레이션 체크리스트

UE 5.3 에서 UE 5.7 로 업그레이드할 때:

- [ ] Substrate 머티리얼 검토 (신규 시스템 도입 준비가 되었다면 변환)
- [ ] PCG 사용 감사 (실험적 버전을 사용 중이라면 프로덕션 API 로 업데이트)
- [ ] Megalights 성능 테스트 (활성화 후 벤치마크)
- [ ] 레거시 입력을 Enhanced Input 으로 마이그레이션
- [ ] 하이폴리 Mesh 를 Nanite 로 변환
- [ ] DX12 (Windows) 또는 Metal 3 (macOS) 를 위한 Shader 업데이트
- [ ] 최소 플랫폼 버전 확인 (Android 8.0, iOS 14)
- [ ] 타깃 하드웨어에서 Lumen 및 Nanite 성능 테스트

---

**출처:**
- https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-engine-5-7-release-notes
- https://dev.epicgames.com/documentation/en-us/unreal-engine/upgrading-projects-to-newer-versions-of-unreal-engine
