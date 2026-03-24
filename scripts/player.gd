extends CharacterBody2D
## 플레이어 스크립트
## WASD 8방향 이동, HP/XP/레벨업, 회전 칼날, 갈릭 폭탄

# ── 이동 ──────────────────────────────────────────────
@export var speed: float = 200.0

# ── 체력 ──────────────────────────────────────────────
var hp: int = 100
var max_hp: int = 100
var damage_cooldown: float = 0.0
const DAMAGE_COOLDOWN_TIME: float = 0.5

# ── 경험치/레벨 ───────────────────────────────────────
var xp: int = 0
var level: int = 1
var xp_to_next_level: int = 20

# ── 시그널 ────────────────────────────────────────────
signal leveled_up(new_level: int)
signal hp_changed(current: int, maximum: int)
signal xp_changed(current: int, required: int)
signal died

# ── 회전 칼날 ─────────────────────────────────────────
var orbital_knives: Array[Node2D] = []
var knife_orbit_angle: float = 0.0
const KNIFE_ORBIT_RADIUS: float = 80.0
const KNIFE_ORBIT_SPEED: float = 3.0
var knife_texture: Texture2D = preload("res://assets/sprites/projectile.png")

# ── 갈릭 폭탄 ─────────────────────────────────────────
var garlic_bomb_active: bool = false
var garlic_bomb_timer: float = 0.0
var garlic_bomb_count: int = 0
const GARLIC_BOMB_COOLDOWN: float = 3.0
const GARLIC_BOMB_RADIUS: float = 120.0
var garlic_texture: Texture2D = preload("res://assets/sprites/갈릭 디핑 소스 폭탄 (투척 무기  던지면 터짐).png")

# ── 셰이더 ────────────────────────────────────────────
var _bg_shader: Shader = preload("res://assets/shaders/remove_white_bg.gdshader")


# ══════════════════════════════════════════════════════
#  초기화 + 메인 루프
# ══════════════════════════════════════════════════════

func _ready() -> void:
	$Sprite2D.material = _make_bg_material()
	hp_changed.emit(hp, max_hp)
	xp_changed.emit(xp, xp_to_next_level)


func _physics_process(delta: float) -> void:
	# 이동
	velocity = _get_input_direction() * speed
	move_and_slide()

	# 무기 업데이트
	_update_orbital_knives(delta)
	_update_garlic_bomb(delta)

	# 데미지 쿨다운
	if damage_cooldown > 0.0:
		damage_cooldown -= delta


# ══════════════════════════════════════════════════════
#  입력 + 전투
# ══════════════════════════════════════════════════════

func _get_input_direction() -> Vector2:
	var input_dir := Vector2.ZERO
	input_dir.x = Input.get_axis("move_left", "move_right")
	input_dir.y = Input.get_axis("move_up", "move_down")
	return input_dir.normalized()


func take_damage(amount: int) -> void:
	if damage_cooldown > 0.0:
		return
	hp = max(hp - amount, 0)
	damage_cooldown = DAMAGE_COOLDOWN_TIME
	hp_changed.emit(hp, max_hp)
	if hp <= 0:
		died.emit()


func add_xp(amount: int) -> void:
	xp += amount
	xp_changed.emit(xp, xp_to_next_level)
	while xp >= xp_to_next_level:
		xp -= xp_to_next_level
		level += 1
		xp_to_next_level = level * 20
		xp_changed.emit(xp, xp_to_next_level)
		leveled_up.emit(level)


# ══════════════════════════════════════════════════════
#  스킬 시스템
# ══════════════════════════════════════════════════════

func apply_skill(skill_type: String) -> void:
	match skill_type:
		"orbital_knife":
			_add_orbital_knife()
		"garlic_bomb":
			garlic_bomb_count += 1
			garlic_bomb_active = true
		"fire_rate":
			var timer := get_node_or_null("AttackTimer") as Timer
			if timer:
				timer.wait_time = max(timer.wait_time * 0.8, 0.1)
		"move_speed":
			speed += 30


# ══════════════════════════════════════════════════════
#  회전 칼날
# ══════════════════════════════════════════════════════

func _add_orbital_knife() -> void:
	var knife := Area2D.new()

	var sprite := Sprite2D.new()
	sprite.texture = knife_texture
	sprite.scale = Vector2(0.04, 0.04)
	sprite.material = _make_bg_material()
	knife.add_child(sprite)

	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(20, 20)
	collision.shape = shape
	knife.add_child(collision)

	knife.collision_layer = 4
	knife.collision_mask = 2
	knife.body_entered.connect(_on_knife_hit_enemy)

	orbital_knives.append(knife)
	add_child(knife)

	# 균등 간격 재배치
	var count := orbital_knives.size()
	for i in count:
		orbital_knives[i].set_meta("angle_offset", (TAU / count) * i)


func _update_orbital_knives(delta: float) -> void:
	# 해제된 칼날 정리
	orbital_knives = orbital_knives.filter(func(k): return is_instance_valid(k))
	if orbital_knives.is_empty():
		return

	knife_orbit_angle += KNIFE_ORBIT_SPEED * delta
	for knife in orbital_knives:
		var angle: float = knife_orbit_angle + float(knife.get_meta("angle_offset", 0.0))
		knife.position = Vector2(cos(angle), sin(angle)) * KNIFE_ORBIT_RADIUS
		knife.rotation = angle + PI / 2


func _on_knife_hit_enemy(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		_kill_enemy(body)


# ══════════════════════════════════════════════════════
#  갈릭 폭탄
# ══════════════════════════════════════════════════════

func _update_garlic_bomb(delta: float) -> void:
	if not garlic_bomb_active:
		return
	garlic_bomb_timer += delta
	if garlic_bomb_timer < GARLIC_BOMB_COOLDOWN:
		return
	garlic_bomb_timer = 0.0

	var enemies := get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return

	# 가까운 적 순서로 정렬
	var sorted := enemies.duplicate()
	sorted.sort_custom(func(a, b):
		return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position)
	)

	for i in mini(garlic_bomb_count, sorted.size()):
		_launch_garlic_bomb(sorted[i].global_position)


func _launch_garlic_bomb(target_pos: Vector2) -> void:
	var bomb := Sprite2D.new()
	bomb.texture = garlic_texture
	bomb.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	bomb.scale = Vector2(0.08, 0.08)
	bomb.z_index = 10
	bomb.material = _make_bg_material()
	bomb.global_position = Vector2(target_pos.x, target_pos.y - 400.0)

	var scene := get_tree().current_scene
	if scene:
		scene.add_child(bomb)
	else:
		return

	# 낙하 → 바운스1 → 바운스2 → 폭발
	var tween := get_tree().create_tween()
	tween.tween_property(bomb, "global_position:y", target_pos.y, 0.4) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(bomb, "global_position:y", target_pos.y - 60.0, 0.15) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(bomb, "global_position:y", target_pos.y, 0.15) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(bomb, "global_position:y", target_pos.y - 25.0, 0.1) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(bomb, "global_position:y", target_pos.y, 0.1) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(func():
		if is_instance_valid(bomb):
			_garlic_explode(bomb.global_position)
			bomb.queue_free()
	)


func _garlic_explode(pos: Vector2) -> void:
	# 폭발 이펙트
	var effect := Sprite2D.new()
	effect.texture = garlic_texture
	effect.global_position = pos
	effect.scale = Vector2(0.01, 0.01)
	effect.modulate = Color(1.0, 0.9, 0.3, 0.7)

	var scene := get_tree().current_scene
	if scene:
		scene.add_child(effect)
		var fx_tween := get_tree().create_tween()
		fx_tween.tween_property(effect, "scale", Vector2(0.25, 0.25), 0.2)
		fx_tween.parallel().tween_property(effect, "modulate:a", 0.0, 0.3)
		fx_tween.tween_callback(effect.queue_free)

	# 범위 내 적 처치
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if pos.distance_to(enemy.global_position) <= GARLIC_BOMB_RADIUS:
			_kill_enemy(enemy)


# ══════════════════════════════════════════════════════
#  유틸리티
# ══════════════════════════════════════════════════════

## 적 처치 공용 함수
func _kill_enemy(enemy: Node2D) -> void:
	if enemy.has_method("die"):
		enemy.die()
	else:
		enemy.queue_free()


## 흰 배경 제거 셰이더 머티리얼 생성
func _make_bg_material() -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = _bg_shader
	return mat
