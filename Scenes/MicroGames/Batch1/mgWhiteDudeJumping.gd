extends Micro_Game

onready var dude:KinematicBody2D = $Dude
onready var dude_sprite = $Dude/white_dude
onready var goal = $Goal
var ground = false
var ground_time = 0.15
var ground_timer = 0
const grav = 0.25
var velocity = Vector2()
const hsp = 3
const jumpsp = -4.5
const hijumpsp = -6.2

var collision_enabled = true
var game_over = false
onready var sfx_victory = AudioManager.get_sound_id("victory.wav")
var xinput = 0
onready var sfx_fall = AudioManager.get_sound_id("falling.wav")
onready var sfx_hit = AudioManager.get_sound_id("shell_kick.wav")

func _init():
	hint_string = "Jump to the top"
	time = 7

func _on_area_entered_hb(a):
	if game_over:
		return
	if a.is_in_group("spike"):
		game_over = true
		collision_enabled = false
		velocity = Vector2()
		AudioManager.play_sfx(sfx_hit)
		dude.scale.y = -1
		pass

func _on_dude_entered_death_area(a):
	if game_over:
		return
	AudioManager.play_sfx(sfx_fall)
	game_over = true

# Called when the node enters the scene tree for the first time.
func _ready():
	$Dude/HB.connect("area_entered",self,"_on_area_entered_hb")
	$DeathArea.connect("area_entered",self,"_on_dude_entered_death_area")
	if difficulty == 0:
		$m.queue_free()
		$h.queue_free()
		$e.visible = true
	elif difficulty == 1:
		$e.queue_free()
		$h.queue_free()
		$m.visible = true
	else:
		$e.queue_free()
		$m.queue_free()
		$h.visible = true
	AudioManager.play_music("ki-orchid.ogg")
	pass # Replace with function body.
	

func _physics_process(delta):
	var high_jump = false
	if !game_over:
		if Input.is_action_pressed("ui_left"):
			xinput = -1
		elif Input.is_action_pressed("ui_right"):
			xinput = 1
		else:
			xinput = 0
		high_jump = Input.is_action_pressed("a")
		
		var bodies = goal.get_overlapping_bodies()
		for b in bodies:
			if b.is_in_group("dude") && ground:
				game_cleared()
				game_over = true
				AudioManager.play_sfx(sfx_victory)
				velocity.x = 0
				xinput = 0
				break
	else:
		xinput = 0
		
		
		
	if ground:
		velocity.x = 0
		dude_sprite.frame = 13
		ground_timer += game_speed*delta
		if ground_timer > ground_time:
			ground_timer = 0
			if high_jump:
				velocity.y = hijumpsp
			else:
				velocity.y = jumpsp
	else:
		dude_sprite.frame = 14
		
	
	velocity.x = lerp(velocity.x,xinput*hsp,0.2*game_speed)
	velocity.y += grav*delta*60*game_speed
	if velocity.y > 7:
		velocity.y = 7
		
	#H
	if collision_enabled:
		var c_result = Global.retro_collision(dude,velocity*game_speed*60*delta)
		
		if c_result[0]:
			velocity = c_result[1]/game_speed
			if c_result[3] != Vector2():
				if c_result[3].y < 0:
					ground = true
				else:
					ground = false
			else:
				ground = false
		else:
			ground = false
	else:
		ground = false
		dude.global_position += velocity
	
		
			