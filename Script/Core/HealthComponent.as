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
}
