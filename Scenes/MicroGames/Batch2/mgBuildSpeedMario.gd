extends KinematicBody2D

var ground = false
var prev_ground = false
var on_wall = false
var prev_on_wall = false
var floor_normal = Vector2.UP
var grav_accel = 480
var velocity = Vector2()

var block_collision = true
var infinite_inertia = false
var stop_on_slopes = true
var max_slides = 6
var max_slope = 1
var game_speed = 1
var floor_deccel = 1*60
var walk_spd = 1*60
var run_spd = 3*60
var hor_spd = walk_spd
var floor_accel =1.25*60
var jump_spd = -3*60
var jump_gain = 3*60
var prev_jump_pressed = false
var jumped = false
onready var spr = $Sprite
var anim_frame = 0

var last_start_frame = -1;
var last_end_frame = -1;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	


func _update_velocity(delta):
	
	if !ground:
		velocity -= floor_normal*grav_accel*delta*game_speed
	var xdir = 0
	if Input.is_action_pressed("ui_left"):
		xdir-=1
	if Input.is_action_pressed("ui_right"):
		xdir+=1
	if Input.is_action_pressed("b") && ground:
		hor_spd = run_spd
	else:
		hor_spd = walk_spd
	
	if Input.is_action_pressed("a"):
		if !prev_jump_pressed:
			if ground:
				velocity.y = jump_spd*game_speed - (clamp(abs(velocity.x),0,run_spd*game_speed)/(run_spd*game_speed))*(jump_gain*game_speed)
				jumped = true
				ground = false
			prev_jump_pressed = true
			
	else:
		if jumped && velocity.y >= -2*60*game_speed:
			jumped = false
			velocity.y = 0
		prev_jump_pressed = false
		
	if velocity.y > 0:
		jumped = false
		
	if xdir == 0:
		var old_vel = velocity.x
		velocity.x += -sign(velocity.x)*floor_deccel*delta*game_speed
		if sign(old_vel) != sign(velocity.x):
			velocity.x = 0
	else:
		if abs(velocity.x) < hor_spd*game_speed:
			velocity.x += xdir*floor_accel*delta*game_speed
			if abs(velocity.x)>hor_spd*game_speed:
				velocity.x = sign(velocity.x)*hor_spd*game_speed
			
		
	
func animation_loop(start,end,spd):
	if last_end_frame != end || last_start_frame != start:
		anim_frame = 0
	last_end_frame = end
	last_start_frame = start
	start = max(0,start)
	var total_frames = spr.hframes*spr.vframes
	end = min(total_frames,end)
	var length = end-start
	anim_frame = fmod(start+anim_frame+spd,length)
	spr.frame = clamp(floor(anim_frame),start,end)
	
func _begin_process(delta):
	pass
	
func _end_process(delta):
	if ground:
		if velocity.x != 0:
			animation_loop(0,4,0.008*delta*60*game_speed*abs(velocity.x));
			spr.scale.x = sign(velocity.x)
		else:
			spr.frame = 0
	else:
		if velocity.y < 0:
			spr.frame = 4
		else:
			spr.frame = 5
	pass

func move(velocity):
	pass

func _physics_process(delta):
	_begin_process(delta)
	
	_update_velocity(delta)
	
	if !ground:
		move_and_slide(velocity,floor_normal,stop_on_slopes,max_slides,max_slope,infinite_inertia)
		
	else:
		#var pxv = velocity.x
		move_and_slide_with_snap(velocity,-max(2,abs(velocity.x*delta*6))*floor_normal,floor_normal,stop_on_slopes,max_slides,max_slope,infinite_inertia)
		#velocity.x = pxv
	prev_on_wall = on_wall
	on_wall = is_on_wall()
	
	var slide_count = get_slide_count()
	
	for i in range(slide_count):
		var col = get_slide_collision(i)
		if col.normal.x == -1 || col.normal.x == 1:
			velocity.x = 0
		if col.normal.y == -1:
			velocity.y = 0
	
	if on_wall && !prev_on_wall:
		velocity.x = 0
	if is_on_ceiling() || is_on_floor():
		velocity.y = 0
	
	prev_ground = ground
	ground = is_on_floor()
	
	_end_process(delta)
