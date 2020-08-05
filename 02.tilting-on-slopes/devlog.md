# Tilting on Slopes

In the tutorial about handling slope movement, [@intelligenced](https://itch.io/profile/intelligenced) asked about [tilting the character parallel](https://itch.io/post/1586517) to the slope. So I decided to make a quick experiment reusing the Slope Movement, which also just got updated with a small refactoring to encapsulate the moving logic into a `_move` method.

Now in this experiment, I've approached tilting the character based on the slope's angle. But how to get the slope angle, you might be thinking, right? We'll see in this new tutorial.

![](https://img.itch.zone/aW1nLzM3NzYyMDkuZ2lm/original/4fO7IA.gif)

## What is a slope?

Well, the first thing to understand when we are dealing with a slope is..._what a slope is?_

The cool thing about programming and game development especially is that things are what you want them to be. That's what a _variable_ or a _method_ declaration is, you name something and describe what this thing is.

In our context, the KinematicBody2D's [`move_and_slide_with_snap`](https://docs.godotengine.org/en/stable/classes/class_kinematicbody2d.html#class-kinematicbody2d-method-move-and-slide-with-snap) allows us to pass an argument (`floor_max_angle`) to describe when the floor stops...being floor. In the documentation, it states that:

> `floor_max_angle` is the maximum angle (in radians) where a slope is still considered a floor (or a ceiling), rather than a wall. The default value equals 45 degrees.

It's very interesting how programming is essentially a philosophical debate. Imagine you're debating how an object should move on a slope and the person asks you "What is a slope?" you **argue** (give an argument) that a slope is a part of the floor or ceiling with an angle lower than `45` degrees. Now that this person knows the definition of a slope, you can keep your debate. The same thing goes here.

In our case, our definition of a slope uses the value from a _const_ that I've declared right below the `SNAP_LENGTH`. I've called it `SLOPE_LIMIT` because beyond this angle the _KinematicBody2D_ can consider that it is handling a wall. I've set the `SLOPE_LIMIT` to be `46` degrees because I want to consider slopes up to `45` degrees.

I've used the `deg2rad` built-in function to convert degrees to radians since the `floor_max_angle` works in radians.

```
extends KinematicBody2D

const FLOOR_NORMAL = Vector2.UP
const SNAP_DIRECTION = Vector2.DOWN
const SNAP_LENGTH = 64.0
const SLOPE_LIMIT = deg2rad(46)

```

This is something that also got to the _Slope Movement_ latest update.

## Getting the Slope angle

Do you know how collisions work in Godot? Well...neither do I, but I do know that we can have access to a lot of information regarding them. But here comes the trick...we better not use the [_KinematicBody2D's_ `get_slide_collision`](https://docs.godotengine.org/en/stable/classes/class_kinematicbody2d.html#class-kinematicbody2d-method-get-slide-collision) because it doesn't always update us since the character doesn't always slide. Here is how this implementation behaves:

![](https://img.itch.zone/aW1nLzM3NzYyMTEuZ2lm/original/%2BSwl7Z.gif)

We need a reliable way to always be updated about the floor's angle. And for that, I present you [**RayCast2D**](https://docs.godotengine.org/en/stable/classes/class_racom aycast2d.html). A _RayCast2D_ allows us to constantly check the floor. It does that by casting a `Vector2` and checking for physical bodies, or even areas. If it intersects with one of those it immediately triggers a collision and stores data about this collision.

One advantage of _RayCast2Ds_ is that they don't accumulate collisions, so if there are 3 possible intersections between the casting point and the target point, it only triggers the first collision.

To tell the _RayCast2D_ where it should cast to...we use the [`cast_to`](https://docs.godotengine.org/en/stable/classes/class_raycast2d.html#class-raycast2d-property-cast-to) property. I love how explicit Godot is. In this experiment, I've used a value of `Vector2(0, 32)`.

But why all that? WHY?! Why are we still here, just to suffer?

Turns out that, as I've mentioned, the _RayCast2D_ stores information about the current collision, including the most meaningful for us in this context: the collision normal.

Using the [`get_collision_normal`](https://docs.godotengine.org/en/stable/classes/class_raycast2d.html#class-raycast2d-method-get-collision-normal) method we can...get...the collision's normal...see? It's not even funny. You try to explain the thing and it's pointless because Godot's engineers did it already. So here goes the code, guess by yourself.

```
func _tilt():
	if is_on_floor() and raycast.is_colliding():
		var normal = raycast.get_collision_normal()
```

Ohh, wait. I forgot to tell what a _collision normal_ is right? So, briefly, a collision normal is a vector that only contains the collision's direction data, its values can range from -1 to 1 and it always has a length of `1`, meaning it is a unitary vector. You can check the [Godot documentation about working with vectors](https://docs.godotengine.org/en/stable/tutorials/math/vector_math.html?highlight=vectors#normalization) for more information.

Why having the collision normal is so important? **READ THE HEADER!**

Yes, using the collision normal is the secret to get the slope's angle. _But how?! How a vector will give me an angle?_ You might be asking yourself, right? Well, turns out that all `Vector2` have a fun property of _having an angle_.

See, in Godot a `Vector2` that points straight to the right, in other words `Vector2.RIGHT` or rather `Vector2(1, 0)`, independently from its length will always have an angle of...**ZERO** degrees! Yes, in Godot Engine we start measuring angles with `Vector2.RIGHT` as base. From there, since vectors are essentially lines, you just need to know the angle between your `Vector2` and `Vector2.RIGHT`. For instance, `Vector2.DOWN`, a.k.a `Vector2(0, 1)`, gives us an angle of `90` degrees.

To know the angle of a `Vector2` you can simply call [`angle()`](https://docs.godotengine.org/en/stable/classes/class_vector2.html?highlight=vector2#class-vector2-method-angle) on any `Vector2` and it returns an angle in radians.

There we have it. Now that we know the slope's angle, let's tilt the character accordingly.

## Tilting the character

Now that we know the slope's angle we just need to rotate accordingly, right? Well...kinda.

See, this tilting, ideally, is just a visual cue for the player, in another post I'll comment the design implications of that, but what you need to know is that you, ideally, shouldn't rotate the whole `KinematicBody2D` but instead just the visual components, in this case, the `Sprite`.

BUT WAIT! You can't simply apply the slope angle as the `Sprite.rotation`. Had you forgotten how we count angles in Godot? Yes, with `Vector2.RIGHT` being `0.0` degrees. And why is this a problem? Because unless your character is drawn like this:

![](https://img.itch.zone/aW1nLzM3NzYyMTUucG5n/original/4r59gi.png)

It won't rotate properly. So we need to add an offset angle...unless you really draw characters like that.

So, we are going to offset the slope's angle by `90.0` degrees in order to properly tilt our character parallel to the slope. And this is how the tilt method looks like at the end.

```
func _tilt():
	if is_on_floor() and raycast.is_colliding():
		var normal = raycast.get_collision_normal()
		sprite.rotation = normal.angle() + deg2rad(90)
```

For full context, you can download the **Tilting on Slopes** files. And we that we finished this tutorial.

You can discuss these topics and more at the [project's community](https://pigdev.itch.io/recipes/community). Also, you can make requests there for future experiments.

That's it, thank you so much for reading. _*Keep developing and until the next time!*_
