extends Node

var player: AudioStreamPlayer
var playback: AudioStreamGeneratorPlayback
var muted: bool = false
var sample_rate: float = 44100.0
var active_tones: Array[Dictionary] = []

# Subtle Late-Night Lounge Ambient Pad
var pad_time: float = 0.0
var pad_p1: float = 0.0
var pad_p2: float = 0.0
var pad_p3: float = 0.0

func _ready() -> void:
	player = AudioStreamPlayer.new()
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = sample_rate
	stream.buffer_length = 0.1
	player.stream = stream
	add_child(player)
	player.play()
	playback = player.get_stream_playback()

func _process(_delta: float) -> void:
	if not playback:
		return
	var frames := playback.get_frames_available()
	if frames <= 0:
		return

	var inv_sr := 1.0 / sample_rate
	for _i in range(frames):
		var sample := 0.0
		if not muted:
			pad_time += inv_sr
			var lfo := 0.5 + 0.5 * sin(pad_time * 0.45)
			var root_f := 110.0 if fmod(pad_time, 16.0) < 8.0 else 87.31
			var third_f := 130.81 if fmod(pad_time, 16.0) < 8.0 else 110.0
			var fifth_f := 164.81
			pad_p1 = fmod(pad_p1 + root_f * inv_sr, 1.0)
			pad_p2 = fmod(pad_p2 + third_f * inv_sr, 1.0)
			pad_p3 = fmod(pad_p3 + fifth_f * inv_sr, 1.0)
			var pad_wave := (sin(pad_p1 * TAU) * 0.5 + sin(pad_p2 * TAU) * 0.3 + sin(pad_p3 * TAU) * 0.2)
			sample += pad_wave * (0.014 + 0.010 * lfo)

			if active_tones.size() > 0:
				var idx := active_tones.size() - 1
				while idx >= 0:
					var t: Dictionary = active_tones[idx]
					if t["delay"] > 0.0:
						t["delay"] -= inv_sr
						idx -= 1
						continue
					var progress: float = t["elapsed"] / t["duration"]
					if progress >= 1.0:
						active_tones.remove_at(idx)
					else:
						var env: float = sin(progress * PI) * (1.0 - progress * 0.6)
						var freq: float = lerpf(t["freq_start"], t["freq_end"], progress)
						t["phase"] += freq * inv_sr
						var wave := sin(t["phase"] * TAU)
						if t["noise"] > 0.0:
							wave = lerpf(wave, randf_range(-1.0, 1.0), t["noise"])
						sample += wave * env * t["amp"]
						t["elapsed"] += inv_sr
					idx -= 1
		sample = clampf(sample, -0.95, 0.95)
		playback.push_frame(Vector2(sample, sample))

func _add_tone(freq_start: float, freq_end: float, duration: float, amp: float = 0.16, noise: float = 0.0, delay: float = 0.0) -> void:
	if muted:
		return
	active_tones.append({
		"freq_start": freq_start,
		"freq_end": freq_end,
		"duration": duration,
		"amp": amp,
		"noise": noise,
		"delay": delay,
		"elapsed": 0.0,
		"phase": 0.0
	})

func _vibrate(duration_ms: int) -> void:
	Input.vibrate_handheld(duration_ms)

func play_flip() -> void:
	_vibrate(18)
	_add_tone(220.0, 640.0, 0.085, 0.14, 0.55, 0.0)
	_add_tone(420.0, 580.0, 0.09, 0.10, 0.0, 0.03)

func play_complete() -> void:
	_vibrate(45)
	_add_tone(440.0, 554.37, 0.16, 0.15, 0.0, 0.0)
	_add_tone(659.25, 880.0, 0.24, 0.15, 0.0, 0.07)

func play_timer_finish() -> void:
	_vibrate(420)
	_add_tone(523.25, 659.25, 0.22, 0.18, 0.0, 0.0)
	_add_tone(659.25, 1046.5, 0.35, 0.20, 0.0, 0.08)

func play_pass() -> void:
	_vibrate(30)
	_add_tone(310.0, 175.0, 0.14, 0.14, 0.2, 0.0)

func play_dice() -> void:
	_vibrate(35)
	_add_tone(620.0, 260.0, 0.06, 0.18, 0.4, 0.0)
	_add_tone(780.0, 340.0, 0.07, 0.15, 0.35, 0.09)
	_add_tone(540.0, 290.0, 0.06, 0.12, 0.3, 0.18)

func play_wheel_tick() -> void:
	_vibrate(12)
	_add_tone(980.0, 460.0, 0.032, 0.14, 0.15, 0.0)

func play_heartbeat() -> void:
	_vibrate(38)
	get_tree().create_timer(0.14).timeout.connect(func(): _vibrate(24))
	_add_tone(78.0, 48.0, 0.11, 0.26, 0.05, 0.0)
	_add_tone(68.0, 42.0, 0.13, 0.20, 0.05, 0.15)

func play_level_up() -> void:
	_vibrate(80)
	_add_tone(523.25, 659.25, 0.18, 0.15, 0.0, 0.0)
	_add_tone(659.25, 783.99, 0.25, 0.16, 0.0, 0.09)

func play_climax() -> void:
	_vibrate(260)
	_add_tone(440.0, 440.0, 0.35, 0.14, 0.0, 0.0)
	_add_tone(554.37, 554.37, 0.35, 0.14, 0.0, 0.10)
	_add_tone(659.25, 880.0, 0.45, 0.18, 0.0, 0.20)
