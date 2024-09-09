extends TextureRect

@onready var score_label = $MarginContainer/HBoxContainer/score_label
@onready var counter_label = $MarginContainer/HBoxContainer/counter_label
@onready var timer_label = $MarginContainer/HBoxContainer/timer_label

var current_score = 0
var current_count = 0
var time_remaining = 0

#Realizar un sistema de combos y de streak
func change_score():
	score_label.text = str(current_score)
	
func change_count():
	counter_label.text = str(current_count)
	
func _on_grid_update_timer(new_time):
	print("Time remaining: ", new_time)
	time_remaining = new_time
	timer_label.text = str(time_remaining)
	
func _ready():
	get_parent().get_node("grid")
	var grid = get_parent().get_node("grid")
	grid.connect("update_timer", Callable(self, "_on_grid_update_timer"))
	
func _process(delta):
	change_score()
	change_count()
