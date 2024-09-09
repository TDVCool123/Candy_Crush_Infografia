extends TextureRect

@onready var label = $Label


# Called when the node enters the scene tree for the first time.
func _ready():
	var grid = get_parent().get_node("grid")
	label.text = str("Nivel ",grid.level)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_next_level_pressed():
	var grid = get_parent().get_node("grid")
	grid.level +=1
	grid.start_level(grid.level)
	label.text = str("Nivel ",grid.level)
	


func _on_previous_level_pressed():
	var grid = get_parent().get_node("grid")
	grid.level -=1
	grid.start_level(grid.level)
	label.text = str("Nivel ",grid.level)
