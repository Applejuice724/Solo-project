extends Control
# TODO
#- 	Hook the new dialogue event system to allow animaitons 
#	and camera movement



## Controls the dialogue UI for the player.
## Handles speaker name, dialogue text, and prompt visibility,
## including animated text display (typewriter effect).
class_name PlayerDialogueBoxScript
@export var _dialogue_text: Label  # Label to display dialogue text
@export var _name_text: Label      # Label to display the current speaker's name
@export var _prompt_box: Panel     # Panel to show dialogue prompts / choices
@export var _dialogue_box: Panel   # Panel that contains the main dialogue text and speaker information
@export var _choice_display_labels : Array[Label]
@export var _choices_panel : Panel


# Dialogue animamiton variables
var _full_Dialogue_text : String
var _char_index: int = 0
var _is_typing : bool = false
var _is_speeding_up_Dialogue : bool = false
var _char_timer: float = 0.0
var _chars_per_second: float = 30.0 
var _text_speed_fast : float = 3.0
var _text_speed_normal : float = 0.7
var _pending_events: Array[DialogueEvent] = []
var _fired_events: Dictionary = {}
	
	
	
## True = fast text speed
## False = normal text speed
func set_is_speeding_up_Dialogue(is_speeding):
	_is_speeding_up_Dialogue = is_speeding

## Toggles fast-forward mode for dialogue text animation.
func toggle_is_speeding_up_Dialogue() -> void:
	_is_speeding_up_Dialogue = !_is_speeding_up_Dialogue
	
## Instantly displays the full dialogue text without animation.
## Use this for skipping or non-animated updates. 
##
## Also cancels any typing animation currently playing
func set_dialogue(text: String) -> void:
	_dialogue_text.text = text	
	if _is_typing:
		_dialogue_text.visible_characters = -1
		_is_typing = false
	
## Sets the choices available to the player in the choice panal
##
## MUST be called after pplay_Dialogue and set_dialogue
##
## @param choices: Array of DialogueChoice objects to display.
## Must not exceed the number of available choice labels
## (i.e. choices.size() <= _choice_display_labels.size()).
##
## @param inputs: Array of input strings mapped to each choice.
## Must be the same size as choices.
## Example: choices[0] corresponds to inputs[0] ("Q", "E", etc).
##
## Side effects
## - Updates choice label text
## - Makes the choices panel visible
func set_dialogue_choices(choices : Array[DialogueChoice], inputs : Array[String]) ->void:
	var _i = 0	
	if _choice_display_labels.size() < choices.size():
		push_error("Warning! Cannot support the amount of choices, please create additional chocie panals in _choice_display_labels")
		return
	for choice in choices:
		_choice_display_labels[_i].text = "["+inputs[_i]+"] "+ choice.get_node_selection_text()
		_i += 1
	_choices_panel.visible = true
	
## Updates the speaker's name displayed in the UI
func set_speaker_name(text: String) -> void:
	_name_text.text = text

## Sets the playback speed of the animaiton for dialogue text
func set_text_speed(normal_speed : float, fast_speed : float):	
	_text_speed_normal = normal_speed
	_text_speed_fast = fast_speed
	
func get_if_typing()->bool:
	return _is_typing
	
## Starts displaying dialogue text using a typewriter animation.
## Resets any current text progress and begins revealing characters over time.
## Also resets any choice related information
func play_Dialogue(text: String) -> void:
	_full_Dialogue_text = text
	_char_index = 0
	_choices_panel.visible = false
	_is_typing = true	
	_dialogue_text.text = text
	_dialogue_text.visible_characters = 0
	
## Starts displaying dialogue text using a typewriter animation.
## Resets any current text progress and begins revealing characters over time.
## Also resets any choice related information 
func play_Dialogue_with_events(text: String, events : Array[DialogueEvent]) -> void:
	_pending_events = events
	_fired_events.clear()
	play_Dialogue(text)
		
## Sets the visibility of the entire UI control 
## including both dialogue and prompt box. 
func ui_box_visible(visible_state : bool):
	visible = visible_state

## Sets the visibility of the dialogue box panel
func dialogue_box_visible(visible_state : bool):
	_dialogue_box.visible = visible_state

## Sets the visibility of the prompt box panel
func prompt_box_visible(visible_state : bool):
	_prompt_box.visible = visible_state
	
## Skips the dialogue animation and loads the entire dialogue at once
## Used when a player wants to display text without the animation
func skip_dialogue_animation() -> void:
	set_dialogue(_full_Dialogue_text)

	for event in _pending_events:
		if not _fired_events.has(event):
			_fire_event(event)
			_fired_events[event] = true
	
func _check_dialogue_events(current_index: int) -> void:
	#print("Current char:", current_index)
	for event in _pending_events:
		#print("Event at:", event.index)
		var key := str(event.index) + "_" + str(event.type)
		if _fired_events.has(key):
			continue
		if event.index == current_index:
			#print("FIRING EVENT")
			_fire_event(event)
			_fired_events[key] = true
	
func clear_choices()->void:
	for label in _choice_display_labels:
		label.text = ""

## Handles the typewriter animation by revealing characters over time.
## Uses a timer-based approach to ensure consistent speed across frame rates.
func _process(delta: float) -> void:
	if not _is_typing:
		return
	var speed = _text_speed_fast if _is_speeding_up_Dialogue else _text_speed_normal
	
	_char_timer += delta * _chars_per_second * speed
	while _char_timer >= 1.0:
		_char_timer -= 1.0
		_char_index += 1
		_check_dialogue_events(_char_index)
	_dialogue_text.visible_characters = _char_index
	if _char_index >= _full_Dialogue_text.length():
		_dialogue_text.visible_characters = -1
		_is_typing = false
		
func _fire_event(event: DialogueEvent) -> void:
	match event.type:
		DialogueEvent.EventType.SOUND:
			_fire_sound(event as DialogueSoundEvent)
		DialogueEvent.EventType.CAMERA:
			pass
		DialogueEvent.EventType.ANIMATION:
			pass
		_:
			push_warning("Unhandled dialogue event type")
				
func _fire_sound(event: DialogueSoundEvent) -> void:
	var audio := AudioStreamPlayer2D.new()
	add_child(audio)
	audio.stream = load(event.audio_path)
	audio.volume_db = event.volume_db
	audio.pitch_scale = event.pitch_scale
	audio.play()
	audio.finished.connect(audio.queue_free)

		
