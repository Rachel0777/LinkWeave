extends ScrollContainer


@export var characterEntity:CharacterEntity
@onready var cname=%name
@onready var nickname=%nickname
@onready var gender=%gender
@onready var age=%age
@onready var appearance=%appearance
@onready var personality=%personality
@onready var background=%background
@onready var character= preload("res://pages/character_card/sub_character.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
func _set_character(character:CharacterEntity):
	#cname.set_meta('character_id',character.id)
	cname.text=character.cname
	nickname.text=character.nickname
	gender.text=character.gender
	age.text=character.age
	appearance.text=character.appearance
	personality.text=character.personality
	background.text=character.background

func _get_character_entity():
	characterEntity = CharacterEntity.new()
	characterEntity.cname=cname.text
	characterEntity.nickname=nickname.text
	characterEntity.gender=gender.text
	characterEntity.age=age.text
	characterEntity.appearance=appearance.text
	characterEntity.personality=personality.text
	characterEntity.background=background.text	
	
	return characterEntity

func _refresh_characterEn():
	if characterEntity == null:
		characterEntity=CharacterEntity.new()
		characterEntity.id=Globalvariable.uuid_util.v4()
	characterEntity.cname=cname.text
	characterEntity.nickname=nickname.text
	characterEntity.gender=gender.text
	characterEntity.age=age.text
	characterEntity.appearance=appearance.text
	characterEntity.personality=personality.text
	characterEntity.background=background.text
	return characterEntity
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_delete_pressed():
	Signalbus.character_deled.emit(_get_character_entity())
	self.queue_free()


func _on_save_pressed():
	_refresh_characterEn()
	%msg_label.show()
	Signalbus.character_added.emit(characterEntity)
	Globalvariable.save_character(characterEntity)
	%Timer.start()
func _on_timer_timeout():
	%msg_label.hide()
