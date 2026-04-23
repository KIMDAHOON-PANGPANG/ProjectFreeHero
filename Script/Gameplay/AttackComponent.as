/*
 * AttackComponent.as
 *
 * ProjectFreeHero M1 — 2.2 AttackComponent
 * 오너 전방 구 트레이스로 HealthComponent 보유 액터에 데미지 적용.
 * 같은 Attack() 호출 내 중복 히트 차단 (로컬 TSet).
 *
 * 사용법 (에디터):
 *   1. BP Actor 에서 Components → Add → "Attack Component" 검색
 *   2. AttackRange / AttackRadius / Damage 를 Details 패널에서 편집 가능
 *   3. BP 그래프에서 Attack() 호출 시 전방 트레이스 실행
 *
 * 노트: Angelscript 바인딩상 ECollisionChannel 의 표준 이름(ECC_Pawn 등)은
 *       노출되지 않고 프로젝트 프로필 이름만 enum 으로 등록되므로,
 *       이름 의존성을 줄이기 위해 SweepMultiByProfile + FName("Pawn") 사용.
 *       "Pawn" 프로필은 Config/DefaultEngine.ini 에서 정의됨.
 */

class UAttackComponent : UActorComponent
{
    UPROPERTY(Category = "Attack")
    float AttackRange = 300.0f;

    UPROPERTY(Category = "Attack")
    float AttackRadius = 80.0f;

    UPROPERTY(Category = "Attack")
    float Damage = 20.0f;

    UPROPERTY(Category = "Attack")
    FName TraceProfileName = n"Pawn";

    UFUNCTION(BlueprintCallable, Category = "Attack")
    void Attack()
    {
        AActor OwnerActor = GetOwner();
        if (OwnerActor == nullptr)
            return;

        FVector Start = OwnerActor.GetActorLocation();
        FVector End = Start + OwnerActor.GetActorForwardVector() * AttackRange;

        FCollisionShape Shape = FCollisionShape::MakeSphere(AttackRadius);
        FCollisionQueryParams Params;
        Params.AddIgnoredActor(OwnerActor);

        TArray<FHitResult> OutHits;
        System::SweepMultiByProfile(
            OutHits,
            Start,
            End,
            FQuat::Identity,
            TraceProfileName,
            Shape,
            Params);

        TSet<AActor> HitActors;
        for (FHitResult& H : OutHits)
        {
            AActor HitActor = H.GetActor();
            if (HitActor == nullptr)
                continue;
            if (HitActors.Contains(HitActor))
                continue;

            HitActors.Add(HitActor);

            UHealthComponent HC = UHealthComponent::Get(HitActor);
            if (HC == nullptr)
                continue;

            HC.ApplyDamage(Damage);
            Log(f"Hit: {HitActor.GetName()} -{Damage} HP");
        }
    }
}
