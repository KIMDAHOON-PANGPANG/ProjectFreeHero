# 경로별 룰

`.claude/rules/` 의 룰은 매칭되는 경로의 파일을 편집할 때 자동으로 강제됩니다:

| 룰 파일 | 경로 패턴 | 강제 사항 |
| ---- | ---- | ---- |
| `gameplay-code.md` | `src/gameplay/**` | 데이터 주도 값, 델타 타임, UI 참조 없음 |
| `engine-code.md` | `src/core/**` | 핫 패스에서 제로 할당, 스레드 안전성, API 안정성 |
| `ai-code.md` | `src/ai/**` | 성능 예산, 디버그 용이성, 데이터 주도 파라미터 |
| `network-code.md` | `src/networking/**` | 서버 권한, 버전 관리되는 메시지, 보안 |
| `ui-code.md` | `src/ui/**` | 게임 상태 소유 금지, 지역화 가능, 접근성 |
| `design-docs.md` | `design/gdd/**` | 필수 8개 섹션, 수식 포맷, 엣지 케이스 |
| `narrative.md` | `design/narrative/**` | 로어 일관성, 캐릭터 보이스, 캐논 레벨 |
| `data-files.md` | `assets/data/**` | JSON 유효성, 네이밍 컨벤션, 스키마 룰 |
| `test-standards.md` | `tests/**` | 테스트 네이밍, 커버리지 요구사항, 픽스쳐 패턴 |
| `prototype-code.md` | `prototypes/**` | 완화된 표준, README 필수, 가설 문서화 |
| `shader-code.md` | `assets/shaders/**` | 네이밍 컨벤션, 성능 목표, 크로스 플랫폼 룰 |
