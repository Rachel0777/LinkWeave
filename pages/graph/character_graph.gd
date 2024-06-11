extends Control
@onready var character=%GraphNode
@onready var graphnode=preload("res://pages/graph/graph_node.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func delete_all_nodes():
	# 遍历所有子节点
	for i in range(get_child_count()):
		var node = get_child(i)
		# 如果子节点是一个 GraphNode，就删除它
		if node is GraphNode:
			# 从场景中移除节点
			remove_child(node)
			# 释放节点资源
			node.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
