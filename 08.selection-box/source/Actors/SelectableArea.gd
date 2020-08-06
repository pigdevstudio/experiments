extends Area2D

signal selection_toggled(selected)

export var exclusive = true

var selected = false setget set_selected


func _input_event(viewport, event, shape_idx):
	if event.is_action_released("select"):
		set_selected(not selected)


func set_selected(select):
	if select:
		_make_exclusive()
		add_to_group("selected")
	else:
		if is_in_group("selected"):
			remove_from_group("selected")
	selected = select
	emit_signal("selection_toggled", selected)


func _make_exclusive():
	if not exclusive:
		return
	for selection_area in get_tree().get_nodes_in_group("selected"):
		selection_area.selected = false
