extends "res://Scripts/MicroGame.gd"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var input_timer = 0.0;
var inputs = [];
var inputs_sprites = [];
onready var input_sprites_parent = $Inputs;
onready var gb_buttons = $GBButtons;
onready var master_player = $MasterPlayer;
onready var sfx_ball_toss = AudioManager.get_sound_id("SFX_BALL_TOSS.wav");
onready var sfx_ball_poof = AudioManager.get_sound_id("SFX_BALL_POOF.wav");
onready var sfx_caught = AudioManager.get_sound_id("SFX_CAUGHT_MON.wav");
onready var sfx_input = AudioManager.get_sound_id("input.wav");
var presses = 0;

onready var sub_anim = $SubZ/Anim

var won = false;

func _init():
	time = 3
	hint_string = "Finish Him!";

# Called when the node enters the scene tree for the first time.
func _ready():
	generate_inputs();
	AudioManager.play_music("MKBGM.OGG");
	$SubZ/Anim.playback_speed = game_speed*2;
	$Scorp/Anim.playback_speed = game_speed*2;
	pass # Replace with function body.

func _process(delta):
	if won:
		return
	if input_timer > 0:
		input_timer-= delta*game_speed;
		if input_timer <= 0:
			input_timer = 0;
			for spr in inputs_sprites:
				spr.visible = true;
			presses = 0;
			
	if Input.is_action_just_pressed(inputs[presses]):
		input_timer = 1;
		inputs_sprites[presses].visible = false;
		presses += 1;
		AudioManager.play_sfx(sfx_input);
		if presses >= inputs.size():
			#to do:play fatality according to the difficulty
			master_player.play("f1")
			game_cleared();
			won = true;
	elif (Input.is_action_just_pressed("ui_accept")||Input.is_action_just_pressed("ui_cancel")||Input.is_action_just_pressed("ui_down")||Input.is_action_just_pressed("ui_left") ||Input.is_action_just_pressed("ui_up")||Input.is_action_just_pressed("ui_right")  )&& input_timer > 0:
		input_timer = 0;
		presses = 0;
		for spr in inputs_sprites:
				spr.visible = true;
			
	pass
	
func toss_sfx():
	AudioManager.play_sfx(sfx_ball_toss);

func poof_sfx():
	AudioManager.play_sfx(sfx_ball_poof);
	
func caught_sfx():
	AudioManager.stop_music();
	AudioManager.play_sfx(sfx_caught);

func catched_sfx():
	pass
	
func fatality_music():
	AudioManager.play_music("MKJingle.ogg");

func victory_music():
	AudioManager.stop_sfx(sfx_caught);
	AudioManager.play_music("PokemonVictory(wild).ogg");
	
func generate_inputs():
	#TO DO: Check difficulty
	inputs = [];
	var actions = ["ui_left","ui_right","ui_down","ui_up","ui_accept","ui_cancel"];
	var length = 3 + difficulty;
	
	for i in range(length):
		inputs.append(actions[randi()%actions.size()]);
		var spr = Sprite.new();
		inputs_sprites.append(spr)
		spr.centered = false;
		input_sprites_parent.add_child(spr);
		spr.texture = gb_buttons.texture;
		spr.offset.x = i*(spr.texture.get_width()/4)+i*2;
		spr.scale = Vector2(2,2);
		spr.hframes = 4;
		spr.vframes = 2;
		match inputs[inputs.size()-1]:
			"ui_up":
				spr.frame = 4
			"ui_left":
				spr.frame = 5
			"ui_down":
				spr.frame = 6
			"ui_right":
				spr.frame = 7
			"ui_accept":
				spr.frame = 0
			"ui_cancel":
				spr.frame = 1
			
	pass