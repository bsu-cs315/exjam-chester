extends CharacterBody3D

@export var speed: float = 5
@export var detection_radius: float = 100.0
@export var health: int = 1

var target: CharacterBody3D = null

func _ready() -> void:
	print("Enemy ready.")
	find_closest_raccoon()

func _physics_process(delta: float) -> void:
	if target == null or !is_instance_valid(target):
		print("Looking for raccoons...")
		find_closest_raccoon()

	if target:
		move_toward_target(delta)

	check_player_collision()

func find_closest_raccoon() -> void:
	var closest_raccoon: CharacterBody3D = null
	var closest_distance: float = detection_radius

	print("Searching for raccoons in the group...")

	for raccoon in get_tree().get_nodes_in_group("raccoons"):
		print("Found raccoon: ", raccoon.name)
		if raccoon is CharacterBody3D:
			var distance = global_transform.origin.distance_to(raccoon.global_transform.origin)

			if distance < closest_distance:
				print("Raccoon ", raccoon.name, " is closer, updating target.")
				closest_raccoon = raccoon
				closest_distance = distance

	target = closest_raccoon

	if target:
		print("Target found: ", target.name)
	else:
		print("No raccoon found within the detection radius.")

func move_toward_target(_delta: float) -> void:
	var direction = (target.global_transform.origin - global_transform.origin).normalized()

	if direction.length() > 0:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed

		move_and_slide()

	var distance_to_target = global_transform.origin.distance_to(target.global_transform.origin)

	if distance_to_target > 0.1:
		look_at(target.global_transform.origin)

func take_damage(amount: int) -> void:
	health -= amount
	print("Enemy hit! Remaining health: ", health)

	if health <= 0:
		die()

func die() -> void:
	print("Enemy ", name, " has been killed.")
	var particles : GPUParticles3D = preload("res://trash_can/trash_can_death.tscn").instantiate()
	get_parent().add_child(particles)
	particles.emitting = true
	particles.global_position = global_position

	queue_free()

func check_player_collision() -> void:
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

		if collider:
			if collider.is_in_group("raccoons"):
				collider.die()
