extends Node

const max_channels = 12 #up to 8 sounds playing at a time
const preload_all = true;
const sfx_path = "res://SFX/";
const mus_path = "res://Music/"

#sound effects
var sfx_players = []
var available = []
var playing = Dictionary()
var ids = Dictionary()
var last_id = 0
var cache = []
var stopping = false
var enabled = false
var music_player:AudioStreamPlayer = AudioStreamPlayer.new();

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(max_channels):
		var s = AudioStreamPlayer.new()
		sfx_players.append(s)
		
		s.connect("finished",self,"_stream_finished",[s])
		available.push_back(s)
		add_child(s);
	if preload_all:
		var dir = Directory.new();
		dir.open(sfx_path);
		dir.list_dir_begin(true);
		var n = dir.get_next();
		while n != "":
			if n.ends_with(".wav"):
				print(get_sound_id(n))
				print(n)
				
			n = dir.get_next();
	add_child(music_player);
func _stream_finished(s):
	var i = s.get_meta("i")
	if i != -1:
		available.append(s)
		playing.erase(i)
	s.stream = null

func get_sound_id(sfx_name):
	var id = ids.get(sfx_name,-1)
	if id == -1:
		ids[sfx_name] = last_id
		id = last_id
		last_id += 1
		cache.append(load(sfx_path+sfx_name))
	return id
	
func play_sfx_name(name):
	play_sfx(get_sound_id(name));
	
func play_sfx(id,speed = -1,return_if_playing = false):
	if available.empty() || !enabled:
		return
	if speed < 0:
		if Global.game_player == null:
			speed = 1
		else:
			speed = Global.game_player.game_speed;
	if id>=last_id:
		print_debug("sound id too big");
		return
	
	if playing.has(id):
		var sp = playing[id];
		if return_if_playing:
			return;
		sp.stop()
		sp.stream = cache[id]
		sp.pitch_scale = speed;
		sp.play(0);
		
		return;
	var sp = available.pop_back()
	
	sp.stream = cache[id]
	sp.set_meta("i",id)
	sp.pitch_scale = speed;
	sp.play(0);
	playing[id] = sp;
	
func play_music(music_name,speed = -1):
	if !enabled:
		return
	if speed < 0:
		if Global.game_player == null:
			speed = 1
		else:
			speed = Global.game_player.game_speed;
	music_player.stream = load(mus_path+music_name);
	music_player.pitch_scale = speed;
	music_player.play();
	


func stop_music():
	if music_player.playing:
		music_player.stop();
	
func stop_sfx(id):
	stopping = true
	var sp = playing.get(id,null);
	if sp != null:
		#manual_stop = true;
		sp.stop();
		playing.erase(id);
		available.append(sp);
		sp.stream = null
	stopping = false
	
func stop_all():
	if playing.empty():
		return
	available.clear()
	for s in sfx_players:
		if s.playing:
			s.stop()
		available.push_back(s)
	playing = Dictionary()
	#stopping = false
