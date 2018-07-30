extends Node2D

const walk_speed = 25000

var velocity
var motion

var kinematic_body

func _ready():
	set_physics_process(true)
	set_process_input(true)

	velocity = Vector2()	
	kinematic_body = get_node('KinematicBody2D')

func _physics_process(delta):
	# Handle movement inputs every frame.
	velocity.y = 0
	velocity.x = 0

	handle_movement()
	motion = velocity * delta
	kinematic_body.move_and_slide(motion)

func handle_movement():
	if (Input.is_key_pressed(KEY_A)):
		velocity.x = -walk_speed
	elif (Input.is_key_pressed(KEY_D)):
		velocity.x =  walk_speed
	elif (Input.is_key_pressed(KEY_W)):
		velocity.y = -walk_speed
	elif (Input.is_key_pressed(KEY_S)):
		velocity.y =  walk_speed
		
