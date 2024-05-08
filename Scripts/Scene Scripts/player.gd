extends CharacterBody2D

const speed = 100
var current_dir = "none"

var input = Vector2.ZERO

func _ready():
	$AnimatedSprite2D.play("idle_down")

func _physics_process(delta):
	player_movement(delta)

func get_input():
	input.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	input.y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	return input.normalized()

func player_movement(delta):
	input = get_input()
	if input == Vector2.ZERO:
		if velocity.length() > (delta):
			velocity = input * 0
		else:
			velocity = Vector2.ZERO
	else:
		velocity += (input * speed)
		velocity = velocity.limit_length(speed)
		
	
	
	if Input.is_action_pressed("move_right"):
		current_dir = "right"
		play_anim(1)
	elif Input.is_action_pressed("move_left"):
		current_dir = "left"
		play_anim(2)
	elif Input.is_action_pressed("move_down"):
		current_dir = "down"
		play_anim(3)
	elif Input.is_action_pressed("move_up"):
		current_dir = "up"
		play_anim(4)
	else:
		play_anim(0)
		
	move_and_slide()

func play_anim(movement):
	var dir = current_dir
	var anim = $AnimatedSprite2D
	
	if dir == "right":
		anim.flip_h = false
		if movement == 1:
			anim.play("walk_side")
		elif movement == 0:
			anim.play("idle_side")
	if dir == "left":
		anim.flip_h = true
		if movement == 2:
			anim.play("walk_side")
		elif movement == 0:
			anim.play("idle_side")
	if dir == "down":
		anim.flip_h = false
		if movement == 3:
			anim.play("walk_down")
		elif movement == 0:
			anim.play("idle_down")
	if dir == "up":
		anim.flip_h = false
		if movement == 4:
			anim.play("walk_up")
		elif movement == 0:
			anim.play("idle_up")

