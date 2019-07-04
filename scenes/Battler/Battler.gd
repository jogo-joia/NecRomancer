extends Node2D
class_name Battler

export(String) var battler_name
export(bool) var player_controlled
export(int) var max_hp
var hp: int
export(int) var max_mp
var mp: int

func initialize():
	hp = max_hp
	mp = max_mp

func play_turn():
	print("{0} plays their turn!".format([battler_name]))
	yield(get_tree().create_timer(0.5), "timeout")
	print("Nothing happens!")
	yield(get_tree().create_timer(0.5), "timeout")