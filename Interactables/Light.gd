extends Node2D

signal light_position
signal light

var old_position
var light_energy = .8


func _ready():
	old_position = global_position
	self.energy = light_energy
	light_changed(false)


func _process(delta):
	if old_position != global_position:
		emit_signal("light_position", global_position)
		old_position = global_position
	
	if Input.is_action_just_pressed("ui_right"):
		position.x += 20 
	if Input.is_action_just_pressed("ui_left"):
		position.x -= 20 


func receive_click(destination):
	# If light is off, turn on at location
	if $TravelTimer.time_left == 0:
		$TravelTimer.start()
		if self.energy == 0:
			global_position = destination
			$TweenLight.interpolate_property(self, "energy", 0, light_energy, 0.5, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
			light_changed(true)
			Jukebox.light_on()
		# if mouse on same place as light currently, off
		elif global_position == destination:
			$TweenLight.interpolate_property(self, "energy", light_energy, 0, 0.5, Tween.TRANS_EXPO, Tween.EASE_OUT)
			light_changed(false)
			Jukebox.light_off()
		# else, tween to location
		else:
			# Check if not travelling
			var travel_duration = 1
			$TweenLight.interpolate_property(self, "position", global_position, destination, travel_duration, Tween.TRANS_QUINT, Tween.EASE_IN_OUT)
			Jukebox.whoosh()
		$TweenLight.start()


func light_changed(on):
	if on:
		emit_signal("light", true)
	else:
		emit_signal("light", false)
