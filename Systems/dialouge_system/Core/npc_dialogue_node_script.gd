extends Area3D
## NPCDialogueNodeScript triggers dialogue when the player enters an NPC's area.
## Holds the path to the JSON dialogue file and manages sending the dialogue tree ID
## to the player so the player controller can load and interact with the dialogue.
class_name NPCDialogueNodeScript

## Dialogue system trigger for NPC interaction.
##
## HOW TO USE:
## 1. Drag this node onto a 3D object
## 2. Assign a dialogue JSON file below
## 3. Play the scene — it auto-triggers in range
##
## PREFAB LOCATION:
## res://dialogue_system/Prefabs/NPC_Dialogue_trigger.tscn

@export_group("Dialogue Setup")
## Instrucitons only, editing this does nothing
@warning_ignore("unused_private_class_variable")
@export_multiline var _info := """ HOW TO USE:
1. Drag res://dialogue_system/Prefabs/NPC_Dialogue_trigger.tscn onto a 3D object
2. Assign a JSON file with dialogue
3. Done
Go to res://dialogue_system/Example Scripts/ for examples"""

@export_group("Dialogue Setup")
## The path to the file, drag and drop the file here to add its path
@export_file("*.json") var dialogue_file: String 
@export var reprompt_time: float = 0.5
@export var player : Node3D
## If the dialogue should retrigger when the player closes dialogue and stays
## in range
@export var dialogue_retrigger_on_exit : bool = true
var _timer: Timer

func _ready() -> void:
	if dialogue_file.is_empty():
		push_error("%s has no dialogue file assigned." % name)
		return
	if not FileAccess.file_exists(dialogue_file):
		push_error("%s references missing dialogue file: %s" 
		% [name, dialogue_file])
		return

	_timer = Timer.new()
	_timer.one_shot = true
	_timer.wait_time = reprompt_time
	_timer.timeout.connect(_try_reprompt)
	add_child(_timer)	
	# Double check this is on for everything to work	
	monitoring = true
	monitorable = true
	for child in get_children():
		print(child.name, " | ", child.get_class())
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


## Called when the an object enters the trigger and determines if it is the
## player charecter. 
func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("Player"):
		return
	_start_dialogue()

## Called when the player goes out of range of the NPC
func _on_body_exited(body: Node3D) -> void:
	if not body.is_in_group("Player"):
		return
	DialogueService.hide_prompt()
	

func _start_dialogue() -> void:
	if _timer:
		_timer.stop()
	DialogueService.request_dialogue(dialogue_file)
	
func _try_reprompt() -> void:
	for body in get_overlapping_bodies():
		if body.is_in_group("Player") and dialogue_retrigger_on_exit:
			_start_dialogue()
			return
