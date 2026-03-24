extends CharacterBody2D
## 적(Enemy) 스크립트
## 플레이어를 추적하고, 충돌 시 데미지 전달, 처치 시 XP 보석 드랍

@export var speed: float = 80.0
@export var damage: int = 10

var xp_gem_scene: PackedScene = preload("res://scenes/xp_gem.tscn")
var _bg_shader: Shader = preload("res://assets/shaders/remove_white_bg.gdshader")

# 바운스 애니메이션
var bounce_time: float = 0.0
const BOUNCE_SPEED: float = 8.0
const BOUNCE_HEIGHT: float = 14.0

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	add_to_group("enemies")
	bounce_time = randf() * TAU
	# 흰 배경 제거 셰이더
	var mat := ShaderMaterial.new()
	mat.shader = _bg_shader
	sprite.material = mat


func _physics_process(delta: float) -> void:
	var player := _get_player()
	if player == null:
		return

	# 플레이어 추적
	var direction := (player.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()

	# 바운스 애니메이션
	bounce_time += delta * BOUNCE_SPEED
	sprite.position.y = -abs(sin(bounce_time)) * BOUNCE_HEIGHT

	# 충돌 시 플레이어에게 데미지 (그룹 체크로 정확하게)
	for i in get_slide_collision_count():
		var collider := get_slide_collision(i).get_collider()
		if collider is CharacterBody2D and collider.is_in_group("player") and collider.has_method("take_damage"):
			collider.take_damage(damage)


## 처치 시 보석 드랍 + 자신 제거
func die() -> void:
	var gem := xp_gem_scene.instantiate()
	gem.global_position = global_position
	get_tree().current_scene.add_child(gem)
	queue_free()


func _get_player() -> CharacterBody2D:
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0] as CharacterBody2D
	return null
