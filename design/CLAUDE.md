# Design Directory

이 디렉터리의 파일을 작성하거나 편집할 때 다음 표준을 따릅니다.

## GDD Files (`design/gdd/`)

모든 GDD는 다음 순서로 **8개의 필수 섹션**을 반드시 포함해야 합니다:
1. Overview — 한 단락 요약
2. Player Fantasy — 의도된 감정과 경험
3. Detailed Rules — 모호하지 않은 메커니즘
4. Formulas — 변수로 정의된 모든 수식
5. Edge Cases — 특수 상황 처리 방식
6. Dependencies — 다른 시스템 목록
7. Tuning Knobs — 설정 가능한 값 식별
8. Acceptance Criteria — 테스트 가능한 성공 조건

**파일 명명:** `[system-slug].md` (예: `movement-system.md`, `combat-system.md`)

**시스템 인덱스:** `design/gdd/systems-index.md` — 새 GDD를 추가할 때 업데이트합니다.

**설계 순서:** Foundation → Core → Feature → Presentation → Polish

**검증:** GDD를 작성한 후에는 `/design-review [path]`를 실행합니다.
관련된 GDD 세트를 완료한 후에는 `/review-all-gdds`를 실행합니다.

## Quick Specs (`design/quick-specs/`)

튜닝 변경, 사소한 메커니즘, 밸런스 조정을 위한 경량 스펙입니다.
작성할 때는 `/quick-design`을 사용합니다.

## UX Specs (`design/ux/`)

- 화면별 스펙: `design/ux/[screen-name].md`
- HUD 설계: `design/ux/hud.md`
- 인터랙션 패턴 라이브러리: `design/ux/interaction-patterns.md`
- 접근성 요구사항: `design/ux/accessibility-requirements.md`

작성할 때는 `/ux-design`을 사용합니다. `/team-ui`로 넘기기 전에 `/ux-review`로 검증합니다.
