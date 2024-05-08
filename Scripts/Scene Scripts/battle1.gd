extends Control

@export var enemy: Resource = null

signal textbox_closed

var enemies: Array = []
var index: int = 0
var current_player_health = 0
var current_enemy_health = 0
var is_defending = false
var turns = 0
var buff_duration = 0


func _ready():
	enemies = $EnemyGroup.get_children()
	set_health(enemies[0].get_node("ProgressBar"), enemy.health, enemy.health)
	set_health($PlayerPanel/PlayerData/ProgressBar, State.current_health, State.max_health)
	#$EnemyGroup/EnemyContainer/Enemy.texture = enemy.texture
	
	current_player_health = State.current_health
	current_enemy_health = enemy.health
	
	$Textbox.hide()
	$ActionsPanel.hide()
	$AttacksPanel.hide()
	
	display_text("A wild %s appears!" % enemy.name.to_upper())
	await textbox_closed
	$ActionsPanel.show()

# Function for updating health bars.
func set_health(progress_bar, health, max_health):
	progress_bar.value = health
	progress_bar.max_value = max_health
	progress_bar.get_node("Label").text = "HP: %d/%d" % [health, max_health]


func _input(_event):
	if (Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)) and $Textbox.visible:
		$Textbox.hide()
		emit_signal("textbox_closed")

func display_text(text):
	$ActionsPanel.hide()
	$AttacksPanel.hide()
	$Textbox.show()
	$Textbox/Label.text = text

# Function for enemy actions. It randomly chooses between three different attacks,
# and uses an ultimate every 6 turns that deals massive damage.
func enemy_turn():
	turns += 1
	if turns == 6:
		if is_defending:
			is_defending = false
			current_player_health = max(0, current_player_health - (enemy.ultimate / 2))
			set_health($PlayerPanel/PlayerData/ProgressBar, current_player_health, State.max_health)
	
			$AnimationPlayer2.play("player_damaged")
			$AnimationPlayer.play("shake")
			await $AnimationPlayer.animation_finished
	
			display_text("The %s used its breath on you." % enemy.name)
			await textbox_closed
			display_text("It dealt a staggering %d damage." % [enemy.ultimate / 2])
			await textbox_closed
		else:
			current_player_health = max(0, current_player_health - (enemy.ultimate))
			set_health($PlayerPanel/PlayerData/ProgressBar, current_player_health, State.max_health)
	
			$AnimationPlayer2.play("player_damaged")
			$AnimationPlayer.play("big_shake")
			await $AnimationPlayer.animation_finished
	
			display_text("The %s used its breath on you." % enemy.name)
			await textbox_closed
			display_text("It dealt a staggering %d damage." % [enemy.ultimate])
			await textbox_closed
		turns = 0
	
	elif is_defending:
		is_defending = false
		$AnimationPlayer.play("mini_shake")
		await $AnimationPlayer.animation_finished
		display_text("You defended successfully!")
		await textbox_closed
		
	else:
		var random_number = randi() % 3
		match random_number:
			0:
				current_player_health = max(0, current_player_health - enemy.damage1)
				set_health($PlayerPanel/PlayerData/ProgressBar, current_player_health, State.max_health)
				
				$AnimationPlayer2.play("player_damaged")
				$AnimationPlayer.play("shake")
				await $AnimationPlayer.animation_finished

				display_text("The %s bit you and dealt %d damage." % [enemy.name, enemy.damage1])
				await textbox_closed
			1:
				current_player_health = max(0, current_player_health - enemy.damage2)
				set_health($PlayerPanel/PlayerData/ProgressBar, current_player_health, State.max_health)
				
				$AnimationPlayer2.play("player_damaged")
				$AnimationPlayer.play("shake")
				await $AnimationPlayer.animation_finished
		
				display_text("The %s swipes at you with its claws and dealt %d damage." % [enemy.name, enemy.damage2])
				await textbox_closed
			2:
				current_player_health = max(0, current_player_health - enemy.damage3)
				set_health($PlayerPanel/PlayerData/ProgressBar, current_player_health, State.max_health)
		
				$AnimationPlayer2.play("player_damaged")
				$AnimationPlayer.play("shake")
				await $AnimationPlayer.animation_finished
				
				display_text("The %s hit you with its tail and dealt %d damage." % [enemy.name, enemy.damage3])
				await textbox_closed
	if turns == 5:
		await get_tree().create_timer(0.25).timeout
		display_text("The %s is charging up a massive attack." % enemy.name)
		await textbox_closed
	if current_player_health == 0:
		$AnimationPlayer.play("player_death")
		await $AnimationPlayer.animation_finished
		
		display_text("You were defeated.")
		await textbox_closed
		
		await get_tree().create_timer(0.25).timeout
		get_tree().change_scene_to_file("res://Scenes/Endings/bad_ending.tscn")
	if buff_duration == 0:
		State.damagebuff = 1
	await get_tree().create_timer(0.25).timeout
	$ActionsPanel.show()


func _on_run_pressed():
	display_text("DID YOU REALLY THINK YOU COULD RUN AWAY?")
	await textbox_closed
	await get_tree().create_timer(0.25).timeout
	display_text("You.....COWARD")
	await textbox_closed
	await get_tree().create_timer(0.25).timeout
	get_tree().change_scene_to_file("res://Scenes/Endings/cowardly_ending.tscn")

func _on_attack_pressed():	
	display_text("How do you attack?")
	await textbox_closed
	await get_tree().create_timer(0.25).timeout
	$AttacksPanel.show()
	


func _on_defend_pressed():
	is_defending = true
	display_text("You prepare defensively.")
	await textbox_closed
	buff_duration = max(0, buff_duration - 1)
	await get_tree().create_timer(0.25).timeout
	enemy_turn()


func _on_staff_bash_pressed():
	display_text("You bash the %s over the head with your staff." % enemy.name)
	await textbox_closed
	current_enemy_health = max(0, current_enemy_health - State.damage*State.damagebuff)
	set_health($EnemyGroup/EnemyContainer/ProgressBar, current_enemy_health, enemy.health)
	$AnimationPlayer.play("enemy_damaged")
	await $AnimationPlayer.animation_finished
	display_text("You dealt %d damage to the %s!" % [State.damage*State.damagebuff, enemy.name])
	await textbox_closed
	
	if current_enemy_health == 0:
		State.damagebuff = 1
		display_text("The %s was defeated!" % enemy.name)
		await textbox_closed
		
		$AnimationPlayer.play("enemy_died")
		await $AnimationPlayer.animation_finished
		$AnimationPlayer.play("player_death")
		await $AnimationPlayer.animation_finished
		display_text("Or so you thought.")
		await textbox_closed
		await get_tree().create_timer(0.25).timeout
		get_tree().change_scene_to_file("res://Scenes/battle2.tscn")
	
	buff_duration = max(0, buff_duration - 1)
	
	enemy_turn()


func _on_fury_attack_pressed():
	display_text("You unleash a flurry of attacks towards the %s." % enemy.name)
	await textbox_closed
	var random_number = (randi() % 4) + 2
	current_enemy_health = max(0, current_enemy_health - State.damage2*State.damagebuff*random_number)
	set_health($EnemyGroup/EnemyContainer/ProgressBar, current_enemy_health, enemy.health)
	$AnimationPlayer.play("enemy_damaged")
	await $AnimationPlayer.animation_finished
	display_text("You dealt %d damage to the %s %d times!" % [State.damage2*State.damagebuff*random_number, enemy.name, random_number])
	await textbox_closed
	if current_enemy_health == 0:
		State.damagebuff = 1
		display_text("The %s was defeated!" % enemy.name)
		await textbox_closed
		
		$AnimationPlayer.play("enemy_died")
		await $AnimationPlayer.animation_finished
		$AnimationPlayer.play("player_death")
		await $AnimationPlayer.animation_finished
		display_text("Or so you thought.")
		await textbox_closed
		await get_tree().create_timer(0.25).timeout
		get_tree().change_scene_to_file("res://Scenes/battle2.tscn")
	
	buff_duration = max(0, buff_duration - 1)
	
	enemy_turn()


func _on_baptism_pressed():
	display_text("You enchant yourself with holy water.")
	await textbox_closed
	
	display_text("It's time to run these holy hands.")
	await textbox_closed
	
	buff_duration = 3
	State.damagebuff = 1.25
	
	enemy_turn()

func _on_back_pressed():
	$AttacksPanel.hide()
	$ActionsPanel.show()
	
