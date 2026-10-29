extends Node
## DialogueManager keeps track of all dialogue and keeps a record of previous 
## dialogues. It allows the player controller to load dialogue with the trees id
## and provides methods to advance the dialogue via interaction with the ability 
## to make choices
class_name DialogueManager

# TODO list
# - Add proper dialogue end handling when next node is invalid/null
# - Add is_dialogue_active() query support
# - Add safeguards for invalid dialogue choice indices
# - Consider adding unique node lookup map for faster ID searches
# - Allow on exit condition/action checks as well as on enter
# - Clean up the node lifecycle 
# - Refactor to allow actions pre conditions and after conditions

var _dialogue_trees : Array[DialogueTree]
var _current_dialogue_tree : DialogueTree
var _current_node : DialogueNode
var _dialogue_state := {"pebbles_count" : 3, "met_explorer" : false}
var _has_active_dialogue = false 
# Map "Node_id : boolean"
signal node_entered(node)
signal node_exited(node)
signal dialogue_started()
signal dialogue_finished()
signal dialogue_continued()

# == Tree management == #
## Sets current dialogue tree
func set_current_dialogue_tree_by_index(dialogue_tree_index : int) -> void:
	if dialogue_tree_index < 0 or dialogue_tree_index >= _dialogue_trees.size():
		push_error("Error! Could not find dialogue tree")
		return
	_current_dialogue_tree = _dialogue_trees[dialogue_tree_index]

func set_current_dialogue_tree_by_id(id : String) -> void:
	for tree in _dialogue_trees:
		if tree.get_tree_id() == id:
			_current_dialogue_tree = tree
			return
	push_error("Error! No tree with the name " + id + " was found")
			
func get_index_of_dialogue_tree(dialogue_tree : DialogueTree) -> int:
	var _index = 0
	for tree in _dialogue_trees:
		if tree.get_tree_id() == dialogue_tree.get_tree_id():
			return _index
		_index += 1	
	return -1

func get_dialogue_tree_at_index(index : int)->DialogueTree:
	return _dialogue_trees[index]
	
func get_dialogue_tree_id_at_index(index : int) -> String:
	return _dialogue_trees[index].get_tree_id()
		
func register_dialogue_tree(dialogue_tree : DialogueTree) -> int:
	_dialogue_trees.append(dialogue_tree)
	return _dialogue_trees.size() - 1

# == Node management == #
## Assumes that all dialogue starts at index 0 unless otherwise
## Specified 
func start_dialogue(start_index: int = 0) -> DialogueNode:
	if _current_dialogue_tree == null:
		push_error("Error current dialogue tree does not exist!")
		return null

	_has_active_dialogue = true
	dialogue_started.emit()

	_current_node = _current_dialogue_tree.set_current_node_by_index(start_index)
	_enter_current_node()
	return _current_node

func change_node(new_node_index: int) -> void:
	if _current_dialogue_tree == null:
		push_error("Error current dialogue tree does not exist!")
		return
	if new_node_index < 0:
		end_dialogue()
		return		
	_leave_current_node()
	_current_node = _current_dialogue_tree.set_current_node_by_index(new_node_index)
	if _current_node == null:
		end_dialogue()
		return
	_enter_current_node()

## When there's no choice advance dialogue and proceed to next default node
func continue_dialogue() -> void:
	if _current_dialogue_tree == null:
		push_error("Error current dialogue tree does not exist!")
		return
	if _current_node == null:
		end_dialogue()
		return
	if _current_node.get_resolve_branches_after_display():
		var branch = _evaluate_branches(_current_node)
		if branch != null:
			change_node(branch.get_next_node_index())
			return
	var next_node := _current_node.get_next_node_as_index()
	if next_node == -1:
		end_dialogue()
		return
	change_node(next_node)
	
## For any actions that are needed while leaving the current node
func _leave_current_node() -> void:
	if _current_node:
		node_exited.emit(_current_node)
		
func end_dialogue() -> void:
	if _current_dialogue_tree:
		_current_dialogue_tree.reset_tree()

	_current_dialogue_tree = null
	_current_node = null
	_has_active_dialogue = false
	dialogue_finished.emit()
	
## For any actions that are needed while leaving the current node
func _enter_current_node() ->void:
	# If the dialogue is finished, do nothing
	if _current_node == null:
		return
	_current_dialogue_tree.mark_node_visited(
		_current_node.get_id_as_string()
	)
	_process_element(_current_node)
	if !_current_node.get_resolve_branches_after_display():
		var branch = _evaluate_branches(_current_node)
		if branch != null:
			change_node(branch.get_next_node_index())
			return			
	node_entered.emit(_current_node)

func get_current_node() -> DialogueNode:
	return _current_node
	
func get_current_dialogue_tree() -> DialogueTree:
	return _current_dialogue_tree
			
# == Actions and conditions management == #		
func _process_element(element : DialogueElement) -> void:
	if not _evaluate_conditions(element.get_conditions()):
		return
	for action in element.get_actions():
		_execute_action(action)
	
func _evaluate_branches(node: DialogueNode) -> DialogueBranch:
	var valid_branches : Array[DialogueBranch] = []
	for branch in node.get_branches():
		if _evaluate_conditions(branch.get_conditions()):
			valid_branches.append(branch)
	if valid_branches.is_empty():
		return null
	valid_branches.sort_custom(
		func(a, b):
			return a.get_priority() > b.get_priority()
	)
	return valid_branches[0]
	
func _execute_action(action) ->void:
	match action.get_type():
		"set_bool": _set_state_value(
				action.get_key(),
				action.get_value()
				)
		"set_int":
			_set_state_value(
				action.get_key(),
				action.get_value()
			)
		"add_int":
			var current_value = get_state_value(
				action.get_key(),
				0
			)
			_set_state_value(
				action.get_key(),
				current_value + action.get_value()
			)
		_:
			push_warning(
				"Unknown action type: " +
				action.get_type()
			)
	
func _evaluate_conditions(conditions: Array[DialogueCondition]) -> bool:
	for condition in conditions:
		var state_value = get_state_value(condition.get_key())
		match condition.get_condition_type():
			DialogueCondition.ConditionType.BOOL_EQUALS:
				if state_value != condition.get_value():
					return false
			DialogueCondition.ConditionType.INT_EQUALS:
				if state_value != condition.get_value():
					return false
			DialogueCondition.ConditionType.INT_GREATER:
				if state_value <= condition.get_value():
					return false
			DialogueCondition.ConditionType.INT_LESS:
				if state_value >= condition.get_value():
					return false
			DialogueCondition.ConditionType.INT_GREATER_OR_EQUAL:
				if state_value < condition.get_value():
					return false
			DialogueCondition.ConditionType.INT_LESS_OR_EQUAL:
				if state_value > condition.get_value():
					return false
	return true
	
# == Dialogue loading == #
## Loads the dialogue into a dialogue tree and saves it in _dialogue_trees and returns the newly added tree ID.d
## @param file_path Path to the dialogue JSON file
func load_dialogue(file_path : String) -> int:
	# Make sure duplicates are not added into the list
	for tree in _dialogue_trees:
		if tree.get_dialogue_file_path() == file_path:
			return get_index_of_dialogue_tree(tree)
	var loader = DialogueLoader.new()
	var tree = loader.load_dialogue(file_path)
	return register_dialogue_tree(tree)
	
# == Query methods == #
func has_visited_node(node_index) -> bool:
	var node = _current_dialogue_tree.get_node_by_index(node_index)
	return _current_dialogue_tree.has_visited_node(node.get_id_as_string())	
	
func has_dialogue_active() -> bool:
	return _has_active_dialogue
	
func get_available_choices() -> Array[DialogueChoice]:
	return _current_node.get_choices()
		
# == State methods == #
func _set_state_value(key: String, value) -> void:
	set_state_internal_value (key, value)
	# Hook up to the save system here, do not remove set_state_internal_value

func get_state_value(key: String, default_value = null):	
	# Remove the return entirely and subsitute it to return actual save values
	# when hooking up to save system
	return get_state_internal_value(key, default_value)

# Internal values, for debugging purposes and unit testing
func get_state_internal_value(key: String, default_value = null):
	return _dialogue_state.get(key, default_value)
	
func set_state_internal_value(key: String, value = null):
	_dialogue_state[key] = value
