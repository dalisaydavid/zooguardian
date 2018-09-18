extends Node

var game_start_time = OS.get_ticks_msec()
var game_end_time = 0
var total_poachers_removed = 0
var total_animals_created = 1
var current_wave_number = 1
var game_over = false

func reset():
	game_start_time = OS.get_ticks_msec()
	game_end_time = 0
	total_poachers_removed = 0
	total_animals_created = 1
	current_wave_number = 1
	game_over = false