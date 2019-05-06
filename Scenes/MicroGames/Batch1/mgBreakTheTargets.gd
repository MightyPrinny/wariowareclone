extends Micro_Game

var remaining = 4
var pee_spawn_timer = 0
var pee_spawn_rate = 20
var pee_spread_cone = 4
var pee_power = 3
var pee_aim_speed = 128
onready var target_base = $target
onready var pee_base = $Pee
onready var pee_spawner = $PSpawner
onready var pee_spawn_point = $PSpawner/PSpawnPoint

var target_spawn_area = Rect2()
var target_exists = false
onready var remaining_text = $mario_pissing_bg/Label

var pee_angle = 0

func _init():
	hint_string = "Break the targets!"
	time = 10
	

func _ready():
	AudioManager.play_music("gam-corner.ogg")
	pee_base.base = pee_base
	pee_aim_speed += difficulty
	var ta = $TargetArea
	target_spawn_area = ta.get_rect()
	remaining = 3+difficulty
	pass # Replace with function body.

func _force_microgame_end():
	.force_microgame_end()
	
func target_destroyed():
	remaining = max(remaining-1,0)
	if remaining == 0:
		game_cleared()
		$AnimationPlayer.play("reveal")
	target_exists = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	remaining_text.text = str(remaining)
	if remaining > 0:
		if !target_exists:
			var grid = 12
			var tx = (randi()%int(target_spawn_area.size.x/grid))*grid + int(target_spawn_area.position.x)
			var ty = (randi()%int(target_spawn_area.size.y/grid))*grid + int(target_spawn_area.position.y)

			var tar = target_base.duplicate()
			add_child(tar)
			tar.creator = self
			tar.position = Vector2(tx,ty)
			target_exists = true
			
		if Input.is_action_pressed("ui_left")||Input.is_action_pressed("ui_up"):
			pee_angle -= pee_aim_speed*delta
			if pee_angle < -35:
				pee_angle = -35
		elif Input.is_action_pressed("ui_right")||Input.is_action_pressed("ui_down"):
			pee_angle += pee_aim_speed*delta
			if pee_angle > 15:
				pee_angle = 15
		
		pee_spawner.rotation_degrees = pee_angle
		pee_spawn_timer += delta*game_speed
		if pee_spawn_timer > (1.0/pee_spawn_rate):
			pee_spawn_timer = 0
			var p = pee_base.duplicate()
			p.game_speed = game_speed
			add_child(p)
			p.global_position = pee_spawn_point.global_position
			var dir:Vector2 = pee_spawn_point.global_position- pee_spawner.global_position
			dir = dir.rotated(rand_range(-deg2rad(pee_spread_cone),deg2rad(pee_spread_cone)))
			p.velocity = pee_power*60*dir.normalized()
			
		
			
