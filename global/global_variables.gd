extends Node

# 随机生成uuid
var uuid_util = preload("res://addon/uuid.gd")

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
	var memoEn = get_inspiration_memo(memo_id)
	# 把linkin对应删除一下
	if len(memoEn.linkout)!=0:
		for link_id in memoEn.linkout:
			var memo_linkEn = get_inspiration_memo(link_id)
			memo_linkEn.linkin.erase(memo_id)
			add_inspiration_memo(memo_linkEn)
			save_inspiration_memo_file()	
	# 如果有linkout对应也删一下
	if len(memoEn.linkin)!=0:
		for link_id in memoEn.linkin:
			var memo_linkEn = get_inspiration_memo(link_id)
			memo_linkEn.linkout.erase(memo_id)
			add_inspiration_memo(memo_linkEn)
			save_inspiration_memo_file()
	# 如果场景有对应的linkout也删一下
	var scene_id_list = get_all_scene_list_keys()
	for scene_id in scene_id_list:
		var sceneEn = get_scene_list(scene_id)
		if memo_id in sceneEn.linkout:
			sceneEn.linkout.erase(memo_id)
			add_scene_list(sceneEn)
			save_scene_list_file()
	inspiration_memo_config_file.erase_section_key('inspiration_memo',memo_id)
	save_inspiration_memo_file()

# ==link==
# link button显示的内容，包括date+tag+content
func get_link_text(memoEn:MemoEntity):
	var today = memoEn.date
	var today_string = str(today.year)+'-'+str(today.month)+'-'+str(today.day)+' '+str(today.hour)+':'+str(today.minute)+':'+str(today.second)
	var text =  today_string
	if memoEn.tag !='NULL':
		text= text +' #'+ get_tag_full_name(memoEn.tag)+' '
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
func update_other_link_in(memoEn:MemoEntity):
	var link_out_list = memoEn.linkout
	if len(link_out_list)!=0:
		for link_id in link_out_list:
			var memo_link_En = get_inspiration_memo(link_id)
			if memoEn.id not in memo_link_En.linkin:
				memo_link_En.linkin.append(memoEn.id)
			add_inspiration_memo(memo_link_En)

# == 日历有关 ==
func calendar_day_color(day1:Dictionary):
	var num = 0
	var memo_id_list = get_all_inspiration_memo_keys()
	for memo_id in memo_id_list:
		var memo:MemoEntity = GlobalVariables.get_inspiration_memo(memo_id)
		var date = memo.date
		if date.year == day1.year and date.month == day1.month and date.day == day1.day:
			num+=1
	return num

# == scene list对应内容 == 
const SCENE_LIST_FILE_PATH = 'user://scene_list.txt'
var scene_list_config_file = ConfigFile.new()
func load_scene_list_file():
	scene_list_config_file.clear()
	scene_list_config_file.load(SCENE_LIST_FILE_PATH)
func save_scene_list_file():
	scene_list_config_file.save(SCENE_LIST_FILE_PATH)
func get_all_scene_list_keys():
	load_scene_list_file()
	return scene_list_config_file.get_section_keys('scene_list')
func get_scene_list(id:String):
	return scene_list_config_file.get_value('scene_list',id)
func add_scene_list(scene_data:SceneEntity):
	# 保存这一条数据
	scene_list_config_file.set_value('scene_list',scene_data.id,scene_data)
func del_scene_list(scene_data:SceneEntity):
	scene_list_config_file.erase_section_key('scene_list',scene_data.id)
	save_scene_list_file()
# 需要一个行数，所以用这个
func find_scene_entity_index_by_id(target_id: String) -> int:
	var scene_id_list = get_all_scene_list_keys()
	for i in range(len(scene_id_list)):
		var sceneEn = get_scene_list(scene_id_list[i])
		if sceneEn.id == target_id:
			return i+1
	return -1

# == tag对应内容，可以复用 == 
# 生成tag对应的存储位置
const CHARACTER_TAG_FILE_PATH = 'user://character_tag.txt'
var character_tag_config_file = ConfigFile.new()
# 加载tag文档
func load_character_tag_file():
	character_tag_config_file.clear()
	character_tag_config_file.load(CHARACTER_TAG_FILE_PATH)
# 保存tag文档
func save_character_tag_file():
	character_tag_config_file.save(CHARACTER_TAG_FILE_PATH)
# 得到所有tag的id
func get_all_character_tag_keys():
	load_character_tag_file()
	return character_tag_config_file.get_section_keys('character_tag')
func get_character_tag(id:String):
	return character_tag_config_file.get_value('character_tag',id)
# 添加tag
func add_character_tag(tag_data:TagEntity):
	# 保存这一条数据
	character_tag_config_file.set_value('character_tag',tag_data.id,tag_data)
	# 判断是否有父类，如果有更新父类的子类
	if tag_data.parent_id!='NULL':
		# 更新父类
		var parent_data:TagEntity = get_character_tag(tag_data.parent_id)
		parent_data.children_id.append(tag_data.id)
		# 覆盖之前父类的数据，从而更新子类
		character_tag_config_file.set_value('character_tag',tag_data.parent_id,parent_data)
# 删除tag
func del_character_tag(tag_data:TagEntity):
	# 删除父类中的记录，如果有父节点以不做
	if tag_data.parent_id != 'NULL':
		character_tag_erase_from_parent(tag_data.id,tag_data.parent_id)
	# 循环删除
	del_character_tag_all_children(tag_data)
# 循环删除
func del_character_tag_all_children(tag_data:TagEntity):
	# 首先把自己删除了
	character_tag_config_file.erase_section_key('character_tag',tag_data.id)
	# 再去把子类删除了
	var children_id_list = tag_data.children_id
	if children_id_list.size()>0:
		for child_id in children_id_list:
			var child_data = get_character_tag(child_id)
			del_character_tag_all_children(child_data)
# 删除父类中的记录
func character_tag_erase_from_parent(current_id:String,parent_id):
	var parent_data:TagEntity = get_character_tag(parent_id)
	print(parent_data.name)
	parent_data.children_id.erase(current_id)
	character_tag_config_file.set_value('character_tag',parent_id,parent_data)
# 获得这个tag的名字，包括其父类的名字
func get_tag_full_name_character(tag_id:String):
	if tag_id == null:
		pass
	else:
		var current_tag = GlobalVariables.get_character_tag(tag_id)
		var tag_names = []
		while current_tag != null:
			tag_names.append(current_tag.name)
			current_tag = GlobalVariables.get_character_tag(current_tag.parent_id)
		var tag_name = ""
		for i in range(tag_names.size() - 1, -1, -1):
			if i!=0:
				tag_name += tag_names[i] + "/"
		tag_name += tag_names[0]
		return tag_name
