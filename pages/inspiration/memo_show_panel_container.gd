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

func _ready():
	_set_memo()
	# 下面的是修改MenuButton的PopUpMenu的，使其TransparentBG=true
	_apply_script_to_menubuttons(self)
	init_menu_btn()

# 做一些关于menu_button的初始化
func init_menu_btn():
	var popMenu = menuButton.get_popup()
	popMenu.index_pressed.connect(_on_menu_item_clicked)

# 获得点击的是哪一个
func _on_menu_item_clicked(index:int):
	# 0编辑
	if index == 0:
		print('编辑')
		Signalbus.panel_double_clicked.emit(memoEn)
	# 1删除
	elif index == 1:
		del_memo()
	# 2复制链接
	elif index == 2:
		pass
	else:
		print("PopupMenu index error!")

# 删除
func del_memo():
	# UI自动删除
	self.queue_free()
	# 从数据中删除
	GlobalVariables.del_memo(memoEn.id)

# 获得这个tag的名字，包括其父类的名字
func get_tag_full_name(tag_id:String) -> String:
	var current_tag = GlobalVariables.get_inspiration_tag(tag_id)
	#print(current_tag.name)
	var tag_names = []
	while current_tag != null:
		tag_names.append(current_tag.name)
		current_tag = GlobalVariables.get_inspiration_tag(current_tag.parent_id)
	var tag_name = ""
	for i in range(tag_names.size() - 1, -1, -1):
		if i!=0:
			tag_name += tag_names[i] + "/"
	tag_name += tag_names[0]
	return tag_name

# 设置一下memo的内容显示
func _set_memo():
	date_label.text = memoEn.date
	# 这里有点问题，不知道为什么……
	if memoEn.tag != "NULL":
		tag_label.show()
		tag_label.text = '# ' + get_tag_full_name(memoEn.tag)
	else:
		tag_label.hide()
	content_label.text = memoEn.content
	if len(memoEn.file_path)!=0:
		for file_path in memoEn.file_path:
			_add_related_file_ui(file_path)

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
			
# 更新UI	
func _add_related_file_ui(file_path:String):
	var relatedFileComp = related_file_comp_scene.instantiate()
	relatedFileComp.filepath = file_path
	# 获取按钮节点
	var file_button = relatedFileComp.get_node("file_button")
	var del_button = relatedFileComp.get_node("del_button")
	# 禁用按钮
	file_button.disabled = true
	del_button.disabled = true
	related_file_container.add_child(relatedFileComp)

# 如果双击panel，则查看内容
func _on_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		Signalbus.panel_double_clicked.emit(memoEn)
