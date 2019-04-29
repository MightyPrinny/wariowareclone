extends Node2D

var hint_string = "DO STUFF!";
var game_name = "something";
var time:int =3;
#The instance of the micro game player playing this micro game
var game_player = null;
var game_speed = 1;
var difficulty = 0;
var game_ended = false
var win_on_timeout = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func game_loss():
	if game_player != null:
		game_player.won_micro_game = false;
	pass

func game_cleared():
	if game_player != null:
		game_player.won_micro_game = true;
	

func force_microgame_end():
	if game_player != null:
		game_player.end_micro_game = true
	pass
	
func play_loss_sfx():
	if game_player != null:
		game_player.play_microgame_loss_sfx()
	else:
		pass
		#AudioManager.play_sfx_name("ww-prologue-loss1.wav")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
