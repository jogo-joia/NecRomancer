extends Node

var last_typing_index: int
var channels: Dictionary

onready var json_parser = $JsonParser
onready var voice_player: AudioStreamPlayer = $VoicePlayer

onready var voices: Dictionary = json_parser.load_data("res://story/voices.json")
onready var sounds: Dictionary = json_parser.load_data("res://story/sounds.json")

func _ready() -> void:
	pass

func speak(voice_name: String = "pencil") -> void:
	var voice: Array = voices[voice_name]
	var rng: int = randi() % voice.size() + 1
	var target_sound: = AudioStreamRandomPitch.new()
	target_sound.audio_stream = load(voice[0])
	target_sound.random_pitch = 1.1
	while rng == last_typing_index:
		rng = randi() % voice.size() + 1
	for index in voice.size():
		if index == rng:
			target_sound.audio_stream = load(voice[index])
	if not voice_player.playing:
		last_typing_index = rng
		voice_player.stream = target_sound
		voice_player.play()

func queue_add(channel: String, sound: Resource, volume: float, pitch: float, loop: = false):
	pass

func queue_start(channel: String):
	pass

func queue_play(channel: String):
	pass

func queue_skip(channel: String):
	pass

func queue_stop(channel: String):
	pass

func queue_pause(channel: String):
	pass

func play(channel: String, sound: String = "", volume: float = 0, pitch: float = 1, loop: = false):
	var player: AudioStreamPlayer
	if channel in channels.keys() and !loop:
		player = channels[channel].player
		player.play(channels[channel].playback_position)
		return
	else:
		player = AudioStreamPlayer.new()
	player = AudioStreamPlayer.new()
	player.set_name(channel)
	add_child(player)
	channels[channel] = {"player": player, "playback_position": 0.0}
	player.stream = load(sounds[sound])
	player.volume_db = volume
	player.pitch_scale = pitch
	player.play()
	yield(player, "finished")
	if loop:
		play(channel, sound, volume, pitch, true)
	if !loop:
		channels.erase(channel)
		player.queue_free()

func play_and_forget(sound: String = "", volume: float = 0, pitch: float = 1, loop: bool = false):
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(player)
	player.stream = load(sounds[sound])
	player.volume_db = volume
	player.pitch_scale = pitch
	player.play()
	yield(player, "finished")
	player.queue_free()
	

func stop(channel: String):
	pass

func resume(channel: String):
	var player: AudioStreamPlayer = channels[channel]["player"]
	player.play()

func pause(channel: String):
	var player: AudioStreamPlayer = channels[channel]["player"]
	channels[channel].playback_position = player.get_playback_position()
	player.stop()
	print("we pausing ", channel, ", it denotes player ", player)