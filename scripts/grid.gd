extends Node2D

# state machine
enum {WAIT, MOVE}
var state

# grid
@export var width: int
@export var height: int
@export var x_start: int
@export var y_start: int
@export var offset: int
@export var y_offset: int

# COLORS
const BLUE = "blue"
const GREEN = "green"
const LIGHT_GREEN = "light_green"
const PINK = "pink"
const YELLOW = "yellow"
const ORANGE = "orange"
# SPECIAL TYPE PIECES
const COLUMN =  "column"
const ROW =  "row"
const ADJACENT = "adjacent"
const NORMAL = "normal"
const RAINBOW = "rainbow"

# piece array
var possible_pieces = [
	preload("res://scenes/blue_piece.tscn"),
	preload("res://scenes/green_piece.tscn"),
	preload("res://scenes/light_green_piece.tscn"),
	preload("res://scenes/pink_piece.tscn"),
	preload("res://scenes/yellow_piece.tscn"),
	preload("res://scenes/orange_piece.tscn"),
]

var row_pieces = {
	BLUE: preload("res://scenes/blue_piece_row.tscn"),
	GREEN: preload("res://scenes/green_piece_row.tscn"),
	LIGHT_GREEN: preload("res://scenes/light_green_piece_row.tscn"),
	ORANGE: preload("res://scenes/orange_piece_row.tscn"),
	PINK: preload("res://scenes/pink_piece_row.tscn"),
	YELLOW: preload("res://scenes/yellow_piece_row.tscn")
}

var column_pieces = {
	BLUE: preload("res://scenes/blue_piece_column.tscn"),
	GREEN: preload("res://scenes/green_piece_column.tscn"),
	LIGHT_GREEN: preload("res://scenes/light_green_piece_column.tscn"),
	ORANGE: preload("res://scenes/orange_piece_column.tscn"),
	PINK: preload("res://scenes/pink_piece_column.tscn"),
	YELLOW: preload("res://scenes/yellow_piece_column.tscn")
}

var adjacent_pieces = {
	BLUE: preload("res://scenes/blue_piece_adjacent.tscn"),
	GREEN: preload("res://scenes/green_piece_adjacent.tscn"),
	LIGHT_GREEN: preload("res://scenes/light_green_piece_adjacent.tscn"),
	ORANGE: preload("res://scenes/orange_piece_adjacent.tscn"),
	PINK: preload("res://scenes/pink_piece_adjacent.tscn"),
	YELLOW: preload("res://scenes/yellow_piece_adjacent.tscn")
}


var rainbow_piece = preload("res://scenes/rainbow_piece.tscn")


#game ui
@onready var top_ui = $"../top_ui"


# current pieces in scene
var all_pieces = []

# swap back
var piece_one = null
var piece_two = null
var last_place = Vector2.ZERO
var last_direction = Vector2.ZERO
var move_checked = false

# touch variables
var first_touch = Vector2.ZERO
var final_touch = Vector2.ZERO
var is_controlling = false

# scoring variables and signals

var combo_count = 1
func scoring(score,combo):
	#var current_score=get_parent().get_node("top_ui").get("current_score")
	top_ui.current_score += score*combo
	current_score += score*combo
	if check_win():
		change_level_state_label_ui(true)
		print("¡Ganaste el nivel! ", level)
		state = WAIT
		print(state)
	elif check_lose():
		change_level_state_label_ui(false)
		print("Perdiste el nivel")
		state = WAIT
		

	print("El score es: ", top_ui.current_score)
	

#Adrian
# counter variables and signals

func discounter():
	if moves > 0:
		moves -= 1
		top_ui.current_count -= 1
		print("Movimientos restantes: ", moves)
		if check_lose():
			change_level_state_label_ui(false)
			print("Perdiste el nivel")
			state = WAIT
			
	print("Quedan : ", top_ui.current_count, " movimientos")

#timer 
signal update_timer(new_time)

#level settings
var level = 1
var goal_score = 1000
var moves = 0
var time_left = 0
var time_passed = 0
var current_score = 0
var max_moves = 0
var timer_active = false




# Called when the node enters the scene tree for the first time.
func _ready():
	state = MOVE
	randomize()
	all_pieces = make_2d_array()
	spawn_pieces()
	
	#Inciar en el nivel 1
	start_level(level)
	top_ui.current_score = current_score
	top_ui.current_count = max_moves
	top_ui.time_remaining = time_left
	
	
	if timer_active:
		start_level_timer_ui()
		

func _process(delta):
	if state == MOVE:
		touch_input()
		
	if timer_active:
		time_passed += delta
		if time_passed >= 1:
			if time_left > 0:
				time_left -= 1
				emit_signal("update_timer", time_left)
				time_passed = 0
			if check_lose():
				state = WAIT
				change_level_state_label_ui(false)
				print("Perdiste el nivel")
				timer_active = false
# Función para iniciar los niveles
func start_level(level_number):
	level = level_number

	match level_number:
		1:
			current_score = 0
			goal_score = 1000
			moves = 0
			time_left = 0
			timer_active = false
			start_level_timer_ui()
			
		2:
			current_score = 0
			goal_score = 800
			max_moves = 18
			moves = max_moves
			timer_active = false
			time_left = 0
			top_ui.current_score = current_score
			top_ui.current_count = max_moves
			top_ui.time_remaining = time_left
			start_level_timer_ui()
			
		3:
			current_score = 0
			goal_score = 1200
			time_left = 60
			max_moves = 0
			moves = 0
			timer_active = true
			start_timer() # Inicia el timer del nivel
			top_ui.current_score = current_score
			top_ui.current_count = max_moves
			top_ui.time_remaining = time_left
			start_level_timer_ui()
			
			
		4:
			current_score = 0
			goal_score = 2000
			max_moves = 25
			moves = max_moves
			time_left = 120
			timer_active = true
			start_timer() # Inicia el timer del nivel
			top_ui.current_score = current_score
			top_ui.current_count = max_moves
			top_ui.time_remaining = time_left
			start_level_timer_ui()
			
	# Resetea el puntaje
	current_score = 0
	print("Iniciando nivel: ", level_number)


# Función para verificar si se ha ganado
func check_win() -> bool:
	return current_score >= goal_score

# Función para verificar si se ha perdido
func check_lose() -> bool:
	if timer_active and time_left <= 0:
		return true
	if moves > 0 and moves <= 0:
		return true
	return false
	
	# Función para iniciar el timer si está activo
func start_timer():
	if timer_active:
		# Asegúrate de tener un Timer en la escena
		get_parent().get_node("destroy_timer").start()
		emit_signal("update_timer", time_left)

# Función para actualizar el tiempo restante

	
func start_level_timer_ui():
	var timer_label = get_parent().get_node("top_ui/MarginContainer/HBoxContainer/timer_label")
	if timer_label:
		timer_label.text = str(time_left) 
		
func change_level_state_label_ui(victoria: bool):
	var bottom_label = get_parent().get_node("bottom_ui/Label")
	if bottom_label:
		if victoria:
			bottom_label.text = str("Ganaste el nivel ", level) 
		else:
			bottom_label.text = str("Perdiste el nivel ", level) 
			
func make_2d_array():
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	return array
	
func grid_to_pixel(column, row):
	var new_x = x_start + offset * column
	var new_y = y_start - offset * row
	return Vector2(new_x, new_y)
	
func pixel_to_grid(pixel_x, pixel_y):
	var new_x = round((pixel_x - x_start) / offset)
	var new_y = round((pixel_y - y_start) / -offset)
	return Vector2(new_x, new_y)
	
func in_grid(column, row):
	return column >= 0 and column < width and row >= 0 and row < height
	
func spawn_pieces():
	for i in width:
		for j in height:
			# random number
			var rand = randi_range(0, possible_pieces.size() - 1)
			# instance 
			var piece = possible_pieces[rand].instantiate()
			# repeat until no matches
			var max_loops = 100
			var loops = 0
			while (match_at(i, j, piece.color) and loops < max_loops):
				rand = randi_range(0, possible_pieces.size() - 1)
				loops += 1
				piece = possible_pieces[rand].instantiate()
			add_child(piece)
			piece.position = grid_to_pixel(i, j)
			# fill array with pieces
			all_pieces[i][j] = piece

func match_at(i, j, color):
	# check left
	if i > 1:
		if all_pieces[i - 1][j] != null and all_pieces[i - 2][j] != null:
			if all_pieces[i - 1][j].color == color and all_pieces[i - 2][j].color == color:
				return true
	# check down
	if j> 1:
		if all_pieces[i][j - 1] != null and all_pieces[i][j - 2] != null:
			if all_pieces[i][j - 1].color == color and all_pieces[i][j - 2].color == color:
				return true

func touch_input():
	var mouse_pos = get_global_mouse_position()
	var grid_pos = pixel_to_grid(mouse_pos.x, mouse_pos.y)
	if Input.is_action_just_pressed("ui_touch") and in_grid(grid_pos.x, grid_pos.y):
		first_touch = grid_pos
		is_controlling = true
		
	# release button
	if Input.is_action_just_released("ui_touch") and in_grid(grid_pos.x, grid_pos.y) and is_controlling:
		is_controlling = false
		final_touch = grid_pos
		touch_difference(first_touch, final_touch)

func swap_pieces(column, row, direction: Vector2):
	var first_piece = all_pieces[column][row]
	var other_piece = all_pieces[column + direction.x][row + direction.y]
	if first_piece == null or other_piece == null:
		return
		
	var is_first_rainbow = first_piece.type == RAINBOW
	var is_other_rainbow =  other_piece.type == RAINBOW
	
	if is_first_rainbow:
		clean_color(column, row, other_piece.color)
		move_checked = true
	if is_other_rainbow:
		clean_color(column + direction.x, row + direction.y, first_piece.color)
		move_checked = true
		
		
	# swap
	state = WAIT
	store_info(first_piece, other_piece, Vector2(column, row), direction)
	all_pieces[column][row] = other_piece
	all_pieces[column + direction.x][row + direction.y] = first_piece
	#first_piece.position = grid_to_pixel(column + direction.x, row + direction.y)
	#other_piece.position = grid_to_pixel(column, row)
	first_piece.move(grid_to_pixel(column + direction.x, row + direction.y))
	other_piece.move(grid_to_pixel(column, row))
	if not move_checked:
		find_matches()

func store_info(first_piece, other_piece, place, direction):
	piece_one = first_piece
	piece_two = other_piece
	last_place = place
	last_direction = direction

func swap_back():
	if piece_one != null and piece_two != null:
		swap_pieces(last_place.x, last_place.y, last_direction)
	state = MOVE
	move_checked = false

func touch_difference(grid_1, grid_2):
	var difference = grid_2 - grid_1
	# should move x or y?
	if abs(difference.x) > abs(difference.y):
		if difference.x > 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(1, 0))
		elif difference.x < 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(-1, 0))
	if abs(difference.y) > abs(difference.x):
		if difference.y > 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(0, 1))
		elif difference.y < 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(0, -1))



func find_matches():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				var current_color = all_pieces[i][j].color
				if is_t_shape(i, j):
					replace_with_special_piece(i, j, current_color, RAINBOW)
				# Check for horizontal matches
				if i <= width - 5:
					if is_match(i, j, Vector2(1, 0), 5):
						replace_with_special_piece(i + 2, j, current_color, ADJACENT)
						#continue
					elif is_match(i, j, Vector2(1, 0), 4):
						replace_with_special_piece(i + 1, j, current_color, ROW)
						#continue
				elif i <= width - 4:
					if is_match(i, j, Vector2(1, 0), 4):
						replace_with_special_piece(i + 1, j, current_color, ROW)
						#continue
						
				
				# Check for vertical matches
				if j <= height - 5:
					if is_match(i, j, Vector2(0, 1), 5):
						replace_with_special_piece(i, j + 2, current_color, ADJACENT)
						#continue
					elif is_match(i, j, Vector2(0, 1), 4):
						replace_with_special_piece(i, j + 1, current_color, COLUMN)
						#continue
				elif j <= height - 4:
					if is_match(i, j, Vector2(0, 1), 4):
						replace_with_special_piece(i, j + 1, current_color, COLUMN)
						#continue
						
				# detect horizontal matches
				if (
					i > 0 and i < width -1 
					and 
					all_pieces[i - 1][j] != null and all_pieces[i + 1][j]
					and 
					all_pieces[i - 1][j].color == current_color and all_pieces[i + 1][j].color == current_color
				):
					all_pieces[i - 1][j].matched = true
					all_pieces[i - 1][j].dim()
					all_pieces[i][j].matched = true
					all_pieces[i][j].dim()
					all_pieces[i + 1][j].matched = true
					all_pieces[i + 1][j].dim()
				# detect vertical matches
				if (
					j > 0 and j < height -1 
					and 
					all_pieces[i][j - 1] != null and all_pieces[i][j + 1]
					and 
					all_pieces[i][j - 1].color == current_color and all_pieces[i][j + 1].color == current_color
				):
					all_pieces[i][j - 1].matched = true
					all_pieces[i][j - 1].dim()
					all_pieces[i][j].matched = true
					all_pieces[i][j].dim()
					all_pieces[i][j + 1].matched = true
					all_pieces[i][j + 1].dim()
					
	get_parent().get_node("destroy_timer").start()
func is_t_shape(i, j) -> bool:
	# Horizontal T shape
	if is_match(i, j, Vector2(1, 0), 3) and (
		(j > 0 and all_pieces[i + 1][j - 1] != null and all_pieces[i + 1][j - 1].color == all_pieces[i][j].color) or
		(j < height - 1 and all_pieces[i + 1][j + 1] != null and all_pieces[i + 1][j + 1].color == all_pieces[i][j].color)
	):
		return true

	# Vertical T shape
	if is_match(i, j, Vector2(0, 1), 3) and (
		(i > 0 and all_pieces[i - 1][j + 1] != null and all_pieces[i - 1][j + 1].color == all_pieces[i][j].color) or
		(i < width - 1 and all_pieces[i + 1][j + 1] != null and all_pieces[i + 1][j + 1].color == all_pieces[i][j].color)
	):
		return true

	return false	
	
func is_match(i, j, direction: Vector2, length: int) -> bool:
	#if all_pieces[i][j].type == RAINBOW:
		#return true
	if all_pieces[i][j] == null:
			return false
	if all_pieces[i][j].color == null:
		return false
	for k in range(1, length):
		var x = i + k * direction.x
		var y = j + k * direction.y
		if not in_grid(x, y):
			return false
		if all_pieces[x][y] == null:
			return false
		if all_pieces[x][y].color == null or all_pieces[x][y].color == "":
			return false
		
		if all_pieces[x][y].color != all_pieces[i][j].color:
			return false
	return true
	
func replace_with_special_piece(i, j, color, type):
	print('special type', type)
	var special_piece
	if type == ROW:
		special_piece = row_pieces[color].instantiate()
	elif type == COLUMN:
		special_piece = column_pieces[color].instantiate()
	elif type == ADJACENT:
		special_piece = adjacent_pieces[color].instantiate()
	elif type == RAINBOW:
		special_piece = rainbow_piece.instantiate()
		print(special_piece, 'de reokace')
	
	if type == ROW or type == COLUMN:
		for k in range(-1, 3):
			if type == ROW and in_grid(i + k, j):
				if all_pieces[i + k][j]:
					all_pieces[i + k][j].matched = true
					all_pieces[i + k][j].dim()
					all_pieces[i + k][j].queue_free()
					all_pieces[i + k][j].queue_free()
					all_pieces[i + k][j] = null
			elif type == COLUMN and in_grid(i, j + k):
				if all_pieces[i][j + k]:
					all_pieces[i][j + k].matched = true
					all_pieces[i][j + k].dim()
					all_pieces[i][j + k].queue_free()
					all_pieces[i][j + k] = null
	elif type == ADJACENT or type == RAINBOW:
		for di in range(-1, 2):
			for dj in range(-1, 2):
				if in_grid(i + di, j + dj) and all_pieces[i + di][j + dj]:
					all_pieces[i + di][j + dj].matched = true
					all_pieces[i + di][j + dj].dim()
					all_pieces[i + di][j + dj].queue_free()
					all_pieces[i + di][j + dj] = null
	
	if all_pieces[i][j]:
		all_pieces[i][j].queue_free()
	all_pieces[i][j] = special_piece
	all_pieces[i][j].type = type
	if all_pieces[i][j].color == "":
		all_pieces[i][j].color = color
	add_child(special_piece)
	special_piece.position = grid_to_pixel(i, j)
	get_parent().get_node("collapse_timer").start()	

func destroy_matched():
	var pieces_matched_count = 0
	var was_matched = false
	
	for i in width:
		for j in height:
			var current_piece = all_pieces[i][j]
			if current_piece != null and current_piece.matched:
				was_matched = true
				pieces_matched_count += 1
				print(pieces_matched_count)
				if current_piece.type == ROW:
					scoring(30 * 8, combo_count)
					clean_row(j)
				elif current_piece.type == COLUMN:
					scoring(30 * 10, combo_count)
					clean_col(i)
				elif current_piece.type == ADJACENT:
					scoring(30 * 24, combo_count)
					clean_col(i)
					clean_row(j)
					clean_all_diag(i, j)
				elif current_piece.type == RAINBOW:
					clean_color(i, j, current_piece.color)
				elif current_piece.type == NORMAL:
				# Destroy the matched piece itself
					all_pieces[i][j].queue_free()
					all_pieces[i][j] = null
				
	# Sistema de puntuación
	if pieces_matched_count == 3:
		scoring(15 * pieces_matched_count, combo_count)
	elif pieces_matched_count == 4:
		scoring(20 * pieces_matched_count, combo_count )
	elif pieces_matched_count == 5:
		scoring(25 * pieces_matched_count, combo_count)
		
	move_checked = true
	# Si hubo alguna coincidencia, empieza el colapso de las columnas
	if was_matched:
		discounter()
		get_parent().get_node("collapse_timer").start()
	else:
		# Si no hubo coincidencias nuevas después de colapsar, revertimos el movimiento
		swap_back()


func clean_row(row):
	for col in range(width):
		if all_pieces[col][row] != null:
			all_pieces[col][row].matched = true
			all_pieces[col][row].dim()
			all_pieces[col][row].queue_free()
			all_pieces[col][row] = null

func clean_col(col):
	for row in range(height):
		if all_pieces[col][row] != null:
			all_pieces[col][row].matched = true
			all_pieces[col][row].dim()
			all_pieces[col][row].queue_free()
			all_pieces[col][row] = null

func clean_all_diag(col, row):
	for offset in range(-min(width, height), min(width, height)):
		# (top-left to bottom-right)
		if (
			in_grid(col + offset, row + offset)
			and all_pieces[col + offset][row + offset] != null
		):
			all_pieces[col + offset][row + offset].matched = true
			all_pieces[col + offset][row + offset].dim()
			all_pieces[col + offset][row + offset].queue_free()
			all_pieces[col + offset][row + offset] = null

		# (top-right to bottom-left)
		if (
			in_grid(col + offset, row - offset) 
			and all_pieces[col + offset][row - offset] != null
		):
			all_pieces[col + offset][row - offset].matched = true
			all_pieces[col + offset][row - offset].dim()
			all_pieces[col + offset][row - offset].queue_free()
			all_pieces[col + offset][row - offset] = null

func clean_color(curr_col, curr_row, color):
	print('cleaneando color ', color)
	for col in range(width):
		for row in range(height):
			var curr_piece = all_pieces[col][row] 
			if curr_piece.color == color:
				all_pieces[col][row].matched = true
				all_pieces[col][row].dim()
				all_pieces[col][row].queue_free()
				all_pieces[col][row] = null
	all_pieces[curr_col][curr_row].matched = true
	all_pieces[curr_col][curr_row].dim()
	all_pieces[curr_col][curr_row].queue_free()
	all_pieces[curr_col][curr_row] = null
	get_parent().get_node("collapse_timer").start()


# Este método es para colapsar las columnas y hacer que las piezas caigan
func collapse_columns():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null:
				# Mirar arriba para ver si hay piezas que deben caer
				for k in range(j + 1, height):
					if all_pieces[i][k] != null:
						all_pieces[i][k].move(grid_to_pixel(i, j))
						all_pieces[i][j] = all_pieces[i][k]
						all_pieces[i][k] = null
						break
	# Después del colapso, rellenar las columnas vacías
	get_parent().get_node("refill_timer").start()

# Rellena las columnas después de que las piezas han caído
func refill_columns():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null:
				var rand = randi_range(0, possible_pieces.size() - 1)
				var piece = possible_pieces[rand].instantiate()
				var max_loops = 100
				var loops = 0
				while (match_at(i, j, piece.color) and loops < max_loops):
					rand = randi_range(0, possible_pieces.size() - 1)
					loops += 1
					piece = possible_pieces[rand].instantiate()
				add_child(piece)
				piece.position = grid_to_pixel(i, j - y_offset)
				piece.move(grid_to_pixel(i, j))
				all_pieces[i][j] = piece
				
	# Después de rellenar, verifica si hay nuevas coincidencias para combos
	check_after_refill()

# Verifica si hay nuevas coincidencias después de rellenar el tablero
func check_after_refill():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null and match_at(i, j, all_pieces[i][j].color):
				find_matches()
				combo_count += 1
				print(combo_count)
		
				get_parent().get_node("destroy_timer").start()
				return
	# Si no hay más coincidencias, permite que el jugador vuelva a mover
	state = MOVE
	move_checked = false
	combo_count = 1
	print(combo_count)


func _on_destroy_timer_timeout():
	print("destroy")
	destroy_matched()

func _on_collapse_timer_timeout():
	print("collapse")
	collapse_columns()

func _on_refill_timer_timeout():
	refill_columns()
	
func game_over():
	state = WAIT
	print("game over")


	
