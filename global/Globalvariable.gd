extends Node

#人物有关的增删改查
const CHARACTER_FILE_PATH="user://character.txt"
var character_config_file=ConfigFile.new()
var character_loaded=false
var version_file = null
var FILE_VERSION_PATH = 'user://version.ini'
#定义一个用户文件夹中存储文件的地址
var img_dir = OS.get_user_data_dir()+'/imgs/'
func load_character_file():
	character_config_file.clear()
	character_config_file.load(CHARACTER_FILE_PATH)
	
func get_character(id:String):
	if not character_loaded:
		character_loaded=load_character_file()
	#获取的是当前新加的人物的entity
	return character_config_file.get_value('character',id)
func get_all_character_keys():
	if not character_loaded:
		character_loaded=load_character_file()
	return character_config_file.get_section_keys('character')

func add_character(characterdata:CharacterEntity):
	var exisits_character=get_character(characterdata.id)
	#按理说 exisits_character应该是空的，如果不是空的就把主键换成原来已有的id
	if exisits_character!=null:
		characterdata.id=exisits_character.id
	character_config_file.set_value('character',characterdata.id,characterdata)
func save_character_file():
	character_config_file.save(CHARACTER_FILE_PATH)
	Signalbus.character_file_changed.emit()
	Signalbus.file_changed.emit(CHARACTER_FILE_PATH.get_file())

var uuid_util = preload("res://addon/uuid.gd")

func update_img_file(imgfilename:String):
	var imgs = get_img_files()
	if imgfilename not in imgs:
		imgs.append(imgfilename)
	version_file.set_value('file','img',imgs)
	save_version_file()

func save_version_file():
	version_file.save(FILE_VERSION_PATH)
func get_img_files():
	return version_file.get_value('file','img',[])

func update_version_time():
	version_file.set_value('time','last',Time.get_unix_time_from_system())
	save_version_file()

func del_character(characterdata:CharacterEntity):
	character_config_file.erase_section_key('character',characterdata.id)

const CONTENT_FILE_PATH="user://content.txt"
var content_config_file=ConfigFile.new()
func load_content_file():
	content_config_file.clear()
	content_config_file.load(CONTENT_FILE_PATH)



