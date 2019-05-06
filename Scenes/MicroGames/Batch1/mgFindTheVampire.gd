extends "res://Scripts/MicroGame.gd"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var bats = []
var playing = {}
onready var swap_timeline = $SwapTimeline
onready var swap_tween = $SwapTween
onready var arrow = $arrow
onready var sfx_explosion = AudioManager.get_sound_id("ssb-explosion.wav")
onready var sfx_overdrive = AudioManager.get_sound_id("jojo-overdrive.wav")
onready var sfx_correct = AudioManager.get_sound_id("correct.wav")
onready var sfx_incorrect = AudioManager.get_sound_id("incorrect.wav")
var game_over = false

onready var vampire_anim = $Bats/b3/bat/Anim

var can_select = false
var selection = 0

var bat_anims = []

func _init():
	hint_string = "Find the vampire"
	time = 15
# Called when the node enters the scene tree for the first time.
func _ready():
	AudioManager.play_music("castlevania-darkness.ogg")
	if difficulty == 0:
		bats.append($Bats/b2)
		bats.append($Bats/b3)
		bats.append($Bats/b4)
		$Bats/b1.visible = false
		$Bats/b5.visible = false
	elif difficulty == 1:
		bats.append($Bats/b1)
		bats.append($Bats/b2)
		bats.append($Bats/b3)
		bats.append($Bats/b4)
		$Bats/b5.visible = false
		$Bats.position.x = 12
	elif difficulty == 2:
		bats.append($Bats/b1)
		bats.append($Bats/b2)
		bats.append($Bats/b3)
		bats.append($Bats/b4)
		bats.append($Bats/b5)
	for i in range(bats.size()):
		bat_anims.append(bats[i].get_node("bat/Anim"))
		bats[i].set_meta("i",i)
	swap_tween.connect("tween_completed",self,"tween_end")

func tween_end(o,s):
	playing.erase(o.get_meta("i"))
	pass

func force_microgame_end():
	.force_microgame_end()

func begin_swapping():
	if difficulty == 0:
		swap_timeline.play("e")
	elif difficulty == 1:
		swap_timeline.play("m")
	elif difficulty == 2:
		swap_timeline.play("h")

func do_swap(allow_extra = true):
	var available = []
	for i in range(bats.size()):
		if !playing.has(i):
			available.append(bats[i])
	if available.size()<2:
		return
	var a = randi()%available.size()
	var b = randi()%available.size()
	if(a == b):
		b = (b+1)%available.size()
	var bat1 = available[a]
	var bat2 = available[b]
	swap_tween.interpolate_property(bat1,NodePath("position"),bat1.position,bat2.position,0.45,Tween.TRANS_CUBIC,Tween.EASE_IN)
	swap_tween.interpolate_property(bat2,NodePath("position"),bat2.position,bat1.position,0.45,Tween.TRANS_CUBIC,Tween.EASE_IN)
	var bat1_id = bat1.get_meta("i")
	var bat2_id = bat2.get_meta("i")
	playing[bat1_id] = 1
	playing[bat2_id] = 1
	bats[bat1_id] = bat2
	bats[bat2_id] = bat1
	var res = bat_anims[bat1_id]
	bat_anims[bat1_id] = bat_anims[bat2_id]
	bat_anims[bat2_id] = res
	bat2.set_meta("i",bat1_id)
	bat1.set_meta("i",bat2_id)
	
	var extra_anim = randi()%2
	
	if extra_anim == 0:
		bat_anims[bat1_id].play("wavev")
		bat_anims[bat2_id].play("wavev2")
	else:
		bat_anims[bat1_id].play("wavev2")
		bat_anims[bat2_id].play("wavev")
	
	#if #allow_extra && difficulty == 2:
		#do_swap(false)
	#else:
	swap_tween.start()
	
			
			
	
	
func enable_player_choice():
	can_select = true
	pass
	
func explosion_sound():
	AudioManager.play_sfx(sfx_explosion)
	
func overdrive_sound():
	AudioManager.play_sfx(sfx_overdrive)
	
func _process(delta):
	if !game_over && !game_ended && can_select:
		arrow.global_position = bats[selection].global_position - Vector2(0,16)
		if Input.is_action_just_pressed("a"):
			if bats[selection].is_in_group("vampire"):
				game_cleared()
				$Bats/BatAnim.play("d")
				vampire_anim.play("reveal")
				AudioManager.play_sfx(sfx_correct)
				arrow.global_position.x = -100
			else:
				AudioManager.play_sfx(sfx_incorrect)
				$Bats/BatAnim.play("d")
				vampire_anim.play("reveal wrong")
				
			can_select = false
		elif Input.is_action_just_pressed("ui_left"):
			selection = (selection-1)%bats.size()
		elif Input.is_action_just_pressed("ui_right"):
			selection = (selection+1)%bats.size()
			