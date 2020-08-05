We saw in the [Moving Platforms](https://pigdev.itch.io/experiments/devlog/160905/moving-platforms) post that is very easy to achieve Moving Platforms in Godot Engine, but as mentioned at the end it is kinda annoying to design their movement using solely the _AnimationPlayer_. So let's talk about how to design all sorts of movement using a design-friendly approach, again with no code required.

![](https://img.itch.zone/aW1nLzM4ODU5MjUuZ2lm/original/pEdHLo.gif)

## Path Follow Platforms

Yes, if you already know the [_PathFollow2D_](https://docs.godotengine.org/en/stable/classes/class_pathfollow2d.html) node you can see where we are going already, but keep reading because there's a small trick to make this work with _KinematicBody2Ds_.

Let's start from the beginning, we are going to create a scene with a [_Path2D_](https://docs.godotengine.org/en/stable/classes/class_path2d.html#class-path2d) node as root. This is the **core** of our _platform movement designing toolkit_. Through this node, we can create and design paths that can even contain curves!

![](https://img.itch.zone/aW1nLzM4ODU5MzAuZ2lm/original/bozDnV.gif)

The next step is to add a _PathFollow2D_ node as a child of the _Path2D_. As said in the documentation a _PathFollow2D_ is:

> [...] useful for making other nodes follow a path, **without coding the movement pattern**. For that, the nodes must be children of this node. The descendant nodes will then move accordingly when setting an offset in this node.

Quite straight forward, right? Before we add our _MovingPlatform_ as a child of the _PathFollow2D_ let's add an _AnimationPlayer_ as a child of the _Path2DFollow_ and remove the one in the _MovingPlatform_ scene. This is how the scene structure looks like by now:

![](https://img.itch.zone/aW1nLzM4ODU5MzIucG5n/original/wVdr8v.png)

The way we can ensure that no matter the length of the [_Curve2D_](https://docs.godotengine.org/en/stable/classes/class_curve2d.html#curve2d) we create the _PathFollow2D_ always runs through every point is by animating the _Path2DFollow > Unit Offset_ property. This is a unitary version of the _Offset_ property, meaning we can offset the _Path2DFollow_ position in the curve using a value that always goes from `0.0` to `1.0`, or rather, from `0%` to `100%`. So we can create an animation with a single track that interpolates this property along its duration. Don't forget to change the _Path2DFollow/AnimationPlayer > Process Mode_ to "Physics".

Also, if you want the platform to always be moving, remember to toggle the _Autoplay_ option on the animation to ensure it's going to play when we load the game. Otherwise, you have to use some kind of trigger to make it play in the middle of the game, like an _Area2D_ to make the platform move when the player is close.

Now if you try this out...it won't work! Haha, gotcha. You thought there weren't any secrets here, right? This is what happens if you try to test this setup as it is:

![](https://img.itch.zone/aW1nLzM4ODU5MzkuZ2lm/original/F45TlJ.gif)

For some reason, the actual collision shape doesn't get its position updated using this approach, which is quite unfortunate. But here goes the fix.

## Fixing the collision

If we simply add a [_RemoteTransform2D_](https://docs.godotengine.org/en/stable/classes/class_remotetransform2d.html) as a child of the _PathFollow2D_ instead of the _MovingPlatform_ we can use it to point to the _MovingPlatform_, that should now be a child of the _Path2D_.

![](https://img.itch.zone/aW1nLzM4ODU5NDAuZ2lm/original/nK2qaY.gif)

And with that, we fixed the issue! No, I don't know how, I don't know why it just works, there are some cases where we just need to accept that we don't understand certain issues nor their solutions. Like why a wooden spoon prevents the pasta from boiling over, we just accept that it does and life goes on.

## Designing the movement

Now that we have our _platform movement designing toolkit_ in place we just need to create new paths and see the magic happening. There are some notes to keep in mind tho:

- Make sure to always create a new _Curve2D_ otherwise you're going to mess with shared resources
- You can mark the _PathFollowPlatform_ as an _Editable Children_ and play with the animation's duration to speed up or slow down the platform movement.

![](https://img.itch.zone/aW1nLzM4ODU5NDIuZ2lm/original/MoGIbu.gif)
