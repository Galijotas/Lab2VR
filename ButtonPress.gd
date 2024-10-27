extends StaticBody3D
var toggle = false
var interactable = true
@export var animation_player: AnimationPlayer

func ButtonInteract():
	if interactable == true:
		interactable = false
		animation_player.play("PressButton")
		await get_tree().create_timer(2.0, false).timeout
		interactable = true
