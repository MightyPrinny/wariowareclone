extends "res://Scripts/MicroGame.gd"

onready var gun = $Toad/Gun
var move_spd = 90
var dir = 1
var rotate_gun = true
var ammo = 4
onready var bullet = $Toad/Gun/Bullet 
onready var bullet_hb = $Toad/Gun/Bullet/HitBox
onready var shoot_pos = $Toad/Gun/sp
onready var screen_area = $ScreenArea
onready var ammo_sprite = $"b1b-hud"
onready var toad_anim = $Toad/AnimationPlayer
onready var kid_mover = $KidMover
onready var gun_sfx = AudioManager.get_sound_id("Impact3.wav")
var game_over = false
var saved_counter = 0
var poped_counter = 0
var kid_count = 0

func _init():
	hint_string = "Save the kids!"
	time = 60
	

# Called when the node enters the scene tree for the first time.
func _ready():
	#game_player.timer_enabled = false
	bullet.visible = false
	gun.frame = 1
	bullet_hb.connect("area_exited",self,"_bullet_exited_screen")
	screen_area.connect("body_exited",self,"kid_exited")
	if difficulty == 0:
		$Hard.queue_free()
		$Medium.queue_free()
		kid_mover.play("e")
		move_spd = 85
		$Easy.visible = true
	elif difficulty == 1:
		$Easy.queue_free()
		$Hard.queue_free()
		kid_mover.play("m")
		$Medium.visible = true
		move_spd = 95
	elif difficulty == 2:
		$Easy.queue_free()
		$Medium.queue_free()
		kid_mover.play("h")
		move_spd = 115
		$Hard.visible = true
	var kids_node = $Kids
	var kids = kids_node.get_children()
	
	for kid in kids:
		kid_count += 1
		kid.microgame = self
		kid.game_speed = game_speed
	AudioManager.play_music("bombermangb3-unknown-song-2.ogg")

func kid_exited(k):
	if !game_over && k.is_in_group("kid"):
		lose_game()
		pass
		
func force_microgame_end():
	.force_microgame_end()
		

func _bullet_exited_screen(a):
	if bullet.visible && a == screen_area:
		
		if ammo > 0:
			gun.frame = 1
			rotate_gun = true
		elif poped_counter < kid_count:
			lose_game()
			
		bullet.visible = false
		bullet.position = Vector2(0,0)
		bullet_hb.remove_from_group("bullet")
	pass

func lose_game():
	game_over = true
	#var t = bullet.global_transform
	#bullet.global_transform = t
	
	play_loss_sfx()
	toad_anim.play("kids_died")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !game_over:
		if saved_counter == kid_count:
			game_cleared()
			toad_anim.play("win")
			game_over = true
			AudioManager.stop_music()
			AudioManager.play_sfx_name("ww-boss-win.wav")
			return
		if rotate_gun:
			if Input.is_action_just_pressed("ui_accept"):
				rotate_gun = false
				bullet.global_transform = shoot_pos.global_transform
				rotate_gun = false
				bullet.visible = true
				gun.frame = 0
				ammo -= 1
				AudioManager.play_sfx(gun_sfx)
			else:
				gun.rotation_degrees += move_spd*delta*dir*game_speed
				if (gun.rotation_degrees < -58 && dir == -1) || (dir == 1 && gun.rotation_degrees >0):
					dir*= -1
		
	if !rotate_gun &&bullet.visible:
		bullet.position.x += 240*delta*game_speed
		bullet_hb.add_to_group("bullet")

	ammo_sprite.frame = clamp(4-ammo,0,4)
