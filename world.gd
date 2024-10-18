extends Node3D

func _process(_delta: float) -> void:
	if get_tree().get_nodes_in_group("enemies").size() <= 0:
		%win_lose.text = "You Win!"
		await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")
	elif get_tree().get_nodes_in_group("raccoons").size() <= 0:
		%win_lose.text = "You Lose!" 
		await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")

	
