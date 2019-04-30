extends "res://Scripts/MicroGame.gd"

#var barrel_scene = PackedScene.new()
#var food_scene = PackedScene.new()

var is_smashing = false

var spawn_timer = 0
var spawn_time = 1.35
var obj_speed = 1.5
onready var spawn_pos = $BarrelSpawnPos.global_position
onready var ddd_hammer_hb = $HammerHB
onready var ddd_anim = $DDDWithHamer/AnimationPlayer
onready var ddd_hb = $DDDWithHamer/HB

func _init():
	hint_string = "Smash barrels"
	time = 7

onready var barrel_node = $Barrel
onready var food_node = $DDDFood
var max_repeat = 3
var last_obj = -1
var repeat_counter = 0
var smash_cooldown = 0.3;
var smash_cooldown_timer = 0
onready var sfx_punch = AudioManager.get_sound_id("punch.wav")
onready var sfx_fruit = AudioManager.get_sound_id("struck.wav")
onready var sfx_barrel = AudioManager.get_sound_id("Impact1.wav");
onready var sfx_fruit_kill = AudioManager.get_sound_id("shell_kick.wav")
# Called when the node enters the scene tree for the first time.
var game_over = false
func _ready():
	AudioManager.play_music("Super Smash Land - Dreamland Music.ogg")
	#food_scene.pack($DDDFood)
	#$Barrel.queue_free()
	#$DDDFood.queue_free()
	barrel_node.set_physics_process(false)
	food_node.set_physics_process(false)
	ddd_anim.connect("animation_finished",self,"ddd_anim_finished")
	ddd_hammer_hb.connect("area_entered",self,"hammered_area")
	ddd_hb.connect("area_entered",self,"ddd_area_entered")
	game_cleared()
	spawn_time -= 0.45*difficulty

func force_microgame_end():
	.force_microgame_end()
	
func ddd_area_entered(a):
	
	if a.is_in_group("food"):
		if game_over:
			return
		a.get_parent().queue_free()
		ddd_anim.stop()
		ddd_anim.play("eat")
		AudioManager.play_sfx(sfx_fruit)
		pass
	elif a.is_in_group("barrel"):
		if ddd_anim.current_animation == "ded":
			return
		AudioManager.play_sfx(sfx_punch)
		ddd_anim.stop()
		ddd_anim.play("ded")
		a.get_parent().spd = 0
		a.get_parent().anim.play("ded")
		AudioManager.play_sfx(sfx_barrel)
		game_loss()
		game_over = true
		pass
	
func hammered_area(a):
	if game_over:
		return
	if a.is_in_group("barrel"):
		a.get_parent().anim.play("ded")
		AudioManager.play_sfx(sfx_barrel)
		a.get_parent().spd = 0
	if a.is_in_group("food"):
		a.get_parent().spd = 0
		AudioManager.play_sfx(sfx_fruit_kill)
		a.get_parent().queue_free()
		game_loss()
		force_microgame_end()
		game_over = true

func ddd_anim_finished(a):
	if a  == "smashing":
		is_smashing = false

func _physics_process(delta):
	spawn_timer = max(0,spawn_timer-delta*game_speed)
	if spawn_timer == 0:
		spawn_timer = spawn_time
		var base;
		var rn = randi()%2
		if rn != last_obj:
			repeat_counter = 0
		else:
			repeat_counter +=1
			if repeat_counter >= max_repeat:
				if rn == 0:
					rn = 1
				else:
					rn = 0
		if rn == 0:
			base = barrel_node
		else:
			base = food_node
		last_obj = rn
		var b = base.duplicate() as Node2D
		b.spd = obj_speed + 0.5*(difficulty)
		b.game_speed = game_speed
		add_child(b)
		b.global_position = spawn_pos
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if smash_cooldown_timer > 0:
		smash_cooldown_timer = max(0,smash_cooldown_timer - delta*game_speed)
	if !game_ended && !game_over:
		if smash_cooldown_timer == 0&& Input.is_action_just_pressed("ui_accept"):
			ddd_anim.stop()
			ddd_anim.play("smash")
			smash_cooldown_timer = smash_cooldown
