extends CharacterBody3D

@export var speed: float = 10.0
@export var rotation_lerp_speed: float = 5
@export var fire_range: float = 1000.0
@export var fire_cooldown: float = 0.02

@onready var gun = $biggunbody

var direction = Vector3.ZERO
var can_fire = true

func _process(delta: float) -> void:
	direction = Vector3.ZERO

	if Input.is_action_pressed("move_forward"):
		direction.x += 1
	if Input.is_action_pressed("move_backward"):
		direction.x -= 1
	if Input.is_action_pressed("move_left"):
		direction.z -= 1
	if Input.is_action_pressed("move_right"):
		direction.z += 1

	if direction != Vector3.ZERO:
		direction = direction.normalized()

	velocity = direction * speed

	move_and_slide()

	rotate_to_movement_direction(delta)

	rotate_gun_toward_mouse()
	
	if Input.is_action_just_pressed("fire") and can_fire:
		fire_ray()
		%trash_cans.text = "Trash cans remaining: " + str(get_tree().get_nodes_in_group("enemies").size() / 2.0)
		can_fire = false
		$biggunbody/biggun/muzzle_light.visible = true
		$biggunbody/biggun/muzzle_flash.emitting = true
		%shoot_audio.play()
		await get_tree().create_timer(fire_cooldown).timeout
		$biggunbody/biggun/muzzle_light.visible = false
		can_fire = true

func rotate_gun_toward_mouse() -> void:
	var camera = get_viewport().get_camera_3d()
	var mouse_pos = get_viewport().get_mouse_position()

	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_direction = camera.project_ray_normal(mouse_pos)

	var plane = Plane(Vector3.UP, global_transform.origin.y)

	var target_position = plane.intersects_ray(ray_origin, ray_direction)

	var gun_position = gun.global_transform.origin
	var target_direction = target_position - gun_position
	target_direction.y = 0

	if target_direction.length() > 0:
		target_direction = target_direction.normalized()
		gun.look_at(gun_position + target_direction, Vector3.UP)

func rotate_to_movement_direction(delta: float) -> void:
	if direction == Vector3.ZERO:
		return
	
	var target_rotation_y = atan2(direction.x, direction.z)

	var current_rotation_y = rotation.y

	rotation.y = lerp_angle(current_rotation_y, target_rotation_y, rotation_lerp_speed * delta)
	
func fire_ray() -> void:
	var gun_forward = -gun.global_transform.basis.z

	var ray_origin = gun.global_transform.origin

	var min_y = -5
	var max_y = 5
	var step_y = 1

	for y_offset in range(min_y, max_y, step_y):
		var ray_start = ray_origin + Vector3(0, y_offset, 0)
		var ray_end = ray_start + gun_forward * fire_range

		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.new()
		query.from = ray_start
		query.to = ray_end
		query.collision_mask = 0b0001

		var result = space_state.intersect_ray(query)

		if result:
			var collider = result["collider"]

			if collider.is_in_group("enemies"):
				print("Hit enemy at Y offset: ", y_offset)
				collider.take_damage(1)
				break

		if result:
			var collider = result["collider"]

			if collider.is_in_group("enemies"):
				print("Hit enemy: ", collider.name)
				collider.take_damage(1)
			else:
				print("Ray hit something else: ", collider.name)
				
func die():
	queue_free()
