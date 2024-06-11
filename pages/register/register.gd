extends Control
@onready var username=%usename
@onready var password=%password
@onready var btn=%Button
@onready var label=%Label2
@onready var target_scene=preload("res://pages/main/main.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

#验证登录信息
func _on_button_pressed():
	if username.text=="admin" and password.text=="123":
		var current_scene=get_tree().current_scene
		current_scene.queue_free()
		var new_scene=target_scene.instantiate()
		get_tree().root.add_child(new_scene)
		get_tree().current_scene=new_scene
	else:
		label.set_text("账号密码错误！")
		$Timer.start()



func _on_timer_timeout():
	label.hide()
