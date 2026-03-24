extends Area2D
## 경험치 보석(XP Gem) 스크립트
## 플레이어가 근처에 오면 자석처럼 빨려가서 XP 전달

# 습득 시 XP 양
var xp_value: int = 5

# 자석 흡수 시스템
var is_attracted: bool = false       # 흡수 중인지 여부
var attract_target: Node2D = null    # 플레이어 참조
const ATTRACT_RANGE: float = 120.0   # 흡수 시작 거리 (픽셀)
const ATTRACT_SPEED: float = 400.0   # 빨려가는 속도 (픽셀/초)
const COLLECT_DIST: float = 15.0     # 획득 거리 (픽셀)

# 흰 배경 제거 셰이더
var bg_remove_shader: Shader = preload("res://assets/shaders/remove_white_bg.gdshader")


func _ready() -> void:
	# 보석 그룹에 등록
	add_to_group("xp_gems")
	# 플레이어(CharacterBody2D)와의 충돌 감지 (직접 접촉 시에도 획득)
	body_entered.connect(_on_body_entered)
	# 흰 배경 제거 셰이더 적용
	var mat := ShaderMaterial.new()
	mat.shader = bg_remove_shader
	$Sprite2D.material = mat


func _process(delta: float) -> void:
	# 플레이어 탐색
	if attract_target == null or not is_instance_valid(attract_target):
		var players := get_tree().get_nodes_in_group("player")
		if players.is_empty():
			return
		attract_target = players[0]

	var dist := global_position.distance_to(attract_target.global_position)

	# 흡수 범위 안에 들어오면 빨려가기 시작
	if not is_attracted and dist <= ATTRACT_RANGE:
		is_attracted = true

	# 빨려가는 중
	if is_attracted:
		var direction := (attract_target.global_position - global_position).normalized()
		global_position += direction * ATTRACT_SPEED * delta

		# 충분히 가까우면 획득
		if global_position.distance_to(attract_target.global_position) <= COLLECT_DIST:
			if attract_target.has_method("add_xp"):
				attract_target.add_xp(xp_value)
			queue_free()


## 직접 접촉 시에도 XP 전달 (FR-10)
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("add_xp"):
		body.add_xp(xp_value)
		queue_free()
