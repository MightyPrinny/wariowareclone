extends KinematicBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var floating = true;
var grav = 0.2;
var yspeed = 0;
var game_speed = 1;
var landed = false;
onready var anim_player = $AnimationPlayer
onready var kid_mover:AnimationPlayer = $"../../KidMover"
var microgame = null;
onready var sfx_pop = AudioManager.get_sound_id("bf-balloon-pop.wav")
onready var sfx_punch = AudioManager.get_sound_id("punch.wav")
onready var sfx_falling = AudioManager.get_sound_id("falling.wav")


# Called when the node enters the scene tree for the first time.
func _ready():
	$HitArea.connect("area_entered",self,"pop_balloon");
	pass # Replace with function body.

func pop_balloon(a):
	if floating && a.is_in_group("bullet"):
		anim_player.play("pop");
		var anim = kid_mover.current_animation
		var an = kid_mover.get_animation(kid_mover.current_animation).duplicate()
		an.track_set_enabled(get_position_in_parent()*2,false)
		an.track_set_enabled(get_position_in_parent()*2+1,false)
	
		kid_mover.add_animation(anim,an)
		kid_mover.stop(false)
		kid_mover.play(anim)
		microgame.poped_counter += 1
		AudioManager.play_sfx(sfx_pop)
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if floating && anim_player.current_animation == "falling":
		floating = false;
		AudioManager.play_sfx(sfx_falling)
	if !floating:
		yspeed += delta*60*grav*game_speed;
		if yspeed > 6:
			yspeed = 6;
		var col = move_and_collide(Vector2(0,yspeed))
		if col != null:
			yspeed = 0;
			if !landed:
				landed = true
				anim_player.play("landed")
				microgame.saved_counter += 1
				AudioManager.play_sfx(sfx_punch)
