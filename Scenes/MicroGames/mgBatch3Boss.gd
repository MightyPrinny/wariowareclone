extends "res://Scripts/MicroGame.gd"

onready var screen_area = $ScreenArea
onready var ball = $Ball
onready var blast = $Blast
onready var blast_anim = $Blast/spr/AnimationPlayer
onready var fox = $Fox
onready var fox_hb = $Fox/FoxSpr/HB
onready var shine_hb = $Fox/FoxSpr/ShineHB
onready var fox_anim = $Fox/AnimationPlayer
onready var sfx_shine = AudioManager.get_sound_id("fox-shine.wav")
onready var krool = $KRool
onready var krool_anim = $KRool/AnimationPlayer
onready var krool_bb = $KRool/BB
onready var krool_hb = $KRool/HB
onready var krool_bt = $KRool/BT
onready var krool_shoot_pos = $KRool/Position2D
onready var ball_hb = $Ball/HB

onready var sfx_hit = AudioManager.get_sound_id("ssb-strong-hit.wav")
onready var sfx_reflect = AudioManager.get_sound_id("Bumper Hit.wav")
onready var sfx_explosion = AudioManager.get_sound_id("ssb-explosion.wav")
onready var sfx_cannon = AudioManager.get_sound_id("cannon.wav")

var ball_speed = 0
var ball_yspeed = 0
var ball_grav = 0
var ball_speedup = 0.25

var prev_ball_speed = 0

var shine_cooldown_timer = 0
var shine_cooldown_time
var shining = false
var krool_max_responses = 5
var krool_response_counter = 0

var game_over = false
var xpl = false
var using_belly = false

func _init():
	time = 15
	hint_string = "Reflect"
	
# Called when the node enters the scene tree for the first time.
func _ready():
	
	fox_anim.playback_speed = 1.5*game_speed
	screen_area.connect("area_exited",self,"_on_area_exited_screen")
	fox_anim.connect("animation_finished",self,"_on_fox_anim_end")
	krool_hb.connect("area_entered",self,"_on_krool_hb_ae")
	krool_bt.connect("area_entered",self,"_on_krool_bt_ae")
	shine_cooldown_time = 0.35
	krool_hb.position.x -= difficulty*2.5
	krool_max_responses += difficulty*2
	#AudioManager.play_music("Super Smash Land - Dreamland Music.ogg")
	AudioManager.play_music("mario-tenis-exhibition-court.ogg")
	
func _on_area_exited_screen(a):
	if game_ended:
		return
	if a.is_in_group("char"):
		if a.global_position.x < (160/2):
			blast.scale.x = 1
			blast.position.x = 0
		else:
			blast.scale.x = -1
			blast.position.x = 160
			
		blast.global_position.y = a.global_position.y-3
		blast_anim.play("b")
		if !xpl:
			xpl = true
			AudioManager.play_sfx(sfx_explosion)
		screen_area.disconnect("area_exited",self,"_on_area_exited_screen")
	if a.is_in_group("ball"):
		ball_yspeed = 0
		ball_grav = 0
		ball_speed = 0
	

func krool_ded():
	game_cleared()
	game_over = true
	force_microgame_end()

func _on_fox_hb_ae(a):
	if !game_over && a.is_in_group("ball"):
		fox_anim.play("die")
		game_over = true
		ball_hit()
		
	pass	
	
func _on_fox_anim_end(a):
	if a == "shine":
		shining = false
	pass

func _on_shine_ae(a):
	if a.is_in_group("ball"):
		if ball.scale.x == -1:
			ball.scale.x = 1
			ball_speed += ball_speedup*game_speed

func _on_krool_belly_ae(a):
	pass
	
func _on_krool_bt_ae(a):
	if krool_response_counter<krool_max_responses && a.is_in_group("ball") && !using_belly && ball.scale.x == 1:
		using_belly = true
		krool_response_counter+=1
		krool_anim.play("reflect")
	pass
	
func _on_krool_hb_ae(a):
	if !game_over && a.is_in_group("ball"):
		krool_anim.play("die")
		game_over = true
		ball_hit()
	pass
	
func force_microgame_end():
	.force_microgame_end()
	
func ball_hit():
	ball_speed = 0
	ball_grav = 0.225
	AudioManager.play_sfx(sfx_hit)
	
func belly_hit():
	ball_speed = prev_ball_speed + ball_speedup
	ball.scale.x = -1
	using_belly = false
	AudioManager.play_sfx(sfx_reflect)

func shoot_ball():
	ball.global_position = krool_shoot_pos.global_position
	ball.scale.x = -1
	ball_speed = (2 + difficulty)*game_speed
	AudioManager.play_sfx(sfx_cannon)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if !game_over:
		if shine_cooldown_timer > 0:
			shine_cooldown_timer -= game_speed*delta;
			if shine_cooldown_timer < 0:
				shine_cooldown_timer = 0
		if shine_cooldown_timer == 0:
			if Input.is_action_just_pressed("a"):
				fox_anim.stop(true)
				fox_anim.play("shine")
				shining = true
				AudioManager.play_sfx(sfx_shine)
				shine_cooldown_timer = shine_cooldown_time

func _physics_process(delta):
	if shining:
		var areas = shine_hb.get_overlapping_areas()
		for area in areas:
			_on_shine_ae(area)
	else:
		var areas = fox_hb.get_overlapping_areas()
		for area in areas:
			_on_fox_hb_ae(area)
	if using_belly:
		var areas = krool_bb.get_overlapping_areas()
		for area in areas:
			if area.is_in_group("ball") && area.scale.x == 1:
				prev_ball_speed = ball_speed
				ball_speed = 0
				using_belly = false
				krool_anim.play("reflect-2")
					
	ball_yspeed += ball_grav
	ball.global_position += Vector2(ball_speed*ball.scale.x,ball_yspeed)*delta*game_speed*60