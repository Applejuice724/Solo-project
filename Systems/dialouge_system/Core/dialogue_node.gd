extends DialogueElement
## DialogueNode represents a single node in a dialogue tree.
## It stores the speaker's name and icon, the dialogue content,
## possible choices, and references to the next node(s).
class_name DialogueNode
var _id: String
var _speaker_name: String
var _speaker_icon_path: String
var _content: String
var _next_node: String            	# Next node as a string ID
var _next_node_as_index: int      	# Next node as an array index
var _choices: Array[DialogueChoice]	# Choices available at this node
var _has_choices: bool            	# True if there are dialogue choices
var _branches : Array[DialogueBranch]
var _resolve_branches_after_display = true

# TODO 
# Need to setup dialogue node editor 2D locations
## Initializes the dialogue node
##
## @param id The ID of the dialogue node
## @param speaker_name The name of the character speaking
## @param speaker_icon_path Path to the character's icon
## @param dialogue_content Text to display in the dialogue box
## @param next_node String ID of the next node (ignored if choices exist)
## @param dialogue_choices Array of DialogueChoice objects for this node
func _init(id: String, speaker_name: String, speaker_icon_path: String,
		   dialogue_content: String, next_node: String, dialogue_choices: Array[DialogueChoice],
			dialogue_conditions : Array[DialogueCondition], dialogue_actions : Array[DialogueAction],
			branches : Array[DialogueBranch], resolve_branches_after_display : bool) -> void:
	super._init(dialogue_conditions, dialogue_actions)
	_id = id
	_speaker_name = speaker_name
	_speaker_icon_path = speaker_icon_path
	_content = dialogue_content
	_next_node = next_node
	_choices = dialogue_choices
	_next_node_as_index = -1
	_has_choices = not _choices.is_empty()
	_branches = branches
	_resolve_branches_after_display = resolve_branches_after_display
	
func get_id_as_string() -> String:
	return _id
	
func get_actions() -> Array[DialogueAction]:
	return _dialogue_actions
			
func get_speaker_name() -> String:
	return _speaker_name
	
func get_content() -> String:
	return _content
	
func get_speaker_icon_path() -> String:
	return _speaker_icon_path

func get_next_node_as_string() -> String:
	return _next_node
	
func get_next_node_as_index() -> int:
	return _next_node_as_index
	
func get_choices() -> Array[DialogueChoice]:
	return _choices	
	
func get_choice_next_node_index(choice : DialogueChoice) -> int:
	return choice.get_next_node_as_index()
	
# Returns 0 untill implementation later
func get_editor_position() ->Array[float]:
	return [0,0]
	
func has_choices() -> bool:
	return _has_choices

# Returns false for now untill later implementation
func has_editor_position():
	return false
	
func set_next_node_as_index(index : int) -> void:
	_next_node_as_index = index
	
func get_branches() -> Array[DialogueBranch]:
	return _branches
	
func get_resolve_branches_after_display() -> bool:
	return _resolve_branches_after_display
	


## Prints all information about this dialogue node for debugging
func print_dialogue_node() -> void:
	print("_____________")
	print("Dialogue node ID: " + _id)
	print("Speaker Name: " + _speaker_name)
	print("Content: " + _content)
	print("Speaker Icon Path: " + _speaker_icon_path)
	print("Next Node as string: " + _next_node)
	print("Next Node as Index: " + str(_next_node_as_index))
	print("_____________")
	
