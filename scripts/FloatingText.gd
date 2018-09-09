extends Node2D

var alive_ticks
var step = 40
var text

func _ready():
	set_process(true)
	alive_ticks = 0
	text = "1"
	
func _process(delta):
	if alive_ticks > 35:
		queue_free()
	self.move_local_y((-1*step)*delta)
	alive_ticks = alive_ticks + 1
	
	get_node("RichTextLabel").clear()
	get_node("RichTextLabel").add_text(text)
