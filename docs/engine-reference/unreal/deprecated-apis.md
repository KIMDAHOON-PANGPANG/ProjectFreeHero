# Unreal Engine 5.7 — 폐기된 API

**최종 검증일:** 2026-02-13

폐기된 API 및 그 대체 수단을 빠르게 찾아볼 수 있는 표입니다.
형식: **X 대신** → **Y 사용**

---

## Input

| 폐기된 API | 대체 | 비고 |
|------------|-------------|-------|
| `InputComponent->BindAction()` | Enhanced Input `BindAction()` | 새로운 입력 시스템 |
| `InputComponent->BindAxis()` | Enhanced Input `BindAxis()` | 새로운 입력 시스템 |
| `PlayerController->GetInputAxisValue()` | Enhanced Input Action Values | 새로운 입력 시스템 |

**마이그레이션:** Enhanced Input 플러그인 설치, Input Actions 및 Input Mapping Contexts 생성.

---

## Rendering

| 폐기된 API | 대체 | 비고 |
|------------|-------------|-------|
| Legacy material nodes | Substrate material nodes | Substrate 는 5.7 에서 프로덕션 준비됨 |
| Forward shading (기본값) | Deferred + Lumen | UE5 에서 Lumen 이 기본값 |
| 기존 라이팅 워크플로우 | Lumen Global Illumination | 실시간 GI |

---

## World Building

| 폐기된 API | 대체 | 비고 |
|------------|-------------|-------|
| UE4 World Composition | World Partition (UE5) | 대규모 월드 스트리밍 |
| Level Streaming Volumes | World Partition Data Layers | 향상된 Level 스트리밍 |

---

## Animation

| 폐기된 API | 대체 | 비고 |
|------------|-------------|-------|
| 기존 애니메이션 리타겟팅 | IK Rig + IK Retargeter | UE5 리타겟팅 시스템 |
| Legacy control rig | Control Rig 2.0 | 프로덕션 준비된 리깅 |

---

## Gameplay

| 폐기된 API | 대체 | 비고 |
|------------|-------------|-------|
| `UGameplayStatics::LoadStreamLevel()` | World Partition streaming | Data Layers 사용 |
| 하드코딩된 입력 바인딩 | Enhanced Input system | 재바인딩 가능, 모듈식 입력 |

---

## Niagara (VFX)

| 폐기된 API | 대체 | 비고 |
|------------|-------------|-------|
| Cascade particle system | Niagara | Cascade 는 완전히 폐기됨 |

---

## Audio

| 폐기된 API | 대체 | 비고 |
|------------|-------------|-------|
| 기존 오디오 믹서 | MetaSounds | 절차적 오디오 시스템 |
| Sound Cue (복잡한 로직용) | MetaSounds | 더 강력한 노드 기반 시스템 |

---

## Networking

| 폐기된 API | 대체 | 비고 |
|------------|-------------|-------|
| `DOREPLIFETIME()` (기본형) | `DOREPLIFETIME_CONDITION()` | 최적화를 위한 조건부 리플리케이션 |

---

## C++ Scripting

| 폐기된 API | 대체 | 비고 |
|------------|-------------|-------|
| UObject 에 `TSharedPtr<T>` 사용 | `TObjectPtr<T>` | UE5 타입 안전 포인터 |
| 수동 RTTI 체크 | `Cast<T>()` / `IsA<T>()` | 타입 안전 캐스팅 |

---

## 빠른 마이그레이션 패턴

### Input 예제
```cpp
// ❌ Deprecated
void AMyCharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent) {
    PlayerInputComponent->BindAction("Jump", IE_Pressed, this, &ACharacter::Jump);
}

// ✅ Enhanced Input
#include "EnhancedInputComponent.h"

void AMyCharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent) {
    UEnhancedInputComponent* EIC = Cast<UEnhancedInputComponent>(PlayerInputComponent);
    if (EIC) {
        EIC->BindAction(JumpAction, ETriggerEvent::Started, this, &ACharacter::Jump);
    }
}
```

### Material 예제
```cpp
// ❌ Deprecated: Legacy material
// Use standard material graph (still works but not recommended)

// ✅ Substrate Material
// Enable: Project Settings > Engine > Substrate > Enable Substrate
// Use Substrate nodes in material editor
```

### World Partition 예제
```cpp
// ❌ Deprecated: Level streaming volumes
// Load/unload levels manually

// ✅ World Partition
// Enable: World Settings > Enable World Partition
// Use Data Layers for streaming
```

### Particle System 예제
```cpp
// ❌ Deprecated: Cascade
UParticleSystemComponent* PSC = CreateDefaultSubobject<UParticleSystemComponent>(TEXT("Particles"));

// ✅ Niagara
UNiagaraComponent* NiagaraComp = CreateDefaultSubobject<UNiagaraComponent>(TEXT("Niagara"));
```

### Audio 예제
```cpp
// ❌ Deprecated: Sound Cue for complex logic
// Use Sound Cue editor nodes

// ✅ MetaSounds
// Create MetaSound Source asset, use node-based audio
```

---

## 요약: UE 5.7 기술 스택

| 기능 | 사용 권장 (2026) | 회피 대상 (레거시) |
|---------|------------------|----------------------|
| **Input** | Enhanced Input | Legacy Input Bindings |
| **Materials** | Substrate | Legacy Material System |
| **Lighting** | Lumen + Megalights | Lightmaps + Limited Lights |
| **Particles** | Niagara | Cascade |
| **Audio** | MetaSounds | Sound Cue (로직용) |
| **World Streaming** | World Partition | World Composition |
| **Animation Retarget** | IK Rig + Retargeter | 기존 리타겟팅 |
| **Geometry** | Nanite (하이폴리) | 표준 Static Mesh LOD |

---

**출처:**
- https://docs.unrealengine.com/5.7/en-US/deprecated-and-removed-features/
- https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-engine-5-7-release-notes
