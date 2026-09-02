extends Container


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DialogueService.dialogue_prompt_started.connect(_show_prompt)
	DialogueService.dialogue_prompt_ended.connect(_hide_prompt)



		
	pass
	
func _show_prompt():
	visible = true
	pass
	
func _hide_prompt():
	visible = false
	pass
