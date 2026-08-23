extends Node


func _ready():
	#_test_loader()
	#_test_manager()
	pass
	

			
func _test_loader():
	var Dialogue_file_path = "res://scripts/Dialogue_system/test_data/test.json"
	var loader = DialogueLoader.new()
	var Dialogue_node_map = loader.load_dialogue(Dialogue_file_path)
	print(Dialogue_node_map)
	for node in Dialogue_node_map:
		node.print_Dialogue_node()
		for choice in node.get_choices():
			choice.print_choice_data()
			
func _test_manager():
	var Dialogue_file_path = "res://scripts/Dialogue_system/test_data/test.json"
	var manager = DialogueManager.new()
	manager.load_Dialogue(Dialogue_file_path)
	var node = manager.start_Dialogue_tree("bree_intro")
	# Initial Dialogue node
	node.print_Dialogue_node()
	# Loop through Dialogue
	while (node != null):
		node = _test_advance(node, manager, 0)

# This will ideally trigger only when the player does an action
# I.E when the player chooses an option or presses a button to continue
func _test_advance(node, manager, choice_seleciton):	
	if node.if_has_choices():
		var next_node = _test_make_choice(node, choice_seleciton)		
		node = manager.advance_Dialogue_tree(next_node)
	else:
		node = manager.advance_Dialogue_tree()
	if (node != null):
		node.print_Dialogue_node()
	return node
	
# Test choice being made
func _test_make_choice(node, choice_seleciton):
	var choices = node.get_choices()
	var choosen_choice = choices[choice_seleciton]
	choosen_choice.print_choice_data()
	var next_node = choosen_choice.get_next_node_as_index()	
	return next_node
	
	
	
