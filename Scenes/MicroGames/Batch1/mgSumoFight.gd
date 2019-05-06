extends Micro_Game

var game_started = false
var game_over = false

onready var player = $Player
onready var player_sprite = $Player/Sprite
onready var player_hb = $Player/PHB
onready var enemy = $Anime
onready var enemy_anim = $Anime/Sprite/AnimationPlayer
onready var battlefield = $Battlefield
onready var player_anim = $Player/Sprite/AnimationPlayer

var player_attack = 0
var input_timer = 0

var enemy_velocity = Vector2()
var enemy_accel = 0.1
var player_velocity = Vector2()
var player_accel = 0.1

var enemy_punch_timer = 0

onready var sfx_fall = AudioManager.get_sound_id("falling.wav")
onready var sfx_land = AudioManager.get_sound_id("Impact3.wav")
onready var sfx_hit = AudioManager.get_sound_id("Impact1.wav")
onready var enemy_collision_shape = $Anime/CollisionShape2D

func _init():
	hint_string = "Push him out"
	time = 8
	game_speed = 1
	difficulty = 2

func _ready():
	battlefield.connect("body_exited",self,"on_area_exited_battlefied")
	player_hb.connect("body_entered",self,"on_player_punch_area")
	player_anim.connect("animation_finished",self,"player_anim_end")
	
	
	$Maurio/Sprite/Area2D.connect("body_entered",self,"on_enemy_punch_body")
	match(difficulty):
		0:
			AudioManager.play_music("blanka.ogg")
			pass
		1:
			AudioManager.play_music("zangief.ogg")
			$Anime/Sprite.free()
			var dunkey = $DunkeyKung/Sprite
			$DunkeyKung.remove_child($DunkeyKung/Sprite)
			dunkey.name = "Sprite"
			enemy.add_child(dunkey,false)
			dunkey.position = Vector2()
			dunkey.scale = Vector2(1,1)
			enemy_anim = dunkey.get_node("AnimationPlayer")
			
			pass
		2:
			AudioManager.play_music("guile.ogg")
			$Anime/Sprite.free()
			var dunkey = $Maurio/Sprite
			$Maurio.remove_child($Maurio/Sprite)
			dunkey.name = "Sprite"
			enemy.add_child(dunkey,false)
			dunkey.position = Vector2()
			dunkey.scale = Vector2(1,1)
			enemy_anim = dunkey.get_node("AnimationPlayer")
			pass
	enemy_anim.connect("animation_finished",self,"enemy_anim_end")
	$Master.play("intro")
	
	
func land_sfx():
	AudioManager.play_sfx(sfx_land)

func on_player_punch_area(a):
	if a.is_in_group("anime"):
		enemy_velocity.x = (4.0-0.15*difficulty)*game_speed
		AudioManager.play_sfx(sfx_hit)
	pass
	
func on_enemy_punch_body(b):
	if b.is_in_group("player"):
		player_velocity.x = -4*game_speed
		AudioManager.play_sfx(sfx_hit)
	pass
	
func force_microgame_end():
	.force_microgame_end()

func on_area_exited_battlefied(a):
	if game_over||game_ended:
		return
	game_over = true
	AudioManager.play_sfx(sfx_fall)
	if a.is_in_group("anime"):
		enemy_anim.play("defeat")
		game_cleared()
		enemy_collision_shape.disabled = true
	else:
		player_anim.play("defeat")
		enemy_anim.stop()
		enemy_anim.play("victory")
		
func enemy_anim_end(a):
	if a == "defeat":
		AudioManager.stop_sfx(sfx_fall)
		player_anim.play("victory")
		
func player_anim_end(a):
	
	if a == "defeat":
		AudioManager.stop_sfx(sfx_fall)
		enemy_anim.play("victory")

func start_game():
	game_started = true

func _process(delta):
	if !game_started || game_over:
		return
		
	match(difficulty):
		0:
			enemy_velocity.x = lerp(enemy_velocity.x,-1*game_speed,enemy_accel*game_speed)
			if !enemy_anim.is_playing():
				enemy_anim.play("walk")
			pass
		1:
			enemy_velocity.x = lerp(enemy_velocity.x,-1.5*game_speed,enemy_accel*game_speed)
			if !enemy_anim.is_playing():
				enemy_anim.play("walk")
				
			pass
		2:
			if enemy_anim.current_animation != "attack":
				enemy_punch_timer += delta*game_speed
				if enemy_punch_timer > (1+rand_range(0,0.5)):
					enemy_punch_timer = 0
					enemy_anim.play("attack")
				else:
					enemy_velocity.x = lerp(enemy_velocity.x,-1.65*game_speed,enemy_accel*game_speed)
					if enemy_anim.current_animation != "walk":
						enemy_anim.play("walk")
						print("walk")
			else:
				enemy_velocity.x = 0
				if! enemy_anim.is_playing():
					enemy_anim.play("walk")
			pass
	if difficulty != 2 || ((difficulty == 2) && (enemy_anim.current_animation != "attack")):
		enemy.move_and_slide(enemy_velocity*60,Vector2(),false,1,0,true)
	if enemy.get_slide_count() >= 1:
		var col = enemy.get_slide_collision(0)
		if col.collider.is_in_group("player") && enemy_velocity.x < 0:
			player_velocity.x = enemy_velocity.x
			
	
	if input_timer == 0:
		if Input.is_action_just_pressed("a"):
			player_anim.stop()
			if player_attack == 0:
				player_attack = 1
				player_anim.play("attack")
			else:
				player_attack = 0
				player_anim.play("attack2")
			input_timer = 0.2
	else:
		input_timer -= delta*game_speed
		if input_timer < 0:
			input_timer = 0
	var xdir = 0
	if Input.is_action_pressed("ui_right"):
		xdir+= 1
	player_velocity.x = lerp(player_velocity.x,xdir*game_speed,player_accel*game_speed)
	if player_velocity.x != 0:
		if !player_anim.is_playing():
			player_anim.play("walk")
		var prev_pos = player.position.x
		player_velocity = player.move_and_slide(player_velocity*60,Vector2(),false,1,0,false)/60
	if abs(player_velocity.x)<0.1:
		if player_anim.current_animation == "walk":
			player_anim.stop()
			player_sprite.frame = 2
	