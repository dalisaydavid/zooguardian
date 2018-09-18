extends Node2D

var current_animal_count

var last_enemy_spawn
var last_animal_spawn
var last_buff_trigger
var last_fence_replenish
var spawn_point_top_right
var spawn_point_bottom_left

var poacher_scene = load("res://prefabs/Poacher.tscn")
var llama_scene = load("res://prefabs/Llama.tscn")
var game_over_scene_name = "res://scenes/SceneGameOver.tscn"

var is_game_over

func _ready():
	set_process(true)
	current_animal_count = 0
	
	last_enemy_spawn = 0
	last_animal_spawn = 0
	last_fence_replenish = 0
	last_buff_trigger = 0
	
	spawn_point_top_right = get_node("SpawnPointTopRight")
	spawn_point_bottom_left = get_node("SpawnPointBottomLeft")
		
	get_node("BackgroundMusic").play()
	
	is_game_over = false

func _process(delta):
	if is_game_over:
		if Input.is_key_pressed(KEY_1):
			get_node("/root/Global").reset()
			get_tree().reload_current_scene()
		elif Input.is_key_pressed(KEY_2):
			get_tree().change_scene("res://scenes/SceneMainMenu.tscn")
		else:
			return
		
	if get_animal_count() <= 0: # or is_darwin_alive() == false:
		print("Lose.")
		get_node("/root/Global").game_end_time = OS.get_ticks_msec()
		var game_over_scene = load(game_over_scene_name)
		add_child(game_over_scene.instance())
		is_game_over = true
		get_node("Darwin").set_process(false)
#		get_tree().change_scene(game_over_scene_name)
		
				
	if OS.get_ticks_msec() - last_enemy_spawn >= 2000:
		spawn_enemy("poacher")
		
	if OS.get_ticks_msec() - last_animal_spawn >= 6000:
		spawn_animal("llama")

	if OS.get_ticks_msec() - last_fence_replenish >= 20000:
		replenish_darwin_fences(2)
		
#	if OS.get_ticks_msec() - last_buff_trigger >= 10000:
#		var animal = get_closest_animal()
#		get_node("Darwin").buff(true, animal.get_buff())

func get_closest_animal():
	var animals = get_tree().get_nodes_in_group("Animal")

	var closest_animal = animals[0]
	var closest_distance_to_darwin = closest_animal.global_position.distance_to(get_node("Darwin").global_position)

	for animal in animals:
		if animal.global_position.distance_to(get_node("Darwin").global_position) < closest_distance_to_darwin:
			closest_animal = animal
			closest_distance_to_darwin = animal.global_position.distance_to(get_node("Darwin").global_position)

	return closest_animal
	

func replenish_darwin_fences(number_of_new_fences):
	if get_node("Darwin").fence_count < get_node("Darwin").max_fence_count:
		get_node("Darwin").fence_count += number_of_new_fences
		last_fence_replenish = OS.get_ticks_msec()

func spawn_enemy(enemy="poacher"):
	if enemy == "poacher":
		var poacher = poacher_scene.instance()
		poacher.global_position = spawn_point_top_right.global_position
		add_child(poacher)
		
	last_enemy_spawn = OS.get_ticks_msec()

func spawn_animal(animal="llama"):
	if animal == "llama":
		var llama = llama_scene.instance()
		llama.global_position = spawn_point_bottom_left.global_position
		add_child(llama)
		get_node("/root/Global").total_animals_created += 1
		
	last_animal_spawn = OS.get_ticks_msec()

func is_darwin_alive():
	return get_node("Darwin").alive

func get_animal_count():
	current_animal_count = 0
	for child in get_children():
		if child.is_in_group("Animal"):
			current_animal_count = current_animal_count + 1
	
	return current_animal_count

