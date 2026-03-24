# Godot Survivors MVP Design Document

> **Summary**: Godot 4 뱀서류 게임 MVP의 상세 기술 설계 — 씬 구조, 스크립트 명세, 충돌 시스템
>
> **Project**: chef-nightmare
> **Version**: 0.1.0
> **Author**: AI + User
> **Date**: 2026-03-24
> **Status**: Draft
> **Planning Doc**: [godot-survivors-mvp.plan.md](../01-plan/features/godot-survivors-mvp.plan.md)

---

## 1. Overview

### 1.1 Design Goals

- Godot 4 에디터에서 F5로 즉시 실행 가능한 완전한 프로젝트
- .tscn 텍스트 포맷을 정확히 준수하여 에디터 호환성 보장
- 핵심 게임플레이 루프(이동→생존→공격) 완성
- Phase 2 확장이 용이한 깔끔한 씬/스크립트 분리 구조

### 1.2 Design Principles

- **씬 분리**: 각 게임 오브젝트(Player, Enemy, Projectile)를 독립 씬으로 분리
- **최소 의존성**: 외부 에셋 없이 Godot 기본 노드만 사용
- **명확한 충돌 레이어**: Player/Enemy/Projectile 간 충돌을 레이어로 분리

---

## 2. Architecture

### 2.1 씬 트리 구조

```
Main (Node2D) [main.tscn]
├── Player (CharacterBody2D) [player.tscn - 인스턴스]
│   ├── ColorRect (파란색 32x32)
│   ├── CollisionShape2D (RectangleShape2D 16x16)
│   └── AttackTimer (Timer, wait_time=0.5, autostart=true)
├── EnemySpawnTimer (Timer, wait_time=1.0, autostart=true)
└── (동적 생성)
    ├── Enemy 인스턴스들...
    └── Projectile 인스턴스들...
```

### 2.2 개별 씬 구조

#### Player 씬 (`scenes/player.tscn`)
```
Player (CharacterBody2D)
├── ColorRect (파란색, size=32x32, position=(-16,-16))
├── CollisionShape2D (RectangleShape2D, size=32x32)
└── AttackTimer (Timer, wait_time=0.5, autostart=true)
```

#### Enemy 씬 (`scenes/enemy.tscn`)
```
Enemy (CharacterBody2D)
├── ColorRect (빨간색, size=24x24, position=(-12,-12))
└── CollisionShape2D (RectangleShape2D, size=24x24)
```

#### Projectile 씬 (`scenes/projectile.tscn`)
```
Projectile (Area2D)
├── ColorRect (노란색, size=8x8, position=(-4,-4))
└── CollisionShape2D (RectangleShape2D, size=8x8)
```

### 2.3 충돌 레이어 설계

| Layer | Name | 용도 |
|-------|------|------|
| 1 | Player | 플레이어 본체 |
| 2 | Enemy | 적 본체 |
| 3 | Projectile | 발사체 |

| 노드 | collision_layer | collision_mask | 설명 |
|------|----------------|----------------|------|
| Player | 1 (Player) | 2 (Enemy) | 적과의 충돌 감지 |
| Enemy | 2 (Enemy) | 1 (Player) | 플레이어와의 충돌 감지 |
| Projectile | 3 (Projectile) | 2 (Enemy) | 적과의 충돌 감지 |

---

## 3. Data Model

### 3.1 Player 상태

```gdscript
# player.gd 변수
var speed: float = 200.0       # 이동 속도 (px/s)
var hp: int = 100              # 체력 (FR-08)
var max_hp: int = 100          # 최대 체력
var xp: int = 0                # 경험치 (FR-08, Phase 2용)
var damage_cooldown: float = 0.0  # 데미지 쿨다운 (중복 데미지 방지)
```

### 3.2 Enemy 상태

```gdscript
# enemy.gd 변수
var speed: float = 80.0        # 추적 속도 (px/s)
var damage: int = 10           # 충돌 데미지량
```

### 3.3 Projectile 상태

```gdscript
# projectile.gd 변수
var speed: float = 400.0       # 발사체 속도 (px/s)
var direction: Vector2         # 발사 방향 (정규화)
var max_range: float = 600.0   # 최대 사거리 (px)
var distance_traveled: float = 0.0  # 이동 거리 추적
```

### 3.4 Main 상태

```gdscript
# main.gd 변수
var enemy_scene: PackedScene   # 적 씬 프리로드
var projectile_scene: PackedScene  # 발사체 씬 프리로드
var spawn_radius: float = 500.0    # 적 스폰 반경 (플레이어 기준)
```

---

## 4. 스크립트 상세 명세

### 4.1 project.godot 설정

```ini
[application]
config/name="Chef Nightmare"
run/main_scene="res://scenes/main.tscn"
config/features=PackedStringArray("4.0")

[display]
window/size/viewport_width=1280
window/size/viewport_height=720

[input]
move_up={deadzone: 0.5, events: [InputEventKey(keycode=87)]}    # W
move_down={deadzone: 0.5, events: [InputEventKey(keycode=83)]}  # S
move_left={deadzone: 0.5, events: [InputEventKey(keycode=65)]}  # A
move_right={deadzone: 0.5, events: [InputEventKey(keycode=68)]} # D

[physics]
common/physics_ticks_per_second=60

[layer_names]
2d_physics/layer_1="Player"
2d_physics/layer_2="Enemy"
2d_physics/layer_3="Projectile"
```

### 4.2 player.gd 명세

| 함수 | 설명 | FR 매핑 |
|------|------|---------|
| `_physics_process(delta)` | WASD 입력 처리 + 이동 + 화면 제한 | FR-01, FR-02 |
| `_get_input_direction()` | 입력 방향 벡터 계산 (정규화) | FR-01 |
| `take_damage(amount)` | HP 감소 처리 (쿨다운 포함) | FR-05 |

**핵심 로직:**
```
_physics_process(delta):
  1. Input.get_axis로 x, y 방향 계산
  2. Vector2(x, y).normalized() * speed로 velocity 설정
  3. move_and_slide() 호출
  4. position을 viewport 범위 내로 clamp
  5. damage_cooldown 감소
```

### 4.3 enemy.gd 명세

| 함수 | 설명 | FR 매핑 |
|------|------|---------|
| `_physics_process(delta)` | 플레이어 방향으로 이동 | FR-04 |
| `_on_collision(body)` | 플레이어 충돌 시 데미지 전달 | FR-05 |

**핵심 로직:**
```
_physics_process(delta):
  1. 씬 트리에서 Player 노드 참조
  2. (player.position - position).normalized() 방향 계산
  3. velocity = direction * speed
  4. move_and_slide() 호출
  5. 충돌 감지: get_slide_collision으로 Player 확인 → take_damage 호출
```

### 4.4 projectile.gd 명세

| 함수 | 설명 | FR 매핑 |
|------|------|---------|
| `_ready()` | 초기 설정 | - |
| `_physics_process(delta)` | 방향으로 이동 + 사거리 체크 | FR-06 |
| `_on_body_entered(body)` | 적 충돌 시 적 제거 + 자신 제거 | FR-07 |

**핵심 로직:**
```
_physics_process(delta):
  1. position += direction * speed * delta
  2. distance_traveled += speed * delta
  3. distance_traveled >= max_range → queue_free()

_on_body_entered(body):
  1. body가 Enemy 그룹 소속인지 확인
  2. body.queue_free()  # 적 제거
  3. queue_free()        # 발사체 자신 제거
```

### 4.5 main.gd 명세

| 함수 | 설명 | FR 매핑 |
|------|------|---------|
| `_ready()` | 씬 프리로드, 타이머 시그널 연결 | - |
| `_on_enemy_spawn_timer_timeout()` | 적 스폰 처리 | FR-03 |
| `_on_attack_timer_timeout()` | 발사체 생성 (Player의 AttackTimer 시그널) | FR-06 |
| `_get_closest_enemy()` | 가장 가까운 적 탐색 | FR-06 |
| `_spawn_enemy()` | 플레이어 주변 랜덤 위치에 적 인스턴스 생성 | FR-03 |

**핵심 로직:**
```
_on_enemy_spawn_timer_timeout():
  1. 랜덤 각도 (0~2PI) 계산
  2. 플레이어 위치 + Vector2(cos, sin) * spawn_radius로 위치 결정
  3. enemy_scene.instantiate() → position 설정 → add_child()

_on_attack_timer_timeout():
  1. _get_closest_enemy()로 가장 가까운 적 탐색
  2. 적이 없으면 return
  3. 플레이어→적 방향 벡터 정규화
  4. projectile_scene.instantiate()
  5. projectile.position = player.position
  6. projectile.direction = direction
  7. add_child(projectile)

_get_closest_enemy():
  1. get_tree().get_nodes_in_group("enemies") 순회
  2. 플레이어와의 거리 계산, 최소 거리 적 반환
```

---

## 5. .tscn 파일 포맷 명세

### 5.1 Godot 4 tscn 텍스트 포맷 규칙

```
[gd_scene load_steps=N format=3 uid="uid://xxx"]    # 씬 헤더
[ext_resource type="Script" path="res://..." id="1"] # 외부 리소스 (스크립트)
[sub_resource type="RectangleShape2D" id="2"]        # 내부 리소스 (Shape)
size = Vector2(16, 16)
[node name="Root" type="CharacterBody2D"]            # 루트 노드
script = ExtResource("1")
[node name="Child" type="ColorRect" parent="."]      # 자식 노드
```

### 5.2 uid 생성 규칙

- 형식: `uid://` + 영문소문자/숫자 12자리 랜덤
- 예: `uid://abc123def456`
- 각 씬마다 고유한 uid 필요

---

## 6. 시그널 연결 명세

| 소스 노드 | 시그널 | 대상 노드 | 대상 함수 |
|-----------|--------|-----------|-----------|
| EnemySpawnTimer | timeout | Main | `_on_enemy_spawn_timer_timeout` |
| Player/AttackTimer | timeout | Main | `_on_attack_timer_timeout` |
| Projectile (Area2D) | body_entered | Projectile | `_on_body_entered` |

**시그널 연결 방식:**
- EnemySpawnTimer, AttackTimer: `.tscn` 파일 내 `[connection]` 섹션 또는 `_ready()`에서 코드 연결
- Projectile body_entered: `_ready()`에서 `body_entered.connect(_on_body_entered)` 코드 연결

---

## 7. 그룹 설계

| 그룹명 | 소속 노드 | 용도 |
|--------|-----------|------|
| `enemies` | 모든 Enemy 인스턴스 | 가장 가까운 적 탐색 시 순회 |
| `player` | Player | 적이 플레이어 참조 시 사용 |

**그룹 등록 방식:**
- Enemy: `.tscn`의 루트 노드에 `groups = ["enemies"]` 또는 `_ready()`에서 `add_to_group("enemies")`
- Player: `.tscn`의 루트 노드에 `groups = ["player"]`

---

## 8. Implementation Guide

### 8.1 File Structure

```
chef-nightmare/
├── project.godot
├── scenes/
│   ├── main.tscn
│   ├── player.tscn
│   ├── enemy.tscn
│   └── projectile.tscn
├── scripts/
│   ├── main.gd
│   ├── player.gd
│   ├── enemy.gd
│   └── projectile.gd
└── docs/
    ├── 01-plan/
    └── 02-design/
```

### 8.2 Implementation Order

1. [ ] **Step 1**: `project.godot` 생성 (설정, 입력 맵, 레이어 이름)
2. [ ] **Step 2**: `player.tscn` + `player.gd` (이동, 화면 제한, HP/XP)
3. [ ] **Step 3**: `enemy.tscn` + `enemy.gd` (추적, 충돌 데미지)
4. [ ] **Step 4**: `projectile.tscn` + `projectile.gd` (방향 이동, 적 제거)
5. [ ] **Step 5**: `main.tscn` + `main.gd` (씬 조합, 스포너, 발사 로직)

### 8.3 FR-Implementation 매핑

| FR | 구현 파일 | Step |
|----|-----------|------|
| FR-01 | player.gd `_physics_process`, `_get_input_direction` | Step 2 |
| FR-02 | player.gd `_physics_process` (clamp) | Step 2 |
| FR-03 | main.gd `_on_enemy_spawn_timer_timeout`, `_spawn_enemy` | Step 5 |
| FR-04 | enemy.gd `_physics_process` | Step 3 |
| FR-05 | enemy.gd 충돌 처리, player.gd `take_damage` | Step 3 |
| FR-06 | main.gd `_on_attack_timer_timeout`, `_get_closest_enemy` | Step 5 |
| FR-07 | projectile.gd `_on_body_entered` | Step 4 |
| FR-08 | player.gd 변수 선언 | Step 2 |

---

## 9. Coding Conventions

### 9.1 Naming Conventions (Godot)

| Target | Rule | Example |
|--------|------|---------|
| 씬 파일 | snake_case.tscn | `player.tscn`, `main.tscn` |
| 스크립트 파일 | snake_case.gd | `player.gd`, `enemy.gd` |
| 노드 이름 | PascalCase | `Player`, `EnemySpawnTimer` |
| 변수 | snake_case | `max_hp`, `spawn_radius` |
| 함수 | snake_case (prefix _) | `_physics_process`, `_on_timeout` |
| 상수 | UPPER_SNAKE_CASE | `MAX_ENEMIES` |
| 시그널 핸들러 | `_on_{NodeName}_{signal}` | `_on_enemy_spawn_timer_timeout` |
| 그룹 이름 | snake_case 복수형 | `enemies`, `projectiles` |

### 9.2 코드 주석 규칙

- 모든 함수에 한국어 주석으로 역할 설명
- 핵심 로직에 인라인 주석 포함
- 클래스 상단에 스크립트 역할 요약 주석

---

## Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 0.1 | 2026-03-24 | Initial draft | AI + User |
