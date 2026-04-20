# 디렉터리 구조 (UE5.7 프로젝트)

```text
ProjectFreeHero/
├── CLAUDE.md                    # 마스터 설정 (이 프로젝트)
├── .claude/                     # 에이전트 정의, 스킬, 훅, 룰, 문서
├── ProjectFreeHero.uproject     # Unreal 프로젝트 기술자
├── Content/                     # UE5 Blueprints, meshes, textures, 에셋 (바이너리)
├── Config/                      # UE5 INI 설정 (DefaultGame/Engine/Input/Editor)
├── Source/                      # ❌ 본 프로젝트 미사용 (BP-only 정책 — 생성 금지)
├── Plugins/                     # 마켓플레이스 / 로컬 플러그인 (로컬 UBG 포함 가능)
├── design/                      # 게임 디자인 문서 (gdd, 내러티브, 레벨, 밸런스)
├── docs/                        # 기술 문서 (아키텍처, ADR, 엔진 레퍼런스)
│   └── engine-reference/unreal/ # UE5.7 고정 API 스냅샷 + PLUGINS.md
├── tests/                       # 테스트 스위트 (자동화 테스트 추가 시 생성)
├── tools/                       # 빌드/파이프라인 도구 (필요 시 생성)
├── prototypes/                  # 일회성 프로토타입 (필요 시 생성)
└── production/                  # 스프린트, 마일스톤, 릴리스
    ├── session-state/           # 일시적 세션 상태 (active.md — gitignore 대상)
    └── session-logs/            # 세션 감사 기록 (gitignore 대상)
```

## UE5 특화 참고 사항

- **Blueprint 우선**: 대부분의 게임플레이는 `Content/` 내 `.uasset` 파일에 존재합니다.
  이 파일들은 바이너리이므로, 텍스트 diff가 아닌 Blueprint diff 도구에 의존하세요.
- **C++ 금지**: 본 프로젝트는 **BP-only** 정책. `Source/` 는 생성하지 않으며,
  모든 게임 로직은 `Content/` 내 `.uasset` Blueprint 로 구현합니다.
  `.claude/rules/` 의 `src/gameplay/**` 경로 스코프 룰은 본 프로젝트에서
  `Content/Blueprints/Gameplay/**` 로 개념적으로 매핑합니다.
- **기본 gitignore**: `Binaries/`, `Intermediate/`, `Saved/`,
  `DerivedDataCache/`, `.vs/` — 이미 `.gitignore`에 포함되어 있습니다.
- **UBG 통합**: Ultimate Engine CoPilot은 Unreal Editor 내부에서 Claude Code를
  호출합니다. 동일한 `.claude/` 트리를 에이전트/스킬/훅 설정으로 읽습니다.
  `.claude/docs/ubg-integration.md` 참조.
