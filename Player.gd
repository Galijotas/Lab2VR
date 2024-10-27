extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@onready var neck := $Neck
@onready var camera := $Neck/Camera3D
@onready var interaction = $Neck/Camera3D/interaction
@onready var hand = $Neck/Camera3D/hand

var picked_object
var pull_power = 8
var kicked_object

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			neck.rotate_y(-event.relative.x * 0.01)
			camera.rotate_x(-event.relative.y * 0.01)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(60))
			
	if Input.is_action_just_pressed("lclick"):
		if picked_object == null:
			pick_object()
		elif picked_object != null:
			remove_object()
			
	if Input.is_action_just_pressed("throwObject"):
		if picked_object != null:
			var knockback = picked_object.position - position
			picked_object.apply_central_impulse(knockback * 3)
			remove_object()
			
	if Input.is_action_just_pressed("interact"):
		door_object()
		
	if Input.is_action_just_pressed("interact"):
		lever_object()
		
	if Input.is_action_just_pressed("interact"):
		button_object()
		
	if Input.is_action_just_pressed("Kick"):
		if kicked_object == null:
			kick_object()

	

func kick_object():
	var collider = interaction.get_collider()
	if collider != null and collider is RigidBody3D:
		kicked_object = collider
		var knockback = kicked_object.position - position
		kicked_object.apply_central_impulse(knockback * 10)
		kicked_object = null
		

func button_object():
		var collider = interaction.get_collider()
		if collider != null and collider.has_method("ButtonInteract"):
			collider.ButtonInteract()

func door_object():
		var collider = interaction.get_collider()
		if collider != null and collider.has_method("DoorInteract"):
			collider.DoorInteract()
			
func lever_object():
		var collider = interaction.get_collider()
		if collider != null and collider.has_method("LeverInteract"):
			collider.LeverInteract()

func pick_object():
	var collider = interaction.get_collider()
	if collider != null and collider is RigidBody3D:
		picked_object = collider
		
func remove_object():
	if picked_object != null:
		picked_object = null

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("Left", "Right", "Forward", "Back")
	var direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	if picked_object != null:
		var a = picked_object.global_transform.origin
		var b = hand.global_transform.origin
		picked_object.set_linear_velocity((b-a)* pull_power)

	move_and_slide()
