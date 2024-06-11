extends Control

@export var sceneEn:SceneEntity

@onready var chapter_edit = %chapter
@onready var place_edit = %place
@onready var time_edit =%time
@onready var event_edit =%event
@onready var scene_list_added_error = %error_msg

@onready var table_container = %TableContainer
@onready var head_container = %head_container
@onready var add_container = %add_container

@onready var scenePanelScene = preload('res://pages/scene_list/scene_list_container.tscn')

@onready var del_btn = %del_button
@onready var add_btn = %add_button

# ==链接部分==
# 首先是选择链接后展示
@onready var related_link_comp_scene = preload("res://components/link_out_stroll_container.tscn")
@onready var related_link_container = %scene_linkout_vboxcontainer
@onready var link_out_btn = %link_out_button
# 存储link_out的id
@onready var link_out_list : Array[String]

func _ready():
	show_all_scene()
	Signalbus.scene_list_clicked.connect(_on_scene_list_clicked)
	# ==下面是链接有关的==
	Signalbus.inspiration_link_add.connect(_on_link_added)
	Signalbus.inspiration_link_deled.connect(_on_link_deled)
	# 删除memo
	Signalbus.inspiration_memo_deled.connect(_on_memo_deled)

# 保存SceneEntity
func save_scene(scene_data:SceneEntity):
	GlobalVariables.add_scene_list(scene_data)
	GlobalVariables.save_scene_list_file()

# 获取一下内容
func get_scene_data()->SceneEntity:
	var sceneEn = SceneEntity.new()
	# uuid 动态生成id
	sceneEn.id = GlobalVariables.uuid_util.v4()
	sceneEn.book_id = 'NULL'
	sceneEn.chapter = chapter_edit.text
	sceneEn.place = place_edit.text
	sceneEn.time = time_edit.text
	sceneEn.event = event_edit.text
	# linkout设置一下
	sceneEn.linkout = link_out_list
	return sceneEn
		
# 看有没有空的
func validate_scene(scene_data:SceneEntity):
	if scene_data.chapter == '':
		return '章节'
	elif scene_data.place == '':
		return '地点'
	elif scene_data.time == '':
		return '时间'
	elif  scene_data.event =='':
		return '事件'
	else:
		return '没有问题'

# 清空一下
func clear_scene_list():
	chapter_edit.clear()
	place_edit.clear()
	time_edit.clear()
	event_edit.clear()

# 顺便清空一下linkout
func clear_scene_link_out():
	link_out_list=[]
	# UI也要清空
	for child in related_link_container.get_children():
		if child != link_out_btn:
			child.queue_free()
	link_out_btn.hide()

func _on_add_button_pressed():
	var scene_data = get_scene_data()
	var error = validate_scene(scene_data)
	if error == '没有问题':
		save_scene(scene_data)
		# 发送技能添加成功的信号
		Signalbus.scene_list_added.emit(scene_data)
		clear_scene_list()
		scene_list_added_error.hide()
		# 删除link，从UI到link_out_list
		clear_scene_link_out()
		show_all_scene()
	else:
		var error_show = error+'不能为空'
		scene_list_added_error.show()

# 显示所有scene
func show_all_scene():
	clear_scene_container(table_container)
	for scene_id in GlobalVariables.get_all_scene_list_keys():
		var scenePanel = scenePanelScene.instantiate()
		scenePanel.sceneEn = GlobalVariables.get_scene_list(scene_id)
		table_container.add_child(scenePanel)

func clear_scene_container(container):
	for child in container.get_children():
		if child != add_container and child !=head_container:
			child.queue_free()

func _on_scene_list_clicked(scene_data:SceneEntity):
	del_btn.set_meta('scene_id',scene_data.id)

func _on_del_button_pressed():
	var scene_id = del_btn.get_meta('scene_id','NULL')
	print(scene_id)
	if scene_id != 'NULL':
		var scene_data = GlobalVariables.get_scene_list(scene_id)
		GlobalVariables.del_scene_list(scene_data)
		show_all_scene()

# ==下面是和scene页面链接有关的==
# 点击链接图标，插入链接
func _on_scene_link_button_pressed():
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
	#sceneEn.linkout.erase(link_id)
	link_out_list.erase(link_id)
	if len(link_out_list) == 0:
		link_out_btn.hide()

# 点击这个button显示该memo的所有link
func _on_link_out_button_pressed():
	Signalbus.window_close.emit('window open')
	Signalbus.inspiration_link_show.emit(link_out_list)

func _on_memo_deled(msg:String):
	if msg == 'memo deled':
		show_all_scene()



