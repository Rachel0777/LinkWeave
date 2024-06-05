extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	var time = Time.get_time_dict_from_system()
	var date = "%d-%02d-%02d %02d:%02d:%02d" % [time["year"], time["month"], time["day"], time["hour"], time["minute"], time["second"]]
	print(date)
