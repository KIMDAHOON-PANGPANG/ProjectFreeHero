# 에이전트 코디네이션 및 위임 맵

## 조직 계층

```
                           [Human Developer]
                                 |
                 +---------------+---------------+
                 |               |               |
         creative-director  technical-director  producer
                 |               |               |
        +--------+--------+     |        (전체 코디네이션)
        |        |        |     |
  game-designer art-dir  narr-dir  lead-programmer  qa-lead  audio-dir
        |        |        |         |                |        |
     +--+--+     |     +--+--+  +--+--+--+--+--+   |        |
     |  |  |     |     |     |  |  |  |  |  |  |   |        |
    sys lvl eco  ta   wrt  wrld gp ep  ai net tl ui qa-t    snd
                                 |
                             +---+---+
                             |       |
                          perf-a   devops   analytics

  추가 리드 (producer/director 에게 보고):
    release-manager         -- 릴리스 파이프라인, 버저닝, 배포
    localization-lead       -- i18n, 문자열 테이블, 번역 파이프라인
    prototyper              -- 빠른 일회성 프로토타입, 컨셉 검증
    security-engineer       -- 안티 치트, 익스플로잇, 데이터 프라이버시, 네트워크 보안
    accessibility-specialist -- WCAG, 색약, 리매핑, 텍스트 스케일링
    live-ops-designer       -- 시즌, 이벤트, 배틀 패스, 리텐션, 라이브 이코노미
    community-manager       -- 패치 노트, 플레이어 피드백, 위기 커뮤니케이션

  엔진 스페셜리스트 (본 프로젝트: Unreal Engine 5.7, BP-only 정책):
    ue-blueprint-specialist   -- 본 프로젝트 주력: BP 그래프 표준, 최적화, 어빌리티/어트리뷰트 BP 시스템 (GAS 대체)
    ue-umg-specialist         -- UI: UMG, CommonUI, 위젯 계층, 데이터 바인딩
    ue-replication-specialist -- 네트워킹: BP 복제, RepNotify, 서버 권한
    unreal-specialist         -- 서브: Config / Plugin / Editor / 크로스 시스템 리뷰 (C++ 작성 금지)
    ue-gas-specialist         -- ❌ 비활성 (BP-only 정책; AttributeSet 이 C++ 요구)
```

### 범례
```
sys  = systems-designer       gp  = gameplay-programmer
lvl  = level-designer         ep  = engine-programmer
eco  = economy-designer       ai  = ai-programmer
ta   = technical-artist       net = network-programmer
wrt  = writer                 tl  = tools-programmer
wrld = world-builder          ui  = ui-programmer
snd  = sound-designer         qa-t = qa-tester
narr-dir = narrative-director perf-a = performance-analyst
art-dir = art-director
```

## 위임 룰

### 누가 누구에게 위임할 수 있는가

| 출발 | 위임 가능 대상 |
|------|----------------|
| creative-director | game-designer, art-director, audio-director, narrative-director |
| technical-director | lead-programmer, devops-engineer, performance-analyst, technical-artist (기술 결정) |
| producer | 모든 에이전트 (자신의 도메인 내 태스크 할당만) |
| game-designer | systems-designer, level-designer, economy-designer |
| lead-programmer | gameplay-programmer, engine-programmer, ai-programmer, network-programmer, tools-programmer, ui-programmer |
| art-director | technical-artist, ux-designer |
| audio-director | sound-designer |
| narrative-director | writer, world-builder |
| qa-lead | qa-tester |
| release-manager | devops-engineer (릴리스 빌드), qa-lead (릴리스 테스트) |
| localization-lead | writer (문자열 리뷰), ui-programmer (텍스트 피팅) |
| prototyper | (독립적으로 작업, producer 와 관련 리드에게 발견 사항 보고) |
| security-engineer | network-programmer (보안 리뷰), lead-programmer (안전한 패턴) |
| accessibility-specialist | ux-designer (접근 가능한 패턴), ui-programmer (구현), qa-tester (a11y 테스트) |
| ue-blueprint-specialist | UE 서브 스페셜리스트 (UMG/Replication) 에게 BP 작업 위임 — 본 프로젝트 엔진 리드 |
| unreal-specialist | Config/Plugin/Editor 관련 작업만 위임 (C++ 작성 금지) |
| UE 서브 스페셜리스트 | (모든 프로그래머에게 BP 패턴 및 최적화 자문) |
| live-ops-designer | economy-designer (라이브 이코노미), community-manager (이벤트 커뮤니케이션), analytics-engineer (인게이지먼트 메트릭) |
| community-manager | (승인을 위해 producer 와 협업, 패치 노트 타이밍은 release-manager 와) |

### 에스컬레이션 경로

| 상황 | 에스컬레이션 대상 |
|-----------|------------|
| 두 디자이너가 메커닉에서 의견 불일치 | game-designer |
| 게임 디자인 vs 내러티브 충돌 | creative-director |
| 게임 디자인 vs 기술 타당성 | producer (중재), 다음 creative-director + technical-director |
| 아트 vs 오디오 톤 충돌 | creative-director |
| 코드 아키텍처 의견 불일치 | technical-director |
| 크로스 시스템 코드 충돌 | lead-programmer, 다음 technical-director |
| 부서 간 일정 충돌 | producer |
| 스코프가 용량 초과 | producer, 컷을 위해 creative-director |
| 품질 게이트 의견 불일치 | qa-lead, 다음 technical-director |
| 성능 예산 위반 | performance-analyst 가 플래그, technical-director 가 결정 |

## 일반 워크플로 패턴

### 패턴 1: 신규 기능 (전체 파이프라인)

```
1. creative-director  -- 기능 컨셉이 비전과 부합하는지 승인
2. game-designer      -- 전체 스펙 포함 디자인 문서 작성
3. producer           -- 작업 일정 수립, 의존성 식별
4. lead-programmer    -- 코드 아키텍처 설계, 인터페이스 스케치 작성
5. [specialist-programmer] -- 기능 구현
6. technical-artist   -- 비주얼 이펙트 구현 (필요 시)
7. writer             -- 텍스트 콘텐츠 작성 (필요 시)
8. sound-designer     -- 오디오 이벤트 목록 작성 (필요 시)
9. qa-tester          -- 테스트 케이스 작성
10. qa-lead           -- 테스트 커버리지 리뷰 및 승인
11. lead-programmer   -- 코드 리뷰
12. qa-tester         -- 테스트 실행
13. producer          -- 태스크 완료 표시
```

### 패턴 2: 버그 수정

```
1. qa-tester          -- /bug-report 로 버그 리포트 작성
2. qa-lead            -- 심각도 및 우선순위 트리아지
3. producer           -- 스프린트에 할당 (S1 이 아닌 경우)
4. lead-programmer    -- 근본 원인 식별, 프로그래머에게 할당
5. [specialist-programmer] -- 버그 수정
6. lead-programmer    -- 코드 리뷰
7. qa-tester          -- 수정 검증 및 리그레션 실행
8. qa-lead            -- 버그 종료
```

### 패턴 3: 밸런스 조정

```
1. analytics-engineer -- 데이터(또는 플레이어 리포트)에서 불균형 식별
2. game-designer      -- 디자인 의도 대비 이슈 평가
3. economy-designer   -- 조정 모델링
4. game-designer      -- 새 값 승인
5. [data file update] -- 설정 값 변경
6. qa-tester          -- 영향받는 시스템 리그레션 테스트
7. analytics-engineer -- 변경 후 메트릭 모니터링
```

### 패턴 4: 신규 영역/레벨

```
1. narrative-director -- 영역의 내러티브 목적 및 비트 정의
2. world-builder      -- 로어 및 환경 컨텍스트 작성
3. level-designer     -- 레이아웃, 인카운터, 페이싱 설계
4. game-designer      -- 인카운터의 메커니컬 디자인 리뷰
5. art-director       -- 영역의 비주얼 방향성 정의
6. audio-director     -- 영역의 오디오 방향성 정의
7. [관련 프로그래머 및 아티스트에 의한 구현]
8. writer             -- 영역별 텍스트 콘텐츠 작성
9. qa-tester          -- 완성된 영역 테스트
```

### 패턴 5: 스프린트 사이클

```
1. producer           -- /sprint-plan new 로 스프린트 계획
2. [모든 에이전트]    -- 할당된 태스크 수행
3. producer           -- /sprint-plan status 로 일일 상태 확인
4. qa-lead            -- 스프린트 중 지속적 테스트
5. lead-programmer    -- 스프린트 중 지속적 코드 리뷰
6. producer           -- post-sprint 훅으로 스프린트 회고
7. producer           -- 학습을 통합한 다음 스프린트 계획
```

### 패턴 6: 마일스톤 체크포인트

```
1. producer           -- /milestone-review 실행
2. creative-director  -- 크리에이티브 진행 상황 리뷰
3. technical-director -- 기술 건전성 리뷰
4. qa-lead            -- 품질 메트릭 리뷰
5. producer           -- go/no-go 논의 중재
6. [모든 디렉터]      -- 필요 시 스코프 조정 합의
7. producer           -- 결정 사항 문서화 및 계획 갱신
```

### 패턴 7: 릴리스 파이프라인

```text
1. producer             -- 릴리스 후보 선언, 마일스톤 기준 충족 확인
2. release-manager      -- 릴리스 브랜치 컷, /release-checklist 생성
3. qa-lead              -- 전체 리그레션 실행, 품질 사인오프
4. localization-lead    -- 모든 문자열 번역 확인, 텍스트 피팅 통과
5. performance-analyst  -- 성능 벤치마크가 타겟 내에 있음을 확인
6. devops-engineer      -- 릴리스 아티팩트 빌드, 배포 파이프라인 실행
7. release-manager      -- /changelog 생성, 릴리스 태그, 릴리스 노트 작성
8. technical-director   -- 주요 릴리스에 대한 최종 사인오프
9. release-manager      -- 배포 후 48시간 모니터링
10. producer            -- 릴리스 완료 표시
```

### 패턴 8: 빠른 프로토타입

```text
1. game-designer        -- 가설 및 성공 기준 정의
2. prototyper           -- /prototype 으로 프로토타입 스캐폴드
3. prototyper           -- 최소 구현 빌드 (일 단위가 아닌 시간 단위)
4. game-designer        -- 기준 대비 프로토타입 평가
5. prototyper           -- 발견 사항 리포트 문서화
6. creative-director    -- 프로덕션 진행 여부 go/no-go 결정
7. producer             -- 승인 시 프로덕션 작업 일정 수립
```

### 패턴 9: 라이브 이벤트 / 시즌 런치

```text
1. live-ops-designer     -- 이벤트/시즌 콘텐츠, 보상, 일정 설계
2. game-designer         -- 이벤트용 게임플레이 메커닉 검증
3. economy-designer      -- 이벤트 이코노미 및 보상 값 밸런싱
4. narrative-director    -- 시즌별 내러티브 테마 제공
5. writer                -- 이벤트 설명 및 로어 작성
6. producer              -- 구현 작업 일정 수립
7. [관련 프로그래머에 의한 구현]
8. qa-lead               -- 이벤트 플로우 end-to-end 테스트
9. community-manager     -- 이벤트 공지 및 패치 노트 초안
10. release-manager      -- 이벤트 콘텐츠 배포
11. analytics-engineer   -- 이벤트 참여 및 메트릭 모니터링
12. live-ops-designer    -- 사후 이벤트 분석 및 학습
```

## 크로스 도메인 커뮤니케이션 프로토콜

### 디자인 변경 알림

디자인 문서가 변경되면 game-designer 는 다음에 알려야 합니다:
- lead-programmer (구현 영향)
- qa-lead (테스트 계획 갱신 필요)
- producer (일정 영향 평가)
- 변경 사항에 따른 관련 스페셜리스트 에이전트

### 아키텍처 변경 알림

ADR 이 생성되거나 수정되면 technical-director 는 다음에 알려야 합니다:
- lead-programmer (코드 변경 필요)
- 영향받는 모든 스페셜리스트 프로그래머
- qa-lead (테스트 전략 변경 가능)
- producer (일정 영향)

### 에셋 표준 변경 알림

아트 바이블 또는 에셋 표준이 변경되면 art-director 는 다음에 알려야 합니다:
- technical-artist (파이프라인 변경)
- 영향받는 에셋으로 작업 중인 모든 콘텐츠 제작자
- devops-engineer (빌드 파이프라인이 영향받는 경우)

## 피해야 할 안티 패턴

1. **계층 우회**: 스페셜리스트 에이전트는 자신의 리드와 상의 없이 리드의 결정을 내려서는 안 됩니다.
2. **크로스 도메인 구현**: 에이전트는 관련 소유자로부터의 명시적 위임 없이
   자신의 지정 영역 밖 파일을 수정해서는 안 됩니다.
3. **그림자 결정**: 모든 결정은 문서화되어야 합니다. 기록 없는 구두 합의는
   모순으로 이어집니다.
4. **모놀리식 태스크**: 에이전트에 할당되는 모든 태스크는 1-3일 내에 완료 가능해야 합니다.
   더 크면 먼저 분해되어야 합니다.
5. **가정 기반 구현**: 스펙이 모호하면 구현자는 추측하지 말고 스펙 작성자에게 물어야 합니다.
   잘못된 추측은 질문보다 비쌉니다.
