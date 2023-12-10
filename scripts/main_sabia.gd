extends Node

@export var obstacle_scene : PackedScene


var game_running : bool
var game_over : bool
var scroll
var score : int = 0
const SCROLL_SPEED : int = 4
var screen_size : Vector2i
var ground_height : int
var obstacles : Array
const OBSTACLE_DELAY : int = 100
const OBSTACLE_RANGE : int = 200


# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_window().size
	ground_height = $GroundSabia.get_node("Sprite2D").texture.get_height()
	new_game()
	
func new_game():
	# reset variables
	game_running = false
	game_over = false
	score = 0
	scroll = 0
	$ScoreLabelSabia.text = str(score)
	$GameOverSabia.hide()
	get_tree().call_group("obstacles_sabia", "queue_free")
	obstacles.clear()
	generate_obstacles()
	$BirdSabia.reset()
	
func _input(event):
	if not game_over:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if not game_running:
					start_game()
				else:
					if $BirdSabia.flying:
						$BirdSabia.flap()
						check_top()
						
func start_game():
	game_running = true
	$BirdSabia.flying = true
	$BirdSabia.flap()
	$ObstacleTimer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game_running:
		scroll += SCROLL_SPEED
		
		if scroll >= screen_size.x:
			scroll = 0 
			
		# move ground node
		$GroundSabia.position.x = -scroll
		
		for obstacle in obstacles:
			obstacle.position.x -= SCROLL_SPEED


func _on_obstacle_timer_timeout():
	generate_obstacles()

func generate_obstacles():
	var obstacle = obstacle_scene.instantiate()
	obstacle.position.x = screen_size.x + OBSTACLE_DELAY
	obstacle.position.y = (screen_size.y - ground_height)/2 + randi_range(-OBSTACLE_RANGE, OBSTACLE_RANGE)
	obstacle.hit.connect(sabia_hit)
	obstacle.scored.connect(scored)
	add_child(obstacle)
	obstacles.append(obstacle)
	
func scored():
	score += 1 
	$ScoreLabelSabia.text = str(score)
	
func stop_game():
	$ObstacleTimer.stop()
	$GameOverSabia.show()
	$BirdSabia.flying = false
	game_running = false
	game_over = true
	
func check_top():
	if $BirdSabia.position.y < 0:
		$BirdSabia.falling = true
		stop_game()
		

func sabia_hit():
	$BirdSabia.falling = true
	stop_game()


func _on_ground_sabia_body_entered(body):
	$BirdSabia.falling = false
	stop_game()


func _on_game_over_sabia_restart():
	new_game()
