extends Resource
## DialogueTree represents a branching conversation.
## It stores all dialogue nodes, tracks the current position in the dialogue,
## and provides utility functions to navigate or reset the conversation.
class_name DialogueTree

var _tree_id : String
var _nodes : Array[DialogueNode] = []
## Tracks the index of the current node in the dialogue tree
var _current_node_index : int = 0 
var _dialogue_file_path : String
var _visited_nodes : Dictionary[String, bool] = {}

## The initialization of the dialogue tree
## A DialogueTree holds all dialogue nodes as well as the position of the current spoken dialogue
##
## @param id the id of the tree, used to start the dialogue
## @param node_array the array of dialogue nodes that will be traveled
## @param dialogue_file_path the path of the file the dialogue is stored on
func _init(id: String, node_array: Array[DialogueNode], dialogue_file_path : String) -> void:
	_tree_id = id
	_nodes = node_array
	_dialogue_file_path = dialogue_file_path

## String ID used to start dialogue by the dialogue manager 
func get_tree_id() -> String:
	return _tree_id

## Returns the DialogueNode currently active in the conversation
func get_current_node() -> DialogueNode:
	if _nodes.is_empty():
		return null
	if _current_node_index < 0 or _current_node_index >= _nodes.size():
		return null
	return _nodes[_current_node_index]

## Returns the index of the current node in the tree
func get_current_node_index() -> int:
	return _current_node_index

## Returns the whole dialogue tree as an array of DialogueNodes
func get_tree_nodes() -> Array[DialogueNode]:
	return _nodes.duplicate()

## Gets the path of the JSON file that this was used to create the dialogue nodes
func get_dialogue_file_path() -> String:
	return _dialogue_file_path
	
func get_node_by_index(index : int) -> DialogueNode:
	return _nodes[index]

## Sets the current node by index and returns it.
## Returns null and pushes an error if the index is invalid.
func set_current_node_by_index(node_index : int) -> DialogueNode:
	if node_index < 0 or node_index >= _nodes.size():
		push_error("DialogueTree: Attempted to set invalid node index %d. Total nodes: %d" % [node_index, _nodes.size()])
		return null		
	_current_node_index = node_index
	return get_current_node()
	
func set_current_node_by_string_ID(node_string_id : String) -> DialogueNode:
	var node_index := 0
	for node in _nodes:
		if node.get_id_as_string() == node_string_id:
			_current_node_index = node_index
			return get_current_node()
		node_index += 1
	push_error(
		"DialogueTree: Failed to find node ID '%s'" % node_string_id
	)
	return null
			
## Resets the current tree to the start of the dialogue
func reset_tree() -> void:
	_current_node_index = 0

func mark_node_visited(node_id: String) -> void:
	_visited_nodes[node_id] = true
	
func has_visited_node(node_id: String) -> bool:
	return _visited_nodes.has(node_id)
	
