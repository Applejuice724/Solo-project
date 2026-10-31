extends GraphNode

class_name DialogueNodeVisual
var editor_data: dialogue_node_editor_data


func setup(data : dialogue_node_editor_data):
	editor_data = data
	title = data.get_id_as_string()
	$speaker_name_input.text = data.get_speaker_name()
	$content_input.text = data.get_content()
	setup_ports()
	$speaker_name_input.text_changed.connect(_on_speaker_name_changed)
	$content_input.text_changed.connect(_on_content_changed)
	$content_input.scroll_fit_content_height = true
	print("GraphNode children:", get_child_count())
	for i in get_child_count():
		print(i, get_child(i).name)
			
func setup_ports():
	clear_all_slots()
	# Previous input
	set_slot(
		0,
		true, 0, Color.WHITE,
		false, 0, Color.WHITE
	)

	# Next output
	set_slot(
		5,
		false, 0, Color.WHITE,
		true, 0, Color.WHITE
	)
	

	
func _on_speaker_name_changed(new_text: String):
	editor_data.set_speaker_name(new_text)


func sync_data_from_inputs():
	editor_data.set_speaker_name($speaker_name_input.text)
	editor_data.set_content($content_input.text)


func _on_content_changed():
	var line_count = $content_input.get_line_count()
	var line_height = $content_input.get_line_height()
	$content_input.custom_minimum_size.y = (line_count * line_height + 10)
	editor_data.set_content($content_input.text)
	
	
	
