extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var microgame_list = [];
var microgame_ids = {};

var global_hud = CanvasLayer.new();

var screen_width = 0;
var screen_height = 0;

var transitioning = false;
var transition_black_rect:ColorRect = null;
var transition_speed = 1;
var transition_state = 0;
var prev_scene = null;
var next_scene = null;
var transition_timer = 0;

var game_player = null;

var game_data = {};

var last_batch_button = ""

func _init():
	screen_height = ProjectSettings.get_setting("display/window/size/height");
	screen_width = ProjectSettings.get_setting("display/window/size/width");
	randomize()
	var dir = Directory.new();
	dir.open("res://Scenes/MicroGames");
	dir.list_dir_begin();
	var name = dir.get_next();
	while name != "":
		if name.begins_with("mg") && name.ends_with(".tscn"):
			var n = name.substr(2,name.length()-7);
			print(n);
			microgame_ids[n] = microgame_list.size();
			microgame_list.append(load("res://Scenes/MicroGames/"+name));
		name = dir.get_next();
	load_game()
	print(ProjectSettings.globalize_path("user://"))
	
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		save_game()
	
func new_black_rect():
	var rect = ColorRect.new();
	rect.color = Color8(0,0,0);
	rect.rect_size = Vector2(screen_width,screen_height);
	return rect;

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)
	get_tree().connect("idle_frame",self,"init_global_hud",[],CONNECT_ONESHOT)
	pass # Replace with function body.

func init_global_hud():
	get_tree().root.add_child(global_hud);
	pass

func change_scene(scene,do_transition=true,speed = 4):
	var ps:PackedScene = null;
	if scene is PackedScene:
		ps = scene;
	elif scene is String:
		ps = load(scene);
	if ps == null:
		print("change_scene: error loading scene");
		return;

	prev_scene = get_tree().current_scene.filename;
	if !do_transition:
		get_tree().change_scene_to(ps);
		return;
	transition_speed = speed;
	transition_black_rect = new_black_rect();
	global_hud.add_child(transition_black_rect);
	transition_black_rect.rect_position = Vector2(0,0);
	transition_state =0;
	next_scene = ps;
	transition_black_rect.color = Color(0,0,0,0);
	transitioning = true;

func reload_scene(do_transition = true,speed = 4):
	var ps =load( get_tree().current_scene.filename)
	
	if ps == null:
		print("change_scene: error loading scene");
		return;
	if !ps is PackedScene:
		print("ass");
		return
	prev_scene = get_tree().current_scene.filename;
	if !do_transition:
		get_tree().change_scene_to(ps);
		return;
	transition_speed = speed;
	transition_black_rect = new_black_rect();
	global_hud.add_child(transition_black_rect);
	transition_black_rect.rect_position = Vector2(0,0);
	transition_state =0;
	next_scene = ps;
	transition_black_rect.color = Color(0,0,0,0);
	transitioning = true;

func save_game():
	if game_data.empty():
		return
	var json_str = JSON.print(game_data);
	var file = File.new();
	var err = file.open("user://game_data.sav",File.WRITE);
	if err != OK:
		print("can't open game_data.sav")
		file.close()
		return
	file.store_string(json_str);
	file.close();

func load_game():
	var file = File.new();
	var err = file.open("user://game_data.sav",File.READ)
	if err != OK:
		print("can't open game_data.sav");
		file.close();
		return
	var json_str = file.get_as_text()
	var result = JSON.parse(json_str)
	file.close();
	if result.error != OK:
		print("can't parse save data file");
		return;
	game_data = result.result;
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if transitioning:
		if delta > 1:
			delta = 1;
		if transition_state == 0:
			transition_black_rect.color = Color(0,0,0,transition_black_rect.color.a+delta*transition_speed);
			if transition_black_rect.color.a >= 1:
				transition_black_rect.color.a = 1;
				transition_state = 1;
				get_tree().change_scene_to(next_scene);
		elif transition_state == 1:
			transition_black_rect.color = Color(0,0,0,transition_black_rect.color.a-delta*transition_speed);
			if transition_black_rect.color.a <= 0:
				transition_black_rect.free();
				transition_black_rect = null;
				transitioning = false;
				transition_state = -1;

