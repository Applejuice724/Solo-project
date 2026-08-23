extends Node
# TODO
# - Look into editor tooling for easier script creation
# - Make each parse step it's own function

## DialogueLoader loads the raw dialogue from the JSON and creates 
## dialogue nodes from that data. As well as any choice dialogues that will be
## attatched to a dialogue node
class_name DialogueLoader

## Extracts values from dialogue file and converts them into dialogue nodes
##
## @param file_path the path to the JSON file as a string
func load_dialogue(file_path: String) -> DialogueTree:
	var parse_result = _load_json_with_comments(file_path)
	#print(parse_result)
	# If the parse fails return null
	if parse_result == null:
		return null
	var _nodes: Array[DialogueNode] = []
	
	var tree_id = parse_result.get("tree_id", "unknown_tree")
	var raw_nodes = []
	if parse_result.has("nodes"):
		raw_nodes = parse_result["nodes"]
	elif parse_result.has("id"):
		raw_nodes = [parse_result]
	else:
		push_error("Invalid dialogue format")
		return null
	
	for node_dict in raw_nodes:
		if typeof(node_dict) == TYPE_DICTIONARY:
			_nodes.append(_create_node(node_dict))			
		else:				
			push_error("Invalid node format, expected Dictionary")
	_connect_dialogue_nodes(_nodes)
	
	if _nodes.is_empty():
		push_error("Error! No nodes found in dialogue JSON file")
	return DialogueTree.new(tree_id, _nodes, file_path)


## Returns a new DialogueNode from a dictionary of data.
## Linking to next nodes is not done here, so next_node index will be -1 initially.
## Converts any choices in 'choices' to DialogueChoice objects.
##
## @param node_info Dictionary containing node fields and choices
func _create_node(node_info: Dictionary) -> DialogueNode:
	var id = node_info.get("id", "")
	var speaker_name = node_info.get("speaker_name", "")
	var speaker_icon_path = node_info.get("speaker_icon", "")
	var content = node_info.get("content", "")
	var next_node = node_info.get("next_node_id", "")
	if next_node == null:
		next_node = ""
	var raw_choices = node_info.get("choices", [])
	var choices : Array[DialogueChoice] = []
	# parse conditions and actions
	var conditions :  Array[DialogueCondition] = _parse_conditions(
		node_info.get("conditions", []))
		
	# If there are any choices, list them. If blank use next_node for next dialogue
	for choice_dict in raw_choices:
		var choice_conditions = _parse_conditions(choice_dict.get("conditions", []))
		var choice_actions = _parse_actions(choice_dict.get("actions", []))
		
		var choice = DialogueChoice.new(
			choice_dict.get("choice_id", ""),
			choice_dict.get("next_node_id", ""),
			choice_dict.get("display_text", ""),
			choice_dict.get("is_visible", true),
			choice_conditions,
			choice_actions
		)
		#print("NODE RAW:", node_info)
		#print("ACTIONS RAW:", node_info.get("actions"))
		#print("CHOICE RAW:", choice_dict)
		#print("CHOICE ACTIONS RAW:", choice_dict.get("actions"))
		choices.append(choice)
	var node_condition = _parse_conditions(node_info.get("conditions", []))
	var node_action = _parse_actions(node_info.get("actions", []))
	var raw_branches = node_info.get("branches", [])
	var branches = _parse_branches(raw_branches)
	var resolve_branches_after_display = node_info.get("resolve_branches_after_display", true)
	var node = DialogueNode.new(id, speaker_name, speaker_icon_path,
		content, next_node, choices, node_condition, node_action, branches, resolve_branches_after_display)
	var raw_events = node_info.get("events", [])
	
	node.set_dialogue_events(_parse_events(raw_events))
	return node
	
	
## Connects dialogue nodes
## Iterates through each node to set the next node index and connect choices
## @param node_dictionary the dictionary of nodes to iterate over each to connect
func _connect_dialogue_nodes(node_array: Array[DialogueNode]) -> void:
	var id_to_index := {}	
	for i in range(node_array.size()):
		id_to_index[node_array[i].get_id_as_string()] = i
		
	# Assign index
	for node in node_array:
		var next_id = node.get_next_node_as_string()
		if id_to_index.has(next_id):
			node.set_next_node_as_index(id_to_index[next_id])
			
	# Assign index to choices
	for node in node_array:
		for choice in node.get_choices():
			var choice_next_id = choice.get_next_node_id()
			if id_to_index.has(choice_next_id):
				choice.set_next_node_as_index(id_to_index[choice_next_id])
			else:
				push_warning("Missing choice node ID: " + choice_next_id)
	
	# Connect branches
	for node in node_array:
		for branch in node.get_branches():
			var branch_next_id = branch.get_next_node_id()

			if id_to_index.has(branch_next_id):
				branch.set_next_node_index(
					id_to_index[branch_next_id]
				)
			else:
				push_warning("Missing branch node ID: " + branch_next_id)

## Allows comments to be made in the Json file allowing for documentation purposes
## Especially with longer dialogue chains
func _load_json_with_comments(file_path: String):
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("Failed to open file")
		return null
	var content = file.get_as_text()
	file.close()
	var cleaned_lines := []
	for line in content.split("\n"):
		var in_string := false
		var i := 0
		while i < line.length():
			var c = line[i]
			if c == '"' and (i == 0 or line[i - 1] != '\\'):
				in_string = !in_string
			if !in_string and i + 1 < line.length():
				if line.substr(i, 2) == "//":
					line = line.substr(0, i)
					break
			i += 1
		cleaned_lines.append(line)
	var cleaned_json = "\n".join(cleaned_lines)
	var result = JSON.parse_string(cleaned_json)
	if typeof(result) != TYPE_DICTIONARY:
		push_error("Invalid JSON")
		return null
	return result
	
func _parse_actions(raw_actions: Array) -> Array[DialogueAction]:
	var actions : Array[DialogueAction] = []
	for action_dict in raw_actions:
		var action = DialogueAction.new(
			action_dict.get("type", ""),
			action_dict.get("key", ""),
			action_dict.get("value")
		)
		actions.append(action)
	return actions
	
func _parse_conditions(raw_conditions: Array) -> Array[DialogueCondition]:
	var conditions: Array[DialogueCondition] = []
	for condition_dict in raw_conditions:
		var condition = DialogueCondition.new(
			_parse_condition_type(condition_dict.get("type", "")),
			condition_dict.get("key", ""),
			condition_dict.get("value")
		)
		conditions.append(condition)
	return conditions

func _parse_condition_type(type_str: String) -> int:
	match type_str:
		"bool_equals":
			return DialogueCondition.ConditionType.BOOL_EQUALS
		"int_equals":
			return DialogueCondition.ConditionType.INT_EQUALS
		"int_greater", "int_greater_than":
			return DialogueCondition.ConditionType.INT_GREATER
		"int_less", "int_less_than":
			return DialogueCondition.ConditionType.INT_LESS
		"int_greater_or_equal":
			return DialogueCondition.ConditionType.INT_GREATER_OR_EQUAL
		"int_less_or_equal":
			return DialogueCondition.ConditionType.INT_LESS_OR_EQUAL
		_:
			push_warning("Unknown condition type: " + type_str)
			return DialogueCondition.ConditionType.BOOL_EQUALS

## Parse raw branches and convert them into dialogue branches
func _parse_branches(raw_branches : Array) -> Array[DialogueBranch]:
	var branches : Array[DialogueBranch] = []

	for branch_dict in raw_branches:
		var branch_conditions = _parse_conditions(
			branch_dict.get("conditions", [])
		)

		var branch = DialogueBranch.new(
			branch_dict.get("next_node_id", ""),
			branch_dict.get("priority", 0),
			branch_conditions
		)
		branches.append(branch)
	return branches
	

func _parse_events(raw_events: Array) -> Array[DialogueEvent]:
	var result: Array[DialogueEvent] = []
	for e in raw_events:
		var type := _parse_event_type(e.get("type", "sound"))
		var event: DialogueEvent
		match type:
			DialogueEvent.EventType.SOUND:
				event = DialogueSoundEvent.new()
				var sound_event := event as DialogueSoundEvent
				sound_event.audio_path = e.get("audio_path", "")
				sound_event.volume_db = e.get("volume_db", 0.0)
				sound_event.pitch_scale = e.get("pitch_scale", 1.0)
			# Will return default events untill implemented
			DialogueEvent.EventType.CAMERA:
				# TODO? 
				event = DialogueEvent.new()
				pass
			DialogueEvent.EventType.ANIMATION:				
				# TODO for sure
				event = DialogueEvent.new()
				pass
			_: # Techncially shouldn't get here but just in case
				push_warning("Unknown event type, defaulting to base event")
				event = DialogueEvent.new()
		event.type = type
		event.index = e.get("index", 0)
		result.append(event)
	return result

func _parse_event_type(type_str: String) -> int:
	match type_str:
		"sound":
			return DialogueEvent.EventType.SOUND
		"camera_shake":
			return DialogueEvent.EventType.CAMERA
		"animation":
			return DialogueEvent.EventType.ANIMATION
		_:
			return DialogueEvent.EventType.CUSTOM
