extends HBoxContainer

@export var filepath:String
@onready var file_button = $file_button

func _ready():
	file_button.text=filepath.get_file()

# 点击按钮删除
func _on_del_button_pressed():
	Signalbus.inspiration_related_file_deled.emit(filepath)
	# 从父类里把自己删掉
	self.queue_free()

# 点击时打开filepath
func _on_file_button_pressed():
	OS.shell_show_in_file_manager(filepath)
