extends Control

@onready var shrinkBtn=%shrinkbutton
@onready var animation_shrink=%shrink
@onready var creation=%creation
@onready var character=%character
@onready var memo=%memo
@onready var home=%home
@onready var menu=%menu
var target_character=preload("res://pages/character_card/character_card.tscn")
var target_content=preload("res://pages/content/content.tscn")
var book_scene=preload("res://pages/home/home.tscn")
var inspiration_scene = preload("res://pages/inspiration/inspiration.tscn")
var list_scene = preload("res://pages/scene_list/scene_list.tscn")

func _ready():
	pass
#缩小动画
func _on_shrinkbutton_pressed():
	animation_shrink.play("shrink")
#扩展动画
func _on_texture_button_pressed():
	%expand.play('expand')

#跳转到人物页面
func _on_character_pressed():
	var children=menu.get_children()
	for child in children:
		remove_child(child)
		child.queue_free()
	var character_scene_scene=target_character.instantiate()
	menu.add_child(character_scene_scene)


#跳转到创作页面
func _on_creation_pressed():
	var children=menu.get_children()
	for child in children:
		remove_child(child)
		child.queue_free()
	var content_scene_scene=target_content.instantiate()
	menu.add_child(content_scene_scene)

#跳转到首页
func _on_home_pressed():
	var children=menu.get_children()
	for child in children:
		remove_child(child)
		child.queue_free()
	var book=book_scene.instantiate()
	menu.add_child(book)

func _on_memo_pressed():
	var children=menu.get_children()
	for child in children:
		remove_child(child)
		child.queue_free()
	var inspiration=inspiration_scene.instantiate()
	menu.add_child(inspiration)

func _on_outline_pressed():
	var children=menu.get_children()
	for child in children:
		remove_child(child)
		child.queue_free()
	var inspiration=list_scene.instantiate()
	menu.add_child(inspiration)
