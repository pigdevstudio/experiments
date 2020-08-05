extends KinematicBody2D

const FLOOR_NORMAL = Vector2.UP
const SNAP_DIRECTION = Vector2.DOWN
const SNAP_LENGTH = 32
const SLOPE_LIMIT = deg2rad(45)

export(float) var speed = 500.0
export(float) var gravity = 2000.0
export(float) var jump_strength = 800.0

var direction = Vector2.ZERO
var velocity = Vector2.ZERO
var snap_vector = SNAP_DIRECTION * SNAP_LENGTH

onready var sprite = $Sprite


func _physics_process(delta):
	move(delta)


func _unhandled_input(event):
	handle_input(event)


func handle_input(event):
	if event.is_action("left") or event.is_action("right"):
		update_direction()
	if event.is_action_pressed("jump"):
		if Input.is_action_pressed("down"):
			fall_through()
		else:
			jump()
	elif event.is_action_released("jump"):
		cancel_jump()
		cancel_fall_through()


func move(delta):
	velocity.y += gravity * delta
	velocity.y = move_and_slide_with_snap(velocity, snap_vector, FLOOR_NORMAL).y
	if is_on_floor():
		snap_vector = SNAP_DIRECTION * SNAP_LENGTH


func jump():
	if is_on_floor():
		snap_vector = Vector2.ZERO
		velocity.y = -jump_strength


func cancel_jump():
	if not is_on_floor() and velocity.y < 0.0:
		velocity.y = 0.0


func fall_through():
	if is_on_floor():
		set_collision_mask_bit(1, false)


func cancel_fall_through():
	if get_collision_mask_bit(1) == false:
		set_collision_mask_bit(1, true)


func update_direction():
	direction.x = Input.get_action_strength("right") - Input.get_action_strength("left") 
	velocity.x = direction.x * speed
	if not velocity.x == 0:
		sprite.flip_h = velocity.x < 0
