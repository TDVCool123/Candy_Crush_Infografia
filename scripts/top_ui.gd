extends TextureRect

@onready var score_label = $MarginContainer/HBoxContainer/score_label
@onready var counter_label = $MarginContainer/HBoxContainer/counter_label

var current_score = 0
var current_count = 0

#Realizar un sistema de combos y de streak
func change_score():
	score_label.text = str(current_score)
	
func _process(delta):
	change_score()
	#poner el label del conteo de movimientos
