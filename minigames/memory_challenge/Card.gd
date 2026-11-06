extends Button

signal card_selected(card)

var icon_name = ""
var revealed = false
var matched = false

var front_texture
var back_texture

func setup(card_name, front, back):

	icon_name = card_name
	front_texture = front
	back_texture = back

	show_back()

func show_back():

	$Icon.texture = back_texture

	revealed = false

func show_front():

	$Icon.texture = front_texture

	revealed = true

func _pressed():

	if matched:
		return

	if revealed:
		return

	show_front()

	card_selected.emit(self)
