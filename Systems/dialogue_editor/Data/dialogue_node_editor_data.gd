extends Resource
class_name dialogue_node_editor_data

var _id: String = ""
var _speaker_name: String = ""
var _speaker_icon_path: String = ""
var _content: String = ""
var _next_node: String = ""
var _next_node_as_index: int = -1
var _choices: Array[DialogueChoice] = []
var _conditions: Array[DialogueCondition] = []
var _actions: Array[DialogueAction] = []
var _events: Array[DialogueEvent] = []
var _branches: Array[DialogueBranch] = []
var _resolve_branches_after_display: bool = true
var _editor_position: Vector2 = Vector2.ZERO


static func from_dialogue_node(node: DialogueNode) -> dialogue_node_editor_data:
	var data := dialogue_node_editor_data.new()
	data.set_id(node.get_id_as_string())
	data.set_speaker_name(node.get_speaker_name())
	data.set_speaker_icon_path(node.get_speaker_icon_path())
	data.set_content(node.get_content())
	data.set_next_node_id(node.get_next_node_as_string())
	data.set_next_node_as_index(node.get_next_node_as_index())
	data.set_choices(node.get_choices())
	data.set_conditions(node.get_conditions())
	data.set_actions(node.get_actions())
	var events := node.get_dialogue_events()
	if events == null:
		events = []
	data.set_dialogue_events(events)
	data.set_branches(node.get_branches())
	data.set_resolve_branches_after_display(
		node.get_resolve_branches_after_display()
	)
	if node.has_editor_position():
		var position := node.get_editor_position()
		if position.size() >= 2:
			data.set_editor_position(Vector2(position[0], position[1]))
	return data


func get_id_as_string() -> String:
	return _id


func set_id(id: String) -> void:
	_id = id


func get_speaker_name() -> String:
	return _speaker_name


func set_speaker_name(speaker_name: String) -> void:
	_speaker_name = speaker_name


func get_speaker_icon_path() -> String:
	return _speaker_icon_path


func set_speaker_icon_path(speaker_icon_path: String) -> void:
	_speaker_icon_path = speaker_icon_path


func get_content() -> String:
	return _content


func set_content(content: String) -> void:
	_content = content


func get_next_node_id() -> String:
	return _next_node


func set_next_node_id(next_node_id: String) -> void:
	_next_node = next_node_id


func get_next_node_as_index() -> int:
	return _next_node_as_index


func set_next_node_as_index(next_node_as_index: int) -> void:
	_next_node_as_index = next_node_as_index


func get_choices() -> Array[DialogueChoice]:
	return _choices


func set_choices(choices: Array[DialogueChoice]) -> void:
	_choices = choices


func add_choice(choice: DialogueChoice) -> void:
	_choices.append(choice)


func has_choices() -> bool:
	return not _choices.is_empty()


func get_conditions() -> Array[DialogueCondition]:
	return _conditions


func set_conditions(conditions: Array[DialogueCondition]) -> void:
	_conditions = conditions


func get_actions() -> Array[DialogueAction]:
	return _actions


func set_actions(actions: Array[DialogueAction]) -> void:
	_actions = actions


func get_dialogue_events() -> Array[DialogueEvent]:
	return _events


func set_dialogue_events(events: Array[DialogueEvent]) -> void:
	_events = events


func get_branches() -> Array[DialogueBranch]:
	return _branches


func set_branches(branches: Array[DialogueBranch]) -> void:
	_branches = branches


func get_resolve_branches_after_display() -> bool:
	return _resolve_branches_after_display


func set_resolve_branches_after_display(resolve_after_display: bool) -> void:
	_resolve_branches_after_display = resolve_after_display


func get_editor_position() -> Vector2:
	return _editor_position


func set_editor_position(editor_position: Vector2) -> void:
	_editor_position = editor_position
