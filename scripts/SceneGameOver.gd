extends Node2D

var message_label
var guard_score_label
var poacher_score_label

var	message_label_prefix_text
var	guard_score_label_prefix_text
var	poacher_score_label_prefix_text
var global

func _ready():
	message_label = get_node("CanvasLayer/VBoxContainer/MessageLabel")
	guard_score_label = get_node("CanvasLayer/VBoxContainer/GuardScoreLabel")
	poacher_score_label = get_node("CanvasLayer/VBoxContainer/PoacherScoreLabel")
	
	message_label_prefix_text = "Animals: 'You tried.'"
	guard_score_label_prefix_text = "Protected animals for "
	poacher_score_label_prefix_text = "Removed "
	
	global = get_node("/root/Global")
	set_guard_score(str((global.game_end_time - global.game_start_time)/1000.0))
	set_poacher_score(str(global.total_poachers_removed))

func set_guard_score(score):
	guard_score_label.text = guard_score_label_prefix_text + score + " seconds."

func set_poacher_score(score):
	poacher_score_label.text = poacher_score_label_prefix_text + score + " poachers."

