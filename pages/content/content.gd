extends Control
@onready var contenttext=%TextEdit
@onready var catalog=%Tree
@onready var clear=%clear
# ==日历部分==
@onready var calendar_container = %month_container
@onready var calendar_scene = preload('res://components/calendar/calendar_month.tscn')

#这段写的代码有些复杂，主要实现就是，如果某一行是以#开头就把它认为是某一章的标题，其余的为内容
func parse_textedit_to_dict(text: String) -> Dictionary:
	var content_dict = {}
	var lines = text.split("\n")
	var index=0
	var document=[]
	for line in lines:
		if line.begins_with('#'):
			document.append(index)
		index+=1
	index=0
	for i in document:
		var title=lines[i].get_slice('#',1)
		var from=document[index]+1
		var to1=0
		if index==document.size()-1:
			to1=lines.size()
		else:
			to1=document[index+1]
		var content=lines.slice(from,to1)
		var c1=''
		for j in content:
			c1=c1+j
		content_dict[title]=c1
		#c1就是那个每章节的内容
		index+=1
	return content_dict
#获取内容
func get_data():
	catalog.clear()
	var root=catalog.create_item()
	catalog.hide_root=true
	Globalvariable.load_content_file()
	var dict={}
	for i in Globalvariable.content_config_file.get_section_keys('content'):
		var key=i
		var value=Globalvariable.content_config_file.get_value('content',i)
		dict[key]=value
	for j in dict.keys():
		var item=catalog.create_item(root)
		item.set_text(0,j)
		
	
# 示例用法
func _ready():
	get_data()
	catalog.item_selected.connect(corrresponding)
	show_calendar()
	_set_label_num()
	# 删除memo
	Signalbus.inspiration_memo_deled.connect(_on_memo_deled)
	
#左侧是一个目录，点击某一个标题，右侧的textedit会显示哪一章的内容
func corrresponding():
	var chapter=catalog.get_selected()
	if chapter==null:
		return
	var chapter_name=chapter.get_text(0)
	var dict={}
	for i in Globalvariable.content_config_file.get_section_keys('content'):
		var key=i
		var value=Globalvariable.content_config_file.get_value('content',i)
		dict[key]=value
	for j in dict.keys():
		if chapter_name==j:
			var original_text = dict[j][j]
			var processed_text = ""
			var char_count = 0
			for i in range(original_text.length()):
				processed_text += original_text[i]
				char_count += 1
				if char_count == 53:
					processed_text += "\n"
					char_count = 0
			contenttext.text=processed_text
			%words_count.text=str(len(processed_text))
			break
#保存所写内容
func _on_save_pressed():
	var dictionary=parse_textedit_to_dict(contenttext.text)
	var title=dictionary.keys()[0]
	Globalvariable.load_content_file()
	Globalvariable.content_config_file.set_value('content',title,dictionary)
	Globalvariable.content_config_file.save(Globalvariable.CONTENT_FILE_PATH)
	%Label2.show()
	%Timer.start()
	get_data()
func _on_timer_timeout():
	%Label2.hide()

#清空textedit
func _on_clear_pressed():
	contenttext.clear()

# ==日历==
func show_calendar():
	clear_memo_container(calendar_container)
	var calendar_month = calendar_scene.instantiate()
	calendar_container.add_child(calendar_month)

# clear一下VBoxontainer
func clear_memo_container(container):
	for child in container.get_children():
		child.queue_free()

func _on_memo_deled(msg:String):
	if msg == 'memo deled':
		show_calendar()
		_set_label_num()
	
# 左上角的label数字修改
func _set_label_num():
	var memo_id_list = GlobalVariables.get_all_inspiration_memo_keys()
	var day_num_label = %day_num_label
	var date_list = []
	for memo_id in memo_id_list:
		var memoEn = GlobalVariables.get_inspiration_memo(memo_id)
		var date = memoEn.date
		var date_string = str(date.year)+'-'+str(date.month)+'-'+str(date.day)
		if date_string not in date_list:
			date_list.append(date_string)
	day_num_label.text = str(len(date_list))
