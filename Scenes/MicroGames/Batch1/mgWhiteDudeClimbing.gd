extends Micro_Game

var climb_speed = 2
var climb_timer = 0
var climb_time = 0.1
var climbing = false
var a = true
var yspeed = 0

onready var dude = $WhiteDude
onready var butt = $WhiteDude/A
onready var victory_anim = $VictoryAnim
onready var sfx_victory = AudioManager.get_sound_id("victory.wav")
onready var sfx_climb = AudioManager.get_sound_id("shantae-jump.wav")
var game_over = false
var killed = false
var end_timer = 0
onready var sfx_hit = AudioManager.get_sound_id("punch.wav")

func _init():
	time = 8
	hint_string = "Climb"

# Called when the node enters the scene tree for the first time.
func _ready():
	if difficulty == 0:
		$m.queue_free()
		$h.queue_free()
		pass
	elif difficulty == 1:
		$h.queue_free()
		$m.visible = true
		pass
	elif difficulty == 2:
		$m.queue_free()
		$h.visible = true
		pass
	
	dude.frame = 15
	if a:
		butt.frame = 0
	else:
		butt.frame = 1
	AudioManager.play_music("mario-tenis-senior-class-segment.ogg")
	$WhiteDude/HB.connect("area_entered",self,"_on_dude_hb_triggered")
	pass # Replace with function body.

func force_microgame_end():
	.force_microgame_end()
	
func _on_dude_hb_triggered(a):
	if game_over:
		return
	if a.is_in_group("anime"):
		game_over = true
		killed = true
		climb_timer = 0
		butt.visible = false
		dude.scale.y = -1
		AudioManager.play_sfx(sfx_hit)
	pass

func _process(delta):
	if killed:
		end_timer += delta*game_speed
		if end_timer > 1:
			force_microgame_end()
	if game_ended || game_over:
		return
	if climb_timer > 0:
		butt.visible = false
		climb_timer = max(climb_timer-delta*game_speed,0)
		return
	butt.visible = true
	if (a && Input.is_action_just_pressed("a")) || (!a && Input.is_action_just_pressed("b")):
		climb_timer = climb_time
		if dude.frame == 15:
			dude.frame = 16
		else:
			dude.frame = 15
		yspeed = -climb_speed
		a = !a
		if a:
			butt.frame = 0
		else:
			butt.frame = 1
		AudioManager.play_sfx(sfx_climb)
	pass
	
func _physics_process(delta):
	if !killed && (game_ended || game_over):
		return
	dude.global_position.y += yspeed*delta*60*game_speed
	
	var oy = 0
	if dude.scale.y == -1:
		oy = 6
	if !killed && dude.position.y <=24:
		dude.frame = 17
		victory_anim.play("victory")
		game_over = true
		game_cleared()
		butt.visible = false
		AudioManager.play_sfx(sfx_victory)
	elif dude.position.y>144-20+oy:
		dude.position.y = 144-20+oy
		yspeed = 0
	if climb_timer == 0:
		yspeed += 0.2*60*delta*game_speed
		if yspeed > 3:
			yspeed = 3
	pass
