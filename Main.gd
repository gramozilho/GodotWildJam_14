extends Node2D

onready var death_screen = load("res://Menus/DeathScreen.tscn")

var shadow_casting_array
var mouse_state = "game"
var do_once = true


func _ready():
	# Transition
	var Mat = $CanvasLayer/EyeTransition.get_material()
	Mat.set_shader_param("cutoff", -.1)
	$CanvasLayer/EyeTransition/AnimationPlayer.play("open")
	shadow_casting_array = get_tree().get_nodes_in_group("cast_shadow")
	for body in shadow_casting_array:
		body.on_light_touching($Light.global_position)
	
	for lamp in get_tree().get_nodes_in_group("lamp"):
		lamp.connect('lamp_touched', $Light, 'receive_click')
	
	for bad_area in get_tree().get_nodes_in_group("bad_area"):
		bad_area.connect("kill_player", $Player, "die")
		if bad_area.is_in_group("enemy"):
			bad_area.connect("light", bad_area, "is_there_light")
	
	#Spawn player on same margin from camera
	var margin_from_camera = $Camera2D.global_position - Vector2(440*$Camera2D.zoom.x, 0)
	$Player.global_position = Vector2(margin_from_camera.x, 279) #Vector2(margin_from_camera, 279)
	
	# Set light to no energy
	$Light.energy = 0
	
	# Hide text
	$Camera2D/VBoxContainer/Message.modulate = Color(1, 1, 1, 0)
	$Camera2D/VBoxContainer/Instruction.modulate = Color(1, 1, 1, 0)
	$Camera2D/VBoxContainer/Extra.modulate = Color(1, 1, 1, 0)
	
	for enemy in get_tree().get_nodes_in_group("enemy"):
		$Light.connect("light", enemy, "is_there_light")


func _process(delta):
	if Input.is_action_pressed("click") and mouse_state == "free":
		$Light.global_position = get_global_mouse_position()


func _on_Light_light_position(light_position):
	for body in shadow_casting_array:
		body.on_light_touching(light_position)


func _on_Door_go_to_next_level():
	$CanvasLayer/EyeTransition/AnimationPlayer.play("close")


func _on_Light_light(on):
	if shadow_casting_array != null:
		# Disable all body shadow collisions
		for body in shadow_casting_array:
			body.if_light_on_enable_shadow(on)


func _on_TextHandler_animation_finished(anim_name):
	pass


func show_first_two_labels(time_delay):
	$MessageTimer.wait_time = .5
	$MessageTimer.start()
	yield($MessageTimer, "timeout")
	$Camera2D/VBoxContainer/TextHandler.play("show_1")
	$MessageTimer.wait_time = time_delay
	$MessageTimer.start()
	yield($MessageTimer, "timeout")
	$Camera2D/VBoxContainer/TextHandler.play("show_2")
	
func hide_all_labels():
	$Camera2D/VBoxContainer/Message.modulate = Color(1, 1, 1, 0)
	$Camera2D/VBoxContainer/Instruction.modulate = Color(1, 1, 1, 0)
	$Camera2D/VBoxContainer/Extra.modulate = Color(1, 1, 1, 0)


func _on_Player_dead():
	# Instance death screen
	var scene_instance = death_screen.instance()
	$CanvasMenu.add_child(scene_instance)


func _on_StuckTimer_timeout():
	hide_all_labels()
	$Camera2D/VBoxContainer/Message.text = "If stuck, restart by pressing R"
	$Camera2D/VBoxContainer/TextHandler.play("show_1")


func _on_EyeTransition_animation_closed():
	var Mat = $CanvasLayer/EyeTransition.get_material()
	Mat.set_shader_param("cutoff", -.1)
	globals.next_level()
