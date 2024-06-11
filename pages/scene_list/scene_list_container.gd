extends HBoxContainer

@export var sceneEn:SceneEntity

@onready var chapter_label = %chapter
@onready var place_label= %place
@onready var time_label =%time
@onready var event_label =%event
@onready var link_out_list = []
@onready var row_column_btn = %row_column_btn

# ==link链接部分==
# 首先是选择链接后展示
@onready var related_link_comp_scene = preload("res://components/link_out_stroll_container.tscn")
@onready var related_link_container = %link_out_vbox_container
@onready var link_out_btn = %link_out_button

func _ready():
	GlobalVariables.load_inspiration_memo_file()
	GlobalVariables.load_inspiration_tag_file()
	_set_scene()

# 设置一下memo的内容显示
func _set_scene():
	row_column_btn.text = str(GlobalVariables.find_scene_entity_index_by_id(sceneEn.id))
	chapter_label.text = sceneEn.chapter
	place_label.text = sceneEn.place
	time_label.text = sceneEn.time
	event_label.text = sceneEn.event
	# 显示链接linkout
	if len(sceneEn.linkout)!=0:
		for link_out in sceneEn.linkout:
			_add_related_link_ui(link_out)



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
	del_btn.hide()
	show_link_container.show()
	show_link_text.set_meta('link_id',link_out)
	var memoEn1 =GlobalVariables.get_inspiration_memo(link_out)
	show_link_text.text = GlobalVariables.get_link_text(memoEn1)
	related_link_container.add_child(link_container)

# 如果按了的话，显示所有linkout
func _on_link_out_button_pressed():
	var link_out_list = sceneEn.linkout
	Signalbus.window_close.emit('window open')
	Signalbus.inspiration_link_show.emit(link_out_list)

# 如果按了的话选中
func _on_row_column_btn_pressed():
	Signalbus.scene_list_clicked.emit(sceneEn)
