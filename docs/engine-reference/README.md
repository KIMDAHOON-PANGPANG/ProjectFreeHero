# Engine Reference Documentation

이 디렉터리에는 이 프로젝트에서 사용하는 게임 엔진의 큐레이션된 버전 고정 문서 스냅샷이 포함되어 있습니다. 이러한 파일이 존재하는 이유는 **LLM 지식에는 컷오프 날짜가 있고** 게임 엔진이 자주 업데이트되기 때문입니다.

## 이것이 존재하는 이유

Claude의 학습 데이터에는 지식 컷오프가 있습니다(현재 2025년 5월). Unreal Engine은 호환성을 깨는 API 변경, 신규 기능, 그리고 deprecated 패턴을 도입하는 업데이트를 배포합니다. 이러한 참조 파일이 없다면 Agent는 구식 코드를 제안하게 됩니다.

이 프로젝트는 **Unreal Engine 5.7**(2025년 11월)에 고정되어 있으며 UBG(Ultimate Engine CoPilot) 플러그인 통합을 사용합니다.

## 구조

각 엔진은 자체 디렉터리를 갖습니다:

```
<engine>/
├── VERSION.md              # 고정된 버전, 검증 날짜, 지식 격차 윈도우
├── breaking-changes.md     # 버전 간 API 변경사항, 리스크 수준별로 정리
├── deprecated-apis.md      # "X 사용 금지 → Y 사용" 조회 테이블
├── current-best-practices.md  # 모델 학습 데이터에 포함되지 않은 신규 프랙티스
└── modules/                # 서브시스템별 빠른 참조(각 ~150줄 이내)
    ├── rendering.md
    ├── physics.md
    └── ...
```

## Agent가 이 파일들을 사용하는 방법

엔진 전문가 Agent는 다음과 같이 지시받습니다:

1. `VERSION.md`를 읽어 현재 엔진 버전을 확인합니다
2. 엔진 API를 제안하기 전에 `deprecated-apis.md`를 확인합니다
3. 버전별 우려사항에 대해 `breaking-changes.md`를 참조합니다
4. 서브시스템별 작업을 위해 관련 `modules/*.md`를 읽습니다

## 유지보수

### 업데이트 시점

- 엔진 버전을 업그레이드한 후
- LLM 모델이 업데이트된 경우(새로운 지식 컷오프)
- `/refresh-docs`를 실행한 후(사용 가능한 경우)
- 모델이 잘못 알고 있는 API를 발견했을 때

### 업데이트 방법

1. `VERSION.md`를 새 엔진 버전과 날짜로 업데이트합니다
2. 버전 전환에 대한 새 항목을 `breaking-changes.md`에 추가합니다
3. 새롭게 deprecated된 API를 `deprecated-apis.md`로 이동합니다
4. `current-best-practices.md`를 새 패턴으로 업데이트합니다
5. 관련 `modules/*.md`를 API 변경사항으로 업데이트합니다
6. 수정된 모든 파일에 "Last verified" 날짜를 설정합니다

### 품질 규칙

- 모든 파일에는 "Last verified: YYYY-MM-DD" 날짜가 있어야 합니다
- 모듈 파일은 150줄 이내로 유지합니다(컨텍스트 예산)
- 올바른/잘못된 패턴을 보여주는 코드 예제를 포함합니다
- 검증을 위한 공식 문서 URL을 링크합니다
- 모델의 학습 데이터와 다른 내용만 문서화합니다
