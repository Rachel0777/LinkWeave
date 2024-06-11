extends Control

# == 标签部分定义代码 == 
# 标签树
@onready var treeWidget = %tag_tree_lucky
# 选择标签父类的按钮
@onready var selectTagBtn = %tag_add_button
# 添加新标签
@onready var tagEdit = %tag_edit
# 新标签添加失败，显示这个label
@onready var inspiration_tag_added_error = %inspiration_tag_added_error

# == 灵感存储添加部分代码 ==
# 这个主要是选择标签
@onready var popup_menu_tag = %popup_menu_tag_tree
@onready var popup_tree = %popup_tag_tree
@onready var button_tag = %tag_add_button_top
@onready var popup_menu = %tag_change_popup_menu
# 这个主要是存储的
@onready var memoEdit = %memo
# memo添加失败，显示这个label
@onready var inspiration_memo_added_error = %inspiration_memo_added_error

# ==灵感展示部分代码==
@export_category('memo entity')
@export var memoEn:MemoEntity
# 要先把组件给preload一下
@export var memoPanelScene:PackedScene = preload("res://pages/inspiration/memo_show_panel_container.tscn")
@onready var memoContainer = %memo_VBcontainer
# 插入文件
@onready var related_file_container = %memo_related_file_container
@onready var related_file_comp_scene = preload("res://components/related_file_components_container.tscn")
@onready var file_btn = %inspiration_file_button
@onready var file_list: Array[String]
# 通过这个button存储一下uuid，实际上是标注一下这个memoEn是否已经存在
@onready var memo_add_btn = %inspiration_add_button
# 获得日期

# ==链接部分==
# 首先是选择链接后展示
@onready var related_link_comp_scene = preload("res://components/link_out_stroll_container.tscn")
@onready var related_link_container = %link_out_vbox_container
@onready var link_out_btn = %link_out_button
# 存储link_out的id
@onready var link_out_list : Array[String]

# ==日历部分==
@onready var calendar_container = %month_container
@onready var calendar_scene = preload('res://components/calendar/calendar_month.tscn')

func _ready():
	# ==下面这是标签的，人物部分可以复用==
	reconstruct_tree(treeWidget)
	Signalbus.inspiration_tag_added.connect(_on_inspiration_tag_added)
	Signalbus.inspiration_tag_deled.connect(_on_inspiration_tag_added)
	
	# ==下面是灵感memo的==
	# 这个主要是添加memo的
	Signalbus.inspiration_memo_added.connect(_on_inspiration_memo_added)
	show_all_memo()
	# 这个主要是memo关联文件有关的
	Signalbus.inspiration_related_file_deled.connect(_on_related_file_deled)
	# 查看memo
	Signalbus.panel_double_clicked.connect(_on_panel_double_clicked)
	# 删除memo
	Signalbus.inspiration_memo_deled.connect(_on_memo_deled)
	# 左上角label显示
	_set_label_num()
	# ==下面是链接有关的==
	Signalbus.inspiration_link_add.connect(_on_link_added)
	Signalbus.inspiration_link_deled.connect(_on_link_deled)
	# ==日历==
	show_calendar()
	
# == 标签部分代码 ==
# 创建树
func reconstruct_tree(tree:Tree):
	tree.clear()
	# 定义树的根节点
	var root: TreeItem = tree.create_item()
	root.set_text(0,'灵感')
	for tag_id in GlobalVariables.get_all_inspiration_tag_keys():
		var tag_data = GlobalVariables.get_inspiration_tag(tag_id)
		if tag_data.parent_id == 'NULL':
			create_tree(root,tag_data)

# 遍历整个树，创建树
func create_tree(node:TreeItem,tag_data:TagEntity):
	var child = node.create_child()
	child.set_text(0,tag_data.name)
	child.set_metadata(0,tag_data.id)
	child.set_tooltip_text(0,'')
	# 如果没有子节点直接返回
	if len(tag_data.children_id)==0:
		return
	else:
		# 如果有子节点，则深度遍历
		for subchild_id in tag_data.children_id:
			var subchild_data = GlobalVariables.get_inspiration_tag(subchild_id)
			create_tree(child,subchild_data)
			
# 信号，如果选中了某个树节点，注意只能选中一个
func _on_tag_tree_lucky_item_selected():
	var selected_item = treeWidget.get_selected()
	if selected_item:
		var tag_name = selected_item.get_text(0)
		var tag_id = selected_item.get_metadata(0)
		selectTagBtn.set_meta('tag_id',tag_id)

# 信号，点击了tag_add_button，先把tagEdit的内容清空
func _on_tag_add_button_pressed():
	var tag_data = get_tag_data()
	if validate(tag_data):
		save_tag(tag_data)
		# 发送技能添加成功的信号
		Signalbus.inspiration_tag_added.emit(tag_data)
		tagEdit.clear()
		inspiration_tag_added_error.hide()
	else:
		inspiration_tag_added_error.show()

# 获得tagEdit中的内容，赋给TagEntity
func get_tag_data()->TagEntity:
	var tagEn = TagEntity.new()
	# uuid 动态生成id
	tagEn.id = GlobalVariables.uuid_util.v4()
	tagEn.name = tagEdit.text
	# parent设置后，需要树形结构中获得对应的id
	tagEn.parent_id = selectTagBtn.get_meta('tag_id','NULL')
	return tagEn

# 保存TagEntity
func save_tag(tag_data:TagEntity):
	GlobalVariables.add_inspiration_tag(tag_data)
	GlobalVariables.save_inspiration_tag_file()
	
# 确认TagEdit中确实有内容
func validate(tag_data:TagEntity)->bool:
	# 验证新添加的技能能为空
	if tag_data.name == '':
		return false
	else:
		return true

# 如果tag添加了，调用这个函数
func _on_inspiration_tag_added(tagEn:TagEntity):
	tagEdit.clear()
	reconstruct_tree(treeWidget)
	selectTagBtn.set_meta('tag_id','NULL')

# 如果按了删除按钮，删除这个节点以及其子节点
func _on_tag_del_button_pressed():
	var tag_del = selectTagBtn.get_meta('tag_id','NULL')
	if tag_del == 'NULL':
		pass
	else:
		# 找到id对应tagEn
		var tag_del_data = GlobalVariables.get_inspiration_tag(tag_del)
		# 获得一下所有的子类
		children_list.append(tag_del)
		get_all_tag_children(tag_del_data)
		# 删除储存的数据
		GlobalVariables.del_inspiration_tag(tag_del_data)
		GlobalVariables.save_inspiration_tag_file()
		# 更新当前UI显示
		Signalbus.inspiration_tag_deled.emit(tag_del_data)
		# 如果删除了，所有的笔记的tag也要跟着删除
		var memo_id_list = GlobalVariables.get_all_inspiration_memo_keys()
		for memo_id in memo_id_list:
			var memoEn1 = GlobalVariables.get_inspiration_memo(memo_id)
			if memoEn1.tag in children_list:
				memoEn1.tag = 'NULL'
				save_memo(memoEn1)
		show_all_memo()
		_set_label_num()
		children_list = []

# 获得一个tag的所有子类
@onready var children_list = []
func get_all_tag_children(tag_data:TagEntity):
	# 再去把子类删除了
	var children_id_list = tag_data.children_id
	if children_id_list.size()>0:
		for child_id in children_id_list:
			var child_data = GlobalVariables.get_inspiration_tag(child_id)
			children_list.append(child_id)
			get_all_tag_children(child_data)

# ==灵感添加存储部分==
# ==memo标签有关==
# 这个其实是tag的部分，但是我不知道人物界面需不需要这样？
# 点击添加tag
func _on_inspiration_tag_button_pressed():
	if not button_tag.visible and not popup_menu_tag.visible:
		reconstruct_tree(popup_tree)
		popup_menu_tag.show()
		button_tag.show()

# 选择了一个tag之后加入
func _on_popup_tag_tree_item_selected():
	var selected_item = popup_tree.get_selected()
	if selected_item:
		var tag_id = selected_item.get_metadata(0)
		# 把这个标签的id存到button_tag里了，之后就可以很方便的通过button_tag存一下
		button_tag.set_meta('tag_id',tag_id)
		button_tag.text = '# '+ GlobalVariables.get_tag_full_name(tag_id)
		popup_menu_tag.hide()
	
# 修改或者删除这个tag
func _on_tag_add_button_top_pressed():
	if not popup_menu.visible:
		popup_menu.show()

# 修改灵感录入时的标签，0是修改，1是删除
func _on_tag_change_popup_menu_id_pressed(id):
	# 删除
	if id==1:
		clear_inspiration_tag()
	# 修改
	elif id==0:
		button_tag.set_meta('tag_id','NULL')
		button_tag.text = '#'
		if not popup_menu.visible:
			popup_menu_tag.show()
		
# 清除灵感上面添加的tag
func clear_inspiration_tag():
	# 先得把button上的Meta给清掉
	button_tag.set_meta('tag_id','NULL')
	button_tag.text = '#'
	# 之后button和PopUpMenu全部收起来
	button_tag.hide()
	popup_menu_tag.hide()

# ==灵感录入有关==
# 填写后如果想要一键清除
func _on_inspiration_cancel_button_pressed():
	memoEdit.clear()
	clear_inspiration_tag()
	inspiration_memo_added_error.hide()
	# 把文件也给删除一下
	clear_inspiration_file()
	# 链接也删除一下
	clear_inspiration_link_out()
	memo_add_btn.set_meta('memo_id','NULL')

# 填写过后存储
# 获得MemoEdit中的内容，赋给MemoEntity
func get_memo_data()->MemoEntity:
	var memoEn = MemoEntity.new()
	# 如果添加，则uuid 动态生成id，否则直接用原来的
	var memo_id = memo_add_btn.get_meta('memo_id','NULL')
	if memo_id not in GlobalVariables.get_all_inspiration_memo_keys():
		memoEn.id = GlobalVariables.uuid_util.v4()
	else:
		memoEn.id = memo_id
	memo_add_btn.set_meta('memo_id','NULL')
	memoEn.content = memoEdit.text
	# 先挖一个坑
	memoEn.book_id = 'NULL'
	# 之前的tag存到了button_tag里，现在取出
	memoEn.tag = button_tag.get_meta('tag_id','NULL')
	# 获得当前时间
	# 这个也先挖一个坑，等回头date那里把时间弄明白了再回来
	var today = Time.get_datetime_dict_from_system()
	memoEn.date = today
	# 链接的linkout和linkin先挖个坑空着
	memoEn.linkout = link_out_list
	if memoEn.id == memo_id:
		var memo_En_original = GlobalVariables.get_inspiration_memo(memo_id)
		memoEn.linkin = memo_En_original.linkin
	# 除了给自己的linkin一下，由于link了别人，还要更新一下别人的linkin
	GlobalVariables.update_other_link_in(memoEn)
	# 文件
	memoEn.file_path = file_list
	return memoEn
	
# 确认MemoEdit中确实有内容
func validate_memo(memo_data:MemoEntity)->bool:
	# 验证新添加的技能能为空
	if memo_data.content == '':
		return false
	else:
		return true

# 保存MemoEntity
func save_memo(memo_data:MemoEntity):
	GlobalVariables.add_inspiration_memo(memo_data)
	GlobalVariables.save_inspiration_memo_file()

# 如果memo添加了，调用这个函数
func _on_inspiration_memo_added(memoEn:MemoEntity):
	memoEdit.clear()

# 点击存储memo，而且需要更新底下的
func _on_inspiration_add_button_pressed():
	var memo_data = get_memo_data()
	if validate_memo(memo_data):
		save_memo(memo_data)
		# 发送技能添加成功的信号
		Signalbus.inspiration_memo_added.emit(memo_data)
		# 根据id是否
		memoEdit.clear()
		clear_inspiration_tag()
		inspiration_memo_added_error.hide()
		# 删除一下文件，这个比较麻烦一点点
		clear_inspiration_file()
		# 删除link，从UI到link_out_list
		clear_inspiration_link_out()
		show_all_memo()
		_set_label_num()
		# 更新日历
		show_calendar()
	else:
		inspiration_memo_added_error.show()

# clear一下VBoxontainer
func clear_memo_container(container):
	for child in container.get_children():
		child.queue_free()

# 显示所有memo
func show_all_memo():
	clear_memo_container(memoContainer)
	for memo_id in GlobalVariables.get_all_inspiration_memo_keys():
		var memoPanel = memoPanelScene.instantiate()
		memoPanel.memoEn = GlobalVariables.get_inspiration_memo(memo_id)
		memoContainer.add_child(memoPanel)

func _on_memo_deled(msg:String):
	if msg == 'memo deled':
		show_all_memo()
		show_calendar()
		_set_label_num()

# ==关联文件有关==
# 加入文件，弹出对话框
func _on_inspiration_file_button_pressed():
	%SelectFileDialog_Inspiration.show()

# 文件中的信号
func _on_select_file_dialog_inspiration_file_selected(path):
	_add_related_file(path)
	
# 加入文件后显示
func _add_related_file(file_path:String):
	# 先保存文件数据
	file_list.append(file_path)
	_add_related_file_ui(file_path)

# 更新UI	
func _add_related_file_ui(file_path:String):
	var relatedFileComp = related_file_comp_scene.instantiate()
	relatedFileComp.filepath = file_path
	related_file_container.add_child(relatedFileComp)
	
# 删除关联文件
func _on_related_file_deled(path:String):
	memoEn.file_path.erase(path)
	file_list.erase(path)

# 清空一下文件部分
func clear_inspiration_file():
	for child in related_file_container.get_children():
		if child != file_btn:
			child.queue_free()
	file_list=[]

# ==灵感页面memo进行一个增删改查==
# 如果双击panel，则发生查看
func _on_panel_double_clicked(memoEn:MemoEntity):
	# 查看前先清空面板
	_on_inspiration_cancel_button_pressed()
	# 显示content
	memoEdit.text = memoEn.content
	# 显示tag的button
	if memoEn.tag != 'NULL':
		var tag_id = memoEn.tag
		button_tag.text = '# '+ GlobalVariables.get_tag_full_name(tag_id)
		button_tag.set_meta('tag_id',tag_id)
		button_tag.show()
	# 显示file
	var file_list1 = memoEn.file_path
	for file in file_list1:
		_add_related_file(file)
	# 显示linkout
	if len(memoEn.linkout)!=0:
		link_out_list = memoEn.linkout
		for link_out in memoEn.linkout:
			_add_related_link_ui(link_out)
	# 具体修改部分得看_on_inspiration_add_button_pressed
	memo_add_btn.set_meta('memo_id',memoEn.id)

# 左上角的label数字修改
func _set_label_num():
	var memo_id_list = GlobalVariables.get_all_inspiration_memo_keys()
	var memo_num_label = %memo_num_label
	memo_num_label.text = str(len(memo_id_list))
	var tag_id_list = GlobalVariables.get_all_inspiration_tag_keys()
	var tag_num_label = %tag_num_label
	tag_num_label.text = str(len(tag_id_list))
	var day_num_label = %day_num_label
	var date_list = []
	for memo_id in memo_id_list:
		var memoEn = GlobalVariables.get_inspiration_memo(memo_id)
		var date = memoEn.date
		var date_string = str(date.year)+'-'+str(date.month)+'-'+str(date.day)
		if date_string not in date_list:
			date_list.append(date_string)
	day_num_label.text = str(len(date_list))
	
# ==下面是和灵感页面链接有关的==
# 显示link的UI,显示链接link
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
	show_link_text.set_meta('link_id',link_out)
	var memoEn1 =GlobalVariables.get_inspiration_memo(link_out)
	show_link_text.text = GlobalVariables.get_link_text(memoEn1)
	related_link_container.add_child(link_container)

# 点击链接图标，插入链接
func _on_inspiration_link_button_pressed():
	link_out_btn.show()
	var link_container = related_link_comp_scene.instantiate()
	related_link_container.add_child(link_container)

# 从component通过信号获取这个链接的id，并存储
func _on_link_added(link_id:String):
	link_out_list.append(link_id)

# 清空一下link
func clear_inspiration_link_out():
	link_out_list=[]
	# UI也要清空
	for child in related_link_container.get_children():
		child.queue_free()
	link_out_btn.hide()

# 删除这一个link
func _on_link_deled(link_id):
	var link_in_En = GlobalVariables.get_inspiration_memo(link_id)
	var memo_id = memo_add_btn.get_meta('memo_id','NULL')
	link_in_En.linkin.erase(memo_id)
	save_memo(link_in_En)
	memoEn.linkout.erase(link_id)
	link_out_list.erase(link_id)
	if len(link_out_list) == 0:
		link_out_btn.hide()

# 点击这个button显示该memo的所有link
func _on_link_out_button_pressed():
	Signalbus.window_close.emit('window open')
	Signalbus.inspiration_link_show.emit(link_out_list)

# ==日历==
func show_calendar():
	clear_memo_container(calendar_container)
	var calendar_month = calendar_scene.instantiate()
	calendar_container.add_child(calendar_month)
