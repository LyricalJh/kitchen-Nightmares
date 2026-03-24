extends CharacterBody2D
## 플레이어 스크립트
## WASD 8방향 이동, 무한 맵 자유 이동, HP/XP/레벨업 관리

# 이동 속도 (픽셀/초)
@export var speed: float = 200.0

# 체력 시스템 (FR-05: 데미지 처리)
var hp: int = 100
var max_hp: int = 100

# 경험치/레벨 시스템 (FR-10, FR-11)
var xp: int = 0
var level: int = 1
var xp_to_next_level: int = 20
var attack_damage: int = 1  # Phase 2 확장용 공격력

# 데미지 쿨다운 (중복 데미지 방지)
var damage_cooldown: float = 0.0
const DAMAGE_COOLDOWN_TIME: float = 0.5

# 시그널 (Phase 2: HUD/LevelUpUI, Phase 3: 게임오버 연동)
signal leveled_up(new_level: int)
signal hp_changed(current: int, maximum: int)
signal xp_changed(current: int, required: int)
signal died  # FR-18: HP 0 도달 시 게임오버 트리거


func _ready() -> void:
	# 초기 HP/XP 시그널 발생 (HUD 초기화용)
	hp_changed.emit(hp, max_hp)
	xp_changed.emit(xp, xp_to_next_level)


func _physics_process(delta: float) -> void:
	# 입력 방향 계산 (FR-01: WASD 8방향 이동)
	var direction := _get_input_direction()

	# 속도 설정 (정규화로 대각선 이동 속도 보정)
	velocity = direction * speed

	# 이동 실행
	move_and_slide()

	# FR-26: 무한 맵 — 화면 제한 없이 자유 이동

	# 회전 칼날 업데이트
	update_orbital_knives(delta)

	# 데미지 쿨다운 감소
	if damage_cooldown > 0.0:
		damage_cooldown -= delta


## 입력 방향 벡터 계산 (정규화된 Vector2 반환)
func _get_input_direction() -> Vector2:
	var input_dir := Vector2.ZERO
	input_dir.x = Input.get_axis("move_left", "move_right")
	input_dir.y = Input.get_axis("move_up", "move_down")
	return input_dir.normalized()


## 데미지 처리 (FR-05: 적 충돌 시 HP 감소)
func take_damage(amount: int) -> void:
	# 쿨다운 중이면 무시
	if damage_cooldown > 0.0:
		return

	hp -= amount
	damage_cooldown = DAMAGE_COOLDOWN_TIME

	# HP 변경 시그널 발생 (FR-15: HUD 업데이트)
	hp_changed.emit(hp, max_hp)

	# HP 0 이하 시 (FR-18: 게임오버 트리거)
	if hp <= 0:
		hp = 0
		hp_changed.emit(hp, max_hp)
		died.emit()


## XP 추가 (FR-10: 보석 습득 시 호출)
func add_xp(amount: int) -> void:
	xp += amount
	xp_changed.emit(xp, xp_to_next_level)
	_check_level_up()


## 레벨업 체크 (FR-11: XP 임계값 도달 시 레벨업)
func _check_level_up() -> void:
	while xp >= xp_to_next_level:
		xp -= xp_to_next_level
		level += 1
		xp_to_next_level = level * 20
		xp_changed.emit(xp, xp_to_next_level)
		leveled_up.emit(level)


## 회전 칼날 시스템
var orbital_knives: Array[Node2D] = []  # 활성 칼날 목록
var knife_orbit_angle: float = 0.0       # 현재 공전 각도
const KNIFE_ORBIT_RADIUS: float = 80.0   # 공전 반경 (픽셀)
const KNIFE_ORBIT_SPEED: float = 3.0     # 공전 속도 (rad/s)
var knife_texture: Texture2D = preload("res://assets/sprites/projectile.png")


## 스킬 적용 (FR-14: 스킬 선택 후 스탯 즉시 적용)
func apply_skill(skill_type: String) -> void:
	match skill_type:
		"orbital_knife":
			_add_orbital_knife()
		"fire_rate":
			var timer := get_node("AttackTimer") as Timer
			timer.wait_time = max(timer.wait_time * 0.8, 0.1)
		"move_speed":
			speed += 30


## 회전 칼날 추가 — 플레이어 주변을 360도 회전하며 적 공격
func _add_orbital_knife() -> void:
	var knife := Area2D.new()

	# 스프라이트 설정
	var sprite := Sprite2D.new()
	sprite.texture = knife_texture
	sprite.scale = Vector2(0.04, 0.04)
	knife.add_child(sprite)

	# 충돌 영역 설정
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(20, 20)
	collision.shape = shape
	knife.add_child(collision)

	# 충돌 레이어 설정 (Projectile 레이어 → Enemy 감지)
	knife.collision_layer = 4
	knife.collision_mask = 2

	# 적 충돌 시 처치
	knife.body_entered.connect(_on_knife_hit_enemy)

	# 칼날 목록에 추가
	orbital_knives.append(knife)
	add_child(knife)

	# 칼날들의 간격을 균등 재배치
	_reposition_knives()


## 칼날 간격 균등 재배치
func _reposition_knives() -> void:
	# 칼날 수에 따라 균등 간격 계산 (예: 2개면 180도, 3개면 120도)
	var count := orbital_knives.size()
	for i in count:
		var angle_offset := (TAU / count) * i
		orbital_knives[i].set_meta("angle_offset", angle_offset)


## 칼날 공전 업데이트 (매 프레임 호출)
func update_orbital_knives(delta: float) -> void:
	if orbital_knives.is_empty():
		return

	knife_orbit_angle += KNIFE_ORBIT_SPEED * delta

	for knife in orbital_knives:
		if not is_instance_valid(knife):
			continue
		var offset: float = knife.get_meta("angle_offset", 0.0)
		var angle := knife_orbit_angle + offset

		# 공전 위치 계산
		knife.position = Vector2(cos(angle), sin(angle)) * KNIFE_ORBIT_RADIUS

		# 칼날 자체도 공전 방향으로 회전
		knife.rotation = angle + PI / 2


## 칼날이 적에게 닿았을 때
func _on_knife_hit_enemy(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		if body.has_method("die"):
			body.die()
		else:
			body.queue_free()
