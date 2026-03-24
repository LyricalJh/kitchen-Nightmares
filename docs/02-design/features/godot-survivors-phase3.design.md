# Godot Survivors Phase 3 Design Document

> **Summary**: 게임 루프 완성 설계 — 타이틀, 게임오버/재시작, 생존 시간/최고 기록, 웨이브 난이도
>
> **Project**: chef-nightmare
> **Version**: 0.3.0
> **Author**: AI + User
> **Date**: 2026-03-24
> **Status**: Draft
> **Planning Doc**: [godot-survivors-phase3.plan.md](../01-plan/features/godot-survivors-phase3.plan.md)

---

## 1. Overview

### 1.1 Design Goals

- 타이틀→플레이→게임오버→재시작의 완전한 게임 루프 완성
- 시간 경과에 따른 웨이브 난이도 증가로 긴장감 제공
- 생존 시간 + 최고 기록으로 리플레이 동기 부여
- 기존 Phase 1/2 코드 최소 수정

### 1.2 Design Principles

- **씬 전환**: `change_scene_to_file()`로 완전한 상태 초기화 보장
- **시그널 기반**: player → main 간 died 시그널로 게임오버 트리거
- **로컬 저장**: ConfigFile로 최고 기록 영구 저장

---

## 2. Architecture

### 2.1 씬 전환 흐름

```
[TitleScreen] ──시작 버튼──> change_scene_to_file("res://scenes/main.tscn")
                                        │
                              [게임 플레이 루프]
                                        │
                              [HP 0 → died 시그널]
                                        │
                              [GameOverUI 표시]
                                   ┌────┴────┐
                                   ▼         ▼
                          [재시작 버튼]   [타이틀 버튼]
                                   │         │
                    reload_current_scene()   change_scene_to_file("title_screen.tscn")
```

### 2.2 TitleScreen 씬 (`scenes/title_screen.tscn`)

```
TitleScreen (Control, full_rect)
├── VBoxContainer (중앙 정렬)
│   ├── TitleLabel ("Chef Nightmare", 큰 폰트)
│   ├── SubtitleLabel ("뱀서류 서바이벌")
│   └── StartButton (Button, "게임 시작")
```

### 2.3 GameOverUI 씬 (`scenes/game_over_ui.tscn`)

```
GameOverUI (CanvasLayer, process_mode=PROCESS_MODE_WHEN_PAUSED)
├── Background (ColorRect, full_rect, Color(0,0,0,0.7))
└── CenterContainer (full_rect)
    └── VBoxContainer (separation=16)
        ├── GameOverLabel ("게임 오버")
        ├── SurvivalTimeLabel ("생존 시간: 00:00")
        ├── BestTimeLabel ("최고 기록: 00:00")
        ├── RestartButton (Button, "다시 시작")
        └── TitleButton (Button, "타이틀로")
```

### 2.4 HUD 수정 (`scenes/hud.tscn`)

기존 VBoxContainer에 TimeLabel 추가:
```
HUD (CanvasLayer) [기존]
└── MarginContainer
    └── VBoxContainer
        ├── HPBar [기존]
        ├── XPBar [기존]
        ├── LevelLabel [기존]
        └── TimeLabel (Label, "00:00") [신규]
```

### 2.5 Main 씬 수정 (`scenes/main.tscn`)

기존 씬에 GameOverUI 인스턴스 추가:
```
Main (Node2D)
├── Player [기존]
├── EnemySpawnTimer [기존]
├── HUD [기존]
├── LevelUpUI [기존]
└── GameOverUI [신규 인스턴스]
```

---

## 3. Data Model

### 3.1 Player 확장

```gdscript
# 신규 시그널
signal died  # HP 0 도달 시 발생
```

### 3.2 Main 확장 변수

```gdscript
# 시간 추적 (FR-22)
var elapsed_time: float = 0.0

# 웨이브 시스템 (FR-23, FR-24)
var wave_level: int = 0
var wave_interval: float = 30.0      # 30초마다 웨이브 증가
var next_wave_time: float = 30.0     # 다음 웨이브 시간
var enemy_speed_multiplier: float = 1.0  # 적 속도 배수

# 게임 상태
var game_over: bool = false
```

### 3.3 ConfigFile 저장 구조

```
파일 경로: user://save_data.cfg
섹션: [records]
키: best_time (float, 초 단위)
```

---

## 4. 스크립트 상세 명세

### 4.1 title_screen.gd

| 함수 | 설명 | FR 매핑 |
|------|------|---------|
| `_ready()` | StartButton 시그널 연결 | - |
| `_on_start_pressed()` | Main 씬으로 전환 | FR-17 |

**핵심 로직:**
```
_on_start_pressed():
  get_tree().change_scene_to_file("res://scenes/main.tscn")
```

### 4.2 game_over_ui.gd

| 함수 | 설명 | FR 매핑 |
|------|------|---------|
| `_ready()` | 버튼 시그널 연결, 숨김, process_mode 설정 | - |
| `show_results(time, best)` | 결과 표시 (생존 시간, 최고 기록) | FR-19 |
| `_on_restart_pressed()` | 게임 재시작 | FR-20 |
| `_on_title_pressed()` | 타이틀로 돌아가기 | FR-20 |
| `_format_time(seconds)` | 초를 MM:SS 형식으로 변환 | FR-19 |

**핵심 로직:**
```
show_results(survival_time, best_time):
  $..../SurvivalTimeLabel.text = "생존 시간: " + _format_time(survival_time)
  $..../BestTimeLabel.text = "최고 기록: " + _format_time(best_time)
  visible = true

_on_restart_pressed():
  get_tree().paused = false
  get_tree().reload_current_scene()

_on_title_pressed():
  get_tree().paused = false
  get_tree().change_scene_to_file("res://scenes/title_screen.tscn")

_format_time(seconds: float) -> String:
  var mins := int(seconds) / 60
  var secs := int(seconds) % 60
  return "%02d:%02d" % [mins, secs]
```

### 4.3 player.gd 수정

| 함수 | 변경 유형 | 설명 | FR 매핑 |
|------|-----------|------|---------|
| 시그널 추가 | 신규 | `signal died` 선언 | FR-18 |
| `take_damage()` | 수정 | HP 0 시 died 시그널 발생 | FR-18 |

**변경점:**
```
# 시그널 추가
signal died

# take_damage() 수정 - HP 0 시:
if hp <= 0:
  hp = 0
  hp_changed.emit(hp, max_hp)
  died.emit()  # 신규: 게임오버 트리거
```

### 4.4 hud.gd 수정

| 함수 | 변경 유형 | 설명 | FR 매핑 |
|------|-----------|------|---------|
| `update_time(seconds)` | 신규 | 경과 시간 표시 | FR-22 |

**추가:**
```gdscript
@onready var time_label: Label = $MarginContainer/VBoxContainer/TimeLabel

func update_time(seconds: float) -> void:
  var mins := int(seconds) / 60
  var secs := int(seconds) % 60
  time_label.text = "%02d:%02d" % [mins, secs]
```

### 4.5 main.gd 수정

| 함수 | 변경 유형 | 설명 | FR 매핑 |
|------|-----------|------|---------|
| `_ready()` | 수정 | GameOverUI 참조, died 시그널 연결 | - |
| `_process(delta)` | 신규 | 시간 추적, HUD 업데이트, 웨이브 체크 | FR-22, FR-23, FR-24 |
| `_on_player_died()` | 신규 | 게임오버 처리 | FR-18, FR-19 |
| `_check_wave(time)` | 신규 | 30초마다 난이도 증가 | FR-23, FR-24 |
| `_load_best_time()` | 신규 | ConfigFile에서 최고 기록 불러오기 | FR-21 |
| `_save_best_time(time)` | 신규 | ConfigFile에 최고 기록 저장 | FR-21 |
| `_spawn_enemy()` | 수정 | enemy_speed_multiplier 적용 | FR-24 |

**핵심 로직:**
```
_ready() 추가:
  @onready var game_over_ui: CanvasLayer = $GameOverUI
  player.died.connect(_on_player_died)
  game_over_ui 버튼 시그널은 game_over_ui.gd 내부에서 처리

_process(delta):
  if game_over:
    return
  elapsed_time += delta
  hud.update_time(elapsed_time)
  _check_wave()

_check_wave():
  if elapsed_time >= next_wave_time:
    wave_level += 1
    next_wave_time += wave_interval
    # 스폰 빈도 증가 (FR-23)
    $EnemySpawnTimer.wait_time = max($EnemySpawnTimer.wait_time * 0.9, 0.3)
    # 적 속도 증가 (FR-24)
    enemy_speed_multiplier *= 1.1

_on_player_died():
  game_over = true
  get_tree().paused = true
  var best := _load_best_time()
  if elapsed_time > best:
    best = elapsed_time
    _save_best_time(best)
  game_over_ui.show_results(elapsed_time, best)

_spawn_enemy() 수정:
  enemy.speed *= enemy_speed_multiplier  # 웨이브 배수 적용

_load_best_time() -> float:
  var config := ConfigFile.new()
  config.load("user://save_data.cfg")
  return config.get_value("records", "best_time", 0.0)

_save_best_time(time: float):
  var config := ConfigFile.new()
  config.load("user://save_data.cfg")
  config.set_value("records", "best_time", time)
  config.save("user://save_data.cfg")
```

---

## 5. project.godot 수정

```ini
[application]
run/main_scene="res://scenes/title_screen.tscn"  # 변경: main → title_screen
```

---

## 6. 시그널 연결 맵 (Phase 3 신규)

| 소스 | 시그널 | 대상 | 대상 함수 | 연결 방식 |
|------|--------|------|-----------|-----------|
| Player | died | Main | `_on_player_died` | 코드 |
| StartButton | pressed | TitleScreen | `_on_start_pressed` | 코드 |
| RestartButton | pressed | GameOverUI | `_on_restart_pressed` | 코드 |
| TitleButton | pressed | GameOverUI | `_on_title_pressed` | 코드 |

---

## 7. process_mode 설정

| 노드 | process_mode | 이유 |
|------|-------------|------|
| GameOverUI | PROCESS_MODE_WHEN_PAUSED | 게임오버 시 버튼 입력 필요 |
| LevelUpUI | PROCESS_MODE_WHEN_PAUSED | 기존 유지 |
| HUD | PROCESS_MODE_ALWAYS | 기존 유지 |

---

## 8. Implementation Guide

### 8.1 Implementation Order

1. [ ] **Step 1**: `title_screen.tscn` + `title_screen.gd` — 타이틀 화면
2. [ ] **Step 2**: `game_over_ui.tscn` + `game_over_ui.gd` — 게임오버 UI
3. [ ] **Step 3**: `player.gd` 수정 — died 시그널 추가
4. [ ] **Step 4**: `hud.tscn` + `hud.gd` 수정 — TimeLabel 추가
5. [ ] **Step 5**: `main.tscn` + `main.gd` 수정 — 시간/웨이브/게임오버/기록 연동
6. [ ] **Step 6**: `project.godot` 수정 — main_scene → title_screen

### 8.2 FR-Implementation 매핑

| FR | 구현 파일 | Step |
|----|-----------|------|
| FR-17 | title_screen.gd `_on_start_pressed` | Step 1 |
| FR-18 | player.gd `died` 시그널, main.gd `_on_player_died` | Step 3, 5 |
| FR-19 | game_over_ui.gd `show_results` | Step 2 |
| FR-20 | game_over_ui.gd `_on_restart_pressed`, `_on_title_pressed` | Step 2 |
| FR-21 | main.gd `_load_best_time`, `_save_best_time` | Step 5 |
| FR-22 | main.gd `_process`, hud.gd `update_time` | Step 4, 5 |
| FR-23 | main.gd `_check_wave` (EnemySpawnTimer.wait_time) | Step 5 |
| FR-24 | main.gd `_check_wave` (enemy_speed_multiplier) | Step 5 |

---

## 9. Coding Conventions

Phase 1/2 컨벤션 유지:

| Target | Rule | Example |
|--------|------|---------|
| 씬 파일 | snake_case.tscn | `title_screen.tscn`, `game_over_ui.tscn` |
| 스크립트 | snake_case.gd | `title_screen.gd`, `game_over_ui.gd` |
| 노드 이름 | PascalCase | `TitleScreen`, `GameOverUI`, `TimeLabel` |
| 시그널 | snake_case | `died` |
| 한국어 주석 | 모든 함수 | FR 매핑 포함 |

---

## Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 0.1 | 2026-03-24 | Initial draft | AI + User |
