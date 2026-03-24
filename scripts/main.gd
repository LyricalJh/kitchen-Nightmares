extends Node2D
## 메인 씬 스크립트
## 적 스포너, 근접 공격, 성장 시스템, 시간/웨이브/게임오버, 무한 맵 관리

# ── 씬/텍스처 프리로드 ──────────────────────────────
var enemy_scene: PackedScene = preload("res://scenes/enemy.tscn")
var hot_sauce_texture: Texture2D = preload("res://assets/sprites/hot_sauce.png")
var _bg_shader: Shader = preload("res://assets/shaders/remove_white_bg.gdshader")

# 적 종류별 텍스처 + 스탯 테이블
const ENEMY_TYPES := [
	{ "texture": "res://assets/sprites/enemy.png",          "speed": 80.0,  "damage": 10, "scale": 1.0,  "weight": 30 },  # 토마토
	{ "texture": "res://assets/sprites/enemy_onion.png",    "speed": 140.0, "damage": 10, "scale": 0.9,  "weight": 25 },  # 양파 (빠름)
	{ "texture": "res://assets/sprites/enemy_mushroom.png", "speed": 60.0,  "damage": 10, "scale": 1.2,  "weight": 20 },  # 버섯 (맷집)
	{ "texture": "res://assets/sprites/enemy_pepperoni.png","speed": 120.0, "damage": 20, "scale": 1.3,  "weight": 15 },  # 페퍼로니 (돌진)
	{ "texture": "res://assets/sprites/enemy_cheese.png",   "speed": 45.0,  "damage": 15, "scale": 1.4,  "weight": 10 },  # 치즈 (느림+큼)
]
var _enemy_textures: Array[Texture2D] = []  # _ready에서 로드
var boss_texture: Texture2D = preload("res://assets/sprites/boss_truffle.png")
var boss_spawned_waves: Array[int] = []

# ── 게임 설정 ────────────────────────────────────────
var spawn_radius: float = 500.0
var elapsed_time: float = 0.0
var game_over: bool = false

# 웨이브 시스템
var wave_level: int = 0
const WAVE_INTERVAL: float = 30.0
var next_wave_time: float = 30.0
var enemy_speed_multiplier: float = 1.0

# 근접 공격
const MELEE_RANGE: float = 150.0

# 원거리 정리
const ENEMY_CLEANUP_DIST: float = 1200.0
const GEM_CLEANUP_DIST: float = 800.0

# ── 바닥 타일 시스템 ─────────────────────────────────
var floor_plain: Array[Texture2D] = [
	preload("res://assets/sprites/floor_tiles/tile_7.png"),
	preload("res://assets/sprites/floor_tiles/tile_8.png"),
	preload("res://assets/sprites/floor_tiles/tile_12.png"),
	preload("res://assets/sprites/floor_tiles/tile_18.png"),
]
var floor_fire: Array[Texture2D] = [
	preload("res://assets/sprites/floor_tiles/tile_9.png"),
	preload("res://assets/sprites/floor_tiles/tile_13.png"),
	preload("res://assets/sprites/floor_tiles/tile_14.png"),
	preload("res://assets/sprites/floor_tiles/tile_17.png"),
	preload("res://assets/sprites/floor_tiles/tile_19.png"),
]
var floor_deco: Array[Texture2D] = [
	preload("res://assets/sprites/floor_tiles/tile_3.png"),
	preload("res://assets/sprites/floor_tiles/tile_11.png"),
	preload("res://assets/sprites/floor_tiles/tile_15.png"),
	preload("res://assets/sprites/floor_tiles/tile_16.png"),
	preload("res://assets/sprites/floor_tiles/tile_20.png"),
]
var floor_object: Array[Texture2D] = [
	preload("res://assets/sprites/floor_tiles/tile_1.png"),
	preload("res://assets/sprites/floor_tiles/tile_2.png"),
	preload("res://assets/sprites/floor_tiles/tile_4.png"),
	preload("res://assets/sprites/floor_tiles/tile_5.png"),
	preload("res://assets/sprites/floor_tiles/tile_6.png"),
	preload("res://assets/sprites/floor_tiles/tile_10.png"),
	preload("res://assets/sprites/floor_tiles/tile_21.png"),
	preload("res://assets/sprites/floor_tiles/tile_22.png"),
	preload("res://assets/sprites/floor_tiles/tile_23.png"),
	preload("res://assets/sprites/floor_tiles/tile_24.png"),
	preload("res://assets/sprites/floor_tiles/tile_25.png"),
]
const FLOOR_WEIGHT_PLAIN := 60.0
const FLOOR_WEIGHT_FIRE := 85.0
const FLOOR_WEIGHT_DECO := 95.0

var floor_tiles: Dictionary = {}
const TILE_SIZE: int = 204
const TILE_RANGE: int = 5
const TILE_CLEANUP: int = 7
var _last_player_tile: Vector2i = Vector2i(99999, 99999)

# ── 노드 참조 ────────────────────────────────────────
@onready var player: CharacterBody2D = $Player
@onready var hud: CanvasLayer = $HUD
@onready var level_up_ui: CanvasLayer = $LevelUpUI
@onready var game_over_ui: CanvasLayer = $GameOverUI
@onready var floor_container: Node2D = $FloorTiles


# ══════════════════════════════════════════════════════
#  초기화
# ══════════════════════════════════════════════════════

func _ready() -> void:
	# 적 텍스처 프리로드
	for etype in ENEMY_TYPES:
		_enemy_textures.append(load(etype["texture"]))

	player.add_to_group("player")

	# 시그널 연결
	$EnemySpawnTimer.timeout.connect(_on_enemy_spawn_timer_timeout)
	$Player/AttackTimer.timeout.connect(_on_attack_timer_timeout)
	player.leveled_up.connect(_on_player_leveled_up)
	player.hp_changed.connect(_on_player_hp_changed)
	player.xp_changed.connect(_on_player_xp_changed)
	player.died.connect(_on_player_died)
	level_up_ui.skill_selected.connect(_on_skill_selected)


# ══════════════════════════════════════════════════════
#  메인 루프
# ══════════════════════════════════════════════════════

func _process(delta: float) -> void:
	if game_over:
		return
	elapsed_time += delta
	hud.update_time(elapsed_time)
	_check_wave()
	_update_floor_tiles()
	_cleanup_distant_objects()


# ══════════════════════════════════════════════════════
#  적 스폰 시스템
# ══════════════════════════════════════════════════════

func _on_enemy_spawn_timer_timeout() -> void:
	if game_over:
		return
	_spawn_enemy()


## 적 인스턴스 생성 — 데이터 테이블 기반 가중치 랜덤
func _spawn_enemy() -> void:
	var enemy := enemy_scene.instantiate()
	var angle := randf() * TAU
	enemy.global_position = player.global_position + Vector2(cos(angle), sin(angle)) * spawn_radius

	var sprite := enemy.get_node("Sprite2D") as Sprite2D

	# 보스 스폰 (웨이브 3+, 웨이브당 1회, 10% 확률)
	if wave_level >= 3 and wave_level not in boss_spawned_waves and randf() < 0.1:
		boss_spawned_waves.append(wave_level)
		sprite.texture = boss_texture
		sprite.scale = Vector2(0.12, 0.12)
		enemy.speed = 40.0
		enemy.damage = 30
		enemy.get_node("CollisionShape2D").scale = Vector2(2.0, 2.0)
	else:
		# 가중치 랜덤으로 적 종류 선택
		var idx := _weighted_random_index()
		var etype: Dictionary = ENEMY_TYPES[idx]
		sprite.texture = _enemy_textures[idx]
		sprite.scale *= etype["scale"]
		enemy.speed = etype["speed"]
		enemy.damage = etype["damage"]

	enemy.speed *= enemy_speed_multiplier
	add_child(enemy)


## 가중치 기반 랜덤 인덱스 선택
func _weighted_random_index() -> int:
	var total_weight := 0
	for etype in ENEMY_TYPES:
		total_weight += etype["weight"]
	var roll := randf() * total_weight
	var cumulative := 0
	for i in ENEMY_TYPES.size():
		cumulative += ENEMY_TYPES[i]["weight"]
		if roll < cumulative:
			return i
	return ENEMY_TYPES.size() - 1


# ══════════════════════════════════════════════════════
#  근접 공격 시스템
# ══════════════════════════════════════════════════════

func _on_attack_timer_timeout() -> void:
	if game_over:
		return

	var enemies_in_range: Array[Node2D] = []
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if player.global_position.distance_to(enemy.global_position) <= MELEE_RANGE:
			enemies_in_range.append(enemy)

	if enemies_in_range.is_empty():
		return

	_show_hot_sauce_attack(enemies_in_range[0].global_position)

	for enemy in enemies_in_range:
		if is_instance_valid(enemy):
			_kill_enemy(enemy)


## 핫소스 물총 발사 이펙트
func _show_hot_sauce_attack(target_pos: Vector2) -> void:
	var sauce := Sprite2D.new()
	sauce.texture = hot_sauce_texture
	sauce.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sauce.scale = Vector2(0.06, 0.06)
	sauce.global_position = player.global_position
	sauce.z_index = 5
	sauce.material = _make_bg_remove_material()

	var dir := (target_pos - player.global_position).angle()
	sauce.rotation = dir
	add_child(sauce)

	var tween := create_tween()
	var end_pos := player.global_position + Vector2(cos(dir), sin(dir)) * 100.0
	tween.tween_property(sauce, "global_position", end_pos, 0.15)
	tween.parallel().tween_property(sauce, "modulate:a", 0.0, 0.2)
	tween.tween_callback(sauce.queue_free)


# ══════════════════════════════════════════════════════
#  웨이브 + 정리
# ══════════════════════════════════════════════════════

func _check_wave() -> void:
	if elapsed_time >= next_wave_time:
		wave_level += 1
		next_wave_time += WAVE_INTERVAL
		$EnemySpawnTimer.wait_time = max($EnemySpawnTimer.wait_time * 0.9, 0.3)
		enemy_speed_multiplier *= 1.1


func _cleanup_distant_objects() -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if player.global_position.distance_to(enemy.global_position) > ENEMY_CLEANUP_DIST:
			enemy.queue_free()
	for gem in get_tree().get_nodes_in_group("xp_gems"):
		if player.global_position.distance_to(gem.global_position) > GEM_CLEANUP_DIST:
			gem.queue_free()


# ══════════════════════════════════════════════════════
#  바닥 타일 시스템
# ══════════════════════════════════════════════════════

func _update_floor_tiles() -> void:
	var current_tile := Vector2i(
		floori(player.global_position.x / TILE_SIZE),
		floori(player.global_position.y / TILE_SIZE)
	)
	if current_tile == _last_player_tile:
		return
	_last_player_tile = current_tile

	for x in range(current_tile.x - TILE_RANGE, current_tile.x + TILE_RANGE + 1):
		for y in range(current_tile.y - TILE_RANGE, current_tile.y + TILE_RANGE + 1):
			var key := Vector2i(x, y)
			if not floor_tiles.has(key):
				var tile := Sprite2D.new()
				tile.texture = _pick_random_floor_texture()
				tile.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
				tile.global_position = Vector2(x * TILE_SIZE + TILE_SIZE / 2, y * TILE_SIZE + TILE_SIZE / 2)
				floor_container.add_child(tile)
				floor_tiles[key] = tile

	var keys_to_remove: Array[Vector2i] = []
	for key in floor_tiles:
		if abs(key.x - current_tile.x) > TILE_CLEANUP or abs(key.y - current_tile.y) > TILE_CLEANUP:
			keys_to_remove.append(key)
	for key in keys_to_remove:
		floor_tiles[key].queue_free()
		floor_tiles.erase(key)


func _pick_random_floor_texture() -> Texture2D:
	var roll := randf() * 100.0
	if roll < FLOOR_WEIGHT_PLAIN:
		return floor_plain.pick_random()
	elif roll < FLOOR_WEIGHT_FIRE:
		return floor_fire.pick_random()
	elif roll < FLOOR_WEIGHT_DECO:
		return floor_deco.pick_random()
	else:
		return floor_object.pick_random()


# ══════════════════════════════════════════════════════
#  이벤트 핸들러
# ══════════════════════════════════════════════════════

func _on_player_died() -> void:
	game_over = true
	get_tree().paused = true
	var best := _load_best_time()
	if elapsed_time > best:
		best = elapsed_time
		_save_best_time(best)
	game_over_ui.show_results(elapsed_time, best)


func _on_player_leveled_up(new_level: int) -> void:
	get_tree().paused = true
	hud.update_level(new_level)
	level_up_ui.show_ui()


func _on_skill_selected(skill_type: String) -> void:
	player.apply_skill(skill_type)
	get_tree().paused = false


func _on_player_hp_changed(current: int, max_val: int) -> void:
	hud.update_hp(current, max_val)


func _on_player_xp_changed(current: int, required: int) -> void:
	hud.update_xp(current, required)


# ══════════════════════════════════════════════════════
#  유틸리티
# ══════════════════════════════════════════════════════

## 적 처치 공용 함수 — 중복 패턴 제거
static func _kill_enemy(enemy: Node2D) -> void:
	if enemy.has_method("die"):
		enemy.die()
	else:
		enemy.queue_free()


## 흰 배경 제거 셰이더 머티리얼 생성
func _make_bg_remove_material() -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = _bg_shader
	return mat


func _load_best_time() -> float:
	var config := ConfigFile.new()
	if config.load("user://save_data.cfg") != OK:
		return 0.0
	return config.get_value("records", "best_time", 0.0)


func _save_best_time(time: float) -> void:
	var config := ConfigFile.new()
	config.load("user://save_data.cfg")  # 없으면 빈 config 사용
	config.set_value("records", "best_time", time)
	config.save("user://save_data.cfg")
