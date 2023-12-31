extends Control


func set_score_name(n : String) -> void:
	$Name.text = n

func set_score(n : String) -> void:
	$Score.text = n

func set_rank(n : String) -> void:
	$Rank.text = n

func set_data(data : Dictionary) -> void:
	set_score_name(data.name)
	set_score(str(data.score))
	set_rank(str(data.rank))

func clear_data() -> void:
	set_score_name("")
	set_score("")
	set_rank("")
