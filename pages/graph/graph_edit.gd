extends GraphEdit
@onready var graphnodetscn=preload("res://pages/graph/graph_node.tscn")
var nodesize=Vector2(120,140)
# Called when the node enters the scene tree for the first time.
func _ready():
	recontruct_graph()
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
#去存储character的文件里遍历每一个人物，看她和谁有联系
func recontruct_graph():
	delete_all_nodes()
	var graphnode:Array[CharacterEntity]
	for character_id in Globalvariable.get_all_character_keys():
		var character_data=Globalvariable.get_character(character_id)
		graphnode.append(character_data)
		_add_node(character_data)
	var k=0
	#children就是添加了几个子节点
	var children=get_children()
	var num=children.size()
	randomize()
	#随机生成位置
	var positions=generate_unique_positions(num)
	print(positions)
	for i in children:
		i._set_node(graphnode[k],positions[k])
		k+=1
	_linkwithnode()

func _add_node(character:CharacterEntity):
	var node=graphnodetscn.instantiate()
	add_child(node)
#保证所有节点不重叠
func generate_unique_positions(count):
	var positions=[]
	var used_positions={}
	while positions.size()<count:
		var pos=Vector2(randi()%900,randi()%900)
		var grid_pos=Vector2(floor(pos.x/nodesize.x),floor(pos.y/nodesize.y))
		if not used_positions.has(grid_pos):
			used_positions[grid_pos]=true
			positions.append(pos)
	return positions

func _linkwithnode():
	#character_data是characterentity类
	for character_id in Globalvariable.get_all_character_keys():
		var character_data=Globalvariable.get_character(character_id)
		var character_name=character_data.cname
		var related_who=character_data.realation_who
		connect_node(character_name,0,related_who,0)
