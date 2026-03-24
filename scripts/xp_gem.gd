extends Area2D
## 경험치 보석(XP Gem) 스크립트
## 적 처치 시 드랍되어 플레이어 접촉 시 XP를 전달

# 습득 시 XP 양
var xp_value: int = 5


func _ready() -> void:
	# 보석 그룹에 등록
	add_to_group("xp_gems")
	# 플레이어(CharacterBody2D)와의 충돌 감지
	body_entered.connect(_on_body_entered)


## 플레이어 접촉 시 XP 전달 (FR-10)
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("add_xp"):
		body.add_xp(xp_value)
		queue_free()  # 보석 제거
