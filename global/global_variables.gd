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
	# 根据链接再更新，但是目前没做链接，先挖个坑

# 删除memo
func del_memo(memo_id:String):
	inspiration_memo_config_file.erase_section_key('inspiration_memo',memo_id)
	save_inspiration_memo_file()
