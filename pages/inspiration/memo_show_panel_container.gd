extends PanelContainer

@export var memoEn:MemoEntity

# 获得需要更新或者显示的组件
@onready var date_label = %inspiration_date
@onready var tag_label = %inspiration_tag_label
@onready var content_label = %memo_content
# 文件显示的小组件
@onready var related_file_comp_scene = preload("res://components/related_file_components_container.tscn")
@onready var related_file_container = %memo_related_file_container
# 进行一个增删改查
@onready var menuButton = %inspiration_inspiration_detail_button

# ==link链接部分==
# 首先是选择链接后展示
@onready var related_link_comp_scene = preload("res://components/link_out_stroll_container.tscn")
@onready var related_link_container = %link_out_vbox_container
@onready var link_out_btn = %link_out_button
@onready var linkin_container = %inspiration_linkin_container
@onready var link_in_btn = %link_in_show_button

func _ready():
	_set_memo()
	# 下面的是修改MenuButton的PopUpMenu的，使其TransparentBG=true
	_apply_script_to_menubuttons(self)
	init_menu_btn()
	init_link_in()

# 做一些关于menu_button的初始化
func init_menu_btn():
	var popMenu = menuButton.get_popup()
	popMenu.index_pressed.connect(_on_menu_item_clicked)

# 获得点击的是哪一个
func _on_menu_item_clicked(index:int):
	# 0编辑
	if index == 0:
		Signalbus.panel_double_clicked.emit(memoEn)
	# 1删除
	elif index == 1:
		del_memo()
	# 2复制链接
	elif index == 2:
		var memo_id = memoEn.id 
		var text_to_copy = memo_id
		DisplayServer.clipboard_set(text_to_copy)
	else:
		print("PopupMenu index error!")

# 删除
func del_memo():
	# UI自动删除
	self.queue_free()
	# 从数据中删除
	GlobalVariables.del_memo(memoEn.id)
	Signalbus.inspiration_memo_deled.emit('memo deled')

# 设置一下memo的内容显示
func _set_memo():
	var today = memoEn.date
	var today_string = str(today.year)+'-'+str(today.month)+'-'+str(today.day)+' '+str(today.hour)+':'+str(today.minute)+':'+str(today.second)
	date_label.text = today_string
	# 这里有点问题，不知道为什么……
	if memoEn.tag != "NULL":
		tag_label.show()
		tag_label.text = '# ' + GlobalVariables.get_tag_full_name(memoEn.tag)
	else:
		tag_label.hide()
	content_label.text = memoEn.content
	# 显示file
	if len(memoEn.file_path)!=0:
		for file_path in memoEn.file_path:
			_add_related_file_ui(file_path)
	# 显示链接linkout
	if len(memoEn.linkout)!=0:
		for link_out in memoEn.linkout:
			_add_related_link_ui(link_out)

# 下面处理MenuButton的，使其背景透明的
func _apply_script_to_menubuttons(node):
	for child in node.get_children():
		if child is MenuButton:
			var popup_menu = child.get_popup()
			if popup_menu:
				_on_popup_about_to_show(popup_menu)
		else:
			_apply_script_to_menubuttons(child)
func _on_popup_about_to_show(popup_menu):
	if popup_menu:
		var viewport = popup_menu.get_viewport()
		if viewport:
			viewport.transparent_bg = true
			
# 更新文件UI	
func _add_related_file_ui(file_path:String):
	var relatedFileComp = related_file_comp_scene.instantiate()
	relatedFileComp.filepath = file_path
	# 获取按钮节点，让用户只能看文件，不能删除关联文件
	var del_button = relatedFileComp.get_node("del_button")
	del_button.hide()
	related_file_container.add_child(relatedFileComp)

# 如果双击panel，则查看内容
func _on_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		Signalbus.panel_double_clicked.emit(memoEn)

# ==link==
# 显示链接link
func _add_related_link_ui(link_out):
	link_out_btn.show()
	var link_container = related_link_comp_scene.instantiate()
	# 获取一下panel，让输入的hide，只显示最后的link
	var add_link_container = link_container.get_node("add_link_container")
	var show_link_container = link_container.get_node("show_link_container")
	var del_btn = show_link_container.get_node("del_button")
	var show_link_text = show_link_container.get_node("link_button")
	add_link_container.hide()
	show_link_container.show()
	# 同时不能删除link
	del_btn.hide()
	show_link_text.set_meta('link_id',link_out)
	var link_memoEn = GlobalVariables.get_inspiration_memo(link_out)
	show_link_text.text = GlobalVariables.get_link_text(link_memoEn)
	related_link_container.add_child(link_container)
	
# 如果按了的话，显示所有linkout
func _on_link_out_button_pressed():
	var link_out_list = memoEn.linkout
	Signalbus.window_close.emit('window open')
	Signalbus.inspiration_link_show.emit(link_out_list)

# 初始化一下linkin
func init_link_in():
	if len(memoEn.linkin)!=0:
		linkin_container.show()
		link_in_btn.text = '被' + str(len(memoEn.linkin)) + '条memo引用'
	else:
		linkin_container.hide()

# 如果按了的话，显示所有linkin
func _on_link_in_button_pressed():
	open_linkin()
func _on_link_in_show_button_pressed():
	open_linkin()
func open_linkin():
	var link_in_list = memoEn.linkin
	Signalbus.window_close.emit('window open')
	Signalbus.inspiration_link_show.emit(link_in_list)
