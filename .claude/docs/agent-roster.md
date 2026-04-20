# 에이전트 로스터

다음 에이전트를 사용할 수 있습니다. 각 에이전트는 `.claude/agents/` 에 전용 정의 파일을 가집니다.
작업에 가장 적합한 에이전트를 사용하세요. 작업이 여러 도메인에 걸쳐 있을 때는
조율 에이전트 (보통 `producer` 또는 도메인 리드) 가 스페셜리스트에게 위임합니다.

## Tier 1 — 리더십 에이전트 (Opus)
| 에이전트 | 도메인 | 사용 시점 |
|-------|--------|-------------|
| `creative-director` | 하이 레벨 비전 | 주요 창의적 결정, 필러 충돌, 톤/방향성 |
| `technical-director` | 기술 비전 | 아키텍처 결정, 기술 스택 선택, 성능 전략 |
| `producer` | 프로덕션 관리 | 스프린트 계획, 마일스톤 추적, 리스크 관리, 코디네이션 |

## Tier 2 — 부서 리드 에이전트 (Sonnet)
| 에이전트 | 도메인 | 사용 시점 |
|-------|--------|-------------|
| `game-designer` | 게임 디자인 | 메커닉, 시스템, 프로그레션, 이코노미, 밸런싱 |
| `lead-programmer` | 코드 아키텍처 | 시스템 디자인, 코드 리뷰, API 디자인, 리팩터링 |
| `art-director` | 비주얼 방향성 | 스타일 가이드, 아트 바이블, 에셋 표준, UI/UX 방향성 |
| `audio-director` | 오디오 방향성 | 음악 방향성, 사운드 팔레트, 오디오 구현 전략 |
| `narrative-director` | 스토리/라이팅 | 스토리 아크, 월드빌딩, 캐릭터 디자인, 대사 전략 |
| `qa-lead` | 품질 보증 | 테스트 전략, 버그 트리아지, 릴리스 준비도, 리그레션 계획 |
| `release-manager` | 릴리스 파이프라인 | 빌드 관리, 버저닝, 체인지로그, 배포, 롤백 |
| `localization-lead` | 국제화 | 문자열 외부화, 번역 파이프라인, 로케일 테스트 |

## Tier 3 — 스페셜리스트 에이전트 (Sonnet 또는 Haiku)
| 에이전트 | 도메인 | 모델 | 사용 시점 |
|-------|--------|-------|-------------|
| `systems-designer` | 시스템 디자인 | Sonnet | 특정 메커닉 구현, 수식 디자인, 루프 |
| `level-designer` | 레벨 디자인 | Sonnet | 레벨 레이아웃, 페이싱, 인카운터 디자인, 플로우 |
| `economy-designer` | 이코노미/밸런스 | Sonnet | 자원 이코노미, 루트 테이블, 프로그레션 커브 |
| `gameplay-programmer` | 게임플레이 코드 | Sonnet | 기능 구현, 게임플레이 시스템 코드 |
| `engine-programmer` | 엔진 시스템 | Sonnet | 코어 엔진, 렌더링, 물리, 메모리 관리 |
| `ai-programmer` | AI 시스템 | Sonnet | Behavior Tree, Pathfinding, NPC 로직, 상태 머신 |
| `network-programmer` | 네트워킹 | Sonnet | 넷코드, 복제, 랙 보상, 매치메이킹 |
| `tools-programmer` | 개발 도구 | Sonnet | 에디터 확장, 파이프라인 도구, 디버그 유틸리티 |
| `ui-programmer` | UI 구현 | Sonnet | UI 프레임워크, 화면, 위젯, 데이터 바인딩 |
| `technical-artist` | 테크 아트 | Sonnet | 셰이더, VFX, 최적화, 아트 파이프라인 도구 |
| `sound-designer` | 사운드 디자인 | Haiku | SFX 디자인 문서, 오디오 이벤트 목록, 믹싱 노트 |
| `writer` | 대사/로어 | Sonnet | 대사 작성, 로어 항목, 아이템 설명 |
| `world-builder` | 월드/로어 디자인 | Sonnet | 월드 룰, 팩션 디자인, 역사, 지리 |
| `qa-tester` | 테스트 실행 | Haiku | 테스트 케이스 작성, 버그 리포트, 테스트 체크리스트 |
| `performance-analyst` | 성능 | Sonnet | 프로파일링, 최적화 권고, 메모리 분석 |
| `devops-engineer` | 빌드/배포 | Haiku | CI/CD, 빌드 스크립트, 버전 관리 워크플로 |
| `analytics-engineer` | 텔레메트리 | Sonnet | 이벤트 추적, 대시보드, A/B 테스트 디자인 |
| `ux-designer` | UX 플로우 | Sonnet | 사용자 플로우, 와이어프레임, 접근성, 입력 처리 |
| `prototyper` | 빠른 프로토타이핑 | Sonnet | 일회성 프로토타입, 메커닉 테스트, 타당성 검증 |
| `security-engineer` | 보안 | Sonnet | 안티 치트, 익스플로잇 방지, 세이브 암호화, 네트워크 보안 |
| `accessibility-specialist` | 접근성 | Haiku | WCAG 준수, 색약 모드, 리매핑, 텍스트 스케일링 |
| `live-ops-designer` | 라이브 운영 | Sonnet | 시즌, 이벤트, 배틀 패스, 리텐션, 라이브 이코노미 |
| `community-manager` | 커뮤니티 | Haiku | 패치 노트, 플레이어 피드백, 위기 커뮤니케이션, 커뮤니티 헬스 |

## 엔진별 에이전트 (본 프로젝트는 Unreal Engine 5.7, **BP-only 정책**)

### 엔진 리드 (본 프로젝트 주력)

| 에이전트 | 엔진 | 모델 | 사용 시점 |
| ---- | ---- | ---- | ---- |
| `ue-blueprint-specialist` | Unreal Engine 5 (BP) | Sonnet | **본 프로젝트 주력** — BP 그래프 설계/최적화, 어빌리티·어트리뷰트 BP 시스템(GAS 대체), 일반 BP 리뷰 |

### 서브 스페셜리스트

| 에이전트 | 서브시스템 | 모델 | 사용 시점 |
| ---- | ---- | ---- | ---- |
| `ue-umg-specialist` | UMG/CommonUI | Sonnet | 위젯 계층, 데이터 바인딩, CommonUI 입력, UI 성능 |
| `ue-replication-specialist` | 네트워킹/복제 | Sonnet | BP 프로퍼티 복제, RepNotify, RPC, 서버 권한 |
| `unreal-specialist` | Config/Plugin/Editor | Sonnet | Config(.ini), 플러그인 설정, 에디터 설정, 크로스 시스템 리뷰만 (**C++ 작성 금지**) |

### 비활성 에이전트 (본 프로젝트 미사용)

| 에이전트 | 비활성 사유 |
| ---- | ---- |
| `ue-gas-specialist` | ❌ **BP-only 정책** — GAS 의 `UAttributeSet` 이 C++ 상속을 요구하므로 본 프로젝트에서 GAS 전체를 미사용. 어빌리티/어트리뷰트/이펙트 관련 작업은 `ue-blueprint-specialist` 로 라우팅. |
