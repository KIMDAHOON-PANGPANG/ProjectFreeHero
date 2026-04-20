# 사용 가능한 스킬 (슬래시 커맨드)

페이즈별로 정리된 68개의 슬래시 커맨드. Claude Code 에서 `/` 를 입력해 접근하세요.

## 온보딩 & 내비게이션

| 커맨드 | 용도 |
|---------|---------|
| `/start` | 첫 온보딩 — 현재 위치를 묻고 적절한 워크플로로 안내 |
| `/help` | 컨텍스트 인식 "다음 무엇을 해야 할까?" — 현재 단계를 읽고 필요한 다음 단계를 표면화 |
| `/project-stage-detect` | 전체 프로젝트 감사 — 페이즈 감지, 존재 갭 식별, 다음 단계 권장 |
| `/setup-engine` | 엔진 + 버전 구성, 지식 갭 감지, 버전 인식 레퍼런스 문서 채움 |
| `/adopt` | 브라운필드 포맷 감사 — 기존 GDD/ADR/스토리의 내부 구조 확인, 마이그레이션 계획 생성 |

## 게임 디자인

| 커맨드 | 용도 |
|---------|---------|
| `/brainstorm` | 프로페셔널 스튜디오 방법론(MDA, SDT, Bartle, verb-first)을 사용한 가이드 기반 아이디에이션 |
| `/map-systems` | 게임 컨셉을 시스템으로 분해하고 의존성 맵핑, 디자인 순서 우선순위화 |
| `/design-system` | 단일 게임 시스템에 대한 섹션별 가이드 GDD 저작 |
| `/quick-design` | 작은 변경용 경량 디자인 스펙 — 튜닝, 조정, 소소한 추가 |
| `/review-all-gdds` | 모든 디자인 문서에 걸친 크로스 GDD 일관성 및 게임 디자인 총체적 리뷰 |
| `/propagate-design-change` | GDD 가 수정되면 영향받는 ADR 을 찾아 영향 리포트 생성 |

## UX & 인터페이스 디자인

| 커맨드 | 용도 |
|---------|---------|
| `/ux-design` | 섹션별 가이드 UX 스펙 저작 (화면/플로우, HUD, 또는 패턴 라이브러리) |
| `/ux-review` | GDD 정합성, 접근성, 패턴 준수 여부에 대해 UX 스펙 검증 |

## 아키텍처

| 커맨드 | 용도 |
|---------|---------|
| `/create-architecture` | 마스터 아키텍처 문서의 가이드 저작 |
| `/architecture-decision` | Architecture Decision Record (ADR) 생성 |
| `/architecture-review` | 모든 ADR 의 완전성, 의존성 순서, GDD 커버리지 검증 |
| `/create-control-manifest` | 승인된 ADR 에서 플랫한 프로그래머 룰 시트 생성 |

## 스토리 & 스프린트

| 커맨드 | 용도 |
|---------|---------|
| `/create-epics` | GDD + ADR 을 아키텍처 모듈당 하나의 에픽으로 변환 |
| `/create-stories` | 단일 에픽을 구현 가능한 스토리 파일로 분해 |
| `/dev-story` | 스토리를 읽고 구현 — 올바른 프로그래머 에이전트로 라우팅 |
| `/sprint-plan` | 스프린트 계획 생성 또는 갱신; sprint-status.yaml 초기화 |
| `/sprint-status` | 빠른 30줄 스프린트 스냅샷 (sprint-status.yaml 읽기) |
| `/story-readiness` | 픽업 전 스토리가 구현 가능한지 검증 (READY/NEEDS WORK/BLOCKED) |
| `/story-done` | 구현 후 8페이즈 완료 리뷰; 스토리 파일 갱신, 다음 스토리 표면화 |
| `/estimate` | 복잡도, 의존성, 리스크 분해를 포함한 구조화된 공수 추정 |

## 리뷰 & 분석

| 커맨드 | 용도 |
|---------|---------|
| `/design-review` | 완전성과 일관성을 위한 게임 디자인 문서 리뷰 |
| `/code-review` | 파일 또는 체인지셋에 대한 아키텍처 코드 리뷰 |
| `/balance-check` | 게임 밸런스 데이터, 수식, 설정을 분석하고 이상치 플래그 |
| `/asset-audit` | 네이밍 컨벤션, 파일 크기 예산, 파이프라인 준수 감사 |
| `/content-audit` | GDD 명시 콘텐츠 수량을 구현된 콘텐츠와 비교 감사 |
| `/scope-check` | 기능 또는 스프린트 스코프를 원래 계획과 비교 분석, 스코프 크립 플래그 |
| `/perf-profile` | 병목 식별을 포함한 구조화된 성능 프로파일링 |
| `/tech-debt` | 기술 부채를 스캔, 추적, 우선순위화, 리포트 |
| `/gate-check` | 개발 페이즈 간 진행 준비도 검증 (PASS/CONCERNS/FAIL) |
| `/consistency-check` | 엔티티 레지스트리 대비 모든 GDD 를 스캔해 문서 간 불일치 (서로 모순되는 스탯, 이름, 룰) 감지 |

## QA & 테스트

| 커맨드 | 용도 |
|---------|---------|
| `/qa-plan` | 스프린트 또는 기능에 대한 QA 테스트 계획 생성 |
| `/smoke-check` | QA 핸드오프 전 크리티컬 패스 스모크 테스트 게이트 실행 |
| `/soak-test` | 장시간 플레이 세션용 소크 테스트 프로토콜 생성 |
| `/regression-suite` | 테스트 커버리지를 GDD 크리티컬 패스에 매핑, 회귀 테스트 없는 수정 버그 식별 |
| `/test-setup` | 프로젝트 엔진용 테스트 프레임워크 및 CI/CD 파이프라인 스캐폴드 |
| `/test-helpers` | 테스트 스위트용 엔진별 테스트 헬퍼 라이브러리 생성 |
| `/test-evidence-review` | 테스트 파일 및 수동 증거 문서의 품질 리뷰 |
| `/test-flakiness` | CI 실행 로그에서 비결정적(플래키) 테스트 감지 |
| `/skill-test` | 스킬 파일의 구조 준수 및 동작 정확성 검증 |

## 프로덕션

| 커맨드 | 용도 |
|---------|---------|
| `/milestone-review` | 마일스톤 진행 상황 리뷰 및 상태 리포트 생성 |
| `/retrospective` | 구조화된 스프린트 또는 마일스톤 회고 실행 |
| `/bug-report` | 구조화된 버그 리포트 생성 |
| `/bug-triage` | 모든 열린 버그를 읽고, 우선순위 vs 심각도 재평가, 오너 및 라벨 할당 |
| `/reverse-document` | 기존 구현에서 디자인 또는 아키텍처 문서 생성 |
| `/playtest-report` | 구조화된 플레이테스트 리포트 생성 또는 기존 플레이테스트 노트 분석 |

## 릴리스

| 커맨드 | 용도 |
|---------|---------|
| `/release-checklist` | 현재 빌드에 대한 릴리스 전 체크리스트 생성 및 검증 |
| `/launch-checklist` | 모든 부서 걸친 런치 준비도 검증 완료 |
| `/changelog` | git 커밋 및 스프린트 데이터에서 체인지로그 자동 생성 |
| `/patch-notes` | git 이력과 내부 데이터에서 플레이어용 패치 노트 생성 |
| `/hotfix` | 감사 기록이 있는 긴급 수정 워크플로, 정상 스프린트 프로세스 우회 |

## 크리에이티브 & 콘텐츠

| 커맨드 | 용도 |
|---------|---------|
| `/prototype` | 메커닉을 검증하는 빠른 일회성 프로토타입 (완화된 표준, 격리된 worktree) |
| `/onboard` | 신규 기여자 또는 에이전트용 컨텍스트 온보딩 문서 생성 |
| `/localize` | 로컬라이제이션 워크플로: 문자열 추출, 검증, 번역 준비도 |

## 팀 오케스트레이션

단일 기능 영역에 여러 에이전트를 조율합니다:

| 커맨드 | 조율 대상 |
|---------|-------------|
| `/team-combat` | game-designer + gameplay-programmer + ai-programmer + technical-artist + sound-designer + qa-tester |
| `/team-narrative` | narrative-director + writer + world-builder + level-designer |
| `/team-ui` | ux-designer + ui-programmer + art-director + accessibility-specialist |
| `/team-release` | release-manager + qa-lead + devops-engineer + producer |
| `/team-polish` | performance-analyst + technical-artist + sound-designer + qa-tester |
| `/team-audio` | audio-director + sound-designer + technical-artist + gameplay-programmer |
| `/team-level` | level-designer + narrative-director + world-builder + art-director + systems-designer + qa-tester |
| `/team-live-ops` | live-ops-designer + economy-designer + community-manager + analytics-engineer |
| `/team-qa` | qa-lead + qa-tester + gameplay-programmer + producer |
