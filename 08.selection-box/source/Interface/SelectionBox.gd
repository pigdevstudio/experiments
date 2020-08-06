extends ColorRect

var click_position = Vector2.ZERO

func _ready():
	rect_size = Vector2.ZERO
	set_process(false)


func _process(delta):
	expand_to_mouse()


func _unhandled_input(event):
	if event.is_action("select"):
		if event.is_pressed():
			click_position = get_global_mouse_position()
		else:
			deselect()
			select()
			reset_rect()
		set_process(event.is_pressed())


func expand_to_mouse():
	var mouse_position = get_global_mouse_position()
	
	var min_point = Vector2.ZERO
	min_point.x = min(mouse_position.x, click_position.x)
	min_point.y = min(mouse_position.y, click_position.y)
	set_begin(min_point)
	
	var max_point = Vector2.ZERO
	max_point.x = max(mouse_position.x, click_position.x)
	max_point.y = max(mouse_position.y, click_position.y)
	set_end(max_point)


func select():
	for selection_area in get_tree().get_nodes_in_group("selectable"):
		if get_global_rect().has_point(selection_area.global_position):
			selection_area.exclusive = false
			selection_area.selected = true


func deselect():
	for selection_area in get_tree().get_nodes_in_group("selected"):
		selection_area.exclusive = true
		selection_area.selected = false


func reset_rect():
	rect_size = Vector2.ZERO
