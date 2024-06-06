extends Resource

class_name MemoEntity

@export var id:String
@export var content:String
@export var book_id: String
@export var tag:String
@export var date:String
# 这个memo链接别人的memo
@export var linkout: Array[String]
# 这个memo被别人的memo链接
@export var linkin: Array[String]
# memo链接的文件
@export var file_path: Array[String]
