extends CanvasLayer
## 레벨업 스킬 선택 UI 스크립트
## 레벨업 시 게임 일시정지 후 3개 스킬 중 1개 선택 (FR-12, FR-13)

# 스킬 선택 시그널 (Main에서 수신)
signal skill_selected(skill_type: String)

# 버튼 참조
@onready var skill_button_1: Button = $Background/CenterContainer/VBoxContainer/SkillButton1
@onready var skill_button_2: Button = $Background/CenterContainer/VBoxContainer/SkillButton2
@onready var skill_button_3: Button = $Background/CenterContainer/VBoxContainer/SkillButton3
@onready var skill_button_4: Button = $Background/CenterContainer/VBoxContainer/SkillButton4


func _ready() -> void:
	# 일시정지 중에도 입력 받을 수 있도록 설정
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	# 초기에는 숨김
	visible = false
	# 버튼 시그널 연결
	skill_button_1.pressed.connect(_on_orbital_knife_selected)
	skill_button_2.pressed.connect(_on_garlic_bomb_selected)
	skill_button_3.pressed.connect(_on_fire_rate_selected)
	skill_button_4.pressed.connect(_on_move_speed_selected)


## UI 표시 (FR-12: 레벨업 시 호출)
func show_ui() -> void:
	visible = true


## UI 숨김 (FR-14: 스킬 선택 후)
func hide_ui() -> void:
	visible = false


## 회전 칼날 스킬 선택
func _on_orbital_knife_selected() -> void:
	skill_selected.emit("orbital_knife")
	hide_ui()


## 갈릭 폭탄 스킬 선택
func _on_garlic_bomb_selected() -> void:
	skill_selected.emit("garlic_bomb")
	hide_ui()


## 근접 공격 속도 스킬 선택
func _on_fire_rate_selected() -> void:
	skill_selected.emit("fire_rate")
	hide_ui()


## 이동 속도 스킬 선택
func _on_move_speed_selected() -> void:
	skill_selected.emit("move_speed")
	hide_ui()
