# Godot Survivors Phase 2 Design Document

> **Summary**: 성장 시스템 상세 설계 — XP 보석, 레벨업, 스킬 선택 UI, HUD
>
> **Project**: chef-nightmare
> **Version**: 0.2.0
> **Author**: AI + User
> **Date**: 2026-03-24
> **Status**: Draft
> **Planning Doc**: [godot-survivors-phase2.plan.md](../01-plan/features/godot-survivors-phase2.plan.md)

---

## 1. Overview

### 1.1 Design Goals

- Phase 1 기존 코드를 최소 수정하며 성장 시스템 추가
- 적 처치 → 보석 → 레벨업 → 스킬 선택의 뱀서류 핵심 루프 완성
- CanvasLayer 기반 HUD/UI로 게임 월드와 독립적인 UI 구현
- 레벨업 시 게임 일시정지/재개가 정확히 동작

### 1.2 Design Principles

- **최소 침습**: 기존 파일은 필요한 부분만 수정, 신규 기능은 신규 파일로 분리
- **시그널 기반 통신**: 노드 간 직접 참조 최소화, 시그널로 이벤트 전달
- **process_mode 활용**: 일시정지 중에도 UI가 동작하도록 설정

---

## 2. Architecture

### 2.1 씬 트리 구조 (Phase 2 확장)

```
Main (Node2D) [main.tscn - 수정]
├── Player (CharacterBody2D) [기존]
│   ├── ColorRect (파란색 32x32)
│   ├── CollisionShape2D
│   └── AttackTimer (Timer, 0.5초)
├── EnemySpawnTimer (Timer, 1초) [기존]
├── HUD (CanvasLayer) [신규 인스턴스]
│   ├── MarginContainer
│   │   ├── VBoxContainer
│   │   │   ├── HPBar (ProgressBar, 빨간색)
│   │   │   ├── XPBar (ProgressBar, 초록색)
│   │   │   └── LevelLabel (Label, "Lv. 1")
├── LevelUpUI (CanvasLayer) [신규 인스턴스]
│   ├── ColorRect (반투명 배경)
│   ├── VBoxContainer (중앙 정렬)
│   │   ├── TitleLabel ("레벨 업! 스킬을 선택하세요")
│   │   ├── SkillButton1 (Button, "공격력 +5")
│   │   ├── SkillButton2 (Button, "발사 속도 +20%")
│   │   └── SkillButton3 (Button, "이동 속도 +30")
└── (동적 생성)
    ├── Enemy [기존]
    ├── Projectile [기존]
    └── XPGem (Area2D) [신규]
```

### 2.2 개별 씬 구조

#### XP Gem 씬 (`scenes/xp_gem.tscn`)
```
XPGem (Area2D)
├── ColorRect (초록색, size=10x10, position=(-5,-5))
└── CollisionShape2D (RectangleShape2D, size=10x10)
```

#### HUD 씬 (`scenes/hud.tscn`)
```
HUD (CanvasLayer)
└── MarginContainer (anchors: top-left, margin=10)
    └── VBoxContainer (separation=4)
        ├── HPBar (ProgressBar, min=0, max=100, value=100, 200x20)
        ├── XPBar (ProgressBar, min=0, max=20, value=0, 200x16)
        └── LevelLabel (Label, text="Lv. 1")
```

#### LevelUpUI 씬 (`scenes/level_up_ui.tscn`)
```
LevelUpUI (CanvasLayer, process_mode=PROCESS_MODE_WHEN_PAUSED)
├── Background (ColorRect, full_rect, Color(0,0,0,0.5))
└── CenterContainer (full_rect)
    └── VBoxContainer (separation=16)
        ├── TitleLabel (Label, "레벨 업! 스킬을 선택하세요")
        ├── SkillButton1 (Button, "공격력 +5")
        ├── SkillButton2 (Button, "발사 속도 +20%")
        └── SkillButton3 (Button, "이동 속도 +30")
```

### 2.3 충돌 레이어 확장

| Layer | Name | 비트값 (.tscn) | 용도 |
|-------|------|:-----------:|------|
| 1 | Player | 1 | 플레이어 (기존) |
| 2 | Enemy | 2 | 적 (기존) |
| 3 | Projectile | 4 | 발사체 (기존) |
| 4 | XPGem | 8 | 경험치 보석 (신규) |

| 노드 | collision_layer | collision_mask | 설명 |
|------|:-:|:-:|------|
| Player | 1 | 2 | 기존 유지 |
| Enemy | 2 | 1 | 기존 유지 |
| Projectile | 4 | 2 | 기존 유지 |
| XPGem | 8 | 1 | Player와만 충돌 감지 |

**project.godot 추가 설정:**
```ini
[layer_names]
2d_physics/layer_4="XPGem"
```

---

## 3. Data Model

### 3.1 Player 확장 변수

```gdscript
# 기존 변수 (유지)
@export var speed: float = 200.0
var hp: int = 100
var max_hp: int = 100
var xp: int = 0

# Phase 2 신규 변수
var level: int = 1                    # 현재 레벨
var xp_to_next_level: int = 20        # 다음 레벨까지 필요 XP
var attack_damage: int = 1            # 발사체 공격력 (Phase 2 확장용)

# Phase 2 신규 시그널
signal leveled_up(new_level: int)     # 레벨업 시 발생
signal hp_changed(current: int, max: int)  # HP 변경 시 발생
signal xp_changed(current: int, required: int)  # XP 변경 시 발생
```

### 3.2 XP Gem 변수

```gdscript
# xp_gem.gd 변수
var xp_value: int = 5                 # 습득 시 XP 양
```

### 3.3 레벨업 XP 공식

```
xp_to_next_level = level * 20
Level 1→2: 20 XP
Level 2→3: 40 XP
Level 3→4: 60 XP
...
```

### 3.4 스킬 스탯 효과

| 스킬 | 효과 | 적용 방식 |
|------|------|-----------|
| 공격력 +5 | attack_damage += 5 | 발사체가 enemy hp 감소 (Phase 3 대비 변수만 준비, 현재는 1hit kill) |
| 발사 속도 +20% | AttackTimer.wait_time *= 0.8 | 타이머 간격 감소 |
| 이동 속도 +30 | speed += 30 | 이동 속도 직접 증가 |

---

## 4. 스크립트 상세 명세

### 4.1 xp_gem.gd 명세

| 함수 | 설명 | FR 매핑 |
|------|------|---------|
| `_ready()` | 그룹 등록, body_entered 시그널 연결 | - |
| `_on_body_entered(body)` | 플레이어 접촉 시 XP 전달 + 자신 제거 | FR-10 |

**핵심 로직:**
```
_ready():
  1. add_to_group("xp_gems")
  2. body_entered.connect(_on_body_entered)

_on_body_entered(body):
  1. body가 "player" 그룹 소속인지 확인
  2. body.add_xp(xp_value) 호출
  3. queue_free()  # 보석 제거
```

### 4.2 player.gd 수정 명세

| 함수 | 변경 유형 | 설명 | FR 매핑 |
|------|-----------|------|---------|
| `add_xp(amount)` | 신규 | XP 추가 + 레벨업 체크 | FR-10, FR-11 |
| `_check_level_up()` | 신규 | XP 임계값 도달 시 레벨업 | FR-11 |
| `apply_skill(skill_type)` | 신규 | 스탯 적용 | FR-14 |
| `take_damage(amount)` | 수정 | hp_changed 시그널 추가 | FR-15 |

**핵심 로직:**
```
add_xp(amount):
  1. xp += amount
  2. xp_changed.emit(xp, xp_to_next_level)
  3. _check_level_up()

_check_level_up():
  1. while xp >= xp_to_next_level:
  2.   xp -= xp_to_next_level
  3.   level += 1
  4.   xp_to_next_level = level * 20
  5.   leveled_up.emit(level)
  6.   xp_changed.emit(xp, xp_to_next_level)

apply_skill(skill_type: String):
  1. match skill_type:
  2.   "attack": attack_damage += 5
  3.   "fire_rate": AttackTimer.wait_time *= 0.8 (min 0.1)
  4.   "move_speed": speed += 30
```

### 4.3 enemy.gd 수정 명세

| 함수 | 변경 유형 | 설명 | FR 매핑 |
|------|-----------|------|---------|
| `die()` | 신규 | 처치 시 보석 드랍 + 자신 제거 | FR-09 |

**핵심 로직:**
```
die():
  1. XP 보석 드랍: xp_gem 씬 인스턴스 생성
  2. gem.global_position = global_position
  3. get_tree().current_scene.add_child(gem)
  4. queue_free()  # 적 자신 제거
```

**변경점**: projectile.gd의 `_on_body_entered`에서 `body.queue_free()` 대신 `body.die()` 호출

### 4.4 projectile.gd 수정 명세

| 함수 | 변경 유형 | 설명 | FR 매핑 |
|------|-----------|------|---------|
| `_on_body_entered(body)` | 수정 | `queue_free()` → `die()` 호출로 변경 | FR-09 |

**변경:**
```
_on_body_entered(body):
  if body.is_in_group("enemies"):
    if body.has_method("die"):
      body.die()       # die()로 보석 드랍 포함 처치
    else:
      body.queue_free()  # 폴백
    queue_free()
```

### 4.5 hud.gd 명세

| 함수 | 설명 | FR 매핑 |
|------|------|---------|
| `update_hp(current, max)` | HP 바 업데이트 | FR-15 |
| `update_xp(current, required)` | XP 바 업데이트 | FR-16 |
| `update_level(level)` | 레벨 표시 업데이트 | FR-16 |

**핵심 로직:**
```
update_hp(current, max_val):
  $MarginContainer/VBoxContainer/HPBar.max_value = max_val
  $MarginContainer/VBoxContainer/HPBar.value = current

update_xp(current, required):
  $MarginContainer/VBoxContainer/XPBar.max_value = required
  $MarginContainer/VBoxContainer/XPBar.value = current

update_level(new_level):
  $MarginContainer/VBoxContainer/LevelLabel.text = "Lv. " + str(new_level)
```

### 4.6 level_up_ui.gd 명세

| 함수 | 설명 | FR 매핑 |
|------|------|---------|
| `_ready()` | 버튼 시그널 연결, 숨김 상태 | - |
| `show_ui()` | UI 표시 | FR-12 |
| `hide_ui()` | UI 숨김 | FR-14 |
| `_on_skill_selected(skill_type)` | 스킬 선택 처리 | FR-13, FR-14 |

**핵심 로직:**
```
_ready():
  1. visible = false
  2. process_mode = PROCESS_MODE_WHEN_PAUSED
  3. 3개 버튼에 pressed 시그널 연결

show_ui():
  1. visible = true

hide_ui():
  1. visible = false

_on_skill_selected(skill_type):
  1. skill_selected 시그널 발생 (skill_type 전달)
  2. hide_ui()
```

**시그널:**
```gdscript
signal skill_selected(skill_type: String)
```

### 4.7 main.gd 수정 명세

| 함수 | 변경 유형 | 설명 | FR 매핑 |
|------|-----------|------|---------|
| `_ready()` | 수정 | HUD/LevelUpUI 시그널 연결 추가 | - |
| `_on_player_leveled_up(level)` | 신규 | 레벨업 처리 (일시정지 + UI) | FR-12 |
| `_on_skill_selected(skill_type)` | 신규 | 스킬 적용 + 게임 재개 | FR-13, FR-14 |
| `_on_player_hp_changed(current, max)` | 신규 | HUD HP 업데이트 | FR-15 |
| `_on_player_xp_changed(current, required)` | 신규 | HUD XP 업데이트 | FR-16 |

**핵심 로직:**
```
_ready() 추가:
  1. xp_gem_scene = preload("res://scenes/xp_gem.tscn")
  2. player.leveled_up.connect(_on_player_leveled_up)
  3. player.hp_changed.connect(_on_player_hp_changed)
  4. player.xp_changed.connect(_on_player_xp_changed)
  5. $LevelUpUI.skill_selected.connect(_on_skill_selected)

_on_player_leveled_up(new_level):
  1. get_tree().paused = true
  2. $HUD.update_level(new_level)
  3. $LevelUpUI.show_ui()

_on_skill_selected(skill_type):
  1. player.apply_skill(skill_type)
  2. get_tree().paused = false

_on_player_hp_changed(current, max_val):
  1. $HUD.update_hp(current, max_val)

_on_player_xp_changed(current, required):
  1. $HUD.update_xp(current, required)
```

---

## 5. 시그널 연결 전체 맵

| 소스 | 시그널 | 대상 | 대상 함수 | 연결 방식 |
|------|--------|------|-----------|-----------|
| EnemySpawnTimer | timeout | Main | `_on_enemy_spawn_timer_timeout` | 코드 (기존) |
| AttackTimer | timeout | Main | `_on_attack_timer_timeout` | 코드 (기존) |
| Projectile | body_entered | Projectile | `_on_body_entered` | 코드 (기존) |
| XPGem | body_entered | XPGem | `_on_body_entered` | 코드 (신규) |
| Player | leveled_up | Main | `_on_player_leveled_up` | 코드 (신규) |
| Player | hp_changed | Main | `_on_player_hp_changed` | 코드 (신규) |
| Player | xp_changed | Main | `_on_player_xp_changed` | 코드 (신규) |
| LevelUpUI | skill_selected | Main | `_on_skill_selected` | 코드 (신규) |
| SkillButton1 | pressed | LevelUpUI | `_on_skill_selected("attack")` | 코드 (신규) |
| SkillButton2 | pressed | LevelUpUI | `_on_skill_selected("fire_rate")` | 코드 (신규) |
| SkillButton3 | pressed | LevelUpUI | `_on_skill_selected("move_speed")` | 코드 (신규) |

---

## 6. 그룹 확장

| 그룹명 | 소속 노드 | 용도 |
|--------|-----------|------|
| `enemies` | Enemy 인스턴스 | 기존 유지 |
| `player` | Player | 기존 유지 |
| `xp_gems` | XPGem 인스턴스 | 보석 관리 (신규) |

---

## 7. process_mode 설정

| 노드 | process_mode | 이유 |
|------|-------------|------|
| LevelUpUI (CanvasLayer) | PROCESS_MODE_WHEN_PAUSED | 게임 일시정지 중에도 버튼 입력 받아야 함 |
| HUD (CanvasLayer) | PROCESS_MODE_ALWAYS | 일시정지 중에도 표시 유지 |
| 나머지 모든 노드 | PROCESS_MODE_INHERIT (기본) | 일시정지 시 함께 정지 |

---

## 8. Implementation Guide

### 8.1 Implementation Order

1. [ ] **Step 1**: `project.godot` 수정 — Layer 4 이름 추가
2. [ ] **Step 2**: `xp_gem.tscn` + `xp_gem.gd` 생성 — 보석 씬/스크립트
3. [ ] **Step 3**: `player.gd` 수정 — XP/레벨업 로직, 시그널, apply_skill
4. [ ] **Step 4**: `enemy.gd` 수정 — die() 함수 추가
5. [ ] **Step 5**: `projectile.gd` 수정 — die() 호출로 변경
6. [ ] **Step 6**: `hud.tscn` + `hud.gd` 생성 — HP/XP 바, 레벨 표시
7. [ ] **Step 7**: `level_up_ui.tscn` + `level_up_ui.gd` 생성 — 스킬 선택 UI
8. [ ] **Step 8**: `main.tscn` + `main.gd` 수정 — 모든 시그널 연결, 일시정지 처리

### 8.2 FR-Implementation 매핑

| FR | 구현 파일 | Step |
|----|-----------|------|
| FR-09 | enemy.gd `die()` | Step 4 |
| FR-10 | xp_gem.gd `_on_body_entered`, player.gd `add_xp` | Step 2, 3 |
| FR-11 | player.gd `_check_level_up` | Step 3 |
| FR-12 | main.gd `_on_player_leveled_up`, level_up_ui.gd `show_ui` | Step 7, 8 |
| FR-13 | level_up_ui.gd 버튼 처리 | Step 7 |
| FR-14 | player.gd `apply_skill`, main.gd `_on_skill_selected` | Step 3, 8 |
| FR-15 | hud.gd `update_hp`, player.gd `hp_changed` 시그널 | Step 3, 6 |
| FR-16 | hud.gd `update_xp`/`update_level`, player.gd `xp_changed` 시그널 | Step 3, 6 |

---

## 9. Coding Conventions

### 9.1 Phase 1 컨벤션 유지

| Target | Rule | Example |
|--------|------|---------|
| 씬 파일 | snake_case.tscn | `xp_gem.tscn`, `hud.tscn`, `level_up_ui.tscn` |
| 스크립트 파일 | snake_case.gd | `xp_gem.gd`, `hud.gd`, `level_up_ui.gd` |
| 노드 이름 | PascalCase | `XPGem`, `HUD`, `LevelUpUI`, `HPBar`, `XPBar` |
| 시그널 | snake_case | `leveled_up`, `hp_changed`, `xp_changed`, `skill_selected` |
| 시그널 핸들러 | `_on_{source}_{signal}` | `_on_player_leveled_up`, `_on_skill_selected` |
| 한국어 주석 | 모든 함수에 포함 | 역할 설명 + FR 매핑 |

---

## Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 0.1 | 2026-03-24 | Initial draft | AI + User |
