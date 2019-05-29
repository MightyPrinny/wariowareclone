extends Micro_Game

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var player = $Player
onready var pipe_combo = $PipeCombo;
onready var bg = $FlappyMarioBG

export var spd = 3.0
export var spawn_interval = 60;

var player_yspeed = 0
var player_grav = 0.35*60
onready var spawn_timer = int(spawn_interval/2)
var game_over = false
var anim_frame = 0
onready var spr = $Player/cape_mario
var player_xspeed = 0
onready var sfx_jump = AudioManager.get_sound_id("cape_rise.wav")

onready var sfx_punch = AudioManager.get_sound_id("punch.wav")

var end_timer =0

# Called when the node enters the scene tree for the first time.
func _ready():
	game_cleared()
	spawn_interval -= 15*difficulty
	pass # Replace with function body.

func _init():
	hint_string = "Survive"
	time = 5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var pipes = get_tree().get_nodes_in_group("pipe")
	if ! game_over:
		spawn_timer += 60*delta*game_speed;
		for p in pipes:
			if !p.base:
				p._update(delta)
		if spawn_timer >= spawn_interval:
			spawn_timer = 0
			var new_pipe = pipe_combo.duplicate()
			add_child(new_pipe)
			new_pipe.position.x = 176
			new_pipe.position.y = (randi()%(90-42))+42
			new_pipe.spd = spd*game_speed
			new_pipe.set_process(true)
			new_pipe.base = false
		bg.position.x -= spd*game_speed*delta*60
		
	
	
		
		
	
	
	if !game_over && Input.is_action_just_pressed("a"):
		player_yspeed = -3.75*game_speed*60
		AudioManager.play_sfx(sfx_jump)
	var ass = 0;
	if player_yspeed<=0:
		ass = -game_speed*0.65
		if game_over && player_yspeed<game_speed:
			ass -= 1*game_speed
	else:
		ass = player_yspeed*0.0015
	anim_frame += ass
	anim_frame = clamp(anim_frame,0,5)
	spr.frame = floor(anim_frame)
	
	
	
	var vel = Vector2(player_xspeed,player_yspeed)
	
	var col = player.move_and_collide(vel*delta,false)
	if col != null || player.position.x != 42:
		if !game_over:
			game_over = true
			game_loss()
			for p in pipes:
				p.position.x -= spd*60*delta
				p.spd = 0
				
			if player.position.x != 42 || (col != null && col.normal.x == -1):
				player_xspeed = -6*60*game_speed
			AudioManager.play_sfx(sfx_punch)
			end_timer = 30
			player_yspeed = 0
		if col!=null && col.normal.y == -1:
			player_xspeed = 0
	
	if end_timer > 0:
		end_timer -= game_speed*delta*60
		if end_timer <= 0:
			end_timer = 0
			force_microgame_end()
	
	player_xspeed = lerp(player_xspeed,0,delta*3)
	player_yspeed += player_grav*game_speed
	
