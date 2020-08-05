Still on the mood of platform games, I've made a quick experiment that even simplify a past approach I've made previously on this topic: **Jump through platforms**.

VIDEO: demo

The idea behind this mechanic is quite simple. There are some platforms that the player can pass through and maybe there are some which players can't.

This kind of mechanic relates to how objects collide with each other. We want them to some times collide and some times don't.

To achieve that in Godot Engine we can work with _Collision Layers_ and _Collision Masks_. OK, this can be quite confusing, but once you get it, it is very simple, so let's start by understanding how _Collision Layers_ and _Collision Masks_ work.

## Collision Layers and Collision Masks

You can think about a collision as a two-way interaction, an object can detect collisions with another and other objects can detect collisions with it.

When an object is on a given _Collision Layer_ it means...exactly that, it is part of the collide-able objects of that layer. But if two objects are in the same layer but their _Collision Mask_ don't match this _Collision Layer_ they won't collide.

In other words, _Collision Layers_ tells where the objects are, while the _Collision Masks_ dictates what it collides with. You are going to get it once we make the player pass through the platforms.

## Pass through platforms

The first thing we need to do is to segregate objects that can be passed through and some objects that the players always collide with. For that, we can create two _Physics Layers_. In the _Project > Project Settings > 2d Physics_ we can rename the layers to that they make more sense for us. I named the layer `0` as _general_ and the layer `1` as _pass-through_.

VIDEO: finding the 2d physics options

Quite self-explanatory, right? Things in the _general_ layer are meant for general collisions, while things in the _pass-through_ are meant to be...passed through.

Now, let's go back to our platform. This is a simple platform, not a moving one, but the logic applies to moving platforms as well.

Here we can already decide if the player can pass through the platform when jumping, in other words, from bottom to top. For that, we just need to toggle the `one_way_collision` flag on the _CollisionShape2D_ node.

IMAGE: one way collision toggled

Then to make this a passable through platform, we are going to the _StaticBody2D_ and disable all the _Collision Masks_, we don't want it to detect collisions with other objects, we want other objects to detect collision with it, and for that, we are going to set its _Collision Layer_ to only be in the _pass-through_ layer, i.e. `1`.

IMAGE: platform collision layers and masks

## Jump through mechanic

Now that we have the platforms set, yes that's all we need to do there, we need to set our player to be able to perform this mechanic.

First things first, since our player needs to detect collisions with both _general_ purpose objects and _pass-through_ objects we are going to enable these _Collision Masks_. For the player it doesn't really matter in which _Collision Layer_ it is in, I'll leave it in none.

IMAGE: player collision layers and masks

The way we can achieve the jump through mechanic is by turning off collisions with objects in the _pass-through_ layer and for that, we just need to disable the _pass-through_ mask in the player. Here is a simple method that disables the _pass-through_ mask on the player, just remember that the player, in this case, is a _KinematicBody2D_:

```
func fall_through():
	if is_on_floor():
		set_collision_mask_bit(1, false)
```

I've checked for `is_on_floor` to ensure that the player needs to be on the platform to be able to fall through it.

At some point we want to re-enable the collisions with the _pass-through_ objects, so let's ensure we have a method for that as well.

```
func cancel_fall_through():
	if get_collision_mask_bit(1) == false:
		set_collision_mask_bit(1, true)
```

Note that the `get` and `set_collision_mask_bit` builtin methods only accept the integer value of the _Collision Mask_, we currently can't pass a string with the name of the physics layer. That's why I'm using `get_collision_mask_bit(1)` because the value of the _pass-through_ layer is `1`.

With these two methods setup, we just need to give players control over them through some inputs. In my design I want players to hold down the _Down_ button and press _Jump_ to be able to fall through platforms. And to give them some level of control over the fall through I want them to be able to cancel the fall through at any moment by releasing the _Jump_ button.

```
# Just pressed the "jump" action
  if event.is_action_pressed("jump"):
    # Checks if player is also holding the "down" action
		if Input.is_action_pressed("down"):
			fall_through()
		else:
			jump()
  # Cancels the pass through and the jump when the "jump" action is released
	elif event.is_action_released("jump"):
		cancel_jump()
		cancel_fall_through()

```

Don't forget to let the level's floor always collide with the player, for that you can simply add the ground/floor to the _general_ _Collision Layer_.

IMAGE: floor collision layer and mask

There we have it, players can now jump and fall through our platforms.

What do you think, simple enough once you get how _Collision Layers_ and _Collision Masks_ work, right? Well, if there is anything you didn't understand, let me know in the comments. Don't forget to [join the community](https://pigdev.itch.io/experiments/community) to discuss this and more mechanics. You can also make [requests](https://itch.io/board/791663/requests) for experiments you'd like me to do.

That's it for this experiment, thank you a lot for reading. _**Keep developing and until the next time!**_
