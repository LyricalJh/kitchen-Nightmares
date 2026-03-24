extends CanvasLayer
## 레벨업 스킬 선택 UI 스크립트
## 레벨업 시 게임 일시정지 후 스킬 선택

signal skill_selected(skill_type: String)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	visible = false

	# 버튼 시그널 연결 — bind()로 스킬 타입을 전달하여 콜백 통합
	$Background/CenterContainer/VBoxContainer/SkillButton1.pressed.connect(_on_skill_chosen.bind("orbital_knife"))
	$Background/CenterContainer/VBoxContainer/SkillButton2.pressed.connect(_on_skill_chosen.bind("garlic_bomb"))
	$Background/CenterContainer/VBoxContainer/SkillButton3.pressed.connect(_on_skill_chosen.bind("fire_rate"))
	$Background/CenterContainer/VBoxContainer/SkillButton4.pressed.connect(_on_skill_chosen.bind("move_speed"))


func show_ui() -> void:
	visible = true


func _on_skill_chosen(skill_type: String) -> void:
	skill_selected.emit(skill_type)
	visible = false
