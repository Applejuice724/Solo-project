extends Control
class_name DialogueEditor

const SAVE_PATH := "res://Dialogue.json"

@onready var graph: GraphEdit = $GraphEdit
@onready var add_node_button: Button = $Toolbar/AddNodeButton
@onready var save_button: Button = $Toolbar/SaveButton
@export var dialogue_node_scene: PackedScene
@export var tree_id: String = "example"
var dialogue_node: DialogueNode
var dialogue_nodes: Dictionary[String, dialogue_node_editor_data] = {}
var visual_nodes: Dictionary[String, DialogueNodeVisual] = {}


func _ready():
	graph.gui_input.connect(_on_graph_gui_input)
	graph.connection_request.connect(_on_connection_request)
	add_node_button.pressed.connect(_on_add_node_button_pressed)
	save_button.pressed.connect(_on_save_button_pressed)


func _on_add_node_button_pressed():
	var position := graph.scroll_offset + graph.size * 0.5 / graph.zoom
	create_node(position)


func _on_save_button_pressed():
	if save_dialogue():
		print("Dialogue saved to " + SAVE_PATH)


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
		data.set_editor_position(visual.position_offset)
		dialogue_nodes[data.get_id_as_string()] = data
		visual_nodes[data.get_id_as_string()] = visual


func create_node(position: Vector2):
	if dialogue_node_scene == null:
		push_error("Error! Dialogue node visual node not configured on editor.")
		return
	var node := dialogue_node_editor_data.new()
	node.set_id(_generate_node_id())
	node.set_speaker_name("")
	node.set_content("")
	var visual_node := dialogue_node_scene.instantiate() as DialogueNodeVisual
	graph.add_child(visual_node)
	visual_node.setup(node)
	visual_node.position_offset = position
	node.set_editor_position(position)
	dialogue_nodes[node.get_id_as_string()] = node
	visual_nodes[node.get_id_as_string()] = visual_node


func save_dialogue() -> bool:
	var output := {
		"tree_id": tree_id,
		"nodes": []
	}
	for id in dialogue_nodes:
		var data := dialogue_nodes[id]
		var visual := visual_nodes[id]
		visual.sync_data_from_inputs()
		data.set_editor_position(visual.position_offset)
		var node_data: Dictionary = {
			"id": data.get_id_as_string(),
			"speaker_name": data.get_speaker_name(),
			"speaker_icon": data.get_speaker_icon_path(),
			"content": data.get_content(),
			"next_node_id": _get_next_node_id_for_visual(visual),
			"choices": _serialize_choices(data.get_choices()),
			"position": {
				"x": visual.position_offset.x,
				"y": visual.position_offset.y
			}
		}
		var conditions := _serialize_conditions(data.get_conditions())
		if not conditions.is_empty():
			node_data["conditions"] = conditions
		var actions := _serialize_actions(data.get_actions())
		if not actions.is_empty():
			node_data["actions"] = actions
		var events := _serialize_events(data.get_dialogue_events())
		if not events.is_empty():
			node_data["events"] = events
		var branches := _serialize_branches(data.get_branches())
		if not branches.is_empty():
			node_data["branches"] = branches
		if not data.get_resolve_branches_after_display():
			node_data["resolve_branches_after_display"] = false
		output["nodes"].append(node_data)

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open " + SAVE_PATH + " for writing.")
		return false
	file.store_string(JSON.stringify(output, "\t"))
	file.close()
	return true


func _generate_node_id() -> String:
	var index := dialogue_nodes.size()
	var new_id := "node_%d" % index
	while dialogue_nodes.has(new_id):
		index += 1
		new_id = "node_%d" % index
	return new_id


func _get_next_node_id_for_visual(visual: DialogueNodeVisual):
	for connection in graph.get_connection_list():
		if connection["from_node"] == visual.name:
			var target := graph.get_node_or_null(
				NodePath(connection["to_node"])
			) as DialogueNodeVisual
			if target != null and target.editor_data != null:
				return target.editor_data.get_id_as_string()
	return null


func _serialize_choices(choices: Array[DialogueChoice]) -> Array:
	var result: Array = []
	for choice in choices:
		var choice_data: Dictionary = {
			"choice_id": choice.get_choice_id(),
			"display_text": choice.get_node_selection_text(),
			"next_node_id": choice.get_next_node_id(),
			"is_visible": choice.is_visible()
		}
		var conditions := _serialize_conditions(choice.get_conditions())
		if not conditions.is_empty():
			choice_data["conditions"] = conditions
		var actions := _serialize_actions(choice.get_actions())
		if not actions.is_empty():
			choice_data["actions"] = actions
		result.append(choice_data)
	return result


func _serialize_conditions(conditions: Array[DialogueCondition]) -> Array:
	var result: Array = []
	for condition in conditions:
		result.append({
			"type": _condition_type_to_string(condition.get_condition_type()),
			"key": condition.get_key(),
			"value": condition.get_value()
		})
	return result


func _serialize_actions(actions: Array[DialogueAction]) -> Array:
	var result: Array = []
	for action in actions:
		result.append({
			"type": action.get_type(),
			"key": action.get_key(),
			"value": action.get_value()
		})
	return result


func _serialize_events(events: Array[DialogueEvent]) -> Array:
	var result: Array = []
	if events == null:
		return result
	for event in events:
		var event_data: Dictionary = {
			"type": _event_type_to_string(event.type),
			"index": event.index
		}
		if event is DialogueSoundEvent:
			var sound_event := event as DialogueSoundEvent
			event_data["audio_path"] = sound_event.audio_path
			event_data["volume_db"] = sound_event.volume_db
			event_data["pitch_scale"] = sound_event.pitch_scale
		result.append(event_data)
	return result


func _serialize_branches(branches: Array[DialogueBranch]) -> Array:
	var result: Array = []
	for branch in branches:
		result.append({
			"next_node_id": branch.get_next_node_id(),
			"priority": branch.get_priority(),
			"conditions": _serialize_conditions(branch.get_conditions())
		})
	return result


func _condition_type_to_string(condition_type: int) -> String:
	match condition_type:
		DialogueCondition.ConditionType.BOOL_EQUALS:
			return "bool_equals"
		DialogueCondition.ConditionType.INT_EQUALS:
			return "int_equals"
		DialogueCondition.ConditionType.INT_GREATER:
			return "int_greater"
		DialogueCondition.ConditionType.INT_LESS:
			return "int_less"
		DialogueCondition.ConditionType.INT_GREATER_OR_EQUAL:
			return "int_greater_or_equal"
		DialogueCondition.ConditionType.INT_LESS_OR_EQUAL:
			return "int_less_or_equal"
		_:
			return "bool_equals"


func _event_type_to_string(event_type: int) -> String:
	match event_type:
		DialogueEvent.EventType.SOUND:
			return "sound"
		DialogueEvent.EventType.CAMERA:
			return "camera_shake"
		DialogueEvent.EventType.ANIMATION:
			return "animation"
		_:
			return "custom"


func remove_visual_node(node: DialogueNodeVisual):
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
