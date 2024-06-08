extends Control

@onready var memo_container = %memo_container
@onready var close_btn = %close_pop_up_button
@onready var window = %window_container
# 要先把组件给preload一下
@export var memoPanelScene:PackedScene = preload("res://pages/inspiration/memo_show_panel_container.tscn")

func _ready():
	GlobalVariables.load_inspiration_memo_file()
	GlobalVariables.load_inspiration_tag_file()
	Signalbus.inspiration_link_show.connect(show_link_memo)

# 如果按了这个，窗口消失
func _on_close_pop_up_button_pressed():
	Signalbus.window_close.emit('window close')

# 显示link_memo
func show_link_memo(memo_id_list):
	# 先清空一下panel
	for child in memo_container.get_children():
		child.queue_free()
	for memo_id in memo_id_list:
		var memoPanel = memoPanelScene.instantiate()
		memoPanel.memoEn = GlobalVariables.get_inspiration_memo(memo_id)
		memo_container.add_child(memoPanel)
