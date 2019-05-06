extends Micro_Game

onready var table = $Table
onready var anim = $LickAnim
onready var spawn_point = $FoodSpawnPoint.position
onready var tongue_area = $LickPoint/Area2D
onready var lick_point = $LickPoint
onready var sfx_lick = AudioManager.get_sound_id("yoshi-tongue.wav")

var table_speed = 90

var licking = false
var food = null

var game_over = false

var food_spawn_rate = 1.15
var food_spawn_timer = 0
var good_food_frame = 0
var food_frame_order = [0,1,2,4,6]
var food_frame_id = 0
onready var food_node = $"Food"

onready var food_base = $"Food/FoodBase"

func get_hint_string():
	var words = ["cake","ice cream","burger","ass","pie","ass","soda"]
	good_food_frame = randi()%5
	if good_food_frame == 3:
		good_food_frame = 4
	elif good_food_frame ==5:
		good_food_frame = 6
	return "Eat "+ words[good_food_frame]

func _init():
	food_frame_order.shuffle()
	hint_string = "Eat burguer"
	time = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	anim.connect("animation_finished",self,"_on_anim_finished")
	food_base.set_process(false)
	food_base.visible = false
	food_base.position = Vector2(-99,-99)
	food_spawn_rate += 0.25*difficulty
	AudioManager.play_music("fulfilled.ogg")
	pass # Replace with function body.
	
	
func _on_anim_finished(a):
	anim.play("d")
	if a == "Lick":
		licking = false
		if food != null:
			force_microgame_end()
			food.queue_free()
			food = null
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	food_spawn_timer += delta*game_speed
	if food_spawn_timer > 1.0/food_spawn_rate:
		food_spawn_timer = 0
		var f = food_base.duplicate()
		food_node.add_child(f)
		
		f.position = spawn_point
		f.game_speed = game_speed
		f.spd = table_speed
		f.visible = true
		f.set_process(true)
		f.frame = food_frame_order[food_frame_id]
		food_frame_id = (food_frame_id+1)%5
	
	table.position.x -= table_speed*game_speed*delta
	if !game_over:
		if !licking:
			if Input.is_action_just_pressed("a"):
				anim.play("Lick")
				licking = true
				AudioManager.play_sfx(sfx_lick)
		else:
			var areas = tongue_area.get_overlapping_areas()
			for a in areas:
				food = a.get_parent()
				if food.frame == good_food_frame:
					game_cleared()
				break
			if food != null:
				food.global_position = lick_point.global_position
	