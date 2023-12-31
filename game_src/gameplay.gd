extends Node2D

func _process(_delta: float) -> void:
	if Input.is_action_pressed("ui_accept"):
		get_tree().change_scene_to_file(Global.SCENE_MAIN_MENU)

	$Icon.rotate(_delta)

func _input(event: InputEvent) -> void:
	if event.is_action_released("pause"):
		call_deferred("_pause")
		
func _pause() -> void:
	$Paused.pause()
	get_tree().paused = true


func _on_end_game_pressed():
	$ScoreSubmitPanel.show_results()
