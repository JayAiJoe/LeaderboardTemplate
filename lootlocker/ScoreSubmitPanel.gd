extends Panel


@onready var player_name = $VBoxContainer/MarginContainer/VBoxContainer/Name
@onready var submit_btn = $VBoxContainer/MarginContainer/VBoxContainer/Submit
@onready var submitted_label = $VBoxContainer/MarginContainer/VBoxContainer/Submitted
@onready var score_label = $VBoxContainer/Score

var results = {}
var labels_dict = {}

func _ready():
	
	player_name.text = LeaderBoard.player_name
	submit_btn.disabled = (len(player_name.text) <= 0)
#	Events.connect("add_new_result", add_new_results)
	submitted_label.text=""
	submit_btn.disabled = false
	Events.score_uploaded_successfully.connect(_on_score_submitted)
	
	randomize()
	score_label.text = str((randi() % 100) * 5 + 200)
	
	

func _on_submit_pressed():
	LeaderBoard._upload_score(score_label.text)
	LeaderBoard._change_player_name(player_name.text)
	LeaderBoard._get_player_name()
	submit_btn.disabled = true
	submit_btn.text = "Submitting..."
	


func add_new_results(property:String, value:String) -> void:
	results[property] = value

func show_results() -> void:
#	for property in labels_dict:
#		if property in results:
#			labels_dict[property].set_text(results[property])
#		else:
#			labels_dict[property].set_text("-1")
	var tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_method(set_position, Vector2(0,1920), Vector2(0,0), 1.5)


func _on_home_pressed():
	get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")


func _on_leaderboard_pressed():
	get_tree().change_scene_to_file("res://lootlocker/ScoresPage.tscn")
	

func _on_again_pressed():
	get_tree().change_scene_to_file("res://game_src/gameplay.tscn")


func _on_name_text_changed(new_text):
	submit_btn.disabled = (len(new_text) <= 0)
	
func _on_score_submitted() -> void:
	submit_btn.text = "Submit"
	submitted_label.text="Score submitted!"
