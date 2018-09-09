extends Node2D

const walk_speed = 20000

var velocity
var motion

var kinematic_body
var action_area_top
var action_area_bottom
var action_area_left
var action_area_right

var health = 5
var fence_count = 30
var max_fence_count = 30

# 1 or true is attack
# 0 or false is build
var toggle_action

var fence_horizontal_scene = load("res://prefabs/FenceHorizontal.tscn")
var fence_vertical_scene = load("res://prefabs/FenceVertical.tscn")

var alive

var animated_sprite
var start_last_attack_animation
var attack_audio
var build_audio

func _ready():
	set_physics_process(true)
	set_process_input(true)

	velocity = Vector2()	
	kinematic_body = get_node('KinematicBody2D')
	
	action_area_top = get_node('KinematicBody2D/ActionAreaTop')
	action_area_bottom = get_node('KinematicBody2D/ActionAreaBottom')
	action_area_left = get_node('KinematicBody2D/ActionAreaLeft')
	action_area_right = get_node('KinematicBody2D/ActionAreaRight')

	toggle_action = true
	
	alive = true

	animated_sprite = get_node('KinematicBody2D/AnimatedSprite')
	start_last_attack_animation = null
	attack_audio = get_node('KinematicBody2D/AttackAudio')
	build_audio = get_node('KinematicBody2D/BuildAudio')

func _physics_process(delta):
	if health <= 0:
		alive = false
	
	# Handle movement inputs every frame.
	velocity.y = 0
	velocity.x = 0

	handle_movement()
	motion = velocity * delta
	kinematic_body.move_and_slide(motion)

func is_last_attack_animation_over():
	if start_last_attack_animation != null:
		return OS.get_ticks_msec()-start_last_attack_animation > 250
	else:
		return true

func check_if_hit(event):
	var area
	var push_vector
	var is_hit_action = false
	var animation
	
	if (animated_sprite.animation == 'AttackLeft' or animated_sprite.animation == 'AttackRight' or animated_sprite.animation == 'AttackDown' or animated_sprite.animation == 'AttackUp') and animated_sprite.is_playing():
		return
	
	if event.is_action_released("up_action"):
		area = action_area_top
		push_vector = Vector2(0,-100*750)
		animation = "AttackUp"
		is_hit_action = true
	elif event.is_action_released("down_action"):
		area = action_area_bottom
		push_vector = Vector2(0,100*750)
		animation = "AttackDown"
		is_hit_action = true
	elif event.is_action_released("left_action"):
		area = action_area_left
		push_vector = Vector2(-100*750,0)
		animation = "AttackLeft"
		is_hit_action = true
	elif event.is_action_released("right_action"):
		area = action_area_right
		push_vector = Vector2(100*750,0)
		animation = "AttackRight"
		is_hit_action = true
		
	if is_hit_action:		
		animated_sprite.play(animation)
		attack_audio.play(0.0)
		start_last_attack_animation = OS.get_ticks_msec()
		var overlapping_bodies = area.get_overlapping_bodies()
		if overlapping_bodies.size() > 0:
			for body in overlapping_bodies:
				if body.get_parent().is_in_group('Pushable'):
					body.get_parent().push(push_vector)
				if body.get_parent().is_in_group('Hittable') and not body.get_parent().is_in_group('Animal'):
					body.get_parent().take_damage(1)

func can_build_direction(build_direction):
	"""if build_direction == 'up' and action_area_top.get_overlapping_bodies().size() > 0:
		return false
		
	if build_direction =='down' and action_area_bottom.get_overlapping_bodies().size() > 0:
		return false
		
	if build_direction == 'left' and action_area_left.get_overlapping_bodies().size() > 0:
		return false
	
	if build_direction == 'right' and action_area_right.get_overlapping_bodies().size() > 0:
		return false"""
		
	return true

func build(event):
	if fence_count <= 0:
		return false
		
	if event.is_action_released("up_action") and can_build_direction('up'):
		var fence_horizontal_instance = fence_horizontal_scene.instance()
		fence_horizontal_instance.global_position = get_node("KinematicBody2D/ActionAreaTop").global_position
		get_tree().get_root().add_child(fence_horizontal_instance)
		fence_count = fence_count - 1
	elif event.is_action_released("down_action") and can_build_direction('down'):
		var fence_horizontal_instance = fence_horizontal_scene.instance()
		fence_horizontal_instance.global_position = get_node("KinematicBody2D/ActionAreaBottom").global_position
		get_tree().get_root().add_child(fence_horizontal_instance)
		fence_count = fence_count - 1
	elif event.is_action_released("left_action") and can_build_direction('left'):
		var fence_vertical_instance = fence_vertical_scene.instance()
		fence_vertical_instance.global_position = get_node("KinematicBody2D/ActionAreaLeft").global_position
		get_tree().get_root().add_child(fence_vertical_instance)
		fence_count = fence_count - 1
	elif event.is_action_released("right_action") and can_build_direction('right'):
		var fence_vertical_instance = fence_vertical_scene.instance()
		fence_vertical_instance.global_position = get_node("KinematicBody2D/ActionAreaRight").global_position
		get_tree().get_root().add_child(fence_vertical_instance)
		fence_count = fence_count - 1


func toggle_action():
	print("toggle_action=",toggle_action)
	self.toggle_action = !toggle_action

func _input(event):
	if self.toggle_action: 
		check_if_hit(event)
	else:
		build(event)
		
	if event.is_action_released("toggle_action"):
		toggle_action()
	
func take_damage(damage):
	print("Darwin took ", damage, " damage!")
	health = health - damage

func handle_movement():
	var animation = null
	if (Input.is_key_pressed(KEY_A)):
		animation = 'MoveLeft'
		velocity.x = -walk_speed
	elif (Input.is_key_pressed(KEY_D)):
		animation = 'MoveRight'
		velocity.x =  walk_speed
	elif (Input.is_key_pressed(KEY_W)):
		animation = 'MoveUp'
		velocity.y = -walk_speed
	elif (Input.is_key_pressed(KEY_S)):
		animation = 'MoveDown'
		velocity.y =  walk_speed
	elif is_last_attack_animation_over():
		animation = 'Idle'
	
	if is_last_attack_animation_over():
		animated_sprite.animation = animation
