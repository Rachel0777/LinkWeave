extends Control
@onready var character_scene=preload("res://pages/character_card/scroll_container.tscn")
@onready var fundamental=preload("res://pages/character_card/sub_character.tscn")
@onready var card_container=%all_card_container
@onready var scrollcontainer=%ScrollContainer
@onready var characternum=%character_num
@onready var panelcontainer=%PanelContainer
var characters:Array[CharacterEntity]
# == 标签部分定义代码 == 
# 标签树
@onready var treeWidget = %tag_tree_lucky
# 选择标签父类的按钮
@onready var selectTagBtn = %tag_add_button
# 添加新标签
@onready var tagEdit = %tag_edit
# 新标签添加失败，显示这个label
@onready var character_tag_added_error = %character_tag_added_error
@onready var colorpickerbtn = %ColorPickerButton

# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalVariables.load_character_tag_file()
	_set_label_num()
	initiate_card()
	# ==下面这是标签的，人物部分可以复用==
	reconstruct_tree(treeWidget)
	Signalbus.character_tag_added.connect(_on_character_tag_added)
	Signalbus.character_tag_deled.connect(_on_character_tag_added)
	Signalbus.character_changed.connect(_on_character_changed)
	
#将之前存储的人物都加载出来
@onready var scroll_container = %ScrollContainer

func initiate_card():
	for child in card_container.get_children():
		if child != scroll_container:
			child.queue_free()
	Globalvariable.load_character_file()
	var index=0
	for i in Globalvariable.character_config_file.get_section_keys('character'):
		#获取的是id
		var cEn=Globalvariable.character_config_file.get_value('character',i)
		characters.append(cEn)
		_add_card(cEn)
		index+=1
	var k=0
	#因为本来有一个scrollcontainer在里面，所以不要第一个
	var children=card_container.get_children().slice(1)
	for i in children:
		for panel in i.get_children():
			panel._set_character(characters[k])
			panel.cname.set_meta('character_id',characters[k].id)
		k+=1
	#这个是左上角的数字（动态统计）
	characternum.set_text(str(index))
		

func _add_card(character:CharacterEntity):
	var sub_character=character_scene.instantiate()
	card_container.add_child(sub_character)
#新加人物
func _on_texture_button_pressed():
	var characterEn=CharacterEntity.new()
	_add_card(characterEn)
	scrollToEnd()
	Globalvariable.load_character_file()
func scrollToEnd():
	var scrollbar= %HScrollContainer.get_h_scroll_bar()
	scrollbar.changed.connect(_scroll_to_bottom)
func _scroll_to_bottom():
	var scrollbar = %HScrollContainer.get_h_scroll_bar()
	scrollbar.value=scrollbar.max_value

#跳转到人物图
func _on_character_graph_pressed():
	var target_scene=load("res://pages/graph/graph_edit.tscn")
	var children=panelcontainer.get_children()
	for child in children:
		remove_child(child)
		child.queue_free()
	var graph_=target_scene.instantiate()
	panelcontainer.add_child(graph_)

# ==tag有关==
# == 标签部分代码 ==
# 创建树
func reconstruct_tree(tree:Tree):
	tree.clear()
	# 定义树的根节点
	var root: TreeItem = tree.create_item()
	root.set_text(0,'人物')
	for tag_id in GlobalVariables.get_all_character_tag_keys():
		var tag_data = GlobalVariables.get_character_tag(tag_id)
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
			var subchild_data = GlobalVariables.get_character_tag(subchild_id)
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
		Signalbus.character_tag_added.emit(tag_data)
		tagEdit.clear()
		character_tag_added_error.hide()
	else:
		character_tag_added_error.show()

# 获得tagEdit中的内容，赋给TagEntity
func get_tag_data()->TagEntity:
	var tagEn = TagEntity.new()
	# uuid 动态生成id
	tagEn.id = GlobalVariables.uuid_util.v4()
	tagEn.name = tagEdit.text
	# parent设置后，需要树形结构中获得对应的id
	tagEn.parent_id = selectTagBtn.get_meta('tag_id','NULL')
	tagEn.color = colorpickerbtn.color
	return tagEn

# 保存TagEntity
func save_tag(tag_data:TagEntity):
	GlobalVariables.add_character_tag(tag_data)
	GlobalVariables.save_character_tag_file()
	
# 确认TagEdit中确实有内容
func validate(tag_data:TagEntity)->bool:
	# 验证新添加的技能能为空
	if tag_data.name == '':
		return false
	else:
		return true

# 如果tag添加了，调用这个函数
func _on_character_tag_added(tagEn:TagEntity):
	tagEdit.clear()
	reconstruct_tree(treeWidget)
	selectTagBtn.set_meta('tag_id','NULL')
	_set_label_num()

# 如果按了删除按钮，删除这个节点以及其子节点
func _on_tag_del_button_pressed():
	var tag_del = selectTagBtn.get_meta('tag_id','NULL')
	if tag_del == 'NULL':
		pass
	else:
		# 找到id对应tagEn
		var tag_del_data = GlobalVariables.get_character_tag(tag_del)
		# 获得一下所有的子类
		children_list.append(tag_del)
		print(children_list)
		get_all_tag_children(tag_del_data)
		# 删除储存的数据
		GlobalVariables.del_character_tag(tag_del_data)
		GlobalVariables.save_character_tag_file()
		# 更新当前UI显示
		Signalbus.character_tag_deled.emit(tag_del_data)
		# 如果删除了，所有的笔记的tag也要跟着删除
		var character_id_list = Globalvariable.get_all_character_keys()
		for character_id in character_id_list:
			var characterEn1 = Globalvariable.get_character(character_id)
			if characterEn1.tag in children_list:
				characterEn1.tag = 'NULL'
				Globalvariable.add_character(characterEn1)
				Globalvariable.save_character_file()
		initiate_card()
		_set_label_num()
		children_list = []

# 获得一个tag的所有子类
@onready var children_list = []
func get_all_tag_children(tag_data:TagEntity):
	# 再去把子类删除了
	var children_id_list = tag_data.children_id
	if children_id_list.size()>0:
		for child_id in children_id_list:
			var child_data = GlobalVariables.get_character_tag(child_id)
			children_list.append(child_id)
			get_all_tag_children(child_data)

# 左上角的label数字修改
func _set_label_num():
	var tag_id_list = GlobalVariables.get_all_character_tag_keys()
	var tag_num_label = %tag_num_label
	tag_num_label.text = str(len(tag_id_list))

func _on_character_changed(msg):
	if msg == 'saved!':
		var index=0
		for i in Globalvariable.character_config_file.get_section_keys('character'):
			index+=1
	#这个是左上角的数字（动态统计）
		characternum.set_text(str(index))
	elif msg == 'deleted!':
		var index=0
		for i in Globalvariable.character_config_file.get_section_keys('character'):
			index+=1
	#这个是左上角的数字（动态统计）
		characternum.set_text(str(index))
		#initiate_card()
