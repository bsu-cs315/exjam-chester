extends Camera3D

var target: Node3D
var smooth_speed: float = 5.0
var offset: Vector3 = Vector3(-13.5, 17, 0)
@onready var audio_player = $background_music

func _ready() -> void:
	if audio_player.stream is AudioStreamPlayer3D:
		audio_player.stream.loop = true
	audio_player.play()
	target = get_parent().get_node("the_raccoon")
	if target == null:
		print("The raccoon node was not found!")

func _process(_delta: float) -> void:
	if not audio_player.playing:
		audio_player.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if target != null:
		self.position = self.position.lerp(target.position + offset, smooth_speed * delta)

	
