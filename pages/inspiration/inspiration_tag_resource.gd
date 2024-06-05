extends Resource

class_name TagEntity

# tag的id
@export var id:String
# tag的name
@export var name:String
# tag的父类
@export var parent_id:String
# tag的子类
@export var children_id:Array[String]
