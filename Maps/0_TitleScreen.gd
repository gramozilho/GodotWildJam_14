extends Control


func _on_Button_pressed():
	globals.next_level()
	Jukebox.button_pressed()


func _on_Button2_pressed():
	get_tree().quit()
	Jukebox.button_pressed()
