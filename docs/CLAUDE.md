# Docs Directory

이 디렉터리의 파일을 작성하거나 편집할 때 다음 표준을 따릅니다.

## Architecture Decision Records (`docs/architecture/`)

ADR 템플릿을 사용하세요: `.claude/docs/templates/architecture-decision-record.md`

**필수 섹션:** Title, Status, Context, Decision, Consequences,
ADR Dependencies, Engine Compatibility, GDD Requirements Addressed

**Status 생명주기:** `Proposed` → `Accepted` → `Superseded`
- `Accepted` 단계는 건너뛸 수 없습니다 — `Proposed` 상태의 ADR을 참조하는 스토리는 자동으로 차단됩니다
- 가이드 플로우를 통해 ADR을 생성할 때는 `/architecture-decision`을 사용합니다

**TR Registry:** `docs/architecture/tr-registry.yaml`
- GDD 요구사항을 스토리와 연결하는 안정적인 요구사항 ID(예: `TR-MOV-001`)
- 기존 ID의 번호는 절대 재부여하지 마세요 — 새 항목만 추가합니다
- `/architecture-review` Phase 8에서 업데이트됩니다

**Control Manifest:** `docs/architecture/control-manifest.md`
- 플랫한 프로그래머 규칙 시트: 레이어별 Required / Forbidden / Guardrails
- 헤더에 날짜가 기록된 `Manifest Version:`
- 스토리는 이 버전을 내장하며, `/story-done`이 오래된 버전인지 확인합니다

**검증:** ADR 세트를 완료한 후에는 `/architecture-review`를 실행합니다.

## Engine Reference (`docs/engine-reference/`)

버전이 고정된 엔진 API 스냅샷입니다. **어떤 엔진 API를 사용하기 전에도
반드시 이곳을 먼저 확인하세요** — LLM의 학습 데이터는 고정된 엔진 버전보다 오래되었습니다.

현재 엔진: `docs/engine-reference/unreal/VERSION.md` 참조
