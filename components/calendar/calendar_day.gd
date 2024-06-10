extends Panel

@export var day: Dictionary
@onready var calendar_day_panel = $"."
@onready var num = GlobalVariables.calendar_day_color(day)

func _ready():
	# 每个 Panel 实例都应该有自己的 StyleBox 实例
	var styleBox = StyleBoxFlat.new()
	
	# 设置边框颜色
	styleBox.border_color = Color.html('#bbbbbb')
	# 设置边框宽度（可以为四个方向分别设置）
	styleBox.border_width_top = 1
	styleBox.border_width_bottom = 1
	styleBox.border_width_left = 1
	styleBox.border_width_right = 1
	
	# 设置背景颜色
	match num:
		0:
			styleBox.set("bg_color", Color.html('#ffffff'))
		1:
			styleBox.set("bg_color", Color.html('#FCF1C5'))
		2:
			styleBox.set("bg_color", Color.html('#FAEAA7'))
		3:
			styleBox.set("bg_color", Color.html('#F8E38D'))
		4:
			styleBox.set("bg_color", Color.html('#FFE476'))
		_:
			styleBox.set("bg_color", Color.html('#F9DC5C'))
	
	# 应用样式盒到 Panel
	add_theme_stylebox_override('panel', styleBox)
	var text = str(day.year)+'-'+str(day.month)+'-'+str(day.day)
	calendar_day_panel.tooltip_text = text

