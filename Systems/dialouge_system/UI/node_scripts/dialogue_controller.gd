extends Node
## This is a input controller for checking for dialogue input specifically
class_name DialogueController

# TODO list
# - Connect node_exited signal if exit animations/effects are needed
# - Move repeated choice input bindings into configurable constants
# - Consider supporting more than 2 dialogue choices dynamically? 
# - Add dialogue box transition animations
# - Prevent dialogue input while pause menu is active

@export var _dialogue_node : PlayerDialogueNodeScript
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact_button_2"):
		_handle_interact()
	if event.is_action_pressed("interact_button_1"):
		_handle_choice(0)
		
	if event.is_action_pressed("jump"):
		_dialogue_node.set_is_fast_forwarding_text_animation(true)
	if event.is_action_released("jump"):
		_dialogue_node.set_is_fast_forwarding_text_animation(false)				
		
func _handle_interact()->void:
	if _dialogue_node.get_dialogue_box_node().get_if_typing():
		_dialogue_node.get_dialogue_box_node().skip_dialogue_animation()
		return
	if _dialogue_node.is_being_prompted_dialogue():
		_dialogue_node.request_start_dialogue()
		return
	if _dialogue_node.is_talking():
		if _dialogue_node.get_dialogue_choices().is_empty():
			_dialogue_node.request_continue_dialogue()
		else:
			_dialogue_node.request_select_choice(1)
		return
		
func _handle_choice(choice_index: int) -> void:
	if !_dialogue_node.is_talking():
		return
	if _dialogue_node.get_dialogue_choices().is_empty():
		return
	_dialogue_node.request_select_choice(choice_index)
	
