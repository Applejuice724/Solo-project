# Test sutie for the dialogue manager
extends GdUnitTestSuite
# TODO
#- More unit testing to ensure that systems are working as intended
#- test_start_dialogue_sets_current_node()
#- test_continue_dialogue_moves_to_next_node()
#- test_end_dialogue_clears_current_node()
#- test_set_state_value_updates_state()
#- test_add_int_action_increases_value()

func test_has_visited_node():
	var manager = auto_free(DialogueManager.new())
	var node := DialogueNode.new(
		"start", "NPC", "", "Hello", "", [], [], [], [], true)
	var tree := DialogueTree.new(
		"test_tree",
		[node],
		""
	)
	manager.register_dialogue_tree(tree)
	manager.set_current_dialogue_tree_by_index(0)
	manager.start_dialogue()
	assert_bool(manager.has_visited_node(0)).is_true()
	
func test_has_not_visited_node():
	var manager = auto_free(DialogueManager.new())
	var node_a := DialogueNode.new(
		"a", "", "", "", "b", [], [], [], [], true)
	var node_b := DialogueNode.new(
		"b", "", "", "", "", [], [], [], [], true)
	var tree := DialogueTree.new(
		"test_tree", [node_a, node_b], "")
	manager.register_dialogue_tree(tree)
	manager.set_current_dialogue_tree_by_index(0)
	manager.start_dialogue()
	assert_bool(manager.has_visited_node(0)).is_true()
	assert_bool(manager.has_visited_node(1)).is_false()
	manager.free()
	
func test_register_dialogue_tree_returns_correct_index():
	var manager = auto_free(DialogueManager.new())
	var node_b := DialogueNode.new(
		"b", "", "", "", "", [], [], [], [], true)
	var tree_a := DialogueTree.new(
		"test_tree", [node_b], "")
	var node_a := DialogueNode.new(
		"a", "", "", "", "b", [], [], [], [], true)
	var tree_b := DialogueTree.new(
		"test_tree", [node_a], "")	
	manager.register_dialogue_tree(tree_a)
	assert_bool(manager.get_dialogue_tree_at_index(0) == tree_a)
	manager.register_dialogue_tree(tree_b)
	assert_bool(manager.get_dialogue_tree_at_index(1) == tree_b)
	manager.free()
	
func test_end_dialogue_clears_current_node():
	var manager = auto_free(DialogueManager.new())
	var node := DialogueNode.new(
		"start", "NPC", "", "Hello", "", [], [], [], [], true)
	var tree := DialogueTree.new(
		"test_tree",
		[node],
		""
	)
	manager.register_dialogue_tree(tree)
	manager.set_current_dialogue_tree_by_index(0)
	manager.start_dialogue()
	manager.end_dialogue()
	assert_bool(manager.get_current_node() == null)
	manager.free()
	
func test_if_has_active_dialogue_reports_correctly():
	var manager = auto_free(DialogueManager.new()) as DialogueManager
	_setup_typcial_conditions(manager)
	manager.start_dialogue()
	assert_bool(manager.has_dialogue_active() == true)
	manager.end_dialogue()
	assert_bool(manager.has_dialogue_active() == false)
	
	
## Sets a typical case for testing purposes	
func _setup_typcial_conditions(manager : DialogueManager) ->void:
	var node := DialogueNode.new(
		"start", "NPC", "", "Hello", "", [], [], [], [], true)
	var tree := DialogueTree.new(
		"test_tree",
		[node],
		""
	)
	manager.register_dialogue_tree(tree)
	manager.set_current_dialogue_tree_by_index(0)
	
	
	
