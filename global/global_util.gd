extends Node
class_name GlobalUtil
static func create_texture_from_absolute_path(path:String):
	return ImageTexture.create_from_image(Image.load_from_file(path))
static func copy_img_to_user_dir(img_path):
	return copy_file_to_dir(img_path, Globalvariable.img_dir).replace(OS.get_user_data_dir(),'user:/')

static func copy_file_to_dir(from:String, to_dir:String):
	if not from.is_absolute_path():
		from = ProjectSettings.globalize_path(from)
	
	if not to_dir.is_absolute_path():
		to_dir = ProjectSettings.globalize_path(to_dir)
	
	if not DirAccess.dir_exists_absolute(to_dir):
		DirAccess.make_dir_absolute(to_dir)
	
	var to_target = to_dir+from.get_file()
	DirAccess.copy_absolute(from, to_target)
	return to_target
