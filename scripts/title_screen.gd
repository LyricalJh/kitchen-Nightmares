extends Control
## 타이틀 화면 스크립트
## 게임 시작 버튼으로 Main 씬 전환 (FR-17)

@onready var start_button: Button = $VBoxContainer/StartButton


func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)


## 게임 시작 (FR-17: Main 씬으로 전환)
func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
