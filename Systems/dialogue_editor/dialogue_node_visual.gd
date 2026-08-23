extends GraphNode

class_name DialogueNodeVisual
var editor_data: dialogue_node_editor_data


func setup(data : dialogue_node_editor_data):
	editor_data = data
	title = data.get_id_as_string()
	$speaker_name_input.text = data.get_speaker_name()
	$content_input.text = data.get_content()
	setup_ports()
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
	

	
func _on_content_changed():
	var line_count = $content_input.get_line_count()
	var line_height = $content_input.get_line_height()
	$content_input.custom_minimum_size.y = (line_count * line_height + 10)
	
