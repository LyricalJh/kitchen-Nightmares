extends Area2D
## 발사체(Projectile) 스크립트
## 지정된 방향으로 이동하고, 적과 충돌 시 적을 제거

# 발사체 속도 (픽셀/초)
var speed: float = 400.0

# 발사 방향 (메인 스크립트에서 설정)
var direction: Vector2 = Vector2.ZERO

# 최대 사거리 (픽셀)
var max_range: float = 600.0

# 이동 거리 추적
var distance_traveled: float = 0.0


func _ready() -> void:
	# 적(CharacterBody2D)과의 충돌 감지 시그널 연결
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	# 방향으로 이동 (FR-06: 자동 발사)
	var move_amount := speed * delta
	position += direction * move_amount

	# 이동 거리 추적
	distance_traveled += move_amount

	# 사거리 초과 시 제거 (메모리 누수 방지)
	if distance_traveled >= max_range:
		queue_free()


## 적과 충돌 시 처리 (FR-07: 적 제거, FR-09: 보석 드랍 포함)
func _on_body_entered(body: Node2D) -> void:
	# 적 그룹 소속인지 확인
	if body.is_in_group("enemies"):
		if body.has_method("die"):
			body.die()       # die()로 보석 드랍 포함 처치
		else:
			body.queue_free()  # 폴백
		queue_free()        # 발사체 자신도 제거
