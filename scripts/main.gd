extends Node2D
## 메인 씬 스크립트
## 적 스포너, 발사체 생성, 성장 시스템, 시간/웨이브/게임오버, 무한 맵 관리

# 씬 프리로드
var enemy_scene: PackedScene = preload("res://scenes/enemy.tscn")
var projectile_scene: PackedScene = preload("res://scenes/projectile.tscn")

# 적 종류별 텍스처
var tex_tomato: Texture2D = preload("res://assets/sprites/enemy.png")
var tex_onion: Texture2D = preload("res://assets/sprites/enemy_onion.png")
var tex_mushroom: Texture2D = preload("res://assets/sprites/enemy_mushroom.png")
var tex_pepperoni: Texture2D = preload("res://assets/sprites/enemy_pepperoni.png")
var tex_cheese: Texture2D = preload("res://assets/sprites/enemy_cheese.png")
var tex_boss: Texture2D = preload("res://assets/sprites/boss_truffle.png")

# 보스 스폰 관리
var boss_spawned_waves: Array[int] = []  # 이미 보스 나온 웨이브

# 적 스폰 반경 (플레이어 기준, 화면 밖에서 스폰)
var spawn_radius: float = 500.0

# 시간 추적 (FR-22)
var elapsed_time: float = 0.0

# 웨이브 시스템 (FR-23, FR-24)
var wave_level: int = 0
var wave_interval: float = 30.0
var next_wave_time: float = 30.0
var enemy_speed_multiplier: float = 1.0

# 게임 상태
var game_over: bool = false

# 바닥 타일 시스템 (FR-27: 동적 랜덤 타일링)
# 순수 바닥 (60%) — 깨끗한 돌바닥
var floor_plain: Array[Texture2D] = [
	preload("res://assets/sprites/floor_tiles/tile_7.png"),
	preload("res://assets/sprites/floor_tiles/tile_8.png"),
	preload("res://assets/sprites/floor_tiles/tile_12.png"),
	preload("res://assets/sprites/floor_tiles/tile_18.png"),
]
# 바닥+약간 불 (25%)
var floor_fire: Array[Texture2D] = [
	preload("res://assets/sprites/floor_tiles/tile_9.png"),
	preload("res://assets/sprites/floor_tiles/tile_13.png"),
	preload("res://assets/sprites/floor_tiles/tile_14.png"),
	preload("res://assets/sprites/floor_tiles/tile_17.png"),
	preload("res://assets/sprites/floor_tiles/tile_19.png"),
]
# 장식 바닥 (10%) — 뼈/해골 등
var floor_deco: Array[Texture2D] = [
	preload("res://assets/sprites/floor_tiles/tile_3.png"),
	preload("res://assets/sprites/floor_tiles/tile_11.png"),
	preload("res://assets/sprites/floor_tiles/tile_15.png"),
	preload("res://assets/sprites/floor_tiles/tile_16.png"),
	preload("res://assets/sprites/floor_tiles/tile_20.png"),
]
# 오브젝트 타일 (5%) — 그릴/냄비/음식
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
var floor_tiles: Dictionary = {}  # Vector2i → Sprite2D
const TILE_SIZE: int = 204        # 204px 원본 크기 그대로
const TILE_RANGE: int = 5         # 플레이어 주변 ±5타일 생성
const TILE_CLEANUP: int = 7       # ±7타일 밖 제거
var _last_player_tile: Vector2i = Vector2i(99999, 99999)

# 원거리 정리 거리 (FR-28, FR-29)
const ENEMY_CLEANUP_DIST: float = 1200.0
const GEM_CLEANUP_DIST: float = 800.0

# 플레이어 참조
@onready var player: CharacterBody2D = $Player

# HUD/UI 참조
@onready var hud: CanvasLayer = $HUD
@onready var level_up_ui: CanvasLayer = $LevelUpUI
@onready var game_over_ui: CanvasLayer = $GameOverUI

# 바닥 타일 컨테이너
@onready var floor_container: Node2D = $FloorTiles


func _ready() -> void:
	# 플레이어를 그룹에 등록 (적이 참조할 수 있도록)
	player.add_to_group("player")

	# 타이머 시그널 연결 (기존)
	$EnemySpawnTimer.timeout.connect(_on_enemy_spawn_timer_timeout)
	$Player/AttackTimer.timeout.connect(_on_attack_timer_timeout)

	# 플레이어 시그널 연결 (Phase 2: 성장 시스템)
	player.leveled_up.connect(_on_player_leveled_up)
	player.hp_changed.connect(_on_player_hp_changed)
	player.xp_changed.connect(_on_player_xp_changed)

	# 레벨업 UI 시그널 연결
	level_up_ui.skill_selected.connect(_on_skill_selected)

	# Phase 3: 게임오버 시그널 연결
	player.died.connect(_on_player_died)


## 매 프레임 처리
func _process(delta: float) -> void:
	if game_over:
		return

	# 경과 시간 추적 (FR-22)
	elapsed_time += delta
	hud.update_time(elapsed_time)

	# 웨이브 난이도 체크 (FR-23, FR-24)
	_check_wave()

	# 동적 바닥 타일 업데이트 (FR-27)
	_update_floor_tiles()

	# 원거리 오브젝트 정리 (FR-28, FR-29)
	_cleanup_distant_objects()


## 동적 바닥 타일 생성/제거 (FR-27: 무한 바닥)
func _update_floor_tiles() -> void:
	# 플레이어 위치를 타일 좌표로 변환
	var current_tile := Vector2i(
		floori(player.global_position.x / TILE_SIZE),
		floori(player.global_position.y / TILE_SIZE)
	)

	# 같은 타일이면 업데이트 불필요 (최적화)
	if current_tile == _last_player_tile:
		return
	_last_player_tile = current_tile

	# 범위 내 없는 타일 생성
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

	# 범위 밖 타일 제거
	var keys_to_remove: Array[Vector2i] = []
	for key in floor_tiles:
		if abs(key.x - current_tile.x) > TILE_CLEANUP or abs(key.y - current_tile.y) > TILE_CLEANUP:
			keys_to_remove.append(key)
	for key in keys_to_remove:
		floor_tiles[key].queue_free()
		floor_tiles.erase(key)


## 가중치 기반 랜덤 바닥 텍스처 선택 (바닥 60%, 불 25%, 장식 10%, 오브젝트 5%)
func _pick_random_floor_texture() -> Texture2D:
	var roll := randf() * 100.0
	if roll < 60.0:
		return floor_plain.pick_random()
	elif roll < 85.0:
		return floor_fire.pick_random()
	elif roll < 95.0:
		return floor_deco.pick_random()
	else:
		return floor_object.pick_random()


## 원거리 적/보석 자동 제거 (FR-28, FR-29)
func _cleanup_distant_objects() -> void:
	# 적 정리 (FR-28: 1200px 이상)
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if player.global_position.distance_to(enemy.global_position) > ENEMY_CLEANUP_DIST:
			enemy.queue_free()

	# 보석 정리 (FR-29: 800px 이상)
	for gem in get_tree().get_nodes_in_group("xp_gems"):
		if player.global_position.distance_to(gem.global_position) > GEM_CLEANUP_DIST:
			gem.queue_free()


## 웨이브 난이도 증가 (FR-23, FR-24: 30초마다)
func _check_wave() -> void:
	if elapsed_time >= next_wave_time:
		wave_level += 1
		next_wave_time += wave_interval

		# 스폰 빈도 증가 (FR-23: 간격 10% 감소, 최소 0.3초)
		$EnemySpawnTimer.wait_time = max($EnemySpawnTimer.wait_time * 0.9, 0.3)

		# 적 속도 증가 (FR-24: 10% 증가)
		enemy_speed_multiplier *= 1.1


## 적 스폰 처리 (FR-03)
func _on_enemy_spawn_timer_timeout() -> void:
	if game_over:
		return
	_spawn_enemy()


## 적 인스턴스 생성 — 5종류 + 보스 랜덤 스폰
func _spawn_enemy() -> void:
	var enemy := enemy_scene.instantiate()

	# 랜덤 각도로 플레이어 주변에 스폰
	var angle := randf() * TAU
	var spawn_pos := player.global_position + Vector2(cos(angle), sin(angle)) * spawn_radius
	enemy.global_position = spawn_pos

	var sprite := enemy.get_node("Sprite2D") as Sprite2D

	# 웨이브 3 이상부터 보스 스폰 (웨이브당 1회)
	if wave_level >= 3 and wave_level not in boss_spawned_waves and randf() < 0.1:
		boss_spawned_waves.append(wave_level)
		sprite.texture = tex_boss
		sprite.scale = Vector2(0.12, 0.12)
		enemy.speed = 40.0
		enemy.damage = 30
		enemy.get_node("CollisionShape2D").scale = Vector2(2.0, 2.0)
	else:
		# 적 종류 랜덤 결정
		var roll := randf() * 100.0
		if roll < 30.0:
			# 토마토 (기본, 30%)
			sprite.texture = tex_tomato
		elif roll < 55.0:
			# 양파 — 빠르고 체력 낮음 (25%)
			sprite.texture = tex_onion
			enemy.speed = 140.0
		elif roll < 75.0:
			# 양송이 버섯 — 보통, 맷집 (20%)
			sprite.texture = tex_mushroom
			sprite.scale *= 1.2
			enemy.speed = 60.0
		elif roll < 90.0:
			# 페퍼로니 — 돌진형, 공격력 높음 (15%)
			sprite.texture = tex_pepperoni
			sprite.scale *= 1.3
			enemy.speed = 120.0
			enemy.damage = 20
		else:
			# 모차렐라 치즈 슬라임 — 느리고 큼 (10%)
			sprite.texture = tex_cheese
			sprite.scale *= 1.4
			enemy.speed = 45.0
			enemy.damage = 15
			enemy.get_node("CollisionShape2D").scale *= 1.2

	# 웨이브 배수 적용 (FR-24: 적 속도 증가)
	enemy.speed *= enemy_speed_multiplier

	add_child(enemy)


## 근접 공격 — 범위 내 모든 적 타격 + 핫소스 물총 이펙트
const MELEE_RANGE: float = 150.0  # 근접 공격 범위
var hot_sauce_texture: Texture2D = preload("res://assets/sprites/hot_sauce.png")

func _on_attack_timer_timeout() -> void:
	if game_over:
		return

	# 근접 범위 내 모든 적 탐색
	var enemies_in_range: Array[Node2D] = []
	for enemy in get_tree().get_nodes_in_group("enemies"):
		var dist := player.global_position.distance_to(enemy.global_position)
		if dist <= MELEE_RANGE:
			enemies_in_range.append(enemy)

	if enemies_in_range.is_empty():
		return

	# 가장 가까운 적 방향으로 핫소스 발사 이펙트
	_show_hot_sauce_attack(enemies_in_range[0].global_position)

	# 범위 내 모든 적 처치
	for enemy in enemies_in_range:
		if is_instance_valid(enemy):
			if enemy.has_method("die"):
				enemy.die()
			else:
				enemy.queue_free()


## 핫소스 물총 발사 이펙트 — 적 방향으로 뿜어지고 사라짐
var _bg_shader: Shader = preload("res://assets/shaders/remove_white_bg.gdshader")

func _show_hot_sauce_attack(target_pos: Vector2) -> void:
	var sauce := Sprite2D.new()
	sauce.texture = hot_sauce_texture
	sauce.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sauce.scale = Vector2(0.06, 0.06)
	sauce.global_position = player.global_position
	sauce.z_index = 5
	var mat := ShaderMaterial.new()
	mat.shader = _bg_shader
	sauce.material = mat

	# 적 방향으로 회전
	var dir := (target_pos - player.global_position).angle()
	sauce.rotation = dir

	add_child(sauce)

	# 플레이어 → 적 방향으로 뿜어지는 애니메이션
	var tween := create_tween()
	var end_pos := player.global_position + Vector2(cos(dir), sin(dir)) * 100.0
	tween.tween_property(sauce, "global_position", end_pos, 0.15)
	tween.parallel().tween_property(sauce, "modulate:a", 0.0, 0.2)
	tween.tween_callback(sauce.queue_free)


## 가장 가까운 적 탐색
func _get_closest_enemy() -> Node2D:
	var enemies := get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return null

	var closest: Node2D = null
	var closest_dist: float = INF

	for enemy in enemies:
		var dist: float = player.global_position.distance_to(enemy.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest = enemy

	return closest


## 게임오버 처리 (FR-18: HP 0 시)
func _on_player_died() -> void:
	game_over = true
	get_tree().paused = true

	# 최고 기록 비교/저장 (FR-21)
	var best := _load_best_time()
	if elapsed_time > best:
		best = elapsed_time
		_save_best_time(best)

	# 게임오버 UI 표시 (FR-19)
	game_over_ui.show_results(elapsed_time, best)


## 레벨업 처리 (FR-12)
func _on_player_leveled_up(new_level: int) -> void:
	get_tree().paused = true
	hud.update_level(new_level)
	level_up_ui.show_ui()


## 스킬 선택 처리 (FR-13, FR-14)
func _on_skill_selected(skill_type: String) -> void:
	player.apply_skill(skill_type)
	get_tree().paused = false


## HP 변경 시 HUD 업데이트 (FR-15)
func _on_player_hp_changed(current: int, max_val: int) -> void:
	hud.update_hp(current, max_val)


## XP 변경 시 HUD 업데이트 (FR-16)
func _on_player_xp_changed(current: int, required: int) -> void:
	hud.update_xp(current, required)


## 최고 기록 불러오기 (FR-21)
func _load_best_time() -> float:
	var config := ConfigFile.new()
	var err := config.load("user://save_data.cfg")
	if err != OK:
		return 0.0
	return config.get_value("records", "best_time", 0.0)


## 최고 기록 저장 (FR-21)
func _save_best_time(time: float) -> void:
	var config := ConfigFile.new()
	config.load("user://save_data.cfg")
	config.set_value("records", "best_time", time)
	config.save("user://save_data.cfg")
