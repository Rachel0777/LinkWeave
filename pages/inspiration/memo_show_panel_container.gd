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
	show_link_text.text=get_link_text(memoEn)
	related_link_container.add_child(link_container)

# 跟显示link相关的
# link button显示的内容，包括date+tag+content
func get_link_text(memoEn:MemoEntity):
	var text = memoEn.date
	if memoEn.tag !='NULL':
		text=text +' #'+ get_tag_full_name(memoEn.tag)+' '
	if len(memoEn.content)>15:
		text+=memoEn.content.substr(0, 15)
		text+='……'
	else:
		text+=memoEn.content
	return text
	
# 如果双击panel，则查看内容
func _on_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		Signalbus.panel_double_clicked.emit(memoEn)
