extends Control

var player: Dictionary
var ally: Dictionary
var opponent: Dictionary

var taking_input = false

onready var battlers = $JsonParser.load_data("res://story/battlers.json")
onready var actors = $JsonParser.load_data("res://story/actors.json")

onready var opponent_label = $EnemyHealthbar/EnemyNameLabel
onready var health_label = $StatsBlock/HealthLabel
onready var wounds_label = $StatsBlock/WoundsLabel
onready var magic_label = $StatsBlock/MagicLabel
onready var health_bar = $EnemyHealthbar

func _ready() -> void:
	$SoundManager.play("combat_bgm", "okey-dokey-smokey", -10, 1, true)
	player = battlers["lydia"]
	opponent = battlers["invincible_necromancer"]
	$StageObject.tag = "opponent"
	$StageObject.data = actors[opponent.actor]
	$StageObject.init()
	# opponent["sprite"] = $fakemancer
	# opponent["animation"] = $fakemancer/AnimationPlayer
	update_ui()
	$DialogBox.output("[b]The Necromancer[/b] stands in measured menace.")
	yield(get_tree().create_timer(1.8), "timeout")
	taking_input = true

func _process(delta: float) -> void:
	$AttackButton.disabled = !taking_input
	$HealButton.disabled = !taking_input
	$RestoreButton.disabled = !taking_input
	if player.hp <= 0 or player.mp <= 0:
		taking_input = false

func initialize(opponent: String, ally: String = "none") -> void:
	pass

# STATS
func damage(target: Dictionary, amount: int):
	target.hp = max(0, target.hp - amount)
	#if target.hp <= 0: die()

func heal(target: Dictionary, amount: int):
	target.hp = min(target.max_hp, target.hp + amount)

func spend_magic(target: Dictionary, amount: int):
	target.mp = max(0, target.mp - amount)
	#if target.mp <= 0: die()

func restore_magic(target: Dictionary, amount: int):
	target.mp = min(target.max_mp, target.mp + amount)

# MOVES
func move_attack(source: Dictionary, target: Dictionary):
	var amount = Random.roll("1d8") + 1
	var formatting = [source.short_name.capitalize(), target.short_name, amount]
	damage(target, amount)
	$DialogBox.output("[b]{0}[/b] attacks [b]{1}[/b] for {2} damage!".format(formatting))
	yield(get_tree().create_timer(2), "timeout")
	var damage_sound = Random.choose(["damage1", "damage2", "damage3"])
	$SoundManager.play_and_forget(damage_sound)
	if target == opponent:
		$WackAnimation.frame = 0
		$WackAnimation.visible = true
		$WackAnimation.play("default")
		$StageObject/AnimationPlayer.play("take_hit")
	if target == player:
		$DamageVignette/AnimationPlayer.play("player_damage")
		wounds_add_effect(amount)
	update_ui()
	yield(get_tree().create_timer(0.5), "timeout")

func move_harpoon(source: Dictionary, target: Dictionary):
	var amount = Random.roll("1d6") + 1
	var formatting = [source.short_name.capitalize(), target.short_name, amount]
	damage(target, amount)
	$DialogBox.output("[b]{0}[/b] harpoons [b]{1}[/b] for {2} damage!".format(formatting))
	yield(get_tree().create_timer(2), "timeout")
	var damage_sound = Random.choose(["damage1", "damage2", "damage3"])
	$SoundManager.play_and_forget(damage_sound)
	if target == opponent:
		$WackAnimation.frame = 0
		$WackAnimation.visible = true
		$WackAnimation.play("default")
		$StageObject/AnimationPlayer.play("take_hit")
	if target == player:
		$DamageVignette/AnimationPlayer.play("player_damage")
		wounds_add_effect(amount)
	update_ui()
	yield(get_tree().create_timer(0.5), "timeout")

func move_heal(source: Dictionary, target: Dictionary):
	var cost = Random.roll("1d4") - 1
	var amount = Random.choose([8, 8, 9, 9, 10, 14])
	var formatting
	spend_magic(source, cost)
	heal(target, amount)
	if source == target:
		formatting = [source.short_name.capitalize(), amount]
		$DialogBox.output("[b]{0}[/b] heals {1} wounds!".format(formatting))
	else:
		formatting = [source.short_name.capitalize(), amount, target.short_name]
		$DialogBox.output("[b]{0}[/b] heals {1} of {2}'s wounds!".format(formatting))
	yield(get_tree().create_timer(1.5), "timeout")
	$SoundManager.play_and_forget("heal")
	if target == player:
		$HealingVignette/AnimationPlayer.play("player_healing", -6)
		wounds_remove_effect(amount)
		magic_remove_effect(amount)
	update_ui()
	yield(get_tree().create_timer(0.5), "timeout")

func move_arcade_heal(source: Dictionary, target: Dictionary):
	var cost = 4
	var amount = 4
	var formatting
	spend_magic(source, cost)
	heal(target, amount)
	if source == target:
		formatting = [source.short_name.capitalize(), amount]
		$DialogBox.output("[b]{0}[/b] heals {1} wounds!".format(formatting))
	else:
		formatting = [source.short_name.capitalize(), amount, target.short_name]
		$DialogBox.output("[b]{0}[/b] heals {1} of {2}'s wounds!".format(formatting))
	yield(get_tree().create_timer(1.5), "timeout")
	$SoundManager.play_and_forget("lifesteal")
	if target == player: wounds_remove_effect(amount)
	update_ui()
	yield(get_tree().create_timer(0.5), "timeout")

func move_restore(source: Dictionary, target: Dictionary):
	var amount = Random.choose([5, 5, 6, 6, 7, 8])
	var formatting
	restore_magic(target, amount)
	if source == target:
		formatting = [source.short_name.capitalize(), amount]
		$DialogBox.output("[b]{0}[/b] restores {1} magic points!".format(formatting))
	else:
		formatting = [source.short_name.capitalize(), amount, target.short_name]
		$DialogBox.output("[b]{0}[/b] restores {1} magic points!".format(formatting))
	yield(get_tree().create_timer(1.65), "timeout")
	$SoundManager.play_and_forget("energize", -8)
	if target == player: magic_add_effect(amount)
	update_ui()
	yield(get_tree().create_timer(0.5), "timeout")

func move_steal_magic(source: Dictionary, target: Dictionary):
	var amount: int = Random.roll("1d4")
	var formatting = [source.short_name.capitalize(), amount, target.short_name]
	spend_magic(target, amount)
	restore_magic(source, amount)
	$DialogBox.output("[b]{0}[/b] steals {1} magic points from {2}!".format(formatting))
	yield(get_tree().create_timer(2), "timeout")
	$SoundManager.play_and_forget("lifesteal")
	if target == player: magic_remove_effect(amount)
	update_ui()
	yield(get_tree().create_timer(0.5), "timeout")

# AI
func opponent_turn():
	taking_input = false
	if player.hp <= 0:
		$DialogBox.output("Damn, you dead.")
	elif opponent.mp <= 0 or opponent.hp <= 0:
		$DialogBox.output("Damn, you've killed 'em.")
	elif opponent.mp <= 5 and Random.prob(70):
		yield(move_steal_magic(opponent, player), "completed")
	elif opponent.hp <= 10 and opponent.mp > 4:
		yield(move_arcade_heal(opponent, opponent), "completed")
	else:
		yield(move_harpoon(opponent, player), "completed")
	taking_input = true

# UI
func update_health_bar():
	var tween = $EnemyHealthbar/Tween
	opponent_label.text = opponent.display_name
	health_bar.max_value = opponent.max_hp
	tween.interpolate_property(
		health_bar, "value",
		null, opponent.hp,
		0.5, Tween.TRANS_BOUNCE, Tween.EASE_OUT
	)
	tween.start()

func update_player_stats():
	var player_hp: String = String(player.max_hp)
	var player_wounds: String = String(player.max_hp - player.hp)
	var player_mp: String = String(player.mp)
	health_label.text = player_hp
	wounds_label.text = player_wounds
	magic_label.text = player_mp

func magic_add_effect(value: int):
	$StatsBlock/MagicEffectLabel.text = String(value)
	$StatsBlock/MagicEffectLabel/AnimationPlayer.play("add")

func magic_remove_effect(value: int):
	$StatsBlock/MagicEffectLabel.text = String(value)
	$StatsBlock/MagicEffectLabel/AnimationPlayer.play("remove")

func wounds_add_effect(value: int):
	$StatsBlock/WoundsEffectLabel.text = String(value)
	$StatsBlock/WoundsEffectLabel/AnimationPlayer.play("add")

func wounds_remove_effect(value: int):
	$StatsBlock/WoundsEffectLabel.text = String(value)
	$StatsBlock/WoundsEffectLabel/AnimationPlayer.play("remove")

func update_ui():
	update_health_bar()
	update_player_stats()

# INPUT
func _on_AttackButton_pressed() -> void:
	if taking_input:
		taking_input = false
		$SoundManager.play_and_forget(Random.choose(["dice_roll", "dice_roll2", "dice_roll3"]))
		yield(move_attack(player, opponent), "completed")
		taking_input = true
		opponent_turn()

func _on_HealButton_pressed() -> void:
	if taking_input:
		taking_input = false
		$SoundManager.play_and_forget(Random.choose(["dice_roll", "dice_roll2", "dice_roll3"]))
		yield(move_heal(player, player), "completed")
		taking_input = true
		opponent_turn()

func _on_RestoreButton_pressed() -> void:
	if taking_input:
		taking_input = false
		$SoundManager.play_and_forget(Random.choose(["dice_roll", "dice_roll2", "dice_roll3"]))
		yield(move_restore(player, player), "completed")
		taking_input = true
		opponent_turn()

func _on_AttackButton_mouse_entered() -> void:
	if !$AttackButton.disabled:
		$SoundManager.play_and_forget(Random.choose(["rollover_001"]), -5)

func _on_HealButton_mouse_entered() -> void:
	if !$HealButton.disabled:
		$SoundManager.play_and_forget(Random.choose(["rollover_001"]), -5)

func _on_RestoreButton_mouse_entered() -> void:
	if !$RestoreButton.disabled:
		$SoundManager.play_and_forget(Random.choose(["rollover_001"]), -5)

func _on_WackAnimation_animation_finished() -> void:
	$WackAnimation.visible = false
