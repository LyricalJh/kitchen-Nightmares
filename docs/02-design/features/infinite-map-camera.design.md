# Infinite Map & Camera Design Document

> **Summary**: 무한 맵 이동 설계 — Camera2D 추적, clamp 제거, 동적 바닥 타일링, 원거리 정리
>
> **Project**: chef-nightmare
> **Version**: 0.4.0
> **Author**: AI + User
> **Date**: 2026-03-24
> **Status**: Draft
> **Planning Doc**: [infinite-map-camera.plan.md](../01-plan/features/infinite-map-camera.plan.md)

---

## 1. Overview

### 1.1 Design Goals

- Player에 Camera2D를 추가하여 자동 추적 구현
- position clamp 제거로 무한 이동 가능
- 플레이어 주변에 바닥 타일을 동적으로 생성/제거하여 무한 바닥 표현
- 원거리 적/보석 자동 제거로 메모리 안정성 확보

### 1.2 Design Principles

- **최소 변경**: 신규 파일 없이 기존 파일 수정만으로 구현
- **청크 기반 타일링**: 16x16 타일을 개별 관리 대신 논리적 청크 단위로 관리
- **거리 기반 정리**: 고정 거리 기준으로 단순하게 오브젝트 정리

---

## 2. Architecture

### 2.1 Player 씬 변경 (`scenes/player.tscn`)

Camera2D 자식 노드 추가:
```
Player (CharacterBody2D)
├── Sprite2D [기존]
├── CollisionShape2D [기존]
├── AttackTimer [기존]
└── Camera2D [신규]
    - position_smoothing_enabled = true
    - position_smoothing_speed = 5.0
    - zoom = Vector2(1, 1)
```

### 2.2 동적 바닥 타일링 시스템

**개념**: 16x16 바닥 타일(scale 1x1)을 플레이어 주변에 격자 형태로 배치. 플레이어 이동에 따라 새 타일 생성, 멀어진 타일 제거.

**타일 크기**: 16px (원본) — 격자 간격 16px
**관리 범위**: 플레이어 중심 ±50타일 (800px) — 화면(1280x720)을 충분히 커버
**정리 범위**: 플레이어 중심 ±60타일 (960px) 밖의 타일 제거

```
┌──────────────────────────────────┐
│        정리 범위 (960px)           │
│  ┌──────────────────────────┐    │
│  │    생성 범위 (800px)       │    │
│  │  ┌──────────────────┐    │    │
│  │  │  화면 (1280x720)  │    │    │
│  │  │    [Player]       │    │    │
│  │  └──────────────────┘    │    │
│  └──────────────────────────┘    │
└──────────────────────────────────┘
```

**구현 방식**: Node2D 컨테이너(`FloorTiles`)에 Sprite2D 타일을 자식으로 관리. Dictionary로 좌표 키 관리.

### 2.3 Main 씬 변경 (`scenes/main.tscn`)

```
Main (Node2D)
├── FloorTiles (Node2D) [신규 — 동적 타일 컨테이너]
├── Player [기존]
├── EnemySpawnTimer [기존]
├── HUD [기존]
├── LevelUpUI [기존]
└── GameOverUI [기존]
```

- 기존 `Floor (TextureRect)` 제거
- `FloorTiles (Node2D)` 빈 컨테이너 추가 (타일이 여기에 동적 추가)

---

## 3. 스크립트 상세 명세

### 3.1 player.gd 수정

| 변경 | 내용 | FR |
|------|------|-----|
| 제거 | `@onready var viewport_size` 변수 | FR-26 |
| 제거 | `_physics_process` 내 position clamp 3줄 | FR-26 |

**변경 전:**
```gdscript
# 화면 크기 참조
@onready var viewport_size: Vector2 = get_viewport_rect().size

# _physics_process 내:
position.x = clamp(position.x, 16.0, viewport_size.x - 16.0)
position.y = clamp(position.y, 16.0, viewport_size.y - 16.0)
```

**변경 후:** 위 코드 전체 제거. 플레이어는 무한히 이동 가능.

### 3.2 player.tscn 수정

Camera2D 노드 추가:
```
[node name="Camera2D" type="Camera2D" parent="."]
position_smoothing_enabled = true
position_smoothing_speed = 5.0
```

- Camera2D는 Player의 자식이므로 자동으로 플레이어를 따라감
- `position_smoothing`으로 부드러운 카메라 이동 (FR-25)

### 3.3 main.gd 수정

**신규 변수:**
```gdscript
# 바닥 타일 시스템 (FR-27)
var floor_texture: Texture2D = preload("res://assets/sprites/floor.png")
var floor_tiles: Dictionary = {}  # Vector2i → Sprite2D
const TILE_SIZE: int = 16
const TILE_RANGE: int = 50       # 플레이어 주변 ±50타일 생성
const TILE_CLEANUP: int = 60     # ±60타일 밖 제거

# 원거리 정리 (FR-28, FR-29)
const ENEMY_CLEANUP_DIST: float = 1200.0
const GEM_CLEANUP_DIST: float = 800.0

# 바닥 타일 컨테이너 참조
@onready var floor_container: Node2D = $FloorTiles
```

**신규 함수:**

| 함수 | 설명 | FR |
|------|------|-----|
| `_update_floor_tiles()` | 플레이어 주변 타일 생성/정리 | FR-27 |
| `_cleanup_distant_objects()` | 원거리 적/보석 제거 | FR-28, FR-29 |

**핵심 로직:**
```
_process(delta) 추가:
  _update_floor_tiles()
  _cleanup_distant_objects()

_update_floor_tiles():
  1. 플레이어 위치를 타일 좌표로 변환: player_tile = Vector2i(player.position / TILE_SIZE)
  2. player_tile 주변 ±TILE_RANGE 순회
  3. floor_tiles에 없는 좌표 → Sprite2D 생성, floor_container에 add_child
  4. floor_tiles에서 ±TILE_CLEANUP 밖인 타일 → queue_free + Dictionary에서 제거

_cleanup_distant_objects():
  1. "enemies" 그룹 순회, 플레이어와 거리 > ENEMY_CLEANUP_DIST → queue_free
  2. "xp_gems" 그룹 순회, 플레이어와 거리 > GEM_CLEANUP_DIST → queue_free
```

**최적화**: `_update_floor_tiles()`는 매 프레임 전체 범위를 순회하면 비효율적. **이전 프레임의 player_tile을 캐싱**하여 타일 좌표가 변경되었을 때만 업데이트.

```gdscript
var _last_player_tile: Vector2i = Vector2i.MAX  # 캐시

func _update_floor_tiles():
  var current_tile := Vector2i(
    int(player.global_position.x) / TILE_SIZE,
    int(player.global_position.y) / TILE_SIZE
  )
  if current_tile == _last_player_tile:
    return  # 같은 타일이면 업데이트 불필요
  _last_player_tile = current_tile

  # 생성: 범위 내 없는 타일 추가
  for x in range(current_tile.x - TILE_RANGE, current_tile.x + TILE_RANGE + 1):
    for y in range(current_tile.y - TILE_RANGE, current_tile.y + TILE_RANGE + 1):
      var key := Vector2i(x, y)
      if not floor_tiles.has(key):
        var tile := Sprite2D.new()
        tile.texture = floor_texture
        tile.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
        tile.global_position = Vector2(x * TILE_SIZE + 8, y * TILE_SIZE + 8)
        floor_container.add_child(tile)
        floor_tiles[key] = tile

  # 정리: 범위 밖 타일 제거
  var keys_to_remove: Array[Vector2i] = []
  for key in floor_tiles:
    if abs(key.x - current_tile.x) > TILE_CLEANUP or abs(key.y - current_tile.y) > TILE_CLEANUP:
      keys_to_remove.append(key)
  for key in keys_to_remove:
    floor_tiles[key].queue_free()
    floor_tiles.erase(key)
```

### 3.4 main.tscn 수정

- `Floor (TextureRect)` 노드 제거
- `FloorTiles (Node2D)` 빈 노드 추가 (Player 위에, 바닥이 캐릭터 아래로)

### 3.5 enemy.gd 수정

**_physics_process에 원거리 자동 제거 추가 (FR-28):**

```gdscript
# _physics_process 내 추가:
var player := _get_player()
if player == null:
  return

# 원거리 자동 제거 (FR-28: 1200px 이상)
if global_position.distance_to(player.global_position) > 1200.0:
  queue_free()
  return
```

### 3.6 xp_gem.gd 수정

**_process 추가로 원거리 자동 제거 (FR-29):**

```gdscript
func _process(_delta: float) -> void:
  # 원거리 자동 제거 (FR-29: 800px 이상)
  var players := get_tree().get_nodes_in_group("player")
  if players.size() > 0:
    if global_position.distance_to(players[0].global_position) > 800.0:
      queue_free()
```

---

## 4. Implementation Guide

### 4.1 Implementation Order

1. [ ] **Step 1**: `player.tscn` 수정 — Camera2D 추가
2. [ ] **Step 2**: `player.gd` 수정 — viewport_size 변수와 clamp 제거
3. [ ] **Step 3**: `main.tscn` 수정 — Floor 제거, FloorTiles 추가
4. [ ] **Step 4**: `main.gd` 수정 — 동적 타일링 + 원거리 정리 로직
5. [ ] **Step 5**: `enemy.gd` 수정 — 원거리 자동 제거
6. [ ] **Step 6**: `xp_gem.gd` 수정 — 원거리 자동 제거

### 4.2 FR-Implementation 매핑

| FR | 구현 파일 | Step |
|----|-----------|------|
| FR-25 | player.tscn (Camera2D, smoothing) | Step 1 |
| FR-26 | player.gd (clamp 제거) | Step 2 |
| FR-27 | main.gd `_update_floor_tiles`, main.tscn FloorTiles | Step 3, 4 |
| FR-28 | enemy.gd (거리 체크 queue_free) | Step 5 |
| FR-29 | xp_gem.gd (거리 체크 queue_free) | Step 6 |

---

## 5. Coding Conventions

기존 컨벤션 유지:

| Target | Rule |
|--------|------|
| 변수명 | snake_case: `floor_tiles`, `_last_player_tile` |
| 상수 | UPPER_SNAKE_CASE: `TILE_SIZE`, `TILE_RANGE`, `ENEMY_CLEANUP_DIST` |
| 한국어 주석 | 모든 함수에 FR 매핑 |

---

## Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 0.1 | 2026-03-24 | Initial draft | AI + User |
