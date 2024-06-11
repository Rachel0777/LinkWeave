extends GraphNode

@export var charaEn:CharacterEntity
@onready var chara_name=%Label
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
#将node的名字设为人物的名字
func _set_node(characterdata:CharacterEntity,position:Vector2):
	chara_name.text=characterdata.cname
	set_name(characterdata.cname)
	set_slot(1,true,0,characterdata.color,true,0,characterdata.color)
	position_offset=position
