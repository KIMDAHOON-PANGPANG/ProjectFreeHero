# Plan — BP-only → "BP + Angelscript + UBG" 정책 전환

> **상태:** Proposal (승인 대기)
> **작성일:** 2026-04-22
> **대상 프로젝트:** ProjectFreeHero (UE 5.7, BP-only 정책 적용 중)
> **사용자 의사결정 반영:** 설치는 보류하고 리서치 우선 / PoC 먼저 / 정책 + 설치 + GDD 영향 평가까지
> **원본 위치:** 이 Plan 파일은 Claude Code의 `/plans/` 디렉터리에서 생성됨.
> 이 저장소에는 집/다른 머신에서의 세션 재개를 위해 사본으로 보관됨.
> 연결 리서치 노트: `docs/research/angelscript-ue57-feasibility.md`

---

## 0. 요약 (TL;DR)

- **무엇:** Blueprint 전용 언어 정책을 **Blueprint + Angelscript**로 확장. C++는 **계속 금지**(예외: Hazelight 엔진 포크 빌드 내부에 존재하지만 프로젝트 코드로 작성하지 않음). UBG는 기존 역할 유지.
- **왜:** AttributeSet의 C++ 요구로 GAS가 비활성 → Angelscript로 UObject 상속이 가능해지면 GAS 재활성이 선택지에 오름. 이터레이션 속도, 텍스트 diff, UE 네이티브 통합.
- **언제:** 이 Plan은 **리서치 + PoC 승인 제안**까지만. 설치/코드 변경은 후속 세션.
- **주요 리스크:** Hazelight 공식의 UE 5.7 브랜치 미확인 / UNREANGEL 공식 테스트는 UE 5.4 까지 / UBG가 엔진 포크에서 동작하는지 미검증 / 한글 경로 이슈가 포크 빌드에서도 재현 가능.

---

## 1. Context (왜 이 변경이 필요한가)

### 1.1 현재 BP-only 정책의 배경

| 원인 | 현재 제약 | 파급 |
|---|---|---|
| `UAttributeSet` C++ 상속 요구 | GAS 전체 스택 비활성 | 커스텀 `UAttributeComponent`/`UAbilityComponent`/`UEffectDataAsset` 구현 필요 |
| Source/ 미생성 (런처 바이너리) | C++ 빌드 툴체인 부재 | 엔진 서브시스템 상속 전반이 BP 한계 |
| UBG가 BP 생성 중심 | C++ 보조 도구 없음 | BP-only 정책이 도구 정합에 유리 |
| 한글 경로(`C:\Users\김다훈`) | Zen DDC 비활성, FileSystem DDC | 엔진 포크 빌드 시 재검증 필요 |

### 1.2 Angelscript 도입의 편익 가설

- **C++ 대안:** `class UHealthAttributeSet : UAttributeSet`과 같은 UObject 상속이 스크립트에서 가능 → GAS 재활성의 기술 전제
- **이터레이션:** Hot-reload 기반. BP 컴파일보다 빠르고 C++보다 훨씬 빠름
- **UE 네이티브 통합:** BP/UObject와 양방향 노출. BP에서 Angelscript 클래스 참조 가능
- **소스 제어 친화:** `.as`는 텍스트 → `.uasset` 바이너리와 달리 diff/리뷰 가능

### 1.3 핵심 전제

**UBG와의 공존은 필수 요건.** UBG가 Hazelight 엔진 포크 또는 바닐라 UNREANGEL 환경에서 정상 동작하지 않으면 본 Plan은 중단하고 BP-only를 유지합니다. 이 결정은 §2 리서치 결과에 의해 게이팅됩니다.

---

## 2. Research Phase (설치 확정 전 필수 확인)

본 Plan은 리서치 완료 전까지 설치/코드 변경을 실행하지 않습니다.

### 2.1 리서치 체크리스트

| # | 항목 | 완료 기준 | 방법 |
|---|---|---|---|
| R1 | Hazelight 공식 저장소의 UE 5.7 브랜치 유무 | `github.com/Hazelight/UnrealEngine-Angelscript`의 `5.7`/`ue5-main`/`release-5.7` 등 브랜치 존재 및 최근 커밋 날짜 | WebFetch + Epic GitHub 접근 |
| R2 | UNREANGEL(바닐라 플러그인)의 UE 5.7 대응 | `WillGordon9999/UNREANGEL` 또는 `UE-Angelscript` 릴리스/이슈 트래커에서 5.7 지원 확인 | WebFetch |
| R3 | UBG가 바닐라 UE 5.7 + UNREANGEL 환경에서 동작 | BpGeneratorUltimate FAB 페이지 호환성 노트 / BlueprintsLab 공식 채널 | WebSearch + UBG 문서 |
| R4 | UBG가 Hazelight 엔진 포크에서 동작 | UBG가 Editor 모듈 의존성에 민감한지 / 포크의 `Programs/` 모듈 차이 | 문서 + GitHub 이슈 검색 |
| R5 | Angelscript로 `UAttributeSet` 상속 가능 여부 | Hazelight 공식 예제에서 `class UFooAttributeSet : UAttributeSet` 패턴 / GAS 플러그인 클래스의 Angelscript 노출 | Hazelight 공식 문서 + 예제 저장소 |
| R6 | DDC/한글 경로 이슈 포크에서 재현 | 엔진 포크 빌드 시 `DerivedDataCache/` 경로 설정 유지 여부 / Zen/FileSystem 선택이 프로젝트 Config에 보존되는지 | 공식 문서 + 로컬 환경 검토(빌드 전) |

### 2.2 리서치 산출물

- 리서치 노트 1건: `docs/research/angelscript-ue57-feasibility.md` (Plan 승인 후 작성)
- 결정: Scenario A (바닐라 + UNREANGEL) vs Scenario B (Hazelight 포크)
- **중단 조건:** R3 또는 R4가 "호환 불가"로 확정되면 Plan 폐기, BP-only 유지

### 2.3 시나리오 의사결정 매트릭스

| 조건 | Scenario A 권장 | Scenario B 권장 |
|---|---|---|
| R1 (Hazelight 5.7 브랜치 존재) | ✗ 무관 | ✓ 필수 |
| R2 (UNREANGEL 5.7 지원) | ✓ 필수 | ✗ 불필요 |
| R3 (UBG 바닐라 호환) | ✓ 필수 | ✗ 불필요 |
| R4 (UBG 포크 호환) | ✗ 불필요 | ✓ 필수 |
| R5 (AttributeSet 상속) | 부분 (플러그인 API 의존) | 완전 지원 가능성 높음 |
| R6 (DDC/한글 경로) | 현재 설정 재사용 | 재검증 필요 |

---

## 3. Installation Runbook (시나리오별)

**본 Plan에서는 실행하지 않음.** 러너북은 리서치 완료 후 선택된 시나리오에 대해서만 실행합니다.

### 3.1 Scenario A' — UnrealEngine-Angelscript-ZH 플러그인 경로 (선택됨)

**선택 근거:** 리서치 결과 Scenario A(UNREANGEL)는 UE 5.7 미지원, Scenario B(엔진 포크)는
Hazelight 공식 5.7 브랜치 미공개. 커뮤니티 포크 **UnrealEngine-Angelscript-ZH/AngelscriptProject**
(UE 5.7, 활발 유지, 2026-04-21 커밋)가 **플러그인 단독 경로**로 두 시나리오 모두를 대체.
전제: 정책 해석 (a) "사용자 게임 코드에서만 C++ 금지, 플러그인 C++ 빌드는 예외"로 명시화
(리서치 §8.1 CP2 결정 1 통과 시).

**사전 블로커 체크리스트**
- [ ] CP2 결정 1 (정책 해석 (a)) 승인 완료
- [ ] VS 2022 + Windows SDK + .NET SDK 설치 (없으면 별도 Task)
- [ ] 디스크 여유 ~10 GB (플러그인 빌드 산출물 + Intermediate)
- [ ] 현재 `.uproject` 백업 (git 커밋)
- [ ] `git status` 클린
- [ ] 한글 경로(`C:\Users\김다훈\`) DDC 현 설정 확인 — FileSystem DDC 유지 중

**설치 단계**
1. 참조 저장소 clone (프로젝트 외부 임시 경로):
   `git clone https://github.com/UnrealEngine-Angelscript-ZH/AngelscriptProject.git`
2. `Plugins/Angelscript/` 디렉터리만 프로젝트로 복사 →
   `ProjectFreeHero/Plugins/Angelscript/`
3. `ProjectFreeHero.uproject`의 `Plugins` 배열에
   `{"Name": "Angelscript", "Enabled": true}` 추가
   (EngineAssociation은 `"5.7"` 유지 — 런처 빌드 그대로)
4. Editor 첫 실행 → 플러그인 자동 컴파일 **(최초 ~30분 소요)**
   - 빌드 로그에서 `AngelscriptRuntime`, `AngelscriptCode` 모듈 컴파일 성공 확인
   - 실패 시 VS/SDK/.NET 버전 재점검 후 롤백
5. `Script/` 디렉터리 생성 (프로젝트 루트 기준, Angelscript 기본 검색 경로)
6. 샘플 `Script/Core/HealthComponent.as` 작성 (Plan §6.2 후보 1)
   → Editor 재시작 없이 hot-reload 동작 확인
7. BP에서 `UHealthComponent` 참조 가능한지 에디터에서 검증
8. (선택, R5 후속) `Script/Core/TestAttributeSet.as`로
   `UAngelscriptAttributeSet` 상속 샘플 작성 — GAS 재활성 기술 전제 확정

**UBG/MCP 영향**
- `.mcp.json` **수정 없음** (엔진 포크 아님, UBG 경로 불변)
- UBG 플러그인과 Angelscript 플러그인의 **동시 로드 안정성 검증 필요** →
  Plan §6.3 V5–V6 게이트(UBG MCP 5개 도구 응답 + `mcp__unreal-handshake__component`가
  Angelscript 컴포넌트 인식)로 커버
- 충돌 발생 시 UBG를 프로젝트 로컬(`Plugins/BpGeneratorUltimate/`)로 이동 고려

**롤백 (단계별)**
1. `.uproject`의 `Plugins` 배열에서 `Angelscript` 항목 제거
2. `Plugins/Angelscript/` 디렉터리 삭제
3. `Script/` 디렉터리 삭제 (Angelscript 전용이면)
4. `Binaries/`, `Intermediate/` 플러시 (Editor 종료 상태에서)
5. DDC 플러시는 **선택** — FileSystem DDC는 프로젝트 외부 경로이므로 보통 불필요
6. Editor 재시작 → 런처 UE 5.7로 정상 로드 확인

**DDC/경로 (한글 경로 주의):**
- 현재 `Config/DefaultEngine.ini`의 FileSystem DDC 설정 유지 (Zen DDC는 한글 경로 이슈로 비활성 중 — memory: `project_ue57_ddc_korean_path`)
- 플러그인 빌드 시 Intermediate는 프로젝트 내부(`Intermediate/Build/`)에 생성 → 한글 경로 영향 없음
- 만약 빌드 단계에서 인코딩 에러 발생 시 V8(Plan §6.3) 실패로 간주 → 롤백

**성공 기준 (PoC 진입 게이트):**
- [ ] 첫 빌드 성공 (V1)
- [ ] `.as` hot-reload 동작 (V2)
- [ ] BP에서 Angelscript 클래스 참조 가능 (V3–V4)
- [ ] UBG MCP 정상 응답 (V5–V6)
- [ ] 한글 경로 빌드 성공 (V8) — Plan §6.3 필수 게이트

---

### ~~3.2 Scenario B — Hazelight 공식 엔진 포크 경로~~ (SUPERSEDED by A')

> **상태:** Scenario A' 채택으로 불필요. Hazelight 공식 UE 5.7 브랜치가 공개 리스트에 없어 R1 확인 불가였고, 150GB+ 디스크 요구 및 UBG 공존 리스크가 있었음. 아래 내용은 **역사적 참조용**으로 보존.
> 참조: `docs/research/angelscript-ue57-feasibility.md` §7.

**사전 블로커 체크리스트**
- [ ] R1, R4 확인 완료
- [ ] Epic GitHub 접근 권한 (UnrealEngine 저장소 가입)
- [ ] VS 2022, Windows SDK, .NET 설치
- [ ] 디스크 여유 150 GB+
- [ ] 런처 UE 5.7과 공존 전략 (EngineAssociation 전환)
- [ ] `.uproject`, `Content/`, `Config/` 전체 백업

**설치 단계**
1. Hazelight 공식 저장소 Clone (R1에서 확인된 브랜치)
2. `Setup.bat` → `GenerateProjectFiles.bat` → VS 빌드 (Development Editor, Win64)
3. `Engine/Binaries/Win64/UnrealEditor.exe` 검증
4. `.uproject`의 `EngineAssociation`을 포크 GUID로 전환 (우클릭 → Switch Unreal Engine Version)
5. UBG 재설치 옵션:
   - **B1:** FAB 설치본을 포크 `Engine/Plugins/Marketplace/`로 복사
   - **B2:** 프로젝트 로컬 `Plugins/BpGeneratorUltimate/`로 이동
   - 선택은 R4 결과에 의존
6. `.mcp.json` 경로 재구성 (B1 또는 B2 경로)
7. Angelscript 기능 확인 (포크 내장)
8. 샘플 `.as` 파일 hot-reload 확인

**UBG/MCP 영향 (Critical)**
- `.mcp.json` **수정 필수**
- UBG가 포크의 Editor 모듈 API 변경에 취약한지 사전 검증 필요
- MCP 응답 시간/도구 목록 비교 테스트 (§6 PoC에서 커버)

**롤백**
1. EngineAssociation을 런처 `"5.7"`로 되돌림
2. `.mcp.json` 백업에서 복원
3. FAB 설치본 경로 재활성
4. 포크 엔진 디렉터리 삭제
5. DDC/Intermediate/Binaries 플러시
6. Editor 재시작 검증

**DDC/경로 (포크 특화):** FileSystem DDC를 프로젝트 Config에 고정 명시. 빌드 명령에 `-NoZenStore` 및 명시적 경로 지정. `DerivedDataCache.ini`의 `[InstalledDerivedDataBackendGraph]` 검토.

---

## 4. Policy & Agent Documentation Update

**본 Plan에서는 수정 지시를 포함하지 않음.** 수정 포인트만 명시합니다.

### 4.1 새 언어 정책 문구 (공통)

> **언어**: Blueprint + Angelscript. C++ 작성은 여전히 금지 (엔진 포크 빌드 경로에 한해 내부적으로 존재하지만 프로젝트 코드는 작성하지 않음). UBG는 BP 생성에 집중, Angelscript는 UObject 상속 및 시스템 레이어.

### 4.2 파일별 수정 포인트

| 파일 | 섹션/라인 | 수정 방침 |
|---|---|---|
| `CLAUDE.md` | L9 언어 정책 | "Blueprint + Angelscript. C++ 금지(엔진 포크 예외)"로 교체 |
| `CLAUDE.md` | L12–13 GAS 미사용 | R5 통과 시 "GAS 재활성 예정", 실패 시 현재 문구 유지 |
| `CLAUDE.md` | L22 `ue-gas-specialist` | R5 결과에 따라 활성/비활성 |
| `.claude/docs/technical-preferences.md` | L9 | 교체 |
| `.claude/docs/technical-preferences.md` | L26 | "C++ 읽기용 + Angelscript 동일 네이밍"으로 확장 |
| `.claude/docs/technical-preferences.md` | L50 금지 패턴 | "C++ 작성 금지 (엔진 포크 경로 제외)" |
| `.claude/docs/technical-preferences.md` | L55, L60 GAS | R5 결과 |
| `.claude/docs/technical-preferences.md` | L73–79 스페셜리스트 | 신설 `ue-angelscript-specialist` 추가 |
| `.claude/docs/technical-preferences.md` | L88 확장자 라우팅 | `.as` 행 추가 |
| `.claude/docs/directory-structure.md` | L10 Source/ 미사용 | "Script/는 Angelscript 사용, C++ Source/는 여전히 미사용" |
| `.claude/docs/directory-structure.md` | L27–30 | `Script/Gameplay/**` 경로 추가 |
| `.claude/docs/quick-start.md` | BP-only 2곳 | "BP + Angelscript" |
| `.claude/docs/agent-roster.md` | L53, 59, 73 | 신설 에이전트 포함 |
| `.claude/docs/agent-coordination-map.md` | L33–38 | `ue-angelscript-specialist` 라인 추가 |
| `.claude/agents/ue-blueprint-specialist.md` | description, 책임 테이블 | Angelscript 경계 추가, 주력 유지 |
| `.claude/agents/ue-blueprint-specialist.md` | "C++ 요청이 들어올 경우" | "C++ 거부 → Angelscript 대안 검토 → BP 대안" 3단계 |
| `.claude/agents/unreal-specialist.md` | 스코프 | Angelscript 환경 설정 / `.as` 플러그인 관리 추가 |
| `.claude/agents/ue-replication-specialist.md` | BP-only 복제 | "Angelscript 복제 가능" 조건부 추가 |
| `.claude/agents/ue-gas-specialist.md` | DEPRECATED 헤더 | R5 통과 시 제거 + 활성화 |
| `docs/engine-reference/unreal/PLUGINS.md` | GAS 섹션 (L21–38) | R5 결과 반영 |
| `docs/engine-reference/unreal/PLUGINS.md` | 빠른 의사결정(L206) | 어빌리티 권장 대상 조정 |

### 4.3 신설 에이전트 — `ue-angelscript-specialist`

**파일:** `.claude/agents/ue-angelscript-specialist.md` (신규)

| 속성 | 값 |
|---|---|
| name | `ue-angelscript-specialist` |
| 모델 | Sonnet |
| tools | Read, Glob, Grep, Write, Edit, Task |
| description | "Angelscript 시스템 레이어(UObject/UActorComponent/UAttributeSet 상속) 담당. BP 리드 및 UBG와 협업. C++ 작성은 여전히 금지." |

**책임 범위**
- `.as` 파일 전반 (`Script/Core/`, `Script/Gameplay/`, `Script/UI/`)
- UObject 상속 시스템 (특히 `UAttributeSet` — R5 통과 시)
- Angelscript ↔ BP 경계 설계 (`UCLASS()` 노출, `UFUNCTION()` 바인딩)
- Hot-reload 워크플로 가이드
- Angelscript 테스트 패턴

**다른 에이전트와의 경계**

| 작업 유형 | 담당 |
|---|---|
| `.as` 시스템 레이어, UObject 상속 | `ue-angelscript-specialist` |
| `.uasset` BP (콘텐츠, 데이터, 캐릭터) | `ue-blueprint-specialist` (주력 유지) |
| UMG/Widget BP | `ue-umg-specialist` |
| Config/Plugin/Editor | `unreal-specialist` |
| GAS `UGameplayAbility`/`UAttributeSet` | `ue-gas-specialist` (R5 통과 시) + `ue-angelscript-specialist` 공동 |
| 복제 | `ue-replication-specialist` (BP + `.as` 모두) |

**금지**
- ❌ C++ 파일 생성/편집
- ❌ BP 콘텐츠 직접 편집 (`ue-blueprint-specialist` 담당)
- ❌ Angelscript 플러그인 자체 수정

### 4.4 `ue-blueprint-specialist` 역할 조정

- **주력 유지** — 프로젝트 대부분은 여전히 BP 콘텐츠
- **축소 영역:** 시스템 레이어의 UObject 상속 작업은 Angelscript로 이관
- **협업 프로토콜:**
  1. BP 콘텐츠가 Angelscript 시스템을 참조할 때 → `ue-angelscript-specialist`가 먼저 인터페이스 확정
  2. Angelscript 정의 UObject를 BP에서 상속/참조 → BP 측은 `ue-blueprint-specialist`
  3. 충돌 시 `unreal-specialist` 중재

### 4.5 `ue-gas-specialist` 재활성 결정 포인트

**게이트:** R5 (Angelscript로 `UAttributeSet` 상속 가능)

- **통과 시:** `status: deprecated` 제거, "⛔ 비활성" 헤더 → "활성 (Angelscript 기반)", 모든 GAS 작업은 Angelscript로, `ue-angelscript-specialist`와 공동 작업
- **실패 시:** 현재 DEPRECATED 유지, 커스텀 BP 스택 유지, Plan의 GAS 재활성 섹션 폐기

### 4.6 파일 확장자 라우팅 추가

`.claude/docs/technical-preferences.md`의 라우팅 표에 추가:

| 파일 확장자/타입 | 스폰할 스페셜리스트 |
|---|---|
| `.as` (Angelscript) | `ue-angelscript-specialist` |
| `.as` (UAttributeSet 상속) | `ue-gas-specialist` (R5 통과 시) + `ue-angelscript-specialist` 공동 |

---

## 5. Existing GDD Impact Assessment

### 5.1 P0 GDD (`design/gdd/auto-target-warping.md`) 영향도

| 섹션 | 현재 전제 | Angelscript 도입 후 |
|---|---|---|
| §6.4 데이터 (BP 자산 4종) | 전부 BP | **보존.** 베이스 클래스를 Angelscript로 정의 가능 (R5 통과 시), 강제 아님 |
| §3.3 후보 탐색 로직 | BP 그래프 | 재작성 가능하나 PoC 대상 제외 (성능 이슈 없음) |
| §6.1 의존 시스템 | BP 가정 | 시스템 베이스는 Angelscript, 인스턴스는 BP 가능 |
| 구현 메모 "C++ 미사용" | 고정 | "C++ 미사용, Angelscript로 시스템 레이어 확장 가능"으로 조정 |

### 5.2 커스텀 BP 어빌리티 시스템의 운명

| R5 결과 | 조치 |
|---|---|
| **통과** | GAS 재활성 → 기존 커스텀 스택은 **마이그레이션 경로**. 새 시스템은 GAS + Angelscript, 기존은 deprecated 예고 후 이관 |
| **실패** | 커스텀 스택 **유지**. Angelscript는 도우미/헬퍼 레이어로만 활용 |

### 5.3 네이밍/데이터 구조 영향

| 항목 | 변경 | 보존 | 마이그레이션 |
|---|---|---|---|
| BP 네이밍 (`BP_*`, `WBP_*`, `BPI_*`) | - | ✓ | - |
| C++ 네이밍 (읽기용) | - | ✓ (Angelscript에도 동일) | - |
| Angelscript 파일 네이밍 | 신규 정의 필요 | - | - |
| `UAttributeComponent` → `UAttributeSet` (R5 통과 시) | 클래스 이름 변경 | - | API 이관 경로 문서화 |
| GameplayTag 계층 | - | ✓ | - |
| DataAsset 구조 | - | ✓ | - |

### 5.4 GDD 재작성 vs 섹션 추가

**결론: 섹션 추가로 충분** (재작성 불필요).
- §6.4 "데이터"에 Angelscript 참조 주석 추가
- 구현 메모를 "C++ 미사용, Angelscript 시스템 레이어 옵션"으로 확장

**단, R5 통과 시:** 신규 GDD 1건 필요 — `design/gdd/ability-system.md` (GAS 재활성, 어빌리티/어트리뷰트/이펙트 재정의, 커스텀 BP 스택 폐기 계획).

---

## 6. PoC Design

### 6.1 목표

리서치에서 선택된 시나리오(A 또는 B)로 **최소 샘플**을 구현해 Angelscript + UBG + BP 세 축의 공존을 검증.

### 6.2 최소 샘플

**후보 1 (권장): HealthComponent 1개**
- `Script/Core/HealthComponent.as` — `UActorComponent` 상속
- 프로퍼티: `MaxHealth`, `CurrentHealth` (`UPROPERTY(EditAnywhere, BlueprintReadWrite)`)
- 메서드: `ApplyDamage(float)`, `Heal(float)`, `OnHealthChanged` 델리게이트
- BP `BP_TestActor`에 부착
- UBG MCP로 활용한 BP 액터 생성 요청

**후보 2 (R5 통과 시 선택적): TestAttributeSet 1개**
- `Script/Core/TestAttributeSet.as` — `UAttributeSet` 상속
- 어트리뷰트: `Health`, `MaxHealth`
- AbilitySystemComponent에 등록 후 BP에서 접근

### 6.3 검증 기준 (PASS/FAIL 게이트)

| # | 기준 | 확인 방법 |
|---|---|---|
| V1 | 프로젝트 빌드 성공 (B) / 플러그인 로드 성공 (A) | Editor 로그 |
| V2 | `.as` 저장 → hot-reload 반영 (5초 이내) | 수동 테스트 |
| V3 | BP에서 Angelscript 클래스 참조 가능 | 수동 테스트 |
| V4 | Angelscript 프로퍼티가 BP 에디터에서 편집 가능 | 수동 테스트 |
| V5 | UBG MCP가 Angelscript 컴포넌트 인식 | `mcp__unreal-handshake__component` 응답 |
| V6 | UBG MCP 전체 도구 목록 정상 응답 | `mcp__unreal-handshake__get_tool_docs` |
| V7 | 프로젝트 패키징 성공 (Development, Win64) | UBT 출력 |
| V8 | 한글 경로에서 빌드 성공 | 로그에 인코딩 에러 없음 |

**PASS:** V1–V6 필수, V7은 A에서 선택 / B에서 필수, V8 필수.
**FAIL:** Plan 폐기, BP-only 롤백.

### 6.4 통과 시 점진 확대

1. **단계 1 (PoC):** HealthComponent 1개
2. **단계 2 (1–2주):** 커스텀 BP 어빌리티 베이스 3종(`UAttributeComponent`, `UAbilityComponent`, `UEffectDataAsset`) Angelscript로 재작성
3. **단계 3 (R5 통과 시):** GAS 재활성 → 신규 어빌리티 시스템 GDD + 구현
4. **단계 4:** `BP_AutoTargetComponent` 베이스를 Angelscript로 승격 (선택)
5. **단계 5:** 신규 시스템은 Angelscript 우선, BP는 콘텐츠/튜닝 전담

각 단계는 이전 단계 검증 완료 후 별도 승인으로 진행.

---

## 7. Critical Files to Modify (승인 후 수정 예정)

### 7.1 정책 문서 (최우선)

| 절대 경로 | 변경 규모 |
|---|---|
| `C:\Dev\ProjectFreeHero\CLAUDE.md` | 중간 (3 섹션) |
| `C:\Dev\ProjectFreeHero\.claude\docs\technical-preferences.md` | 큼 (9곳 + 라우팅) |
| `C:\Dev\ProjectFreeHero\.claude\docs\directory-structure.md` | 작음 |
| `C:\Dev\ProjectFreeHero\.claude\docs\agent-roster.md` | 중간 |
| `C:\Dev\ProjectFreeHero\.claude\docs\agent-coordination-map.md` | 중간 |
| `C:\Dev\ProjectFreeHero\.claude\docs\quick-start.md` | 작음 |
| `C:\Dev\ProjectFreeHero\docs\engine-reference\unreal\PLUGINS.md` | 중간 |

### 7.2 에이전트 정의

| 절대 경로 | 변경 규모 |
|---|---|
| `C:\Dev\ProjectFreeHero\.claude\agents\ue-blueprint-specialist.md` | 중간 |
| `C:\Dev\ProjectFreeHero\.claude\agents\unreal-specialist.md` | 작음 |
| `C:\Dev\ProjectFreeHero\.claude\agents\ue-replication-specialist.md` | 작음 |
| `C:\Dev\ProjectFreeHero\.claude\agents\ue-gas-specialist.md` | 큼 (R5 의존) |
| `C:\Dev\ProjectFreeHero\.claude\agents\ue-angelscript-specialist.md` | **신규** |

### 7.3 프로젝트 설정

| 절대 경로 | 변경 규모 | 트리거 |
|---|---|---|
| `C:\Dev\ProjectFreeHero\ProjectFreeHero.uproject` | 작음 | Scenario A 또는 B |
| `C:\Dev\ProjectFreeHero\.mcp.json` | 중간 | Scenario B만 |

### 7.4 GDD/Design

| 절대 경로 | 변경 규모 | 트리거 |
|---|---|---|
| `C:\Dev\ProjectFreeHero\design\gdd\auto-target-warping.md` | 작음 | 정책 업데이트 후 |
| `C:\Dev\ProjectFreeHero\design\gdd\ability-system.md` | **신규** | R5 통과 시에만 |

---

## 8. Verification Plan

### 8.1 정책 문서 수정 후
- [ ] `/review-all-gdds` — GDD 8 섹션 표준 + 엔티티 레지스트리 무결성
- [ ] `/consistency-check` — BP-only/GAS 미사용 문구 일관 업데이트 검증
- [ ] grep 검증: `BP-only` 남은 구 문구 0건 / `Angelscript` 신규 문구 기대 위치 확인

### 8.2 설치 후 (PoC)
- [ ] Editor 정상 시작 (플러그인 로드 로그)
- [ ] `.as` 파일이 BP에서 참조 가능
- [ ] UBG MCP 최소 5개 도구 응답
- [ ] 패키징 (Development, Shipping 각 1회)
- [ ] DDC 플러시 후 재빌드 성공

### 8.3 GDD 영향 평가 후
- [ ] `design/registry/entities.yaml` 무결성
- [ ] `design/gdd/systems-index.md` 업데이트 (ability-system.md 추가 시)
- [ ] `auto-target-warping.md` Tuning Knob 값 보존

---

## 9. Open Questions / Decision Gates

| # | 질문 | 게이트/트리거 | 현재 기본값 |
|---|---|---|---|
| Q1 | Scenario A vs B | R1–R4 결과 | 미결정 |
| Q2 | `ue-gas-specialist` 재활성 | R5 결과 | 미결정 |
| Q3 | PoC 샘플: HealthComponent만 vs + TestAttributeSet | R5 통과 여부 | HealthComponent(기본). R5 통과 시 추가 |
| Q4 | 커스텀 BP 어빌리티 스택 운명 | GAS 재활성 여부 | R5 통과 시 마이그레이션, 실패 시 유지 |
| Q5 | `ue-blueprint-specialist` "주력" 타이틀 유지 | Angelscript 비중 | 유지 (콘텐츠 여전히 BP 중심) |
| Q6 | Angelscript 경로 컨벤션 (`Script/` 등) | 선택된 플러그인 기본값 | 플러그인 관례 따름 |
| Q7 | UBG 프로젝트 로컬 설치 vs FAB 유지 (B 시나리오) | R4 결과 | 리서치 후 결정 |

### 다음 세션에 물어야 할 것

1. Plan §2의 R1–R6 리서치 수행 허가
2. Epic GitHub, Hazelight, UNREANGEL 저장소 접근 WebFetch/WebSearch 허가
3. `docs/research/angelscript-ue57-feasibility.md` 생성 허가
4. R5 결과에 따른 §4.5 `ue-gas-specialist` 재활성 확정 승인
5. Scenario 선택 승인 (A 또는 B)
6. PoC 시작 승인 (설치 실행)
7. PoC 결과 리뷰 후 단계 2 진입 승인

---

## 10. 승인 체크포인트

- [x] **CP1 — Plan 승인 (2026-04-22):** 전체 방향/범위 승인 완료
- [ ] **CP2 — 리서치 결과 리뷰:** R1–R6 완료 후 Scenario 선택 + GAS 재활성 결정
      → 리서치 노트 작성 완료 (`docs/research/angelscript-ue57-feasibility.md`),
        결정 대기 중
- [ ] **CP3 — 설치 러너북 실행 승인:** 선택된 시나리오 §3 실행 허가
- [ ] **CP4 — PoC 결과 리뷰:** V1–V8 게이트 통과 확인 후 점진 확대 여부

각 체크포인트 통과 없이는 다음 단계로 진행하지 않습니다.

---

**Plan 끝.** 승인 시 §2 Research Phase로 이동합니다.
