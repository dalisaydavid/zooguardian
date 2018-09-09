extends Node2D

var health

var velocity
var kinematic_body

var is_pushed
var push_velocity

var walk_speed = 10000
var direction
var last_direction_change
var last_attack

var action_area_top
var action_area_bottom
var action_area_left
var action_area_right

var bodies_in_earshot
var followable_bodies_in_earshot
var last_body_in_earshot
var last_earshot_check

func _ready():
	set_physics_process(true)
	
	kinematic_body = get_node('KinematicBody2D')
	
	health = 1
	
	is_pushed = false
	push_velocity = Vector2(0,0)
	velocity = Vector2(0,0)

	direction = ""
	last_direction_change = 0
	last_attack = 0
	
	bodies_in_earshot = []
	last_body_in_earshot = null
	last_earshot_check = 0
	followable_bodies_in_earshot = []
	
	action_area_top = get_node("KinematicBody2D/ActionAreaTop")
	action_area_bottom = get_node("KinematicBody2D/ActionAreaBottom")
	action_area_left = get_node("KinematicBody2D/ActionAreaLeft")
	action_area_right = get_node("KinematicBody2D/ActionAreaRight")

func _physics_process(delta):
	if health <= 0:
		get_node("/root/Global").total_poachers_removed += 1
		queue_free()
		
	# Detect if being pushed.
	if is_pushed:
		var motion = push_velocity * delta
		kinematic_body.move_and_slide(motion)
		is_pushed = false
	
	# Detect if any bodies are in earshot.
	if has_followable_bodies_in_earshot():
		handle_followable_bodies_in_earshot()
	else:
		# Choose a new direction every 2 seconds.
		if OS.get_ticks_msec() - last_direction_change >= 2000:
			var movement_direction = choose_random_move_direction(walk_speed, direction)
			self.velocity = movement_direction[0]
			self.direction = movement_direction[1]
		
	# Attack every 2 seconds.
	if OS.get_ticks_msec() - last_attack >= 2000:
		# Attack friendlies in earshot.
		attack_friendlies()
		
		# Attack any hittable and buildable things.
		attack_buildables()
			
	 
	var motion = velocity * delta
	kinematic_body.move_and_slide(motion)

func attack_friendlies():
	if bodies_in_earshot.size():
		for body in bodies_in_earshot:
			if in_attack_range(body) and body.get_parent().is_in_group("Animal") and not body.get_parent().is_in_group("Enemy"):
				attack(body)

func attack_buildables():
	if bodies_in_earshot.size():
		for body in bodies_in_earshot:
			if in_attack_range(body) and body.get_parent().is_in_group("Buildable"):
				attack(body)
				
	
func has_followable_bodies_in_earshot():
	for body in bodies_in_earshot:
		if body.get_parent().is_in_group("Followable"):
			return true
	return false
	
func handle_followable_bodies_in_earshot():
	followable_bodies_in_earshot = []
	for body in bodies_in_earshot:
		if body.get_parent().is_in_group("Followable"):
			followable_bodies_in_earshot.append(body)
			
	move_towards(followable_bodies_in_earshot.back())

func in_attack_range(body):
	return action_area_top.overlaps_body(body) or action_area_bottom.overlaps_body(body) or action_area_left.overlaps_body(body) or action_area_left.overlaps_body(body)

func move_towards(body):
	var horizontal_move = false
	var horizontal_walk_speed = Vector2(0,0)
	var direction = null
	var vertical_move = false
	var vertical_walk_speed = Vector2(0,0)
	self.velocity = Vector2(0,0)
	if (body.global_position.x-kinematic_body.global_position.x) >= 10:
		horizontal_move = true
		horizontal_walk_speed = walk_speed
		direction = 'up'
	elif (body.global_position.x-kinematic_body.global_position.x) <= -10:
		horizontal_walk_speed = -1*walk_speed
		horizontal_move = true
		direction = 'down'
	
	if (body.global_position.y-kinematic_body.global_position.y) >= 10:
		vertical_walk_speed = walk_speed
		vertical_move = true
		direction = 'left'
	elif (body.global_position.y-kinematic_body.global_position.y) <= -10:
		vertical_walk_speed = -1*walk_speed
		vertical_move = true
		direction = 'right'
	
	if horizontal_move and vertical_move:
		self.direction = direction
		randomize()
		var random_move_choice = randi()%2
		if random_move_choice == 0:
			self.velocity.x = horizontal_walk_speed
		else:
			self.velocity.y = vertical_walk_speed
	elif horizontal_move and not vertical_move:
		self.direction = direction
		self.velocity.x = horizontal_walk_speed
	elif vertical_move and not horizontal_move:
		self.direction = direction
		self.velocity.y = vertical_walk_speed
		
func attack(body):
	if body.get_parent().is_in_group('Hittable') and not body.get_parent().is_in_group('Enemy'):
		body.get_parent().take_damage(1)
				
	last_attack = OS.get_ticks_msec()

func attack_in_direction():
	var area
	if self.direction == "up":
		area = get_node("KinematicBody2D/ActionAreaTop")
	elif self.direction == "down":
		area = get_node("KinematicBody2D/ActionAreaBottom")
	elif self.direction == "left":
		area = get_node("KinematicBody2D/ActionAreaLeft")
	elif self.direction == "right":
		area = get_node("KinematicBody2D/ActionAreaRight")

	if area != null:
		var overlapping_bodies = area.get_overlapping_bodies()
		if overlapping_bodies.size() > 0:
			for body in overlapping_bodies:
				print(get_name(), " attacking ", body.get_parent().get_name(), " in the ", self.direction, "direction.")
				if body.get_parent().is_in_group('Hittable') and not body.get_parent().is_in_group('Enemy'):
					body.get_parent().take_damage(1)
				
	last_attack = OS.get_ticks_msec()

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
	elif random_move_choice == 1:
		movement.x = step*-1 #rand_range(1, step)*-1
	elif random_move_choice == 2:
		movement.y = step #rand_range(1, step)*1
	else:
		movement.y = step*-1 #rand_range(1, step)*-1

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
	health = health - damage

	var floating_text = load("res://prefabs/FloatingText.tscn").instance()
	floating_text.global_position = kinematic_body.global_position
	get_parent().add_child(floating_text)


func _on_Earshot_body_entered(body):
	if body.get_parent() != self:
		bodies_in_earshot.append(body)


func _on_Earshot_body_exited(body):
	if body.get_parent() != self:
		bodies_in_earshot.remove(bodies_in_earshot.find(body))

