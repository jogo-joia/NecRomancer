extends Node

func _ready():
	randomize()

func choose(kwargs: Array):
	return kwargs[randi() % kwargs.size()]

func roll(dice_notation: String) -> int:
	var split: Array = dice_notation.split("d", false, 2)
	var amount: int = int(split[0])
	var faces: int = int(split[1])
	var result: int = 0
	print("rolling ", amount, "d", faces, " (", dice_notation, ")")
	for roll_index in amount:
		var roll_result = randi() % faces + 1
		print("individual roll: ", roll_result)
		result += roll_result
	print("Result: ", result)
	return result

func prob(probability: float) -> bool:
	var result: int = randi() % 101
	print("result: ", result, " probability: ", probability)
	return result <= probability