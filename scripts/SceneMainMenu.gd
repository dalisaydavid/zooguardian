extends VBoxContainer

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_MenuButton_mouse_entered():
	get_node("LlamaRun").global_position = get_node("MenuButton/Position2D").global_position
	get_node("UIHover").play(0.0)
	
func _on_MenuButton2_mouse_entered():
	get_node("LlamaRun").global_position = get_node("MenuButton2/Position2D").global_position
	get_node("UIHover").play(0.0)
	
func _on_MenuButton3_mouse_entered():
	get_node("LlamaRun").global_position = get_node("MenuButton3/Position2D").global_position
	get_node("UIHover").play(0.0)

func _on_MenuButton_pressed():
	get_node("/root/Global").reset()
	get_tree().change_scene("res://scenes/Scene0.tscn")

func _on_MenuButton2_pressed():
	get_tree().change_scene("res://scenes/SceneControlMenu.tscn")

func _on_MenuButton3_pressed():
	get_tree().quit()
