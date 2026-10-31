extends Node
## This is the public interface between the Dialogue system and the NPC, Player,
## and any other system that needs to interact with the dialogue system.
# Signals
signal dialogue_started(tree_id)
signal dialogue_finished
signal dialogue_continued
signal dialogue_prompt_started
signal dialogue_prompt_ended

# Variables
var _dialogue_manager: DialogueManager
var _current_prompter: NPCDialogueNodeScript


func _ready() -> void:
	_dialogue_manager = DialogueManager.new()
	add_child(_dialogue_manager)
	
func request_dialogue(dialogue_file: String) -> void:
	# print("DialogueService: Request received: ", dialogue_file)
	if _dialogue_manager == null:
		push_error("DialogueService has not been configured.")
		return
	if dialogue_file.is_empty():
		push_error("Cannot start dialogue: dialogue file is empty.")
		return
	if not FileAccess.file_exists(dialogue_file):
		push_error("Cannot start dialogue: file does not exist: " + dialogue_file)
		return
	# print("DialogueService: Loading dialogue...")
	var dialogue_tree_index := _dialogue_manager.load_dialogue(dialogue_file)
	# print("DialogueService: Loaded tree index: ", dialogue_tree_index)
	if dialogue_tree_index < 0:
		push_error("Failed to load dialogue: " + dialogue_file)
		return
	_dialogue_manager.set_current_dialogue_tree_by_index(dialogue_tree_index)
	#print("DialogueService: Starting dialogue...")
	_dialogue_manager.start_dialogue()
	var tree := _dialogue_manager.get_current_dialogue_tree()
	dialogue_started.emit(tree.get_tree_id())
	# print("DialogueService: Dialogue started.")
	
func request_prompt(requester : NPCDialogueNodeScript) -> void:	
	if get_if_dialogue_active():
		return
	dialogue_prompt_started.emit()
	_current_prompter = requester
	
func request_hide_prompt(requester : NPCDialogueNodeScript) -> void:	
	dialogue_prompt_ended.emit()
	if requester == _current_prompter:
		_current_prompter = null
	
func request_start_conversation() ->void:
	if _dialogue_manager.has_dialogue_active():
		push_error("Errror! Dialogue already started, finish current dialogue before starting a new dialogue")		
		return	
	if _current_prompter == null:
		return
	request_dialogue(_current_prompter.dialogue_file)
	dialogue_prompt_ended.emit()
	
func request_dialogue_choice(choice : DialogueChoice)->void:
	if _dialogue_manager.has_dialogue_active():
		_on_dialogue_continued(choice)		
	else:
		push_error("Errror! Dialogue has not started, start a dialogue before continueing new dialogue")	
	
			
func request_advance_conversation()->void:
	if _dialogue_manager.has_dialogue_active():
		_on_dialogue_continued()		
	else:
		push_error("Errror! Dialogue has not started, start a dialogue before continueing new dialogue")		
	
		
func _on_dialogue_continued(choice: DialogueChoice = null) ->void:
	if _dialogue_manager.get_current_node().has_choices():
		if choice:
			_dialogue_manager.continue_dialogue_with_choice(choice)
		else:
			push_error("Error! Dialogue has choices but none were found, please put the choice in request_dialogue_choice()")
	else:
		_dialogue_manager.continue_dialogue()
	if _dialogue_manager.has_dialogue_active():
		dialogue_continued.emit()
	else:
		dialogue_finished.emit()

## Getters
func get_if_dialogue_active():
	return _dialogue_manager.has_dialogue_active()

func get_current_node_dialogue()->DialogueNode:
	return _dialogue_manager.get_current_node()
	
func get_current_node_choices()->Array[DialogueChoice]:
	return _dialogue_manager.get_available_choices()
	
func get_if_node_has_choices()->bool:
	return _dialogue_manager.get_current_node().has_choices()
