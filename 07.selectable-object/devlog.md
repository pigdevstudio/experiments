# Selectable Objects

In many strategy games is common to have multiple controllable units. A cool mechanic to have in these situations is to allow the player to select only one unit to control at a time.

![](https://img.itch.zone/aW1nLzM5NjcwMDIuZ2lm/original/qio8mP.gif)

_Download the Selectable Objects experiment_

<iframe frameborder="0" src="https://itch.io/embed/679971?linkback=true" width="552" height="167"><a href="https://pigdev.itch.io/experiments">Gamedev Experiments by Pigdev</a></iframe>


So, let's see in this experiment a quick way to set up a selection system for in-game objects!

## Selection Area

The major concern here is to identify if the player clicked or not on the unit. Well...guess what? Yes, Godot allows us to make that kind of thing really easily.

Using [CollisionObject2D's `_input_event` callback ](https://docs.godotengine.org/en/stable/classes/class_collisionobject2d.html#class-collisionobject2d-method-input-event) we can detect if there was a click event inside a CollisionObject2D's CollisionShape2D.

Since an Area2D inherits from CollisionObject2D we can create a reusable class to communicate selection events, i.e. a SelectionArea. To do that we can create a boolean `selected` variable and toggle it whenever the player clicked inside our SelectionArea.

```
extends Area2D

var selected = false setget set_selected


func _input_event(viewport, event, shape_idx):
	if event.is_action_released("select"):
		set_selected(not selected)


func set_selected(select):
  selected = select
```

The line `set_selected(not selected)` might be confusing, so let me explain it. It basically set the `selected` variable to the opposite of what it currently is, i.e. if it currently is `true` it becomes `false` and vice versa, this is how to easily toggle a `bool`.

> Why did we encapsulate `selected` inside the `set_selected` method?

I knew you would ask that!

Well, put it simply: we didn't finish the code yet. Don't haste me.

This SelectionArea is not very useful if it doesn't notify other objects when the `selected` variable changes. So let's create a new signal to communicate that and emit it right after we set the `selected` variable in the `set_selected` method. See? That's why we need it, we are going to encapsulate some processes together.

```
extends Area2D

signal selection_toggled(selected)

var selected = false setget set_selected


func _input_event(viewport, event, shape_idx):
	if event.is_action_released("select"):
		set_selected(not selected)


func set_selected(select):
  selected = select
  emit_signal("selection_toggled", selected)
```

## Preventing multiple selections

As it is our SelectionArea already does its job, but...we may want to prevent multiple SelectionAreas from being selected at the same time. For that, we can make this a self-contained system. Every time a SelectionArea gets selected we are going to deselect every other SelectionArea that was selected before. For that, we can rely on Node groups.

Whenever the SelectionArea gets selected we are going to run through all the other SelectionAreas that were in the `"selected"` group and deselect them, making this one exclusively selected.

```
func set_selected(select):
	if select:
		_make_exclusive()
		add_to_group("selected")
	else:
		remove_from_group("selected")
	selected = select
	emit_signal("selection_toggled", selected)


  func _make_exclusive():
  	for selection_area in get_tree().get_nodes_in_group("selected"):
  		selection_area.selected = false

```

As I said, this is an `optional` feature, maybe you want to be able to have multiple selected objects, or you may want to toggle this feature on/off based on if the `CTRL` key is held. In any case, we can export a `bool` variable to be able to control this behavior. Then we just need to return from the `_make_exclusive` method before deselecting other SelectionAreas if `exclusive == false`. The SelectionArea class final version looks like this after this addition:

```
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
		remove_from_group("selected")
	selected = select
	emit_signal("selection_toggled", selected)


func _make_exclusive():
	if not exclusive:
		return
	for selection_area in get_tree().get_nodes_in_group("selected"):
		selection_area.selected = false
```

With that, making them exclusive is as simple as changing the `exclusive` variable to `false`. This can be done even in the Inspector during the playtest.

![](https://img.itch.zone/aW1nLzM5NjcwMDMuZ2lm/original/c8KllI.gif)
![](https://img.itch.zone/aW1nLzM5NjcwMDUuZ2lm/original/C74xUp.gif)

## Using the Selection Area

Now we just need to use this class together with the object we want to be selectable and using the `selection_toggled` signal we can modify its behavior accordingly.

For instance, in the demo experiment, I just set the Player units to don't process inputs if they aren't selected. I also display a Label with a "Selected" text if the character is selected.

```
func _on_SelectableArea2D_selection_toggled(selected):
	set_process_unhandled_input(selected)
	label.visible = selected

```

If you have any questions or if something wasn't clear, please leave a comment below. Don't forget to [join the community](https://pigdev.itch.io/experiments/community) to discuss this and more topics as well. You can also make [requests](https://itch.io/board/791663/requests) for more experiments you'd like me to do.

That's it for this experiment, thank you a lot for reading. _**Keep developing and until the next time!**_
