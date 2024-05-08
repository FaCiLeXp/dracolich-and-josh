extends Control

@export var enemy: Resource = null
@export var enemy2: Resource = null
@export var enemy3: Resource = null

signal textbox_closed
signal choice
signal minion_died
signal ability_choice

var on: bool = true
var enemies: Array = []
var index: int = 0
var current_player_health = 0
var current_enemy_health_1 = 0
var current_enemy_health_2 = 0
var current_enemy_health_3 = 0
var is_defending = false
var turns = 0
var minions: int = 5
var buff_duration: int = 0
var abilities: int = 2
var vt_cd: int = 0
var hw_cd: int = 0
var mh_cd: int = 0
var nf_cd: int = 0

func _ready():
	enemies = $EnemyGroup.get_children()
	set_health(enemies[0].get_node("ProgressBar"), enemy.health, enemy.health)
	set_health(enemies[1].get_node("ProgressBar"), enemy2.health/2, enemy2.health)
	set_health(enemies[2].get_node("ProgressBar"), enemy3.health, enemy3.health)
	set_health($PlayerPanel/PlayerData/ProgressBar, 99, State.max_health)
	enemies[0].get_node("Enemy").texture = enemy.texture
	enemies[1].get_node("Enemy").texture = enemy2.texture
	enemies[2].get_node("Enemy").texture = enemy3.texture
	
	current_player_health = State.current_health/2
	current_enemy_health_1 = enemy.health
	current_enemy_health_2 = enemy2.health/2
	current_enemy_health_3 = enemy3.health
	
	$Textbox.hide()
	$ActionsPanel.hide()
	
	$AnimationPlayer.play("scene_in")
	await $AnimationPlayer.animation_finished
	display_text("The %s has split itself!" % enemy2.name.to_upper())
	await textbox_closed
	await get_tree().create_timer(0.25).timeout
	display_text("Maybe you should get rid of the smaller ones first.")
	await textbox_closed
	await get_tree().create_timer(0.25).timeout
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
	$AbilitiesChoicePanel.hide()
	$Textbox.show()
	$Textbox/Label.text = text

# Function for enemy actions. It randomly chooses between three different attacks,
# and uses an ultimate every 6 turns that deals massive damage.
func enemy_turn():	
	turns += 1
	if turns == 6:
		if is_defending:
			is_defending = false
			current_player_health = max(0, current_player_health - (enemy2.ultimate / 2))
			set_health($PlayerPanel/PlayerData/ProgressBar, current_player_health, State.max_health)
	
			$AnimationPlayer.play("shake")
			await $AnimationPlayer.animation_finished
	
			display_text("The %s used its breath on you." % enemy2.name)
			await textbox_closed
			display_text("It dealt a staggering %d damage." % [enemy2.ultimate / 2])
			await textbox_closed
		else:
			current_player_health = max(0, current_player_health - (enemy2.ultimate))
			set_health($PlayerPanel/PlayerData/ProgressBar, current_player_health, State.max_health)
	
			$AnimationPlayer.play("big_shake")
			await $AnimationPlayer.animation_finished
	
			display_text("The %s used its breath on you." % enemy2.name)
			await textbox_closed
			display_text("It dealt a staggering %d damage." % [enemy2.ultimate])
			await textbox_closed
		turns = 0
	
	elif is_defending:
		$AnimationPlayer.play("mini_shake")
		await $AnimationPlayer.animation_finished
		display_text("You defended successfully!")
		await textbox_closed
		get_tree().create_timer(0.25).timeout
		
	else:
		var random_number = randi() % 3
		match random_number:
			0:
				current_player_health = max(0, current_player_health - enemy2.damage1)
				set_health($PlayerPanel/PlayerData/ProgressBar, current_player_health, State.max_health)
	
				$AnimationPlayer.play("shake")
				await $AnimationPlayer.animation_finished
	
				display_text("The %s bit you and dealt %d damage." % [enemy2.name, enemy2.damage1])
				await textbox_closed
			1:
				current_player_health = max(0, current_player_health - enemy2.damage2)
				set_health($PlayerPanel/PlayerData/ProgressBar, current_player_health, State.max_health)
	
				$AnimationPlayer.play("shake")
				await $AnimationPlayer.animation_finished
	
				display_text("The %s swipes at you with its claws and dealt %d damage." % [enemy2.name, enemy2.damage2])
				await textbox_closed
			2:
				current_player_health = max(0, current_player_health - enemy2.damage3)
				set_health($PlayerPanel/PlayerData/ProgressBar, current_player_health, State.max_health)
	
				$AnimationPlayer.play("shake")
				await $AnimationPlayer.animation_finished
	
				display_text("The %s hit you with its tail and dealt %d damage." % [enemy2.name, enemy2.damage3])
				await textbox_closed
	if current_enemy_health_1 > 0:
		if is_defending:
			$AnimationPlayer.play("mini_shake")
			await $AnimationPlayer.animation_finished
			display_text("You defended successfully!")
			await textbox_closed
			get_tree().create_timer(0.25).timeout
		else:
			current_player_health = max(0, current_player_health - enemy.damage1)
			set_health($PlayerPanel/PlayerData/ProgressBar, current_player_health, State.max_health)
			$AnimationPlayer.play("shake")
			await $AnimationPlayer.animation_finished
			display_text("The %s hit you and dealt %d damage." % [enemy.name, enemy.damage1])
			await textbox_closed
	if current_enemy_health_3 > 0:
		if is_defending:
			$AnimationPlayer.play("mini_shake")
			await $AnimationPlayer.animation_finished
			display_text("You defended successfully!")
			await textbox_closed
			get_tree().create_timer(0.25).timeout
		else:
			current_player_health = max(0, current_player_health - enemy3.damage1)
			set_health($PlayerPanel/PlayerData/ProgressBar, current_player_health, State.max_health)
			$AnimationPlayer.play("shake")
			await $AnimationPlayer.animation_finished
			display_text("The %s hit you and dealt %d damage." % [enemy3.name, enemy3.damage1])
			await textbox_closed
	if turns == 5:
		display_text("The %s is charging up a massive attack." % enemy.name)
		await textbox_closed
	if current_player_health == 0:
		$AnimationPlayer.play("player_death")
		await $AnimationPlayer.animation_finished
		
		display_text("You were defeated.")
		await textbox_closed
		
		await get_tree().create_timer(0.25).timeout
		get_tree().change_scene_to_file("res://Scenes/Endings/bad_ending.tscn")
	is_defending = false
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
	display_text("Choose who you want to attack")
	await textbox_closed
	enemies[index].get_node("focus").show()
	await get_tree().create_timer(0.25).timeout
	_choice()
	await choice
	on = true
	enemies[index].get_node("focus").hide()
	display_text("How do you attack?")
	await textbox_closed
	await get_tree().create_timer(0.25).timeout
	$AttacksPanel.show()

func _on_defend_pressed():
	is_defending = true
	
	display_text("You prepare defensively.")
	await textbox_closed
	
	await get_tree().create_timer(0.25).timeout

	enemy_turn()

func switch_focus(x,y):
	enemies[x].get_node("focus").show()
	enemies[y].get_node("focus").hide()

func _choice():
	while on:
		if Input.is_action_just_pressed("ui_left"):
			if index > 0:
				index -= 1
				switch_focus(index, index+1)
		if Input.is_action_just_pressed("ui_right"):
			if index < enemies.size() - 1:
				index += 1
				switch_focus(index, index-1)
		if Input.is_action_just_pressed("ui_accept"):
			on = false
		await get_tree().create_timer(0.01).timeout
	emit_signal("choice")

func _on_staff_bash_pressed():
	match index:
		0:
			display_text("You bash the %s over the head with your staff." % enemy.name)
			await textbox_closed
			current_enemy_health_1 = max(0, current_enemy_health_1 - State.damage)
			set_health(enemies[index].get_node("ProgressBar"), current_enemy_health_1, enemy.health)
			$AnimationPlayer.play("enemy_damaged_1")
			await $AnimationPlayer.animation_finished
			display_text("You dealt %d damage to the %s!" % [State.damage*State.damagebuff, enemy.name])
			await textbox_closed
		1:
			display_text("You bash the %s over the head with your staff." % enemy2.name)
			await textbox_closed
			current_enemy_health_2 = max(0, current_enemy_health_2 - State.damage)
			set_health(enemies[index].get_node("ProgressBar"), current_enemy_health_2, enemy2.health)
			$AnimationPlayer.play("enemy_damaged_2")
			await $AnimationPlayer.animation_finished
			display_text("You dealt %d damage to the %s!" % [State.damage*State.damagebuff, enemy2.name])
			await textbox_closed
		2:
			display_text("You bash the %s over the head with your staff." % enemy3.name)
			await textbox_closed
			current_enemy_health_3 = max(0, current_enemy_health_3 - State.damage)
			set_health(enemies[index].get_node("ProgressBar"), current_enemy_health_3, enemy3.health)
			$AnimationPlayer.play("enemy_damaged_3")
			await $AnimationPlayer.animation_finished
			display_text("You dealt %d damage to the %s!" % [State.damage*State.damagebuff, enemy3.name])
			await textbox_closed
	check_death()
	end_turn()
	enemy_turn()

func _on_fury_attack_pressed():
	var random_number = (randi() % 4) + 2
	match index:
		0:
			display_text("You unleash a flurry of attacks towards the %s." % enemy.name)
			await textbox_closed
			if current_enemy_health_1 != -1:
				current_enemy_health_1 = max(0, current_enemy_health_1 - State.damage2*State.damagebuff*random_number)
				set_health(enemies[index].get_node("ProgressBar"), current_enemy_health_1, enemy.health)
			$AnimationPlayer.play("enemy_damaged_1")
			await $AnimationPlayer.animation_finished
			display_text("You dealt %d damage to the %s %d times!" % [State.damage2*State.damagebuff*random_number, enemy.name, random_number])
			await textbox_closed
		1:
			display_text("You unleash a flurry of attacks towards the %s." % enemy2.name)
			await textbox_closed
			current_enemy_health_2 = max(0, current_enemy_health_2 - State.damage2*State.damagebuff*random_number)
			set_health(enemies[index].get_node("ProgressBar"), current_enemy_health_2, enemy2.health)
			$AnimationPlayer.play("enemy_damaged_2")
			await $AnimationPlayer.animation_finished
			display_text("You dealt %d damage to the %s %d times!" % [State.damage2*State.damagebuff*random_number, enemy2.name, random_number])
			await textbox_closed
		2:
			display_text("You unleash a flurry of attacks towards the %s." % enemy3.name)
			await textbox_closed
			if current_enemy_health_3 != -1:
				current_enemy_health_3 = max(0, current_enemy_health_3 - State.damage2*State.damagebuff*random_number)
				set_health(enemies[index].get_node("ProgressBar"), current_enemy_health_3, enemy3.health)
			$AnimationPlayer.play("enemy_damaged_3")
			await $AnimationPlayer.animation_finished
			display_text("You dealt %d damage to the %s %d times!" % [State.damage2*State.damagebuff*random_number, enemy3.name, random_number])
			await textbox_closed
	check_death()
	end_turn()
	enemy_turn()

func _on_baptism_pressed():
	display_text("You enchant yourself with holy water.")
	await textbox_closed

	display_text("It's time to run these holy hands.")
	await textbox_closed
	
	buff_duration = 4
	State.damagebuff = 1.25
	
	end_turn()
	enemy_turn()


func _on_vampiric_touch_pressed():
	if vt_cd == 1:
		display_text("You feel too tired. Wait for %d more turn." % vt_cd)
		await textbox_closed
		await get_tree().create_timer(0.25).timeout
		$AttacksPanel.show()
	elif vt_cd > 1:
		display_text("You feel too tired. Wait for %d more turns." % vt_cd)
		await textbox_closed
		await get_tree().create_timer(0.25).timeout
		$AttacksPanel.show()
	else:
		match index:
			0:
				if current_enemy_health_1 != -1:
					display_text("You siphon the life out of the %s." % enemy.name)
					await textbox_closed
					current_enemy_health_1 = max(0, current_enemy_health_1 - State.damage)
					set_health(enemies[index].get_node("ProgressBar"), current_enemy_health_1, enemy.health)
					$AnimationPlayer.play("enemy_damaged_1")
					await $AnimationPlayer.animation_finished
					display_text("You dealt %d damage to the %s!" % [State.vt_damage*State.damagebuff, enemy.name])
					await textbox_closed
					current_player_health = min(current_player_health + ((State.vt_damage*State.damagebuff)/2), State.max_health)
					set_health($PlayerPanel/PlayerData/ProgressBar, current_player_health, State.max_health)
					display_text("You heal yourself for %d health." % ((State.vt_damage*State.damagebuff)/2))
					await textbox_closed
			1:
				display_text("You siphon the life out of the %s." % enemy2.name)
				await textbox_closed
				current_enemy_health_2 = max(0, current_enemy_health_2 - State.damage)
				set_health(enemies[index].get_node("ProgressBar"), current_enemy_health_2, enemy2.health)
				$AnimationPlayer.play("enemy_damaged_2")
				await $AnimationPlayer.animation_finished
				display_text("You dealt %d damage to the %s!" % [State.vt_damage*State.damagebuff, enemy2.name])
				await textbox_closed
				current_player_health = min(current_player_health + ((State.vt_damage*State.damagebuff)/2), State.max_health)
				set_health($PlayerPanel/PlayerData/ProgressBar, current_player_health, State.max_health)
				display_text("You heal yourself for %d health." % ((State.vt_damage*State.damagebuff)/2))
				await textbox_closed
			2:
				if current_enemy_health_3 != -1:
					display_text("You siphon the life out of the %s." % enemy3.name)
					await textbox_closed
					current_enemy_health_3 = max(0, current_enemy_health_3 - State.damage)
					set_health(enemies[index].get_node("ProgressBar"), current_enemy_health_3, enemy3.health)
					$AnimationPlayer.play("enemy_damaged_3")
					await $AnimationPlayer.animation_finished
					display_text("You dealt %d damage to the %s!" % [State.vt_damage*State.damagebuff, enemy3.name])
					await textbox_closed
					current_player_health = min(current_player_health + ((State.vt_damage*State.damagebuff)/2), State.max_health)
					set_health($PlayerPanel/PlayerData/ProgressBar, current_player_health, State.max_health)
					display_text("You heal yourself for %d health." % ((State.vt_damage*State.damagebuff)/2))
					await textbox_closed
		check_death()
		end_turn()
		vt_cd = 2
		enemy_turn()


func _on_holy_ward_pressed():
	if hw_cd == 1:
		display_text("You feel too tired. Wait for %d more turn." % hw_cd)
		await textbox_closed
		await get_tree().create_timer(0.25).timeout
		$AttacksPanel.show()
	elif hw_cd > 1:
		display_text("You feel too tired. Wait for %d more turns." % hw_cd)
		await textbox_closed
		await get_tree().create_timer(0.25).timeout
		$AttacksPanel.show()
	else:
		display_text("You begin channeling divine light.")
		await textbox_closed
		if current_enemy_health_1 != -1:
			current_enemy_health_1 = max(0, current_enemy_health_1 - State.hw_damage)
			set_health(enemies[0].get_node("ProgressBar"), current_enemy_health_1, enemy.health)
		current_enemy_health_2 = max(0, current_enemy_health_2 - State.hw_damage)
		set_health(enemies[1].get_node("ProgressBar"), current_enemy_health_2, enemy2.health)
		if current_enemy_health_3:
			current_enemy_health_3 = max(0, current_enemy_health_3 - State.hw_damage)
			set_health(enemies[2].get_node("ProgressBar"), current_enemy_health_3, enemy3.health)
		if current_enemy_health_1 > 0:
			$AnimationPlayer.play("enemy_damaged_1")
		$AnimationPlayer2.play("enemy_damaged_2")
		if current_enemy_health_3 > 0:
			$AnimationPlayer3.play("enemy_damaged_3")
		if current_enemy_health_1 > 0:
			await $AnimationPlayer.animation_finished
		await $AnimationPlayer2.animation_finished
		if current_enemy_health_3 > 0:
			await $AnimationPlayer3.animation_finished
		display_text("You dealt %d damage to all enemies!" % [State.hw_damage*State.damagebuff])
		await textbox_closed
		
		check_death()
		end_turn()
		hw_cd = 3
		enemy_turn()


func _on_mass_heal_pressed():
	if mh_cd == 1:
		display_text("You feel too tired. Wait for %d more turn." % mh_cd)
		await textbox_closed
		await get_tree().create_timer(0.25).timeout
		$AttacksPanel.show()
	elif mh_cd > 1:
		display_text("You feel too tired. Wait for %d more turns." % mh_cd)
		await textbox_closed
		await get_tree().create_timer(0.25).timeout
		$AttacksPanel.show()
	else:
		display_text("A surge of healing energy emerges from within you.")
		await textbox_closed
		await get_tree().create_timer(0.25).timeout
		current_player_health = min(current_player_health + (State.mh_heal), State.max_health)
		set_health($PlayerPanel/PlayerData/ProgressBar, current_player_health, State.max_health)
		display_text("You heal yourself for %d health." % (State.mh_heal))
		await textbox_closed
		
		end_turn()
		mh_cd = 4
		enemy_turn()


func _on_null_field_pressed():
	if nf_cd == 1:
		display_text("You feel too tired. Wait for %d more turn." % nf_cd)
		await textbox_closed
		await get_tree().create_timer(0.25).timeout
		$AttacksPanel.show()
	else:
		is_defending = true
		display_text("You protect yourself with magic.")
		await textbox_closed
		display_text("Use another action.")
		await textbox_closed
		await get_tree().create_timer(0.25).timeout
		
		end_turn()
		nf_cd = 1
		$ActionsPanel.show()

func minion_death():
	if abilities < 3:
		abilities = abilities + 1
		$"AttacksPanel/Actions/Vampiric Touch".show()
		$AttacksPanel.hide()
		await get_tree().create_timer(0.25).timeout
		display_text("You have learned Vampiric Touch.")
		await textbox_closed
		await get_tree().create_timer(0.25).timeout
		emit_signal("minion_died")
	else:
		await get_tree().create_timer(0.25).timeout
		match minions:
			1:
				display_text("You can learn Null Field.")
				await textbox_closed
				await get_tree().create_timer(0.25).timeout
				display_text("You have too many abilities. Choose one to forget.")
				await textbox_closed
				await get_tree().create_timer(0.25).timeout
				$"AbilitiesChoicePanel/Actions/Null Field".visible = true
				$AbilitiesChoicePanel.show()
			2:
				display_text("You can learn Mass Heal.")
				await textbox_closed
				await get_tree().create_timer(0.25).timeout
				display_text("You have too many abilities. Choose one to forget.")
				await textbox_closed
				await get_tree().create_timer(0.25).timeout
				$"AbilitiesChoicePanel/Actions/Mass Heal".visible = true
				$AbilitiesChoicePanel.show()
			3:
				display_text("You can learn Holy Ward.")
				await textbox_closed
				await get_tree().create_timer(0.25).timeout
				display_text("You have too many abilities. Choose one to forget.")
				await textbox_closed
				await get_tree().create_timer(0.25).timeout
				$"AbilitiesChoicePanel/Actions/Holy Ward".visible = true
				$AbilitiesChoicePanel.show()
			_:
				pass
		await get_tree().create_timer(0.25).timeout
		
	
func end_turn():
	buff_duration = max(0, buff_duration - 1)
	vt_cd = max(0, vt_cd - 1)
	hw_cd = max(0, hw_cd - 1)
	mh_cd = max(0, mh_cd - 1)
	nf_cd = max(0, nf_cd - 1)


func _on_fury_attack_pressed_choice():
	match minions:
		1:
			$"AbilitiesChoicePanel/Actions/Null Field".show()
			$"AttacksPanel/Actions/Null Field".show()
			$"AbilitiesChoicePanel/Actions/Fury Attack".hide()
			$"AttacksPanel/Actions/Fury Attack".hide()
			display_text("You have forgotten Fury Attack and learned Null Field.")
			await textbox_closed
			await get_tree().create_timer(0.25).timeout
			emit_signal("minion_died")
		2:
			$"AbilitiesChoicePanel/Actions/Mass Heal".show()
			$"AttacksPanel/Actions/Mass Heal".show()
			$"AbilitiesChoicePanel/Actions/Fury Attack".hide()
			$"AttacksPanel/Actions/Fury Attack".hide()
			display_text("You have forgotten Fury Attack and learned Mass Heal.")
			await textbox_closed
			await get_tree().create_timer(0.25).timeout
			emit_signal("minion_died")
		3:
			$"AbilitiesChoicePanel/Actions/Holy Ward".show()
			$"AttacksPanel/Actions/Holy Ward".show()
			$"AbilitiesChoicePanel/Actions/Fury Attack".hide()
			$"AttacksPanel/Actions/Fury Attack".hide()
			display_text("You have forgotten Fury Attack and learned Holy Ward.")
			await textbox_closed
			await get_tree().create_timer(0.25).timeout
			emit_signal("minion_died")


func _on_baptism_pressed_choice():
	match minions:
		1:
			$"AbilitiesChoicePanel/Actions/Null Field".show()
			$"AttacksPanel/Actions/Null Field".show()
			$"AbilitiesChoicePanel/Actions/Baptism".hide()
			$"AttacksPanel/Actions/Baptism".hide()
			display_text("You have forgotten Baptism and learned Null Field.")
			await textbox_closed
			await get_tree().create_timer(0.25).timeout
			emit_signal("minion_died")
		2:
			$"AbilitiesChoicePanel/Actions/Mass Heal".show()
			$"AttacksPanel/Actions/Mass Heal".show()
			$"AbilitiesChoicePanel/Actions/Baptism".hide()
			$"AttacksPanel/Actions/Baptism".hide()
			display_text("You have forgotten Baptism and learned Mass Heal.")
			await textbox_closed
			await get_tree().create_timer(0.25).timeout
			emit_signal("minion_died")
		3:
			$"AbilitiesChoicePanel/Actions/Holy Ward".show()
			$"AttacksPanel/Actions/Holy Ward".show()
			$"AbilitiesChoicePanel/Actions/Baptism".hide()
			$"AttacksPanel/Actions/Baptism".hide()
			display_text("You have forgotten Baptism and learned Holy Ward.")
			await textbox_closed
			await get_tree().create_timer(0.25).timeout
			emit_signal("minion_died")


func _on_vampiric_touch_pressed_choice():
	match minions:
		1:
			$"AbilitiesChoicePanel/Actions/Null Field".show()
			$"AttacksPanel/Actions/Null Field".show()
			$"AbilitiesChoicePanel/Actions/Vampiric Touch".hide()
			$"AttacksPanel/Actions/Vampiric Touch".hide()
			display_text("You have forgotten Vampiric Touch and learned Null Field.")
			await textbox_closed
			await get_tree().create_timer(0.25).timeout
			emit_signal("minion_died")
		2:
			$"AbilitiesChoicePanel/Actions/Mass Heal".show()
			$"AttacksPanel/Actions/Mass Heal".show()
			$"AbilitiesChoicePanel/Actions/Vampiric Touch".hide()
			$"AttacksPanel/Actions/Vampiric Touch".hide()
			display_text("You have forgotten Vampiric Touch and learned Mass Heal.")
			await textbox_closed
			await get_tree().create_timer(0.25).timeout
			emit_signal("minion_died")
		3:
			$"AbilitiesChoicePanel/Actions/Holy Ward".show()
			$"AttacksPanel/Actions/Holy Ward".show()
			$"AbilitiesChoicePanel/Actions/Vampiric Touch".hide()
			$"AttacksPanel/Actions/Vampiric Touch".hide()
			display_text("You have forgotten Vampiric Touch and learned Holy Ward.")
			await textbox_closed
			await get_tree().create_timer(0.25).timeout
			emit_signal("minion_died")


func _on_holy_ward_pressed_choice():
	match minions:
		1:
			$"AbilitiesChoicePanel/Actions/Null Field".show()
			$"AttacksPanel/Actions/Null Field".show()
			$"AbilitiesChoicePanel/Actions/Holy Ward".hide()
			$"AttacksPanel/Actions/Holy Ward".hide()
			display_text("You have forgotten Holy Ward and learned Null Field.")
			await textbox_closed
			await get_tree().create_timer(0.25).timeout
			emit_signal("minion_died")
		2:
			$"AbilitiesChoicePanel/Actions/Mass Heal".show()
			$"AttacksPanel/Actions/Mass Heal".show()
			$"AbilitiesChoicePanel/Actions/Holy Ward".hide()
			$"AttacksPanel/Actions/Holy Ward".hide()
			display_text("You have forgotten Holy Ward and learned Mass Heal.")
			await textbox_closed
			await get_tree().create_timer(0.25).timeout
			emit_signal("minion_died")
		3:
			$"AbilitiesChoicePanel/Actions/Holy Ward".hide()
			$"AttacksPanel/Actions/Holy Ward".hide()
			display_text("You have forgotten Holy Ward.")
			await textbox_closed
			await get_tree().create_timer(0.25).timeout
			emit_signal("minion_died")


func _on_mass_heal_pressed_choice():
	match minions:
		1:
			$"AbilitiesChoicePanel/Actions/Null Field".show()
			$"AttacksPanel/Actions/Null Field".show()
			$"AbilitiesChoicePanel/Actions/Mass Heal".hide()
			$"AttacksPanel/Actions/Mass Heal".hide()
			display_text("You have forgotten Mass Heal and learned Null Field.")
			await textbox_closed
			await get_tree().create_timer(0.25).timeout
			emit_signal("minion_died")
		2:
			$"AbilitiesChoicePanel/Actions/Mass Heal".hide()
			$"AttacksPanel/Actions/Mass Heal".hide()
			display_text("You have forgotten Mass Heal.")
			await textbox_closed
			await get_tree().create_timer(0.25).timeout
			emit_signal("minion_died")


func _on_null_field_pressed_choice():
	match minions:
		1:
			$"AbilitiesChoicePanel/Actions/Null Field".hide()
			$"AttacksPanel/Actions/Null Field".hide()
			display_text("You have forgotten Null Field.")
			await textbox_closed
			await get_tree().create_timer(0.25).timeout
			emit_signal("minion_died")

func check_death():
	if current_enemy_health_1 == 0:
		minions = max(0, minions - 1)
		current_enemy_health_1 = -1
		display_text("The %s was defeated!" % enemy.name)
		await textbox_closed
		$AnimationPlayer.play("enemy_died_1")
		await $AnimationPlayer.animation_finished
		minion_death()
		await minion_died
		if minions > 2:
			current_enemy_health_1 = 30
			display_text("The %s summoned another %s." % [enemy2.name, enemy.name])
			await textbox_closed
			$AnimationPlayer.play("minion_1_summon")
			await $AnimationPlayer.animation_finished
			set_health(enemies[0].get_node("ProgressBar"), current_enemy_health_1, enemy.health)
		await get_tree().create_timer(0.25).timeout
	
	if current_enemy_health_2 == 0:
		current_enemy_health_2 = -1
		display_text("The %s was defeated!" % enemy2.name)
		await textbox_closed
		$AnimationPlayer.play("enemy_died_2")
		await $AnimationPlayer.animation_finished
		await get_tree().create_timer(0.25).timeout
		$AnimationPlayer.play("enemy_died_2")
		$AnimationPlayer.play("scene_out")
		display_text("ARGHHHHHHHHH!")
		await textbox_closed
		await $AnimationPlayer.animation_finished
		await get_tree().create_timer(0.25).timeout
		get_tree().change_scene_to_file("res://Scenes/Endings/good_ending.tscn") 
		
	if current_enemy_health_3 == 0:
		minions = max(0, minions - 1)
		current_enemy_health_3 = -1
		display_text("The %s was defeated!" % enemy3.name)
		await textbox_closed
		$AnimationPlayer.play("enemy_died_3")
		await $AnimationPlayer.animation_finished
		minion_death()
		await minion_died
		if minions > 2:
			current_enemy_health_3 = 30
			display_text("The %s summoned another %s." % [enemy2.name, enemy3.name])
			await textbox_closed
			$AnimationPlayer.play("minion_3_summon")
			await $AnimationPlayer.animation_finished
			set_health(enemies[2].get_node("ProgressBar"), current_enemy_health_3, enemy3.health)
		await get_tree().create_timer(0.25).timeout
 
