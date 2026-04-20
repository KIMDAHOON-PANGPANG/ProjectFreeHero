# Unreal Engine 5.7 — 현재 베스트 프랙티스

**최종 검증일:** 2026-02-13

LLM 의 학습 데이터에 포함되지 않았을 수 있는 모던 UE5 패턴입니다.
UE 5.7 기준 프로덕션 준비된 권장 사항입니다.

---

## 프로젝트 셋업

### 신규 프로젝트는 UE 5.7 사용
- 최신 기능: Megalights, 프로덕션 준비된 Substrate 및 PCG
- 더 나은 성능과 안정성

### 올바른 렌더링 기능 선택
- **Lumen**: 실시간 글로벌 일루미네이션 (대부분의 프로젝트에 권장)
- **Nanite**: 고폴리곤 메시를 위한 가상화 지오메트리 (상세한 환경에 권장)
- **Megalights**: 수백만 개의 동적 라이트 (복잡한 라이팅에 권장)
- **Substrate**: 모듈식 머티리얼 시스템 (신규 프로젝트에 권장)

---

## C++ 코딩

### 모던 C++ 기능 사용 (UE5.7 의 C++20)

```cpp
// ✅ TObjectPtr<T> 사용 (UE5 타입 안전 포인터)
UPROPERTY()
TObjectPtr<UStaticMeshComponent> MeshComp;

// ✅ 구조적 바인딩
if (auto [bSuccess, Value] = TryGetValue(); bSuccess) {
    // Use Value
}

// ✅ Concepts 및 제약 (C++20)
template<typename T>
concept Damageable = requires(T t, float damage) {
    { t.TakeDamage(damage) } -> std::same_as<void>;
};
```

### 가비지 컬렉션을 위해 UPROPERTY() 사용

```cpp
// ✅ UPROPERTY 가 GC 가 이것을 삭제하지 않도록 보장
UPROPERTY()
TObjectPtr<AActor> MyActor;

// ❌ Raw 포인터는 댕글링이 될 수 있음
AActor* MyActor; // 위험! 가비지 컬렉션될 수 있음
```

### Blueprint 노출을 위해 UFUNCTION() 사용

```cpp
// ✅ Blueprint 에서 호출 가능
UFUNCTION(BlueprintCallable, Category="Combat")
void TakeDamage(float Damage);

// ✅ Blueprint 에서 구현 가능
UFUNCTION(BlueprintImplementableEvent, Category="Combat")
void OnDeath();
```

---

## Blueprint 베스트 프랙티스

### Blueprint vs C++ 사용

- **C++**: 코어 게임플레이 시스템, 성능이 중요한 코드, 로우레벨 엔진 상호작용
- **Blueprint**: 빠른 프로토타이핑, 콘텐츠 제작, 데이터 드리븐 로직, 디자이너 워크플로

### Blueprint 성능 팁

```cpp
// ✅ Event Tick 은 아껴서 사용 (비용이 큼)
// 타이머 또는 이벤트 선호

// ✅ Blueprint Nativization 사용 (Blueprint → C++)
// Project Settings > Packaging > Blueprint Nativization

// ✅ 자주 접근하는 컴포넌트는 캐싱
// 매 틱마다 GetComponent 를 호출하지 말 것
```

---

## 렌더링 (UE 5.7)

### 글로벌 일루미네이션에 Lumen 사용

```cpp
// 활성화: Project Settings > Engine > Rendering > Dynamic Global Illumination Method = Lumen
// 실시간 GI, 라이트맵 베이킹 불필요 (권장)
```

### 고폴리곤 메시에 Nanite 사용

```cpp
// Static Mesh 에서 활성화: Details > Nanite Settings > Enable Nanite Support
// 수백만 개의 트라이앵글을 자동으로 LOD (상세 메시에 권장)
```

### 복잡한 라이팅에 Megalights 사용 (UE 5.5+)

```cpp
// 활성화: Project Settings > Engine > Rendering > Megalights = Enabled
// 수백만 개의 동적 라이트를 최소 비용으로 지원
```

### Substrate 머티리얼 사용 (5.7 에서 프로덕션 준비됨)

```cpp
// 활성화: Project Settings > Engine > Substrate > Enable Substrate
// 모듈식, 물리적으로 정확한 머티리얼 (신규 프로젝트에 권장)
```

---

## Enhanced Input System

### Enhanced Input 셋업

```cpp
// 1. Input Action 생성 (IA_Jump)
// 2. Input Mapping Context 생성 (IMC_Default)
// 3. 매핑 추가: IA_Jump → Space Bar

// C++ 셋업:
#include "EnhancedInputComponent.h"
#include "EnhancedInputSubsystems.h"

void AMyCharacter::BeginPlay() {
    Super::BeginPlay();

    if (APlayerController* PC = Cast<APlayerController>(GetController())) {
        if (UEnhancedInputLocalPlayerSubsystem* Subsystem =
            ULocalPlayer::GetSubsystem<UEnhancedInputLocalPlayerSubsystem>(PC->GetLocalPlayer())) {
            Subsystem->AddMappingContext(DefaultMappingContext, 0);
        }
    }
}

void AMyCharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent) {
    UEnhancedInputComponent* EIC = Cast<UEnhancedInputComponent>(PlayerInputComponent);
    EIC->BindAction(JumpAction, ETriggerEvent::Started, this, &ACharacter::Jump);
    EIC->BindAction(MoveAction, ETriggerEvent::Triggered, this, &AMyCharacter::Move);
}

void AMyCharacter::Move(const FInputActionValue& Value) {
    FVector2D MoveVector = Value.Get<FVector2D>();
    AddMovementInput(GetActorForwardVector(), MoveVector.Y);
    AddMovementInput(GetActorRightVector(), MoveVector.X);
}
```

---

## Gameplay Ability System (GAS)

### 복잡한 게임플레이에 GAS 사용

```cpp
// ✅ GAS 사용: 어빌리티, 버프, 데미지 계산, 쿨다운
// 모듈식, 확장 가능, 멀티플레이어 대응

// 설치: "Gameplay Abilities" 플러그인 활성화

// 어빌리티 예시:
UCLASS()
class UGA_Fireball : public UGameplayAbility {
    GENERATED_BODY()

public:
    virtual void ActivateAbility(...) override {
        // 어빌리티 로직
        SpawnFireball();
        CommitAbility(); // 코스트/쿨다운 커밋
    }
};
```

---

## World Partition (대규모 월드)

### 오픈 월드에 World Partition 사용

```cpp
// 활성화: World Settings > Enable World Partition
// 플레이어 위치를 기반으로 월드 셀을 자동 스트리밍

// Data Layer: 콘텐츠 구성 (예: "Gameplay", "Audio", "Lighting")
// Runtime Data Layer: 런타임에 로드/언로드
```

---

## Niagara (VFX)

### Niagara 사용 (Cascade 아님)

```cpp
// 생성: Content Browser > 우클릭 > FX > Niagara System
// GPU 가속, 노드 기반 파티클 시스템 (권장)

// 파티클 스폰:
UNiagaraComponent* NiagaraComp = UNiagaraFunctionLibrary::SpawnSystemAtLocation(
    GetWorld(),
    ExplosionSystem,
    GetActorLocation()
);
```

---

## MetaSounds (오디오)

### 프로시저럴 오디오에 MetaSounds 사용

```cpp
// 생성: Content Browser > 우클릭 > Sounds > MetaSound Source
// 노드 기반 오디오, 복잡한 로직에서 Sound Cue 를 대체 (권장)

// MetaSound 재생:
UAudioComponent* AudioComp = UGameplayStatics::SpawnSound2D(
    GetWorld(),
    MetaSoundSource
);
```

---

## 복제 (멀티플레이어)

### 서버 권한 패턴

```cpp
// ✅ 클라이언트가 입력을 보내고, 서버가 검증 및 복제
UFUNCTION(Server, Reliable)
void Server_Move(FVector Direction);

void AMyCharacter::Server_Move_Implementation(FVector Direction) {
    // 서버가 검증 및 이동 적용
    AddMovementInput(Direction);
}

// ✅ 중요 상태 복제
UPROPERTY(Replicated)
int32 Health;

void AMyCharacter::GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& OutLifetimeProps) const {
    Super::GetLifetimeReplicatedProps(OutLifetimeProps);
    DOREPLIFETIME(AMyCharacter, Health);
}
```

---

## 성능 최적화

### 오브젝트 풀링 사용

```cpp
// ✅ Spawn/Destroy 대신 오브젝트 재사용
TArray<AActor*> ProjectilePool;

AActor* GetPooledProjectile() {
    for (AActor* Proj : ProjectilePool) {
        if (!Proj->IsActive()) {
            Proj->SetActive(true);
            return Proj;
        }
    }
    // 풀 고갈, 새로 스폰
    return SpawnNewProjectile();
}
```

### Instanced Static Mesh 사용

```cpp
// ✅ Hierarchical Instanced Static Mesh Component (HISM)
// 동일한 메시 수천 개를 단일 드로우 콜로 렌더링
UHierarchicalInstancedStaticMeshComponent* HISM = CreateDefaultSubobject<UHierarchicalInstancedStaticMeshComponent>(TEXT("Trees"));
for (int i = 0; i < 1000; i++) {
    HISM->AddInstance(FTransform(RandomLocation));
}
```

---

## 디버깅

### 로깅 사용

```cpp
// ✅ 구조화된 로깅
UE_LOG(LogTemp, Warning, TEXT("Player health: %d"), Health);

// 커스텀 로그 카테고리
DECLARE_LOG_CATEGORY_EXTERN(LogMyGame, Log, All);
DEFINE_LOG_CATEGORY(LogMyGame);
UE_LOG(LogMyGame, Error, TEXT("Critical error!"));
```

### Visual Logger 사용

```cpp
// ✅ 비주얼 디버깅
#include "VisualLogger/VisualLogger.h"

UE_VLOG_SEGMENT(this, LogTemp, Log, StartPos, EndPos, FColor::Red, TEXT("Raycast"));
UE_VLOG_LOCATION(this, LogTemp, Log, TargetLocation, 50.f, FColor::Green, TEXT("Target"));
```

---

## 요약: UE 5.7 권장 스택

| 기능 | 사용 권장 (2026) | 노트 |
|---------|------------------|-------|
| **라이팅** | Lumen + Megalights | 실시간 GI, 수백만 개의 라이트 |
| **지오메트리** | Nanite | 고폴리곤 메시, 자동 LOD |
| **머티리얼** | Substrate | 모듈식, 물리적으로 정확 |
| **입력** | Enhanced Input | 리바인드 가능, 모듈식 |
| **VFX** | Niagara | GPU 가속 |
| **오디오** | MetaSounds | 프로시저럴 오디오 |
| **월드 스트리밍** | World Partition | 대규모 오픈 월드 |
| **게임플레이** | Gameplay Ability System | 복잡한 어빌리티, 버프 |

---

**출처:**
- https://docs.unrealengine.com/5.7/en-US/
- https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-engine-5-7-release-notes
