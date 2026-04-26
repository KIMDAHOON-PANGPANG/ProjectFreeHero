/*
 * HealthComponent.as
 *
 * ProjectFreeHero BP+Angelscript 정책 PoC 샘플 (Plan §6.2 후보 1)
 * Hot-reload + BP 경계 검증용 최소 컴포넌트.
 *
 * 사용법 (에디터):
 *   1. BP Actor 에서 Components → Add → "Health Component" 검색
 *   2. MaxHealth, CurrentHealth 를 Details 패널에서 편집 가능
 *   3. BP 그래프에서 ApplyDamage / Heal / GetHealthPercent / IsDead 호출 가능
 */

class UHealthComponent : UActorComponent
{
    UPROPERTY(Category = "Health")
    float MaxHealth = 100.0f;

    UPROPERTY(Category = "Health")
    float CurrentHealth = 100.0f;

    /**
     * MaxHealth 를 NewMax 로 재설정하고 CurrentHealth 도 동일 값으로 만들어
     * "풀 HP 로 시작" 시키는 헬퍼. BP BeginPlay 에서 인스턴스별 HP override 용.
     * (Angelscript 는 static 미지원 — instance method. BP 에서 호출 시
     *  Get HealthComponent → SetMaxHealth.Target 에 명시적 연결 필요.)
     */
    UFUNCTION(BlueprintCallable, Category = "Health")
    void SetMaxHealth(float NewMax)
    {
        if (NewMax <= 0.0f)
            return;

        MaxHealth = NewMax;
        CurrentHealth = NewMax;
    }

    UFUNCTION(BlueprintCallable, Category = "Health")
    void ApplyDamage(float DamageAmount)
    {
        if (DamageAmount <= 0.0f)
            return;

        CurrentHealth = Math::Max(0.0f, CurrentHealth - DamageAmount);
        Log(f"HealthComponent: -{DamageAmount} → {CurrentHealth}/{MaxHealth}");
    }

    UFUNCTION(BlueprintCallable, Category = "Health")
    void Heal(float HealAmount)
    {
        if (HealAmount <= 0.0f)
            return;

        CurrentHealth = Math::Min(MaxHealth, CurrentHealth + HealAmount);
        Log(f"HealthComponent: +{HealAmount} → {CurrentHealth}/{MaxHealth}");
    }

    UFUNCTION(BlueprintPure, Category = "Health")
    float GetHealthPercent() const
    {
        return MaxHealth > 0.0f ? CurrentHealth / MaxHealth : 0.0f;
    }

    UFUNCTION(BlueprintPure, Category = "Health")
    bool IsDead() const
    {
        return CurrentHealth <= 0.0f;
    }

    UFUNCTION(BlueprintPure, Category = "Health")
    bool IsExecutable() const
    {
        return !IsDead() && CurrentHealth <= MaxHealth * 0.2f;
    }
}
