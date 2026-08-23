extends DialogueElement
## DialogueChoice represents a single choice in a DialogueNode.
## It stores the next node reference to go to if this choice is selected,
## the text displayed to the player, and its visibility state.
class_name DialogueChoice

var _choice_id: String
var _next_node_id: String
var _next_node_as_index: int = -1
var _node_selection_text: String # Text displayed to the player for this choice
var _is_visible: bool


## The initialization of the dialogue choice node
##
## @param choice_id The id for the choice being made
## @param next_node_id The node that this choice will lead to if chosen
## @param node_selection_text The text that will be displayed as the option
## @param is_vis If this choice is visible
func _init(choice_id: String, next_node_id: String, node_selection_text: String, is_vis: bool,
	 		dialogue_conditions : Array[DialogueCondition], dialogue_actions : Array[DialogueAction]) -> void:
	super._init(dialogue_conditions, dialogue_actions)
	_choice_id = choice_id
	_next_node_id = next_node_id
	_node_selection_text = node_selection_text
	_is_visible = is_vis
	
func get_choice_id() -> String:
	return _choice_id
	
func get_next_node_id() -> String:
	return _next_node_id
	
func get_next_node_as_index() -> int:
	return _next_node_as_index
	
func set_next_node_as_index(index : int) -> void:
	_next_node_as_index = index
	
func get_node_selection_text() -> String:
	return _node_selection_text

func get_actions() -> Array[DialogueAction]:
	return _dialogue_actions
	
func is_visible() -> bool:
	return _is_visible
	
func print_choice_data() -> void:
	print("_____________")
	print("Choice ID: " + _choice_id)
	print("Next Node ID: " + _next_node_id)
	print("Next Node Index: " + str(_next_node_as_index))
	print("Node Selection Text: " + _node_selection_text)
	print("Is Visible: " + str(_is_visible))
	print("_____________")
	
