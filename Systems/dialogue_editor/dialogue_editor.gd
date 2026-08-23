extends Control
class_name DialogueEditor

@onready var graph: GraphEdit = $GraphEdit
@export var dialogue_node_scene: PackedScene
var dialogue_node: DialogueNode
var dialogue_nodes: Dictionary[String, dialogue_node_editor_data] = {}
var visual_nodes: Dictionary[String, DialogueNodeVisual] = {}



func _ready():
	graph.gui_input.connect(_on_graph_gui_input)
	graph.connection_request.connect(_on_connection_request)
	$save_button.pressed.connect(_on_save_button_pressed)
	
func _on_save_button_pressed():
	save_dialogue()
	print("Dialogue Saved!")
	
func _on_connection_request(
	from_node: StringName, from_port: int, to_node: StringName, to_port: int): 
		graph.connect_node(from_node, from_port, to_node, to_port)
	
func load_tree(tree: DialogueTree):
	for node in tree.get_tree_nodes():
		var data := dialogue_node_editor_data.from_dialogue_node(node)
		var visual := dialogue_node_scene.instantiate() as DialogueNodeVisual
		graph.add_child(visual)
		visual.setup(data)
		visual.position_offset = Vector2(
			randi() % 100,
			randi() % 100
		)
		dialogue_nodes[data.get_id_as_string()] = data
		visual_nodes[data.get_id_as_string()] = visual
		
func create_node(position: Vector2):
	if dialogue_node_scene == null:
		push_error("Error! Dialogue node visual node not configured on editor.")
		return
	var node := dialogue_node_editor_data.new()
	node.set_id("node_%d" % dialogue_nodes.size())
	node.set_speaker_name("")
	node.set_content("")
	var visual_node := dialogue_node_scene.instantiate() as DialogueNodeVisual
	graph.add_child(visual_node)
	visual_node.setup(node)
	visual_node.position_offset = position
	dialogue_nodes[node.get_id_as_string()] = node
	visual_nodes[node.get_id_as_string()] = visual_node
		
func save_dialogue():
	var output = {
		"tree_id":"example",
		"nodes":[]
	}
	for id in dialogue_nodes:
		var data = dialogue_nodes[id]
		var visual = visual_nodes[id]
		output.nodes.append({
			"id": data.get_id_as_string(),
			"speaker_name": data.get_speaker_name(),
			"content": data.get_content(),
			"position":{
				"x": visual.position_offset.x,
				"y": visual.position_offset.y
			},
			"choices":[]
		})		
		var file = FileAccess.open(
			"res://dialogue.json",
			FileAccess.WRITE
		)

		file.store_string(JSON.stringify(output,"\t"))
		
	var file = FileAccess.open(
		"res://dialogue.json",
		FileAccess.WRITE
	)
	file.store_string(
		JSON.stringify(output, "\t")
	)
	file.close()	
	
func remove_visual_node(node : DialogueNodeVisual):
	var id = node.editor_data.get_id_as_string()
	dialogue_nodes.erase(id)
	visual_nodes.erase(id)
	node.queue_free()
		
func _on_graph_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			create_node(graph.scroll_offset + event.position / graph.zoom)
			
	if event.is_action_pressed("ui_text_delete"):
		for node in graph.get_children():
			if node is GraphNode and node.selected:
				remove_visual_node(node)	
				
