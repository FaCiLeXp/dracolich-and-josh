extends CharacterBody2D


var speed = 40
var player_chase = false
var player = null
var touch = false

func _ready():
	$AnimatedSprite2D.play("idle_down")
	$AnimatedSprite2D2.play("idle_down")

func _physics_process(delta):
	if player_chase:
		position += (player.position - position)/speed


func _on_detection_area_body_entered(body):
	player = body
	player_chase = true


func _on_detection_area_body_exited(body):
	player = null
	player_chase = false


func _on_hitbox_body_entered(body: CharacterBody2D):
	$"../AnimationPlayer".play("scene_transition")
	await $"../AnimationPlayer".animation_finished
	await get_tree().create_timer(0.01).timeout
	get_tree().change_scene_to_file("res://Scenes/battle1.tscn")
