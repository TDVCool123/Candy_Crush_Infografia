extends TextureRect

@onready var label = $Label
@onready var lose_label = $lose_label
@onready var win_label = $win_label


# Called when the node enters the scene tree for the first time.
func _ready():
	var grid = get_parent().get_node("grid")
	label.text = str("Nivel ",grid.level)
	lose_label.hide()
	win_label.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_next_level_pressed():
	var grid = get_parent().get_node("grid")
	grid.level +=1
	grid.start_level(grid.level)
	label.text = str("Nivel ",grid.level)
	label.show()
	lose_label.hide()
	win_label.hide()
	


func _on_previous_level_pressed():
	var grid = get_parent().get_node("grid")
	grid.level -=1
	grid.start_level(grid.level)
	label.text = str("Nivel ",grid.level)
	label.show()
	lose_label.hide()
	win_label.hide()
