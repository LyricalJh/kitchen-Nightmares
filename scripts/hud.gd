extends CanvasLayer
## HUD 스크립트
## HP 바, XP 바, 레벨 숫자, 생존 시간을 화면 상단에 실시간 표시

# 노드 참조
@onready var hp_bar: ProgressBar = $MarginContainer/VBoxContainer/HPBar
@onready var xp_bar: ProgressBar = $MarginContainer/VBoxContainer/XPBar
@onready var level_label: Label = $MarginContainer/VBoxContainer/LevelLabel
@onready var time_label: Label = $MarginContainer/VBoxContainer/TimeLabel


## HP 바 업데이트 (FR-15)
func update_hp(current: int, max_val: int) -> void:
	hp_bar.max_value = max_val
	hp_bar.value = current


## XP 바 업데이트 (FR-16)
func update_xp(current: int, required: int) -> void:
	xp_bar.max_value = required
	xp_bar.value = current


## 레벨 표시 업데이트 (FR-16)
func update_level(new_level: int) -> void:
	level_label.text = "Lv. " + str(new_level)


## 경과 시간 표시 업데이트 (FR-22)
func update_time(seconds: float) -> void:
	var mins := int(seconds) / 60
	var secs := int(seconds) % 60
	time_label.text = "%02d:%02d" % [mins, secs]
