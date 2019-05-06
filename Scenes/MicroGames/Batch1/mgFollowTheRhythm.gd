extends "res://Scripts/MicroGame.gd"

onready var music_player = AudioManager.music_player
onready var beat_anim = $BeatAnim
onready var arrow = $TimingBar/Arrow
onready var progress = $Progress
var good_length = 0.3
var prev_pressed = false

onready var sfx_correct = AudioManager.get_sound_id("select1.wav")

var input_timer = 0
onready var dancing_guy = $DancingGuy

#Music synchronization stuff

var bpm = 250
var incr = 0

var meter = 0
var pressed = false
var begin_time = 0

var prev_beats = 0;
var prev_input_timer = 0
var beated = false
var timing_offset = 0.0
var latency = 0.0
var dancing =false;

func _init():
	hint_string = "Follow the rhythm"
	time = 8

# Called when the node enters the scene tree for the first time.
func _ready():
	if difficulty == 0:
		bpm = 180
		timing_offset = 0.15
		pass
	elif difficulty == 1:
		bpm = 180
		timing_offset = 0.15
		pass
	elif difficulty == 2:
		bpm = 180
		timing_offset = 0.15
		pass
	beat_anim.playback_speed = (bpm/60)*game_speed
	
	incr = (100.0/float(bpm))*15
	start_music()
	
func start_music():
	AudioManager.play_music("Super Smash Land - Dreamland Music.ogg")
	begin_time = OS.get_ticks_usec()
	#dance_anim.play("1bpm")
	latency = Performance.get_monitor(Performance.AUDIO_OUTPUT_LATENCY)
	#var latency = Performance.get_monitor(Performance.AUDIO_OUTPUT_LATENCY)
	#beat_timeline.seek(latency)


		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	var current_time = (OS.get_ticks_usec() - begin_time) / 1000000.0
	prev_input_timer = input_timer
	input_timer = fmod((current_time * (bpm*game_speed) / 60.0)+timing_offset+latency,1)
	if dancing:
		dancing_guy.frame = fmod((current_time * (bpm*game_speed*2) / 60.0)+timing_offset+latency,4)
	if input_timer < prev_input_timer:
		beated = false
		if !pressed:
			meter = clamp(meter-incr*0.2,0,100)
			if meter < 81:
				game_loss()
			dancing = false
	
		pressed = false
	if !beated && input_timer >= 0.3:
		beat_anim.play("beat")
		beated = true
	
	if  (Input.is_action_just_pressed("b")||Input.is_action_just_pressed("a")):
		if !pressed &&((input_timer) >= (0.5-good_length) && (input_timer) <= (0.5+good_length)):
			meter = clamp(meter+incr,0,100)
			if meter >= 81:
				game_cleared()
			pass
			AudioManager.play_sfx(sfx_correct)
			pressed = true
			dancing = true
		else:
			meter = clamp(meter-incr*0.5,0,100)
			if meter < 81:
				game_loss()
			dancing = false
		arrow.position.x = (input_timer)*148
	progress.value = meter
	
