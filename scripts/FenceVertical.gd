extends Node2D

var health

func _ready():
	set_process(true)
	health = 5

func _process(delta):
	if health <= 0:
		queue_free()

func take_damage(damage):
	health = health - damage
