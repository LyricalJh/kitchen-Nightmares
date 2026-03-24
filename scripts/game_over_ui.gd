extends CanvasLayer
## 게임오버 UI 스크립트
## HP 0 시 생존 시간/최고 기록 표시, 재시작/타이틀 버튼 (FR-19, FR-20)

# 노드 참조
@onready var survival_time_label: Label = $Background/CenterContainer/VBoxContainer/SurvivalTimeLabel
@onready var best_time_label: Label = $Background/CenterContainer/VBoxContainer/BestTimeLabel
@onready var restart_button: Button = $Background/CenterContainer/VBoxContainer/RestartButton
@onready var title_button: Button = $Background/CenterContainer/VBoxContainer/TitleButton


func _ready() -> void:
	# 일시정지 중에도 입력 받을 수 있도록 설정
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	# 초기에는 숨김
	visible = false
	# 버튼 시그널 연결
	restart_button.pressed.connect(_on_restart_pressed)
	title_button.pressed.connect(_on_title_pressed)


## 결과 표시 (FR-19: 생존 시간, 최고 기록)
func show_results(survival_time: float, best_time: float) -> void:
	survival_time_label.text = "생존 시간: " + _format_time(survival_time)
	best_time_label.text = "최고 기록: " + _format_time(best_time)
	visible = true


## 재시작 (FR-20: Main 씬 리로드)
func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


## 타이틀로 돌아가기 (FR-20)
func _on_title_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")


## 초를 MM:SS 형식으로 변환
func _format_time(seconds: float) -> String:
	var mins := int(seconds) / 60
	var secs := int(seconds) % 60
	return "%02d:%02d" % [mins, secs]
