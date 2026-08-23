extends UIElement
## Handles player-side dialogue interactions.
## Responsible for triggering dialogue events
## Dialogue service will handle the event this is just a way to trigger it.

class_name PlayerDialogueNodeScript
@onready var dialogue_box: Control
@export var _dialogue_manager : DialogueManager
@export var _dialogue_box : PlayerDialogueBoxScript
@export var _text_speed_normal : float = 0.7
@export var _text_speed_fast : float = 3.0

var _is_being_prompted_dialogue : bool  = false
var _is_talking : bool = false

func _ready() -> void:
	_dialogue_manager.node_entered.connect(_on_node_entered)
	_dialogue_manager.dialogue_started.connect(_on_dialogue_start)
	_dialogue_manager.dialogue_finished.connect(_on_dialogue_finished)
	if _dialogue_box != null:
		_dialogue_box.set_text_speed(_text_speed_normal, _text_speed_fast)
	else:
		push_error("Warning! No dialogue box found, dialogue will not be displayed")

# === UI updates == #
## Updates the dialogue UI with the given node's content.
## Displays speaker name, dialogue text, and available choices.
## Ends the dialogue if the node is null.
func _display_dialogue(node : DialogueNode) -> void:
	if node == null:
		push_error("Tried to display null dialogue node")
		return
	_dialogue_box.dialogue_box_visible(true)
	_dialogue_box.set_speaker_name(
		node.get_speaker_name()
	)
	_dialogue_box.play_Dialogue_with_events(
		node.get_content(),
		node.get_dialogue_events()
	)
	var dialogue_choices := node.get_choices()
	if dialogue_choices:
		_dialogue_box.set_dialogue_choices(
			dialogue_choices,
			_get_inputs_for_choices()
		)
	else:
		_dialogue_box.clear_choices()

func _hide_dialogue() -> void:
	_dialogue_box.dialogue_box_visible(false)
	_dialogue_box.clear_choices()

## Enables the dialogue prompt when the player is in range of an NPC.
## Sets the prompting state and displays the prompt UI.
func start_dialogue_prompt() -> void:
	if _dialogue_box:
		_is_being_prompted_dialogue = true
		_dialogue_box.prompt_box_visible(true)

## ends the current Dialogue prompt
## Used for when the player goes outside the range of a NPC with dialogue
func end_dialogue_prompt() -> void:
	if _dialogue_box:
		_is_being_prompted_dialogue = false
		_dialogue_box.prompt_box_visible(false)

# === Signal hooks == #
## When the node is entered display node contents
func _on_node_entered(node: DialogueNode) -> void:
	_is_talking = true
	_display_dialogue(node)

func _on_node_exited(node: DialogueNode) -> void:
	pass

func _on_dialogue_start() -> void:
	_is_talking = true
	end_dialogue_prompt()
	Game.ui._take_control()


func _on_dialogue_finished() -> void:
	_is_talking = false
	_hide_dialogue()
	Game.ui._give_control()

# === Getters == #
## Used by the NPC when the player gets in range to load their dialogue into
## the players dialogue manager
func get_dialogue_choices() -> Array[DialogueChoice]:
	var current_node := _dialogue_manager.get_current_node()
	if current_node == null:
		return []
	return current_node.get_choices()



# === Dialogue manager requests == #
## Begins a new dialogue sequence.
## Transitions the player into dialogue state, disables player controls,
## loads the first dialogue node, and updates the UI.
func request_start_dialogue() -> void:
	_dialogue_manager.start_dialogue()

## Advances to the next dialogue node without a player choice.
## Ends the dialogue if no further nodes exist.
func request_continue_dialogue() ->void:
	_dialogue_manager.continue_dialogue()

## Advances the dialogue using a selected choice.
## Resolves the next node based on the choice index and updates the UI.
func request_select_choice(choice : int) -> void:
	var current_node := _dialogue_manager.get_current_node()
	if current_node == null:
		return
	var choices := current_node.get_choices()
	if choice < 0 or choice >= choices.size():
		push_error("Invalid dialogue choice index")
		return
	var next_node := choices[choice].get_next_node_as_index()
	_dialogue_manager.change_node(next_node)

# === Dialogue load functions == #
func register_raw_dialogue_tree(raw_path: String) -> String:
	var tree_index = _dialogue_manager.load_dialogue(raw_path)
	var tree = _dialogue_manager.get_dialogue_tree_id_at_index(tree_index)
	return tree

func set_current_tree(tree_id: String) -> void:
	_dialogue_manager.set_current_dialogue_tree_by_id(tree_id)


## Sets the text speed for the animation for dialogue to fast if true
## When set to false the animation will be set to normal speed
func set_is_fast_forwarding_text_animation(is_fast_forwading : bool) ->void:
	_dialogue_box.set_is_speeding_up_Dialogue(is_fast_forwading)


func _get_inputs_for_choices()->Array[String]:
	var _inputs : Array[String] = []
	_inputs.append(_get_key_for_action("interact_button_1"))
	_inputs.append(_get_key_for_action("interact_button_2"))
	return _inputs

## Returns a human-readable key bound to the given input action.
## Used for displaying dynamic input prompts in the UI.
func _get_key_for_action(action_name: String) -> String:
	var events = InputMap.action_get_events(action_name)
	for ev in events:
		if ev is InputEventKey:
			return OS.get_keycode_string(ev.physical_keycode)
	if events.size() > 0:
		return events[0].as_text()
	return "?"

func get_dialogue_box_node()->PlayerDialogueBoxScript:
	return _dialogue_box

func is_being_prompted_dialogue()->bool:
	return _is_being_prompted_dialogue

func is_talking()->bool:
	return _is_talking
