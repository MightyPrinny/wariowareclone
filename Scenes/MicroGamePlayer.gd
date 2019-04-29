extends Node2D

#Must be set before instantiating the scene
#it contains the available microgames as a PackedScene array
var possible_microgames_list = [];
export(PoolStringArray) var possible_microgames = PoolStringArray();
export var endless:bool = false;
export var has_boss:bool = false;
export var boss:PackedScene = null;
export var games_until_speedup = 3;
export var always_endless = false;
export var speedup_amount = 0.15;

#If it has a boss the boss will show up after this many games
export var games_until_boss = 10;



var microgame_list = [];
var current_microgame = null;
var completed_micro_game = false;
var won_micro_game = false;
var micro_game_timer = 0;
var speedup_counter = 0;
var boss_game_counter = 0;
var in_game = false;
var boss_time = false;
var end_micro_game = false;

onready var master_anim = $MasterPlayer;
onready var anim = $HUD/AnimationPlayer;
onready var hint = $"HUD/2x/Hint";
onready var base_anim_speed = anim.playback_speed;
onready var gb_boom = $HUD/Hud4/boom;
onready var timer_node = $HUD/Timer;
onready var timer_anim = $HUD/Timer/AnimationPlayer;
onready var timer_rope = $HUD/Timer/Rope;
onready var timer_fire = $HUD/Timer/Fire;
onready var timer_numbers = $HUD/Timer/Number;

var timer_enabled = true;

onready var live_node_parent = $HUD/Hud4/Lives;
onready var lives = 4;
var life_sprites = [];

var base_game_speed = 1;
var game_speed = 1;
var game_difficulty = 0;

onready var counter = 0;
onready var counter_node = $HUD/Hud4/C/Counter;

onready var sfx_intro1 = AudioManager.get_sound_id("warioware-microgame-intro.wav");
onready var sfx_intro2 = AudioManager.get_sound_id("warioware-microgame-intro-2.wav");

onready var sfx_success1 = AudioManager.get_sound_id("warioware-microgame-win-wa.wav");
onready var sfx_success2 = AudioManager.get_sound_id("warioware-microgame-win-wa-2.wav");

onready var sfx_lose = AudioManager.get_sound_id("ww-prologue-loss1.wav");
onready var sfx_lose2 = AudioManager.get_sound_id("ww-prologue-loss-2.wav")
onready var sfx_speedup = AudioManager.get_sound_id("warioware-speedup.wav");
onready var sfx_game_over = AudioManager.get_sound_id("warioware-game-over.wav")
onready var game_over_scene = load("res://Scenes/GameOver.tscn")

var batch_cleared = false;
var high_scores = [0,0,0];

var enable_win_key = true

# Called when the node enters the scene tree for the first time.
func _ready():
	
	if possible_microgames.size()>0:
		for s in possible_microgames:
			possible_microgames_list.append(Global.microgame_list[Global.microgame_ids[s]]);
		
	var sprs = live_node_parent.get_children();
	for spr in sprs:
		if spr is Sprite:
			life_sprites.append(spr);
	Global.game_player = self;
	var val = Global.game_data.get(name+".cleared");
	if val != null:
		batch_cleared = val
	for i in range(3):
		val = Global.game_data.get(name+".hs"+str(i))
		if val != null:
			high_scores[i] = int(val)
	set_game_speed(base_game_speed)
	AudioManager.stop_all();
	AudioManager.stop_music()
	AudioManager.play_sfx_name("ww-prologue-get-ready.wav")
	if always_endless:
		batch_cleared = true;
	pass # Replace with function body.
	
func _physics_process(delta):
	if in_game:
		if enable_win_key && Input.is_action_just_pressed("win"):
			end_micro_game = true;
			won_micro_game = true;
		if !end_micro_game && micro_game_timer > 0:
			var prev_timer = floor(micro_game_timer);
			if !boss_time:
				micro_game_timer -= delta*game_speed;
			if micro_game_timer <= 0:
				micro_game_timer = 0;
				end_micro_game = true;
			if timer_enabled && (prev_timer != floor(micro_game_timer)):
				timer_rope.region_rect.size = Vector2(3+(timer_rope.texture.get_width()-3)*(floor(micro_game_timer)/ current_microgame.time),timer_rope.texture.get_height())
				timer_fire.global_position.x = timer_rope.global_position.x+timer_rope.region_rect.size.x*2;
				timer_numbers.set_text(str(floor(micro_game_timer+1)));
			if timer_enabled && micro_game_timer == 0:
					timer_anim.play("boom");
		if end_micro_game:
			AudioManager.stop_all();
			AudioManager.stop_music();
			micro_game_timer = 0;
			if won_micro_game:
				master_anim.play("win game");
				pass
			else:
				master_anim.play("lose game");
			end_micro_game = false;
			in_game = false;
			current_microgame.game_ended = true
			current_microgame.set_process(false)
			current_microgame.set_process_internal(false)
			current_microgame.set_physics_process(false)
			current_microgame.set_physics_process_internal(false)
			

func set_game_speed(val):
	var ap = get_tree().get_nodes_in_group("scaled_anim");
	for p in ap:
		p.playback_speed = val;
	game_speed = val;
	hint.anim_speed = float(200*game_speed);
	


func prepare_next():
	if !boss_time:
		boss_game_counter += 1;
	if boss_game_counter >= games_until_boss:
		set_game_speed(base_game_speed)
		AudioManager.play_sfx(sfx_speedup,game_speed);
		master_anim.play("boss");
		speedup_counter = 0;
		boss_game_counter = 0;
		boss_time = true
		return
	if !boss_time:
		speedup_counter+=1;
		if speedup_counter>games_until_speedup:
			speedup_counter = 0;
			boss_game_counter -= 1;
			set_game_speed(game_speed+speedup_amount);
			AudioManager.play_sfx(sfx_speedup,game_speed);
			master_anim.play("speedup");
			return
	
	if microgame_list.empty():
		microgame_list = [];
		for m in possible_microgames_list:
			microgame_list.append(m);
		microgame_list.shuffle();
		#add boss here
	var next;
	if !boss_time:
	 	next = microgame_list.pop_back();
	else:
		next = boss
	if next != null:
		current_microgame = next.instance();
		current_microgame.game_player = self;
		current_microgame.game_speed = game_speed;
		current_microgame.difficulty = game_difficulty;
		hint.set_text("¬W"+current_microgame.hint_string);
		var text = str(counter).pad_zeros(3);
		counter += 1;
		
		counter_node.set_text(text);
	completed_micro_game = false;
	won_micro_game = false;
	micro_game_timer = current_microgame.time;
		
#Ends the micro game without waiting for the time to run out
func skip_timer():
	end_micro_game = true;
	pass
	
#Mark the current micro game as won
func win_game():
	won_micro_game = true;
	pass
	
func lose_sfx():
	var sfx_id = 0;
	var rng = randi() %2;
	if rng == 0:
		sfx_id = sfx_lose;
	else:
		sfx_id = sfx_lose2;
	AudioManager.play_sfx(sfx_id,game_speed);
	
func play_microgame_loss_sfx():
	pass


func update_highscore():
	var pos = -1;

	var score = counter-1;
	high_scores.append(score);
	high_scores.sort()
	var length = high_scores.size()
	high_scores = [high_scores[length-3],high_scores[length-2],high_scores[length-1]]


func on_player_ending():
	Global.change_scene("res://Scenes/MGBatchSelectMenu.tscn",true)
	pass
	
func on_win_anim_end():
	if !batch_cleared && counter >= games_until_boss:
		batch_cleared = true;
		update_highscore()
		save_game()
		master_anim.play("end");
		anim.play("win");
		print(name+" boss cleared for the first time")
		
		return
	if boss_time:
		if batch_cleared:
			anim.play("d")
			if game_difficulty < 2:
				game_difficulty += 1;
				master_anim.play("levelup")
			else:
				set_game_speed(game_speed+speedup_amount);
				master_anim.play("speedup")
				base_game_speed = game_speed;
			AudioManager.play_sfx(sfx_speedup,game_speed);
			#boss_game_counter -= 1;
			#speedup_counter -= 1;
		boss_time = false;

func on_lose_anim_end():
	if lives > 0:
		master_anim.play("Begin game",-1,1,false);
	else:
		set_game_speed(1)
		var game_over = game_over_scene.instance();
		$HUD.add_child(game_over);
		update_highscore()
		save_game()
		game_over.set_scores(high_scores);
		
		AudioManager.play_sfx(sfx_game_over)
		
	
func save_game():
	for i in range(3):
		Global.game_data[name+".hs"+str(i)] = high_scores[i]
	Global.game_data[name+".cleared"] = batch_cleared
	Global.save_game()

func free_current_game():
	if current_microgame != null:
		current_microgame.free();
		current_microgame = null;
	
func decrease_lives():
	if lives <= 0:
		return
	var spr = life_sprites[life_sprites.size()-lives];
	spr.visible = false;
	gb_boom.global_position = spr.global_position;
	lives -= 1;
	if lives == 0:
		game_over();
	
	pass
	
func success_sfx():
	AudioManager.stop_all();
	AudioManager.stop_music();
	var sfx_id = 0;
	var rng = randi() %2;
	if rng == 0:
		sfx_id = sfx_success1;
	else:
		sfx_id = sfx_success2;
	AudioManager.play_sfx(sfx_id,game_speed);
	
func game_over():
	pass

func start_next():
	end_micro_game = false;
	won_micro_game = false;
	
	if current_microgame != null:
		add_child(current_microgame);
		var ap = get_tree().get_nodes_in_group("mg_anim");
		for p in ap:
			p.playback_speed = game_speed;
	else:
		print("wtf");
	anim.play("out");
	in_game = true;
	

func play_microgame_intro_sound():
	var sfx_id = 0;
	var rng = randi() %2;
	if rng == 0:
		sfx_id = sfx_intro1;
	else:
		sfx_id = sfx_intro2;
	AudioManager.stop_all()
	AudioManager.play_sfx(sfx_id,game_speed);
	
func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		Global.game_player = null
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
