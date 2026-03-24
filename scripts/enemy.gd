extends CharacterBody2D
## 적(Enemy) 스크립트
## 플레이어를 실시간 추적하고, 충돌 시 데미지를 전달
## 처치 시 XP 보석을 드랍 (FR-09)

# 추적 속도 (픽셀/초)
@export var speed: float = 80.0

# 충돌 데미지량
@export var damage: int = 10

# XP 보석 씬 프리로드 (FR-09: 처치 시 드랍)
var xp_gem_scene: PackedScene = preload("res://scenes/xp_gem.tscn")


func _ready() -> void:
	# 적 그룹에 등록 (발사체의 타겟 탐색용)
	add_to_group("enemies")


func _physics_process(_delta: float) -> void:
	# 플레이어 노드 참조 (FR-04: 실시간 추적)
	var player := _get_player()
	if player == null:
		return

	# 플레이어 방향으로 이동
	var direction := (player.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()

	# 충돌 감지 (FR-05: 플레이어와 충돌 시 데미지 전달)
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		if collider is CharacterBody2D and collider.has_method("take_damage"):
			collider.take_damage(damage)


## 처치 시 보석 드랍 + 자신 제거 (FR-09)
func die() -> void:
	# XP 보석 드랍
	var gem := xp_gem_scene.instantiate()
	gem.global_position = global_position
	get_tree().current_scene.add_child(gem)
	# 적 제거
	queue_free()


## 씬 트리에서 플레이어 노드 찾기
func _get_player() -> CharacterBody2D:
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0] as CharacterBody2D
	return null
