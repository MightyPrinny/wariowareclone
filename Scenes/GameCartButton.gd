extends TextureButton

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var sprite = $spr
var had_focus = false;
onready var sfx_input = AudioManager.get_sound_id("input.wav")
export(PoolStringArray) var unlock_check_keys = PoolStringArray()
export(String) var scene_path = ""

export var disable_on_ready = false
export(String) var score_check_key = ""

onready var cursor = $"../../cur"
onready var first = $"../../top3/1st"
onready var second = $"../../top3/2nd"
onready var third = $"../../top3/3rd"
# Called when the node enters the scene tree for the first time.
func _ready():
	if disable_on_ready:
		enabled_focus_mode = false
	if unlock_check_keys.size() > 0:
		var locked = false
		for unlock_check_key in unlock_check_keys:
			var val = Global.game_data.get(unlock_check_key+".cleared")
			if val != null:
				if !val:
					locked = true
					break
			else:
				locked = true
				break
		if locked:
			enabled_focus_mode = false
			sprite.frame = 0
	pass # Replace with function body.



func _pressed():
	var scene = load(scene_path)
	if scene != null && scene is PackedScene:
		if !Global.transitioning:
			enabled_focus_mode = false
			Global.last_batch_button = name
			Global.change_scene(scene)
			AudioManager.play_sfx_name("select5.wav")
	print("press")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if has_focus():
		if !had_focus:
			AudioManager.play_sfx(sfx_input,1)
			had_focus = true
			show_scores()
			
		cursor.global_position = rect_global_position
	else:
		had_focus = false
	
func show_scores():
	if score_check_key != "":
		var val = Global.game_data.get(score_check_key+".hs0")
		if val != null:
			third.set_text(str(val))
		val = Global.game_data.get(score_check_key+".hs1")
		if val != null:
			second.set_text(str(val))
		val = Global.game_data.get(score_check_key+".hs2")
		if val != null:
			first.set_text(str(val))
	else:
		first.set_text("0");
		second.set_text("0");
		third.set_text("0");