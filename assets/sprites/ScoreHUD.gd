extends Node2D

var animals_protected_label
var fences_label
var attack_or_build_label
var prefix

func _ready():
	set_process(true)
	animals_protected_label = get_node('CanvasLayer/VBoxContainer/AnimalsProtectedLabel')
	fences_label = get_node('CanvasLayer/VBoxContainer/FencesLabel')
	attack_or_build_label = get_node('CanvasLayer/VBoxContainer/AttackOrBuildLabel')

func _process(delta):
	var animal_count = get_parent().get_animal_count()
	animals_protected_label.text = "Animals Protected: " + str(animal_count) + "/" + str(get_node("/root/Global").total_animals_created)
	
	var darwin_fences_count = get_parent().get_node('Darwin').fence_count
	fences_label.text = "Fences: " + str(darwin_fences_count)
	
	var attack_or_build = "Toggle Action: "
	if get_parent().get_node('Darwin').toggle_action:
		attack_or_build = attack_or_build + "Attack"
	else:
		attack_or_build = attack_or_build + "Build"
	attack_or_build_label.text = attack_or_build
	
	