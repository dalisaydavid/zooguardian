extends Node2D

func _ready():
	set_process(true)

func _process(delta):
	self.rotation = get_angle_to(get_global_mouse_position()) + rotation
