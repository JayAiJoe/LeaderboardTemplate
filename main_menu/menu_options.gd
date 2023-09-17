extends VFlowContainer

@export var gameplay_scene:PackedScene
@export var settings_scene:PackedScene

func _ready() -> void:
	if(Events.is_lootlocker_connection_established):
		enable_leaderboards_button()
	else:
		Events.lootlocker_connection_established.connect(enable_leaderboards_button)
	
	get_children()[0].grab_focus()
	
	if !OS.has_feature("pc"):
		$Quit.hide()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_packed(settings_scene)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_packed(gameplay_scene)

func _on_leaderboard_pressed():
	get_tree().change_scene_to_file("res://lootlocker/ScoresPage.tscn")

func enable_leaderboards_button() -> void:
	$Leaderboard.disabled = false
	$Leaderboard.text = "Leaderboard"
