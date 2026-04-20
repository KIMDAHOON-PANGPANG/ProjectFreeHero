# Unreal Engine — 버전 레퍼런스

| 항목 | 값 |
|-------|-------|
| **엔진 버전** | Unreal Engine 5.7 |
| **릴리스 날짜** | 2025년 11월 |
| **프로젝트 고정일** | 2026-02-13 |
| **문서 최종 검증일** | 2026-02-13 |
| **LLM 지식 컷오프** | 2025년 5월 |

## 지식 격차 경고

LLM의 학습 데이터는 Unreal Engine 약 5.3 버전까지만 포함하고 있을 가능성이 높습니다. 버전 5.4, 5.5,
5.6, 5.7에는 모델이 알지 못하는 중요한 변경 사항이 도입되었습니다.
Unreal API 호출을 제안하기 전에 반드시 이 디렉터리를 먼저 교차 확인하세요.

## 컷오프 이후 버전 타임라인

| 버전 | 릴리스 | 리스크 수준 | 핵심 테마 |
|---------|---------|------------|-----------|
| 5.4 | 2025년 중반 경 | HIGH | Motion Design 도구, 애니메이션 개선, PCG 강화 |
| 5.5 | 2025년 9월 경 | HIGH | Megalights(수백만 개 라이트), 애니메이션 저작, MegaCity 데모 |
| 5.6 | 2025년 10월 경 | MEDIUM | 성능 최적화, 버그 수정 |
| 5.7 | 2025년 11월 | HIGH | PCG 프로덕션 준비됨, Substrate 프로덕션 준비됨, AI Assistant |

## UE 5.3 에서 UE 5.7 로의 주요 변경 사항

### 호환성 파괴 변경
- **Substrate Material System**: 새로운 머티리얼 프레임워크 (기존 머티리얼 시스템 대체)
- **PCG (Procedural Content Generation)**: 프로덕션 준비됨, 주요 API 변경
- **Megalights**: 새로운 라이팅 시스템 (수백만 개의 동적 라이트)
- **Animation Authoring**: 새로운 리깅 및 애니메이션 도구
- **AI Assistant**: 에디터 내장 AI 가이드 (실험적)

### 신규 기능 (컷오프 이후)
- **Megalights**: 대규모 동적 라이팅 (수백만 개의 라이트)
- **Substrate Materials**: 프로덕션 준비된 모듈식 머티리얼 시스템
- **PCG Framework**: 절차적 월드 생성 (5.7 에서 프로덕션 준비됨)
- **Enhanced Virtual Production**: MetaHuman 통합, 보다 심화된 VP 워크플로우
- **애니메이션 개선**: 향상된 리깅, 블렌딩, 절차적 애니메이션
- **AI Assistant**: 에디터 내장 AI 도움말 (실험적)

### 폐기된 시스템
- **Legacy Material System**: 신규 프로젝트는 Substrate 로 마이그레이션
- **Old PCG API**: 새로운 프로덕션 준비된 PCG API 사용 (5.7+)

## 검증된 출처

- 공식 문서: https://docs.unrealengine.com/5.7/
- UE 5.7 릴리스 노트: https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-engine-5-7-release-notes
- 5.7 신규 사항: https://dev.epicgames.com/documentation/en-us/unreal-engine/whats-new
- UE 5.7 공지: https://www.unrealengine.com/en-US/news/unreal-engine-5-7-is-now-available
- UE 5.5 블로그: https://www.unrealengine.com/en-US/blog/unreal-engine-5-5-is-now-available
- 마이그레이션 가이드: https://docs.unrealengine.com/5.7/en-US/upgrading-projects/
