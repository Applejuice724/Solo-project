extends Node
## This is the public interface between the Dialogue system and the NPC, Player,
## and any other system that needs to interact with the dialogue system.
# Signals
signal dialogue_started(tree_id)
signal dialogue_finished
signal dialogue_continued()
signal dialogue_prompt_started
signal dialogue_prompt_ended
# Variables
var _dialogue_manager: DialogueManager
var _has_dialogue_active : bool

func _ready() -> void:
	_dialogue_manager = DialogueManager.new()
	add_child(_dialogue_manager)
	_dialogue_manager.dialogue_started.connect(_on_dialogue_started)
	_dialogue_manager.dialogue_finished.connect(_on_dialogue_finished)
	
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
	# print("DialogueService: Dialogue started.")
	
func request_prompt() -> void:	
	if has_dialogue_active():
		return		
	dialogue_prompt_started.emit()	
	
func request_hide_prompt() -> void:	
	dialogue_prompt_ended.emit()
	
func request_start_conversation() ->void:
	if _dialogue_manager.has_dialogue_active():
		push_error("Errror! Dialogue already started, finish current dialogue before starting a new dialogue")		
		return	
	
func request_advance_conversation()->void:
	if _dialogue_manager.has_dialogue_active():
		_on_dialogue_continued()		
	else:
		push_error("Errror! Dialogue has not started, start a dialogue before continueing new dialogue")		
	
	
func _on_dialogue_started() -> void:
	var tree := _dialogue_manager.get_current_dialogue_tree()
	if tree == null:
		push_error("Dialogue started without a current dialogue tree.")
		return
	dialogue_started.emit(tree.get_tree_id())
	
func _on_dialogue_continued() ->void:
	var tree := _dialogue_manager.get_current_dialogue_tree()
	if tree == null:
		push_error("Dialogue started without a current dialogue tree.")
		return
	_dialogue_manager.continue_dialogue()
	dialogue_continued.emit(tree)

func _on_dialogue_finished() -> void:
	dialogue_finished.emit()

## Getters
func has_dialogue_active():
	return _has_dialogue_active
