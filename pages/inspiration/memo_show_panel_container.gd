extends PanelContainer

@export var memoEn:MemoEntity

# 获得需要更新或者显示的组件
@onready var date_label = %inspiration_date
@onready var tag_label = %inspiration_tag_label
@onready var content_label = %memo_content

func _ready():
	_set_memo()
	# 下面的是修改MenuButton的PopUpMenu的，使其TransparentBG=true
	_apply_script_to_menubuttons(self)

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



