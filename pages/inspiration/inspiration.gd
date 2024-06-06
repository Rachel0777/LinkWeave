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

func _ready():
	# 下面这是标签的，人物部分可以复用
	reconstruct_tree(treeWidget)
	Signalbus.inspiration_tag_added.connect(_on_inspiration_tag_added)
	Signalbus.inspiration_tag_deled.connect(_on_inspiration_tag_added)
	# 下面是灵感memo的
	Signalbus.inspiration_memo_added.connect(_on_inspiration_memo_added)
	show_all_memo()
	
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
		# 删除储存的数据
		GlobalVariables.del_inspiration_tag(tag_del_data)
		GlobalVariables.save_inspiration_tag_file()
		# 更新当前UI显示
		Signalbus.inspiration_tag_deled.emit(tag_del_data)

# ==灵感添加存储部分==
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
		button_tag.text = '# '+get_tag_full_name(tag_id)
		popup_menu_tag.hide()

# 获得这个tag的名字，包括其父类的名字
func get_tag_full_name(tag_id:String) -> String:
	var current_tag = GlobalVariables.get_inspiration_tag(tag_id)
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

# 关于灵感录入有关的
# 填写后如果想要一键清除
func _on_inspiration_cancel_button_pressed():
	memoEdit.clear()
	clear_inspiration_tag()
	inspiration_memo_added_error.hide()

# 填写过后存储
# 获得MemoEdit中的内容，赋给MemoEntity
func get_memo_data()->MemoEntity:
	var memoEn = MemoEntity.new()
	# uuid 动态生成id
	memoEn.id = GlobalVariables.uuid_util.v4()
	memoEn.content = memoEdit.text
	# 现挖一个坑
	memoEn.book_id = 'NULL'
	# 之前的tag存到了button_tag里，现在取出
	memoEn.tag = button_tag.get_meta('tag_id','NULL')
	## 获得当前时间
	## 这个也先挖一个坑，等回头date那里把时间弄明白了再回来
	#var time = Time.get_time_dict_from_system()
	#memoEn.date = "%d-%02d-%02d %02d:%02d:%02d" % [time["year"], time["month"], time["day"], time["hour"], time["minute"], time["second"]]
	#print(memoEn.date)
	# 链接的linkout和linkin先挖个坑空着
	
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
		memoEdit.clear()
		clear_inspiration_tag()
		inspiration_memo_added_error.hide()
		clear_memo_container(memoContainer)
		show_all_memo()
	else:
		inspiration_memo_added_error.show()

# clear一下VBoxontainer
func clear_memo_container(container):
	for child in container.get_children():
		child.queue_free()

# 显示所有memo
func show_all_memo():
	for memo_id in GlobalVariables.get_all_inspiration_memo_keys():
		var memoPanel = memoPanelScene.instantiate()
		memoPanel.memoEn = GlobalVariables.get_inspiration_memo(memo_id)
		memoContainer.add_child(memoPanel)
