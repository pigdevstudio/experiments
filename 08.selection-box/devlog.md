In the [Selectable Object experiment](https://pigdev.itch.io/experiments/devlog/166154/selectable-objects) we've seen how to use Area2D to create a SelectableArea to trigger selection on a single object at a time.

But...in strategy games, especially in the RTS genre, it's more likely that we would want players to select multiple units at once. A common solution for this kind of system is a _SelectionBox_.

![](https://img.itch.zone/aW1nLzQwMDI2NzIuZ2lm/original/9%2Bx2I2.gif)

[_Download the SelectionBox experiment!_(https://pigdev.itch.io/experiments)

This is the most common approach in many user interfaces, you've probably used such thing with your OS graphic interface.

The SelectionBox is a rectangle that grows towards the mouse selecting everything inside it once we release the left mouse button.

![](https://img.itch.zone/aW1nLzQwMDI2NzMuZ2lm/original/QKXJpf.gif)

In this experiment's approach, I'm going to take advantage of the previous experiment's SelectableArea, but once you get the idea you can implement it with any CanvasItem.

## Rect resizing

For this system, I'm going to use a [`ColorRect`](https://docs.godotengine.org/en/stable/classes/class_colorrect.html) just to have a decent looking SelectionBox, but you can use any Control node, preferably one that serves pure graphical purposes like a TextureRect.

Then I'll rename it _SelectionBox_ and change the _Color_ property to a transparent blue.

![](https://img.itch.zone/aW1nLzQwMDI2ODUuZ2lm/original/R6RpzM.gif)

Almost everything from here is done code-wise, so let's attach a script to it!

The first that we need to do is to detect when the player presses the left mouse button, here I've created an InputAction on the _Project > Project Settings > Input Map_ and called it "selection", it refers to left mouse button input events.

When the player presses the `selection` InputAction we want to reset the Rect's size. We'll need to know where the player clicked, so let's keep the `click_position` stored in a member variable.

```
extends ColorRect

var click_position = Vector2.ZERO

func _unhandled_input(event):
  if event.is_action("select"):
    if event.is_pressed():
      reset_rect()
      click_position = get_global_mouse_position()


func reset_rect():
  rect_size = Vector2.ZERO
```

With the box in place, we want to be allowed to scale it while holding the left mouse button and dragging the mouse. For that, we are going to expand the SelectionBox by setting its end point to the mouse position with the `set_end` method.

Since we want to do this smoothly whenever the mouse changes its position we are going to `expand_to_mouse` in the `_process` callback.

To prevent this from happening if we are not holding the left mouse button, we can toggle the `_process` callback based on if the `select` action is pressed and start without processing by calling `set_process(false)` at the `_ready` callback.

```
func _ready():
  set_process(false)


func _unhandled_input(event):
	if event.is_action("select"):
		if event.is_pressed():
			reset_rect()
		set_process(event.is_pressed())


func _process(delta):
  expand_to_mouse()


func expand_to_mouse():
  var mouse_position = get_global_mouse_position()
  set_begin(click_position)
  set_end(mouse_position)
```

![](https://img.itch.zone/aW1nLzQwMDI2ODcuZ2lm/original/XY3SfT.gif)

## Fixing begin and end points

Now we have a bit of a problem, our SelectionBox only resizes to the right and bottom, i.e. in the third quadrant.

![](https://img.itch.zone/aW1nLzQwMDI2ODguZ2lm/original/yP%2FbEw.gif)

To fix that we need to fix the begin and end points. The idea is that:

- The begin vertical and horizontal axes should be the minimum value between the current mouse position and the click position
- The end vertical and horizontal axes should be the maximum value between the current mouse position and the click position

Well...for that we can use the `min` and `max` builtin functions to build two new points based on that logic. Our `expand_to_mouse` method should become something like this:

```
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
```

And that should fix that problem!

![](https://img.itch.zone/aW1nLzQwMDI2ODkuZ2lm/original/vvB8xH.gif)

## Selecting selectable stuff

Now, here is where things start to get a bit complicated because is when game systems start to interact with each other and the approaches can become quite _ad hoc-y_.

When we release the left mouse button we want to deselect everything that was selected before and select everything that is selectable.

Why did I say that things get a bit complicated? Simply because I don't know how your selection system works, so you have to guess it yourself. But if you are using my SelectableArea approach you can assume a few things:

- We can toggle a `selected` bool on them
- We can iterate through a `selected` node group to know what is currently selected

But how do we know what is _selectable_ or not? Well...we can use more groups. By adding SelectableAreas to a `selectable` group we can scope down the objects we need to process to know what can be selected when we release the left mouse button.

![](https://img.itch.zone/aW1nLzQwMDI2NTkucG5n/original/RxoPT9.png)

Knowing the selectable objects available we just need to know if their `global_position` is inside the SelectionBox by using the `has_point` method on the SelectionBox global rectangle.

```
func select():
	for selection_area in get_tree().get_nodes_in_group("selectable"):
		if get_global_rect().has_point(selection_area.global_position):
			selection_area.exclusive = false
			selection_area.selected = true
```

Remember that if a `SelectableArea.exclusive = true` it will deselect other SelectableAreas when its `selected` becomes `true`. So to prevent that we set `exclusive` to `false` before selecting it.

Now, to deselect is about the same process, but we have a scope even narrower. Since SelectableAreas add themselves to a `selected` group we just need to iterate on it and set their `selected` variable to `false`

```
func deselect():
	for selection_area in get_tree().get_nodes_in_group("selected"):
		selection_area.exclusive = true
		selection_area.selected = false
```

Finally, we just need to call the `deselect()` method before calling the `select()` when we release the left mouse button and reset it again after we've selected what we want.

```
func _unhandled_input(event):
	if event.is_action("select"):
		if event.is_pressed():
			reset_rect()
			click_position = get_global_mouse_position()
		else:
			deselect()
			select()
      reset_rect()
		set_process(event.is_pressed())
```

Since we are resetting the rect when we release the `select` InputAction, we don't need to reset it again when we click, so we can remove it from the `if event.is_pressed()` branch. The final code looks like this:

```
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

```


---

If you have any questions or if something wasn't clear, please leave a comment below. Don't forget to [join the community](https://pigdev.itch.io/experiments/community) to discuss this experiment and more topics as well.

You can also make [requests](https://itch.io/board/791663/requests) for more experiments you'd like to see.

That's it for this experiment, thank you a lot for reading. _**Keep developing and until the next time!**_
