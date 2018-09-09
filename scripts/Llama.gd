extends Node2D

var health

var velocity
var kinematic_body

var is_pushed
var push_velocity

var walk_speed = 10050
var direction
var last_direction_change
var last_attack

var animated_sprite

func _ready():
	set_physics_process(true)
	
	kinematic_body = get_node('KinematicBody2D')
	
	health = 3
	
	is_pushed = false
	push_velocity = Vector2(0,0)
	velocity = Vector2(0,0)

	direction = ""
	last_direction_change = 0
	last_attack = 0
	
	animated_sprite = get_node("KinematicBody2D/AnimatedSprite")

func _physics_process(delta):
	if health <= 0:
		queue_free()
		
	if is_pushed:
		var motion = push_velocity * delta
		kinematic_body.move_and_slide(motion)
		is_pushed = false
	
	if OS.get_ticks_msec() - last_direction_change >= 5000:
		var movement_direction = choose_random_move_direction(walk_speed, direction)
		self.velocity = movement_direction[0]
		self.direction = movement_direction[1]
	 
	var motion = velocity * delta
	kinematic_body.move_and_slide(motion)
	
	move_offscreen_indicator()

func move_offscreen_indicator():
	var camera = get_tree().get_root().get_node("Scene0/Camera2D")
	var offscreen_indicator = get_node("OffscreenIndicator")
	
	var old_offscreen_position = Vector2(offscreen_indicator.global_position.x, offscreen_indicator.global_position.y)
	
	offscreen_indicator.global_position.x = kinematic_body.global_position.x
	if not camera.is_area_in_view(offscreen_indicator.get_node("Area2D")):
		offscreen_indicator.global_position = old_offscreen_position
	else:
		old_offscreen_position = offscreen_indicator.global_position

	offscreen_indicator.global_position.y = kinematic_body.global_position.y
	if not camera.is_area_in_view(offscreen_indicator.get_node("Area2D")):
		offscreen_indicator.global_position = old_offscreen_position
	else:
		old_offscreen_position = offscreen_indicator.global_position

func choose_random_move_direction(step, current_dir=""):
	var dir_index = ['right','left','up','down']
	randomize()
	var random_move_choice = randi()%4
	var movement = Vector2()
	var dir = ""
	dir = dir_index[random_move_choice]

	while dir == current_dir:
		randomize()
		random_move_choice = randi()%4
		movement = Vector2()
		dir = dir_index[random_move_choice]

	if random_move_choice == 0:
		movement.x = step # rand_range(1, step)
		animated_sprite.animation = "MoveRight"
	elif random_move_choice == 1:
		movement.x = step*-1 #rand_range(1, step)*-1
		animated_sprite.animation = "MoveLeft"
	elif random_move_choice == 2:
		movement.y = step #rand_range(1, step)*1
		animated_sprite.animation = "MoveDown"
	else:
		movement.y = step*-1 #rand_range(1, step)*-1
		animated_sprite.animation = "MoveUp"

	last_direction_change = OS.get_ticks_msec()
	return [movement,dir]
	
func move(velocity):
	self.velocity.x += velocity.x
	self.velocity.y += velocity.y

func push(velocity):
	is_pushed = true
	push_velocity.x = self.velocity.x + velocity.x
	push_velocity.y = self.velocity.y + velocity.y

func take_damage(damage):
	print(get_name(), " taking ", damage, " damage.")
	health = health - damage
	
	var floating_text = load("res://prefabs/FloatingText.tscn").instance()
	floating_text.global_position = kinematic_body.global_position
	get_parent().add_child(floating_text)


	