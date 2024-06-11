extends Control

@onready var book=preload("res://pages/home/book.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_texture_button_pressed():
	var book_=book.instantiate()
	$PanelContainer/VBoxContainer/HBoxContainer.add_child(book_)
