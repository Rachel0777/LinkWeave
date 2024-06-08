extends Node

# 随机生成uuid
var uuid_util = preload("res://addon/uuid.gd")

#func _ready():
	#load_inspiration_memo_file()
	#load_inspiration_tag_file()

# == tag对应内容，可以复用 == 
# 生成tag对应的存储位置
const INSPIRATION_TAG_FILE_PATH = 'user://inspiration_tag.txt'
var inspiration_tag_config_file = ConfigFile.new()
# 加载tag文档
func load_inspiration_tag_file():
	inspiration_tag_config_file.clear()
	inspiration_tag_config_file.load(INSPIRATION_TAG_FILE_PATH)
# 保存tag文档
func save_inspiration_tag_file():
	inspiration_tag_config_file.save(INSPIRATION_TAG_FILE_PATH)
# 得到所有tag的id
func get_all_inspiration_tag_keys():
	load_inspiration_tag_file()
	return inspiration_tag_config_file.get_section_keys('inspiration_tag')
func get_inspiration_tag(id:String):
	return inspiration_tag_config_file.get_value('inspiration_tag',id)
# 添加tag
func add_inspiration_tag(tag_data:TagEntity):
	# 保存这一条数据
	inspiration_tag_config_file.set_value('inspiration_tag',tag_data.id,tag_data)
	# 判断是否有父类，如果有更新父类的子类
	if tag_data.parent_id!='NULL':
		# 更新父类
		var parent_data:TagEntity = get_inspiration_tag(tag_data.parent_id)
		parent_data.children_id.append(tag_data.id)
		# 覆盖之前父类的数据，从而更新子类
		inspiration_tag_config_file.set_value('inspiration_tag',tag_data.parent_id,parent_data)
# 删除tag
func del_inspiration_tag(tag_data:TagEntity):
	# 删除父类中的记录，如果有父节点以不做
	if tag_data.parent_id != 'NULL':
		inspiration_tag_erase_from_parent(tag_data.id,tag_data.parent_id)
	# 循环删除
	del_inspiration_tag_all_children(tag_data)
# 循环删除
func del_inspiration_tag_all_children(tag_data:TagEntity):
	# 首先把自己删除了
	inspiration_tag_config_file.erase_section_key('inspiration_tag',tag_data.id)
	# 再去把子类删除了
	var children_id_list = tag_data.children_id
	if children_id_list.size()>0:
		for child_id in children_id_list:
			var child_data = get_inspiration_tag(child_id)
			del_inspiration_tag_all_children(child_data)
# 删除父类中的记录
func inspiration_tag_erase_from_parent(current_id:String,parent_id):
	var parent_data:TagEntity = get_inspiration_tag(parent_id)
	print(parent_data.name)
	parent_data.children_id.erase(current_id)
	inspiration_tag_config_file.set_value('inspiration_tag',parent_id,parent_data)
# 获得这个tag的名字，包括其父类的名字
func get_tag_full_name(tag_id:String):
	if tag_id == null:
		pass
	else:
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

# == memo对应内容 ==
const INSPIRATION_MEMO_FILE_PATH = 'user://inspiration_memo.txt'
var inspiration_memo_config_file = ConfigFile.new()
# 加载memo文档
func load_inspiration_memo_file():
	inspiration_memo_config_file.clear()
	inspiration_memo_config_file.load(INSPIRATION_MEMO_FILE_PATH)
# 保存memo文档
func save_inspiration_memo_file():
	inspiration_memo_config_file.save(INSPIRATION_MEMO_FILE_PATH)
# 得到所有memo的id
func get_all_inspiration_memo_keys():
	load_inspiration_memo_file()
	return inspiration_memo_config_file.get_section_keys('inspiration_memo')
func get_inspiration_memo(id:String):
	return inspiration_memo_config_file.get_value('inspiration_memo',id)
# 添加memo
func add_inspiration_memo(memo_data:MemoEntity):
	# 保存这一条数据
	inspiration_memo_config_file.set_value('inspiration_memo',memo_data.id,memo_data)

# 删除memo
func del_memo(memo_id:String):
	inspiration_memo_config_file.erase_section_key('inspiration_memo',memo_id)
	save_inspiration_memo_file()

# ==link==
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
	
## 找到一个memoEn的所有linkin，即根据别的的linkout找
#func get_link_in(memo_id:String):
	#var link_in_list = []
	#var memo_id_list = get_all_inspiration_memo_keys()
	#for memo in memo_id_list:
		#var memoEn = get_inspiration_memo(memo)
		#var memo_link_out = memoEn.linkout
		#if memo_id in memo_link_out:
			#link_in_list.append(memo)
	#return link_in_list

# 更新别人的linkin，即新建了一个memo，有一个linkout，更新其他memo的linkin
func  update_other_link_in(memoEn:MemoEntity):
	var link_out_list = memoEn.linkout
	if len(link_out_list)!=0:
		for link_id in link_out_list:
			var memo_link_En = get_inspiration_memo(link_id)
			if memoEn.id not in memo_link_En.linkin:
				memo_link_En.linkin.append(memoEn.id)
			add_inspiration_memo(memo_link_En)

