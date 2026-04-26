/*
 * TelegraphComponent.as
 *
 * ProjectFreeHero M1 — 3.1 TelegraphComponent
 * 적의 강공 직전 "공격 시작!" 시각 신호 → 0.8초 카운트다운 → OnTelegraphFire.
 *
 * 사용법 (BP):
 *   1. 적 BP Actor 에 "Telegraph Component" 추가
 *   2. Details 패널에서 TelegraphDuration / bShowHeadIcon / bShowGroundRing 튜닝
 *   3. AI 가 강공 결정 시 StartTelegraph() 호출
 *   4. OnTelegraphFire 델리게이트 구독 → 실제 AttackComponent.Attack() 호출
 *   5. 도중 사망/이탈 시 CancelTelegraph() 호출 → OnTelegraphCancelled 발행
 *
 * 검증 (M1 3.1 AC):
 *   AC1: StartTelegraph() → OnTelegraphStart broadcast + 로그 "Telegraph: Start (duration=X)"
 *   AC2: TelegraphDuration 후 OnTelegraphFire 1회 + 로그 "Telegraph: Fire"
 *   AC3: 도중 CancelTelegraph() → OnTelegraphCancelled + 로그 "Telegraph: Cancelled"
 *
 * 구현 노트:
 *   - 타이머 대신 Tick 기반 — Angelscript Timer 바인딩 명확치 않아 우회.
 *     매 프레임 if (!bActive) return; 으로 비활성 시 즉시 빠짐 — 비용 미미.
 *   - default PrimaryComponentTick.bCanEverTick = true 로 ActorComponent
 *     기본 비활성 Tick 을 강제 활성.
 *   - GDD: design/gdd/telegraph-system.md
 */

UDELEGATE void FTelegraphEvent();

class UTelegraphComponent : UActorComponent
{
    default PrimaryComponentTick.bCanEverTick = true;
    default PrimaryComponentTick.bStartWithTickEnabled = true;

    // ---- Tuning Knobs (Details 패널 노출) ----

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Telegraph")
    float TelegraphDuration = 0.8f;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Telegraph|UI")
    bool bShowHeadIcon = true;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Telegraph|UI")
    bool bShowGroundRing = false;

    // ---- Events (BP 에서 구독 가능) ----

    UPROPERTY(BlueprintAssignable, Category = "Telegraph|Events")
    FTelegraphEvent OnTelegraphStart;

    UPROPERTY(BlueprintAssignable, Category = "Telegraph|Events")
    FTelegraphEvent OnTelegraphFire;

    UPROPERTY(BlueprintAssignable, Category = "Telegraph|Events")
    FTelegraphEvent OnTelegraphCancelled;

    // ---- 내부 상태 (Read-only at runtime) ----

    private bool bActive = false;
    private float ActiveDuration = 0.0f;
    private float Elapsed = 0.0f;

    // ---- Public API ----

    /**
     * 텔레그래프 시작. Duration=0 또는 음수면 TelegraphDuration default 사용.
     * 이미 활성 중이면 무시 (M1 단순화 — 큐잉 X).
     */
    UFUNCTION(BlueprintCallable, Category = "Telegraph")
    void StartTelegraph(float Duration = 0.0f)
    {
        if (bActive)
        {
            Log("Telegraph: Already active, ignored");
            return;
        }

        float UseDuration = Duration > 0.0f ? Duration : TelegraphDuration;
        if (UseDuration <= 0.0f)
        {
            Log(f"Telegraph: Invalid duration ({UseDuration}), ignored");
            return;
        }

        ActiveDuration = UseDuration;
        Elapsed = 0.0f;
        bActive = true;

        OnTelegraphStart.Broadcast();
        Log(f"Telegraph: Start (duration={ActiveDuration})");
    }

    /**
     * 텔레그래프 중단. 활성 중일 때만 동작. OnTelegraphCancelled broadcast.
     */
    UFUNCTION(BlueprintCallable, Category = "Telegraph")
    void CancelTelegraph()
    {
        if (!bActive)
            return;

        bActive = false;
        OnTelegraphCancelled.Broadcast();
        Log("Telegraph: Cancelled");
    }

    UFUNCTION(BlueprintPure, Category = "Telegraph")
    bool IsActive() const
    {
        return bActive;
    }

    UFUNCTION(BlueprintPure, Category = "Telegraph")
    float GetRemainingTime() const
    {
        return bActive ? Math::Max(0.0f, ActiveDuration - Elapsed) : 0.0f;
    }

    // ---- Tick — 시간 카운트 ----

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        if (!bActive)
            return;

        Elapsed += DeltaSeconds;
        if (Elapsed >= ActiveDuration)
        {
            bActive = false;
            OnTelegraphFire.Broadcast();
            Log("Telegraph: Fire");
        }
    }
}
