# Moving Platforms

One of the most iconic objects in a platform game is...a platform. But I've been experimenting with them and look, they are kinda complex if you asked me. There's this variant called _Moving Platform_ which has an interesting property: it moves.

Heh, you might be thinking it is a mundane feature, right? It's not! It's complex to handle movement trying to maintain two objects in synced motion.

![](https://img.itch.zone/aW1nLzM4MjA4NDMuZ2lm/original/ZUyx6y.gif)

Well, turns out that Godot has some small secrets here and there that help us achieve proper moving platforms. Let's start with the Player.

## The Player

Did I need a chapter just to tell you that we have to use `move_and_slide_with_snap` for this mechanic? Maybe not, but now that I've done it...

We have to use a `KinematicBody` for the player and move it using `move_and_slide_with_snap`, you can read the [_Slope Movement_](https://pigdev.itch.io/experiments/devlog/157521/slope-movement-in-godot-engine) experiment to know how to use this method properly. Or you can download the _Moving Platform_ experiment and just start from there.

<iframe frameborder="0" src="https://itch.io/embed/679971" width="552" height="167"><a href="https://pigdev.itch.io/experiments">Gamedev Experiments by Pigdev</a></iframe>

_take the chance to make a donation, pretty please_

The reason why we need to use the `move_and_slide_with_snap` is because...it ensures the Player snaps to the moving platform. So as the moving platform moves, the Player will stay in place. So we don't have to handle this manually syncing their velocity. Quite convenient, right?

## The Moving Platform

Now here comes the real trick...Something that people don't realize quite often is that

> _IF A BODY MOVES IT IS KINEMATIC_

I say that to my past self all the time, how could I not think about that back then. I used to try with _StaticBody2D_ because, duh, it's just a platform, _KinematicBody2D_ is for players and whatever. But don't be naive, Godot knows when something moves or not. Don't try to move a _StaticBody_, because it's meant to be static.

So the root of our moving platform is a _KinematicBody2D_, let's add a _CollisionShape_ so it is capable of detecting collisions. And just to have some graphics on the screen I'll draw a rectangle with _Polygon2D_.

![](https://img.itch.zone/aW1nLzM4MjA4NDQuZ2lm/original/%2B1wtxx.gif)

Alright, so turns out _KinematicBody2D_ has a property named _Sync to Physics_. Let's read what the documentation says about it:

> If true, the body's movement will be synchronized to the physics frame. This is useful when animating movement via AnimationPlayer, **for example on moving platforms**

![](https://img.itch.zone/aW1nLzM4MjA4NDguZ2lm/original/1gI7lx.gif)

What a coincidence, right!? It's almost as if when we read the documentation we learn how to do stuff, it's magical.

Let's toggle this property on the Inspector and...I dunno, maybe _animate the movement via AnimationPlayer_?

Using an _AnimationPlayer_ I'll animate the platform movement, it'll be like an elevator it goes up then down.

![](https://img.itch.zone/aW1nLzM4MjA4NTEuZ2lm/original/xXZt6d.gif)

Now, there's a small problem. See, we are animating the Platform _position_, right? So if we instance this Moving Platform as it is, as soon as we play the animation it will go back to the position we animated it.

![](https://img.itch.zone/aW1nLzM4MjA4NTUuZ2lm/original/3QHgX6.gif)

To be able to properly position the Moving Platform we need to make a _Node2D_ the root of the scene and use it to offset the position properly because with that the animation on the _KinematicBody2D_ will be relative to the parent.

![](https://img.itch.zone/aW1nLzM4MjA4NTcuZ2lm/original/UVvqxl.gif)

Now we can properly position our platform in the game's world and as you can see it works wonderfully.

![](https://img.itch.zone/aW1nLzM4MjA4NjAuZ2lm/original/q4Pzen.gif)

Well, there's a small inconvenience with this approach which I think you've already noticed. It is very inconvenient to create keyframes for each and every movement you want your Moving Platform to perform, plus you'd need one animation for each different moving pattern...Fear nothing, I've already solved that and you'll be impressed with how simple it is, coming next week.

![](https://img.itch.zone/aW1nLzM4MjA4NjIuZ2lm/original/fj3Zxo.gif)

Leave a comment below if you are liking the project so far, also let me know if you have any question. By the way, don't forget that we can discuss this and more topics on the [Community](https://pigdev.itch.io/experiments/community) and especially, you can make requests for more experiments on the [Requests](https://itch.io/board/791663/requests) board!

That's it, thank you for reading. _**Keep developing and until the next time!**_
