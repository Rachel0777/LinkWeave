extends VBoxContainer

@onready var link_button = %link_button
@onready var link_text_edit = %link_text
# 错误信息
@onready var link_error_msg = %link_input_error
@onready var add_link_container = %add_link_container
@onready var show_link_container = %show_link_container

func _ready():
	GlobalVariables.load_inspiration_memo_file()
	GlobalVariables.load_inspiration_tag_file()

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

# 点击这个button，加入一个链接
func _on_link_add_button_pressed():
	var link_id = link_text_edit.text
	var memo_all_id = GlobalVariables.get_all_inspiration_memo_keys()
	# id正确，成功添加
	if link_id in memo_all_id:
		link_error_msg.hide()
		var memoEn = GlobalVariables.get_inspiration_memo(link_id)
		link_button.text = get_link_text(memoEn)
		add_link_container.hide()
		show_link_container.show()
		Signalbus.inspiration_link_add.emit(link_id)
		# 把元数据赋到button上，这样可以知道这个link的id
		link_button.set_meta('link_id',link_id)
	# id错误，添加失败，弹出错误信息
	else:
		link_error_msg.show()

# 删除该条链接
func _on_del_button_pressed():
	var link_id = link_button.get_meta('link_id')
	# 把链接的id传递给主页面，方便删除
	Signalbus.inspiration_link_deled.emit(link_id)
	# 从父类里把自己删掉
	self.queue_free()
