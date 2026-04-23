/*
 * TestAttributeSet.as
 *
 * ProjectFreeHero BP+Angelscript+GAS 재활성 PoC (Plan §6.2 후보 2, R5 검증).
 * UAngelscriptAttributeSet 상속으로 GAS UAttributeSet 의 C++ 제약을 우회.
 *
 * 사용법 (에디터):
 *   1. BP Actor 에 AbilitySystemComponent (또는 UAngelscriptAbilitySystemComponent) 부착
 *   2. BP 그래프: AbilitySystemComponent → Register Attribute Set → UTestAttributeSet 선택
 *   3. Health / MaxHealth 에 대해 GetAttributeCurrentValue / SetAttributeBaseValue 호출
 */

class UTestAttributeSet : UAngelscriptAttributeSet
{
    // AttributeName 은 UAngelscriptAttributeSet::PostInitProperties 에서 auto-populate.
    // 초기값은 GameplayEffect 또는 InitFromMetaDataTable 로 주입. (여기서는 기본값 0.0)
    UPROPERTY(Category = "Attributes", Replicated)
    FAngelscriptGameplayAttributeData Health;

    UPROPERTY(Category = "Attributes", Replicated)
    FAngelscriptGameplayAttributeData MaxHealth;
}
