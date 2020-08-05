extends KinematicBody2D

const FLOOR_NORMAL = Vector2.UP
const SNAP_DIRECTION = Vector2.DOWN
const SNAP_LENGTH = 64.0
const SLOPE_LIMIT = deg2rad(46)

export(float) var speed = 500.0
export(float) var gravity = 2000.0

var direction = Vector2.ZERO
var velocity = Vector2.ZERO
var snap_vector = SNAP_DIRECTION * SNAP_LENGTH

onready var sprite = $Sprite
onready var raycast = $RayCast2D
onready var anim_tree = $AnimationTree


func _physics_process(delta):
	_move(delta)
	_tilt()



func _move(delta):
	velocity.y += gravity * delta
	velocity.y = move_and_slide_with_snap(velocity, snap_vector, FLOOR_NORMAL,
			true, 4, SLOPE_LIMIT).y


func _tilt():
	var blend_position = 0.0
	if is_on_floor() and raycast.is_colliding():
		var normal = raycast.get_collision_normal()
		blend_position = abs(normal.aspect())
	anim_tree.set("parameters/blend_position", blend_position)


func _unhandled_input(event):
	if event.is_action("left") or event.is_action("right"):
		update_direction()


func update_direction():
	direction.x = Input.get_action_strength("right") - Input.get_action_strength("left") 
	velocity.x = direction.x * speed
	if not velocity.x == 0:
		sprite.flip_h = velocity.x < 0
