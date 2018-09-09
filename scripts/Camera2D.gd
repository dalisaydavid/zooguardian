extends Camera2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var bodies_in_view
var areas_in_view
func _ready():
	set_process(true)
	shake_on = false
	
	bodies_in_view = []
	areas_in_view = []
	
# Animate this to increase/decrease/fade the shaking
var shake_amount = 1.5
var shake_on
func toggle_shake():
	shake_on = not shake_on
	
func _process(delta):
	#if event.type == InputEvent.MOUSE_MOTION:
	var darwin_position = get_parent().get_node('Darwin/KinematicBody2D').global_position
	self.global_position = darwin_position
	
	if not get_parent().get_node('Darwin').is_last_attack_animation_over():
		shake_on = true
	else:
		shake_on = false

	if shake_on:
		self.set_offset(Vector2( \
			rand_range(-1.0, 1.0) * shake_amount, \
			rand_range(-1.0, 1.0) * shake_amount \
		))

func is_body_in_view(body):
	var body_found = bodies_in_view.find(body)
	return body_found != null
	
func is_area_in_view(area):
	var area_found = areas_in_view.find(area)
	return area != null

func _on_Area2D_body_entered(body):
	bodies_in_view.append(body)

func _on_Area2D_body_exited(body):
	bodies_in_view.remove(bodies_in_view.find(body))

func _on_Area2D_area_entered(area):
	areas_in_view.append(area)

func _on_Area2D_area_exited(area):
	areas_in_view.remove(areas_in_view.find(area))
