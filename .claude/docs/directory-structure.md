# 디렉터리 구조 (UE5.7 프로젝트)

```text
ProjectFreeHero/
├── CLAUDE.md                    # 마스터 설정 (이 프로젝트)
├── .claude/                     # 에이전트 정의, 스킬, 훅, 룰, 문서
├── ProjectFreeHero.uproject     # Unreal 프로젝트 기술자
├── Content/                     # UE5 Blueprints, meshes, textures, 에셋 (바이너리)
├── Config/                      # UE5 INI 설정 (DefaultGame/Engine/Input/Editor)
├── Script/                      # Angelscript 시스템 레이어 (`.as` — BP+Angelscript 정책)
│   ├── Core/                    # UObject/Component 상속 (HealthComponent 등)
│   ├── Gameplay/                # 게임플레이 시스템 (어빌리티, 어트리뷰트)
│   └── UI/                      # Widget helper 로직
├── Source/                      # ❌ 사용자 C++ 금지 (플러그인 C++는 Plugins/*/Source/ 에 격리)
├── Plugins/                     # 마켓플레이스 / 로컬 플러그인
│   ├── Angelscript/             # UnrealEngine-Angelscript-ZH (커뮤니티 UE 5.7 플러그인)
│   └── BpGeneratorUltimate/     # UBG (로컬 배치 시)
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

- **BP + Angelscript 이중 레이어**:
  - **콘텐츠/튜닝**은 `Content/` 내 `.uasset` Blueprint (바이너리, BP diff 도구 사용)
  - **시스템 레이어**는 `Script/` 내 `.as` Angelscript (텍스트, 일반 diff/리뷰 가능)
  - 사용자 C++ 금지. `Source/` 생성 금지. `.claude/rules/` 의 `src/gameplay/**` 룰은
    본 프로젝트에서 `Content/Blueprints/Gameplay/**` + `Script/Gameplay/**` 로 매핑.
- **기본 gitignore**: `Binaries/`, `Intermediate/`, `Saved/`,
  `DerivedDataCache/`, `.vs/` — 이미 `.gitignore`에 포함되어 있습니다.
- **UBG 통합**: Ultimate Engine CoPilot은 Unreal Editor 내부에서 Claude Code를
  호출합니다. 동일한 `.claude/` 트리를 에이전트/스킬/훅 설정으로 읽습니다.
  `.claude/docs/ubg-integration.md` 참조.
