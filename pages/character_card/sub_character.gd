extends Control
@export var characterEntity:CharacterEntity
@onready var cname=%name
@onready var nickname=%nickname
@onready var gender=%gender
@onready var age=%age
@onready var appearance=%appearance
@onready var personality=%personality
@onready var background=%background
@onready var save_button=%save
@onready var delete_button=%delete
@onready var picture=%FileDialog
@onready var towho=%rewho
@onready var redetail=%redetail
@onready var tag_optionbtn=%tag
var img_path=''
var relation_towho=''
var tag=''
const  CHARA_ADDED_ERROR_NO_NAME = 1
const  CHARA_ADDED_ERROR_NO_DES = 2
const  CHARA_ADDED_VALIDATED = 3

# 这个主要是选择标签
@onready var popup_menu_tag = %popup_menu_tag_tree
@onready var popup_tree = %popup_tag_tree
@onready var button_tag = %tag_button
@onready var popup_menu = button_tag.get_popup()
@onready var character_tag_button = %character_tag_button

func _ready():
	# 下面的是修改MenuButton的PopUpMenu的，使其TransparentBG=true
	_apply_script_to_menubuttons(self)
	GlobalVariables.load_character_tag_file()
	Globalvariable.load_character_file()
	get_character_item()
	init_menu_btn()
	
#初始化两个optionbutton
func get_character_item():
	Globalvariable.load_character_file()
	for i in Globalvariable.character_config_file.get_section_keys('character'):
		var cEn=Globalvariable.character_config_file.get_value('character',i)
		#print(cEn.cname)
		towho.add_item(cEn.cname)

func generate_character_id():
	return Globalvariable.uuid_util.v4()
#如果要改也要新增一个参数 tag:TagEntity，还有那个颜色想想办法
func get_character_data(cname:LineEdit,nickname:LineEdit,gender:LineEdit,age:LineEdit,appearance:TextEdit,background:TextEdit,personality:TextEdit,picture,relation_detail:LineEdit,relation_who:String,newID:bool=true):
	Globalvariable.load_character_file()
	var CharaEn=CharacterEntity.new()
	#要修改这个newid的判定
	
	if newID:
		CharaEn.id=generate_character_id()
	else:
		CharaEn.id=cname.get_meta('character_id')
		pass
	relation_towho=towho.get_item_text(towho.get_selected())
	#tag=tag_optionbtn.get_item_text(tag_optionbtn.get_selected())
	#要根据这个tag的名称返回TagEntity
	#CharaEn.tag=
	CharaEn.cname=cname.text
	CharaEn.nickname=nickname.text
	CharaEn.gender=gender.text
	CharaEn.age=age.text
	CharaEn.appearance=appearance.text
	CharaEn.background=background.text
	CharaEn.personality=personality.text
	CharaEn.img_path=picture
	CharaEn.relationdetail=redetail.text
	CharaEn.realation_who=relation_towho
	var tag_name=button_tag.get_meta('tag_id','NULL')
	CharaEn.tag =tag_name
	var tagEn=GlobalVariables.get_character_tag(tag_name)
	#这个color就要改
	if tagEn!=null:  
		CharaEn.color=tagEn.color
	return CharaEn
	
#保存人物
func _on_save_pressed():
	var name_group:Array[String]
	Globalvariable.load_character_file()
	#section_keys获得的就是id get_value是实际的characterentity
	for i in Globalvariable.character_config_file.get_section_keys('character'):
		var cEn=Globalvariable.character_config_file.get_value('character',i)
		name_group.append(cEn.cname)
	#都是默认为true了！
	var character_data=get_character_data(cname,nickname,gender,age,appearance,background,personality,img_path,redetail,relation_towho)
	if character_data.cname in name_group:
		character_data=get_character_data(cname,nickname,gender,age,appearance,background,personality,img_path,redetail,relation_towho,false)
	save_character_data(character_data)
	Signalbus.character_changed.emit('saved!')

func save_character_data(characterdata:CharacterEntity):
	cname.set_meta('character_id',characterdata.id)
	var validate_result=validate(characterdata)
	if validate_result==CHARA_ADDED_VALIDATED:
		save_character(characterdata)
		%right_ins.show()
		%Timer.start()
	else:
		%wrong_ins.show()
		%Timer.start()
func _on_timer_timeout():
	%right_ins.hide()
	%wrong_ins.hide()
	%picture_format.hide()
func save_character(characterdata:CharacterEntity):
	Globalvariable.add_character(characterdata)
	Globalvariable.save_character_file()
#姓名和性格不能为空
func validate(characterdata:CharacterEntity):
	if characterdata.cname=='':
		return CHARA_ADDED_ERROR_NO_NAME
	elif characterdata.personality=='':
		return CHARA_ADDED_ERROR_NO_DES
	return CHARA_ADDED_VALIDATED
#删除人物
func _on_delete_pressed():
	self.queue_free()
	var characterdata=get_character_data(cname,nickname,gender,age,appearance,background,personality,img_path,redetail,relation_towho,false)
	Globalvariable.del_character(characterdata)
	Globalvariable.save_character_file()
	Signalbus.character_changed.emit('deleted!')

#显示人物的照片
func _on_texture_button_pressed():
	picture.show()

func _on_file_dialog_file_selected(path):
	if not path.get_extension() in ['png','svg','jpg','jpeg']:
		%picture_format.show()
		%Timer.start()
	img_path=global_util.copy_img_to_user_dir(path)
	_set_character_img(img_path)
	
func _set_character_img(img_path:String):
	var texture=global_util.create_texture_from_absolute_path(img_path)
	%TextureButton.texture_normal=texture
	%TextureButton.texture_pressed=texture
	%TextureButton.texture_hover=texture
	%TextureButton.texture_focused=texture

func _set_character(characterdata:CharacterEntity):
	_set_character_img(characterdata.img_path)
	cname.text=characterdata.cname
	age.text=characterdata.age
	appearance.text=characterdata.appearance
	background.text=characterdata.background
	personality.text=characterdata.personality
	nickname.text=characterdata.nickname
	gender.text=characterdata.gender
	redetail.text=characterdata.relationdetail
	for i in towho.get_item_count():
		if towho.get_item_text(i)==characterdata.realation_who:
			towho.select(i)
			break
	if characterdata.tag != "NULL":
		button_tag.show()
		button_tag.text = '# ' + GlobalVariables.get_tag_full_name_character(characterdata.tag)
		character_tag_button.hide()
	else:
		button_tag.hide()
		character_tag_button.show()

func _on_character_tag_button_pressed():
	if not popup_menu_tag.visible:
		reconstruct_tree(popup_tree)
		popup_menu_tag.show()
		button_tag.show()
		character_tag_button.hide()

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

# 选择了一个tag之后加入
func _on_popup_tag_tree_item_selected():
	var selected_item = popup_tree.get_selected()
	if selected_item:
		var tag_id = selected_item.get_metadata(0)
		# 把这个标签的id存到button_tag里了，之后就可以很方便的通过button_tag存一下
		button_tag.set_meta('tag_id',tag_id)
		button_tag.text = '# '+ GlobalVariables.get_tag_full_name_character(tag_id)
		popup_menu_tag.hide()
	
# 修改灵感录入时的标签，0是修改，1是删除
func _on_menu_item_clicked(id:int):
	# 删除
	if id==1:
		clear_character_tag()
		character_tag_button.show()
	# 修改
	elif id==0:
		## 获取按钮的全局位置
		#var button_tag_global_position = button_tag.get_global_position()
		## 获取按钮的尺寸
		#var button_tag_size = 30
		## 计算 PopupMenu 的新位置，使其位于按钮的正下方
		#var popup_x = button_tag_global_position.x
		#var popup_y = button_tag_global_position.y + button_tag_size
		## 将新位置转换为相对于 PopupMenu 父节点的局部位置
		#var parent_node = popup_menu_tag.get_parent()
		#var popup_local_position = parent_node.to_local(Vector2(popup_x, popup_y))
		## 设置 PopupMenu 的位置
		#popup_menu_tag.rect_position = popup_local_position
		button_tag.set_meta('tag_id','NULL')
		button_tag.text = '#'
		if not popup_menu_tag.visible:
			reconstruct_tree(popup_tree)
			popup_menu_tag.show()
		
# 清除灵感上面添加的tag
func clear_character_tag():
	# 先得把button上的Meta给清掉
	button_tag.set_meta('tag_id','NULL')
	button_tag.text = '#'
	# 之后button和PopUpMenu全部收起来
	button_tag.hide()
	popup_menu_tag.hide()
	character_tag_button.show()

# 做一些关于menu_button的初始化
func init_menu_btn():
	var popMenu = button_tag.get_popup()
	popMenu.index_pressed.connect(_on_menu_item_clicked)
		
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
