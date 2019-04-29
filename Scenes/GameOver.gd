extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var first = $"2x/HighScores/1st"
onready var second = $"2x/HighScores/2nd"
onready var third = $"2x/HighScores/3rd"

var exit_scene:PackedScene = load("res://Scenes/MGBatchSelectMenu.tscn");
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		Global.reload_scene()
		pass
	elif Input.is_action_just_pressed("ui_cancel"):
		Global.change_scene(exit_scene)
		pass
	
func set_scores(scores):
	first.set_text(str(scores[2]))
	second.set_text(str(scores[1]))
	third.set_text(str(scores[0]))
	pass
