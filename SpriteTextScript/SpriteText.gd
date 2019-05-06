tool
class_name SpriteText
extends ReferenceRect

var animate = false;
var anim_timer = 0;
var anim_timer_i:int = 0;
export var ignore_rect = false;
export var char_spacing:int = 0;
export var centered:bool = false;
export var space_width = 4;
export(String,MULTILINE) var text = "¬SSample ¬C01¬WText" setget set_text,get_text;
export(String) var character_set = " !\"#$%&'()*+,-./0123456789;M<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";
export(PoolIntArray) var custom_char_spaces = []
var _text = "";
export var visible_characters:int = -1 setget set_visible_chars,get_visible_chars;
export var font_texture:Texture = null setget set_font_texture,get_font_texture;
export var char_width:int = 8 setget set_char_width,get_char_width;
export var char_height:int = 8 setget set_char_height,get_char_height;
export var anim_speed:float = 60;
export var anim_interval:float = 0;
export var tab_spaces:int = 2;
var anim_interval_timer = 0;
var char_map:Dictionary;
var can_draw:bool = false;
var has_char_map = false;
export var texture_rows:int = 10 setget set_texture_rows,get_texture_rows;
var wchars;
var hchars;
var colors = [];
var text_width = 0;
var rng = RandomNumberGenerator.new();

var initialized = false;

var anim_id:int = 0;

func _ready():
	_text = text;
	set_process(true);
	if font_texture != null:
		can_draw = true;
		setup();
func set_text(var txt):
	text = txt;
	
	if !is_inside_tree():
		return;
	_ready();
	update();

func get_text():
	return text;
	
func set_visible_chars(var value):
	visible_characters = value;
	if !is_inside_tree():
		return;
	_ready();
	update();
	
func get_char_width():
	return char_width;
	
func set_char_width(v):
	char_width = max(0,v);
	if !is_inside_tree():
		return;
	_ready();
	update();
	
func set_char_height(v):
	char_height = max(0,v);
	if !is_inside_tree():
		return;
	_ready();
	update();

func get_char_height():
	return char_height
	
func get_texture_rows():
	return texture_rows;
	
func set_texture_rows(v):
	texture_rows = max(0,v);
	if !is_inside_tree():
		return;
	_ready();
	update();

func get_visible_chars():
	return visible_characters;
	
func get_font_texture():
	return font_texture;
	
func set_font_texture(v):
	font_texture = v;
	if !is_inside_tree():
		return;
	_ready();
	update();

func setup():
	var font_w:int = font_texture.get_width();
	var font_h:int = font_texture.get_height();
	wchars = int(font_w/char_width);
	hchars = int(font_h/char_height);
	if Engine.editor_hint || !initialized:
		initialized = true;
		colors.resize(13);
		colors[0] = Color.white;
		colors[1] = Color.yellow;
		colors[2] = Color.green;
		colors[3] = Color.blue;
		colors[4] = Color.red;
		colors[5] = Color.yellowgreen;
		colors[6] = Color.brown;
		colors[7] = Color.purple;
		colors[8] = Color.azure;
		colors[9] = Color.beige;
		colors[10] = Color.bisque;
		colors[11] = Color.burlywood;
		colors[12] = Color.chartreuse;
		char_map = Dictionary();
		var cid = 0;
		for c in character_set:
			char_map[c] = cid;
			cid += 1;
	if centered && custom_char_spaces.size()>0:
		var l = _text.length();
		var ci = 0
		text_width = 0
		while ci < l:
			var c = _text[ci];
			var ch_id = char_map.get(c,-1);
			if ch_id != -1:
				var ccsz = custom_char_spaces.size()
				if ccsz >0 && ch_id<ccsz:
					text_width += custom_char_spaces[ch_id]
				else:
					text_width += char_width
			elif c == ' ':
				text_width += space_width
			elif c == '\t':
				text_width += tab_spaces*space_width 
			ci += 1
					
		pass
	elif centered:
		text_width = text.length()*char_width;
		

func _process(delta):
	if animate:
		anim_timer += anim_speed*delta;
		anim_timer_i = floor(anim_timer);
		if (anim_interval>0):
			anim_interval_timer += delta;
			if anim_interval_timer >= anim_interval:
				update();
				anim_interval_timer = 0
		else:
			update()
	else:
		anim_timer = 0;

func _draw():
	var x:int = 0;
	var y:int = 0;
	#var i:int = 0;
	#var j:int = 0;
	var total = 0;
	var ox = 0;
	var oy = 0;
	
	var cx = 0;
	var cy = 0;
	
	var length = _text.length();
	var ci = 0;
	var col = Color.white;
	var has_anim = false;
	anim_id = 0;
	var cv = 0;
	if centered:
		cv = rect_size.x*0.5 - text_width*0.5
	var cchar_space = 0;
	while ci < length:
		var c = _text[ci];
		var ch_id = char_map.get(c,-1);
		if ch_id == -1:
			if c == ' ':
				cx += space_width
				if !ignore_rect && cx > floor(rect_size.x):
					cy += char_height;
					cx = 0;
				
			if c == '\n':
				cx = 0;
				cy+=char_height
			elif c == '\t':
				cx += tab_spaces;
				if !ignore_rect && cx > floor(rect_size.x):
					cy += char_height;
					cx = 0;
			
			elif c == '¬' && ci+1 < length:
				var fx_char = _text[ci+1];
				if (ci+3) < length && fx_char=='C':
					var num = str(_text[ci+2])+str(_text[ci+3]);
					var numI = num.to_int();
					if numI < colors.size():
						col = colors[numI];
						ci += 3;
				elif fx_char == 'N':
					anim_id = 0;
					ci += 1;
				elif fx_char == 'W':#Wavy text
					anim_id = 1;
					has_anim = true;
					ci += 1;
					pass;
				elif fx_char == 'S':#Shakey text
					anim_id = 2;
					has_anim = true;
					ci += 1;
					pass;
			ci += 1;
			continue;
		ox = 0;
		oy = 0;
		y = floor(ch_id/wchars);
		x = ch_id%wchars;
		
		var ccsz = custom_char_spaces.size()
		if ccsz >0 && ch_id<ccsz:
			cchar_space = custom_char_spaces[ch_id]
		else:
			cchar_space = char_width
		match anim_id:
			1:
				oy = cos((anim_timer + ci * char_height) / char_height);
			2:
				
				oy = rng.randi_range(-1,1)*anim_speed;
				ox = rng.randi_range(-1,1)*anim_speed;
		
		total = total +1;
		if visible_characters >= 0 && total > visible_characters:
			break;
		
		
		draw_texture_rect_region(font_texture,Rect2(cv+cx+ox,cy+oy,cchar_space,char_height),Rect2(x*char_width,y*char_height,cchar_space,char_height),col,false);
		
		cx += cchar_space+floor(char_spacing);
		if !ignore_rect && cx > floor(rect_size.x):
			cy += char_height;
			cx = 0;
			if cy > rect_size.y:
				break;
		
		ci += 1;
		
	if has_anim:
		animate = true;

