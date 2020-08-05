# Jump with snap

In the first experiment about moving on slopes, I mentioned that with the `move_and_slide_with_snap` jumping would become a tricky feature. This is because since the character will stay snapped to the floor as long as the `snap_vector` touches the floor, it would be impossible to apply a force that would push the character upwards.

But...guess what? There is a simple workaround to handle those situations.

![](https://img.itch.zone/aW1nLzM5MzE0NjUuZ2lm/original/h%2BaYrA.gif)

_Download the Jump with Snap experiment_:

<iframe frameborder="0" src="https://itch.io/embed/679971" width="552" height="167"><a href="https://pigdev.itch.io/experiments">Gamedev Experiments by Pigdev</a></iframe>

## Zeroing the snap vector

I don't want to waste your time with fancy approaches. Neither I'll go through the implementation of a normal jump, you can check other tutorials for that or just read the `Player.gd` file is quite simple.

The way you can enable the jump in `KinematicBody2Ds` that move with `move_and_slide_with_snap` is by passing a `snap_vector` with **no length**. This ensures that the `snap_vector` never touches the floor, thus the character won't be snapped.

```
func jump():
	if is_on_floor():
		snap_vector = Vector2.ZERO
		velocity.y = -jump_strength
```

We first check if the character `is_on_floor()` because we don't want to jump in middle air, then we set the `snap_vector` to `Vector2.ZERO` and only after that we apply the jump force using `jump_strength` note it's negative because to move up we need negative values.

## Turning on the snap again

Note that with only the above implementation, after the first jump the character would never snap to the floor again and would not move on slopes properly.

![](https://img.itch.zone/aW1nLzM5MzE0NjYuZ2lm/original/%2BS954J.gif)

Remember in the move on slopes experiment that we had two constants for the `SNAP_DIRECTION` and the `SNAP_LENGTH`? Now is time to fall back to them.

Whenever we jump and touch the floor again we want to enable snapping again when the character moves, for that as soon as we touch the floor, i.e. `is_on_floor() == true`, we set the `snap_vector` back to its defaults using those constants.


```
func move(delta):
	velocity.y += gravity * delta
	velocity.y = move_and_slide_with_snap(velocity, snap_vector,
			FLOOR_NORMAL, true).y

	if is_on_floor() and snap_vector == Vector2.ZERO:
		reset_snap()

func reset_snap():
	snap_vector = SNAP_DIRECTION * SNAP_LENGTH
```

With that our character is ready to jump like a kangaroo!

![](https://img.itch.zone/aW1nLzM5MzE0NjguZ2lm/original/vSY4G6.gif)

If you have any questions or if something wasn't clear, please leave a comment below. Don't forget to [join the community](https://pigdev.itch.io/experiments/community) to discuss this and more topics as well. You can also make [requests](https://itch.io/board/791663/requests) for more experiments you'd like me to do.

That's it for this experiment, thank you a lot for reading. _**Keep developing and until the next time!**_
