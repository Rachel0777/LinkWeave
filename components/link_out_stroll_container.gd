extends VBoxContainer

@onready var link_button = %link_button
@onready var link_text_edit = %link_text
# 错误信息
@onready var link_error_msg = %link_input_error
@onready var add_link_container = %add_link_container
@onready var show_link_container = %show_link_container
# 获得一下弹出窗口组件
#@export var link_window_scene = preload('res://pages/inspiration/PopUpLink.tscn')
@onready var memo_popup = %memo_pop_up_panel
@onready var memo_panel = $memo_pop_up_panel/PopUpLink

func _ready():
	GlobalVariables.load_inspiration_memo_file()
	GlobalVariables.load_inspiration_tag_file()
	# 如果这个popuplink close popuppanel跟着关闭
	Signalbus.window_close.connect(_pop_up_link_closed)

# 点击这个button，加入一个链接
func _on_link_add_button_pressed():
	var link_id = link_text_edit.text
	add_link_out(link_id)

func add_link_out(link_id):
	var memo_all_id = GlobalVariables.get_all_inspiration_memo_keys()
	# id正确，成功添加
	if link_id in memo_all_id:
		link_error_msg.hide()
		var memoEn = GlobalVariables.get_inspiration_memo(link_id)
		link_button.text = GlobalVariables.get_link_text(memoEn)
		add_link_container.hide()
		show_link_container.show()
		Signalbus.inspiration_link_add.emit(link_id)
		# 把元数据赋到button上，这样可以知道这个link的id
		link_button.set_meta('link_id',link_id)
	# id错误，添加失败，弹出错误信息
	else:
		link_error_msg.show()
		link_text_edit.clear()

# 删除该条链接
func _on_del_button_pressed():
	var link_id = link_button.get_meta('link_id')
	# 把链接的id传递给主页面，方便删除
	Signalbus.inspiration_link_deled.emit(link_id)
	# 从父类里把自己删掉
	self.queue_free()

# 点击时，显示链接的memo
func _on_link_button_pressed():
	memo_popup.show()
	var link_id = link_button.get_meta('link_id')
	var link_list=[]
	link_list.append(link_id)
	Signalbus.inspiration_link_show.emit(link_list)

func _pop_up_link_closed(msg):
	if msg == 'window close':
		memo_popup.hide()
	elif msg == 'window open':
		memo_popup.show()

