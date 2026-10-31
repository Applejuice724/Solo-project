extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DialogueService.dialogue_started.connect(_display_started_conversation)
	DialogueService.dialogue_continued.connect(_display_continued_conversation)
	DialogueService.dialogue_finished.connect(_dialog_ended)


func _display_started_conversation(_tree_id: String) -> void:
	self.visible = true
	_display_node(DialogueService.get_current_node_dialogue())
	
func _display_continued_conversation()->void:
	_display_node(DialogueService.get_current_node_dialogue())

func _display_node(node: DialogueNode) -> void:
	if node == null:
		push_error("DialogueService returned a null current node.")
		return
	$HBoxContainer/VBoxContainer/SpeakerLabel.text = node.get_speaker_name()
	$HBoxContainer/DialogueLabel.text = node.get_content()
	
func _dialog_ended()->void:
	self.visible = false
	
