# godot-survivors-phase2 Gap Analysis Report

> **Analysis Type**: Gap Analysis (Design vs Implementation)
> **Project**: chef-nightmare | **Version**: 0.2.0 | **Date**: 2026-03-24
> **Design Doc**: `docs/02-design/features/godot-survivors-phase2.design.md`

---

## Match Rate: 97% (91/93 items + 2 partial)

| Category | Items | Matched | Status |
|----------|:-----:|:-------:|:------:|
| project.godot | 2 | 2 | ✅ |
| XP Gem (scene+script) | 11 | 11 | ✅ |
| Player (signals+functions) | 13 | 13 | ✅ |
| Enemy die() | 5 | 5 | ✅ |
| Projectile 수정 | 5 | 5 | ✅ |
| HUD (scene+script) | 10 | 10 | ✅ |
| LevelUpUI (scene+script) | 14 | 12 | ⚠️ 2 partial |
| Main (scene+script) | 11 | 11 | ✅ |
| Signal map | 8 | 8 | ✅ |
| Groups | 3 | 3 | ✅ |
| process_mode | 3 | 3 | ✅ |
| FR Coverage | 8/8 | 8 | ✅ |

## Minor Differences (4건, 기능 영향 없음)

| # | Item | Design | Implementation | Impact |
|---|------|--------|----------------|--------|
| 1 | LevelUpUI CenterContainer 부모 | CanvasLayer 직접 자식 | Background(ColorRect) 자식 | 없음 |
| 2 | 버튼 핸들러 패턴 | 단일 `_on_skill_selected(type)` | 3개 별도 함수 | 없음 |
| 3 | hp_changed 파라미터명 | `max` | `maximum` | 없음 |
| 4 | xp_gem_scene 프리로드 위치 | main.gd | enemy.gd (더 적절) | 없음 |

## Beneficial Additions (6건)

| # | Item | Value |
|---|------|-------|
| 1 | `has_method("add_xp")` 가드 | 방어적 프로그래밍 |
| 2 | _ready()에서 초기 HP/XP 시그널 | HUD 초기값 표시 |
| 3 | @onready 노드 참조 | 캐싱된 노드 접근 |
| 4 | show_percentage = false | 깔끔한 UI |
| 5 | Button custom_minimum_size | 일관된 버튼 크기 |
| 6 | TitleLabel 중앙 정렬 | 적절한 텍스트 배치 |

## FR Coverage: 8/8 (100%)

| FR | Status |
|----|:------:|
| FR-09 적 처치 시 보석 드랍 | ✅ |
| FR-10 보석 접촉 시 XP 획득 | ✅ |
| FR-11 레벨업 시스템 | ✅ |
| FR-12 일시정지 + UI 표시 | ✅ |
| FR-13 스킬 3종 선택 | ✅ |
| FR-14 스킬 적용 + 게임 재개 | ✅ |
| FR-15 HP 바 HUD | ✅ |
| FR-16 XP 바 + 레벨 HUD | ✅ |

**Verdict**: 설계와 구현이 매우 잘 일치. 4건의 차이 모두 기능 영향 없음. 수정 불필요.
