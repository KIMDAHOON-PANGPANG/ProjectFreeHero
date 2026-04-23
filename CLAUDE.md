# ProjectFreeHero — 게임 스튜디오 에이전트 아키텍처

조율된 Claude Code 서브에이전트를 통해 관리되는 인디 UE5.7 게임 개발 프로젝트입니다.
각 에이전트는 고유한 도메인을 담당하며, 관심사의 분리와 품질을 강제합니다.

## 기술 스택

- **엔진**: Unreal Engine 5.7 (2025-11 고정, 문서 검증일 2026-02-13)
- **언어**: **Blueprint + Angelscript** — 게임 로직 C++ 작성 금지. 플러그인 C++(UBG, Angelscript 런타임) 빌드는 예외이며, `Source/` 는 빌드 인프라 보일러플레이트(Target.cs, Build.cs, IMPLEMENT_PRIMARY_GAME_MODULE) 전용으로만 유지. Angelscript는 `UnrealEngine-Angelscript-ZH/AngelscriptProject` 커뮤니티 플러그인 기반, `Script/` 디렉터리 하위에서 UObject/Component/AttributeSet 상속이 가능
- **AI CoPilot**: UBG — Ultimate Engine CoPilot (BlueprintsLab, FAB) —
  Unreal Editor 내부에서 직접 Claude Code를 실행하며, 본 `.claude/` 설정을 읽습니다
- **어빌리티 프레임워크**: **GAS 조건부 재활성** — Angelscript의 `UAngelscriptAttributeSet` 래퍼로 C++ 상속 제약 우회 가능. PoC(Plan §6) 통과 시 GAS 정식 재활성, 그전까지는 커스텀 BP 시스템(`UAttributeComponent` / `UAbilityComponent` / `UEffectDataAsset`) 유지.
  `FGameplayTag` / `FGameplayTagContainer` 는 BP 지원되므로 태그 의미론은 그대로 활용.
- **버전 관리**: Git, 트렁크 기반 개발 (origin: GitHub 공개 저장소)
- **빌드 시스템**: Unreal Build Tool (UBT) / Unreal Automation Tool (UAT)
- **에셋 파이프라인**: Content/ (Blueprints, meshes, textures) — UE Editor + UBG 경유

> **활성 엔진 스페셜리스트**: `ue-blueprint-specialist` (**주력**, BP 콘텐츠 리드),
> `ue-angelscript-specialist` (`.as` 시스템 레이어, UObject/Component/AttributeSet 상속),
> `ue-umg-specialist` (UI), `ue-replication-specialist` (BP + `.as` 복제),
> `unreal-specialist` (Config / Plugin / Editor 설정 전용).
> **조건부**: `ue-gas-specialist` — Angelscript PoC(Plan §6) 통과 시 재활성.
> UBG 플러그인 워크플로는 `.claude/docs/ubg-integration.md` 참조.

## 프로젝트 구조

@.claude/docs/directory-structure.md

## 엔진 버전 레퍼런스

@docs/engine-reference/unreal/VERSION.md
@docs/engine-reference/unreal/PLUGINS.md

## 기술 선호 사항

@.claude/docs/technical-preferences.md

## 코디네이션 규칙

@.claude/docs/coordination-rules.md

## 협업 프로토콜

**자율 실행이 아닌, 사용자 주도 협업.**
모든 작업은 다음 단계를 따릅니다: **질문 -> 선택지 -> 결정 -> 초안 -> 승인**

- 에이전트는 Write/Edit 도구 사용 전에 반드시 "이 내용을 [파일경로]에 기록해도 될까요?"라고 질문해야 합니다
- 에이전트는 승인을 요청하기 전에 반드시 초안 또는 요약을 보여주어야 합니다
- 다중 파일 변경은 전체 변경 세트에 대한 명시적 승인을 필요로 합니다
- 사용자 지시 없이는 커밋하지 않습니다

전체 프로토콜과 예시는 `docs/COLLABORATIVE-DESIGN-PRINCIPLE.md` 참조.

> **첫 세션인가요?** 프로젝트에 엔진이 설정되지 않았고 게임 컨셉도 없다면,
> `/start`를 실행해 가이드 기반 온보딩 플로우를 시작하세요.

## 코딩 표준

@.claude/docs/coding-standards.md

## 컨텍스트 관리

@.claude/docs/context-management.md
