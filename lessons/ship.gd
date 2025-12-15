extends Area2D

@onready var thruster_sound_player: AudioStreamPlayer = $ThrusterSoundPlayer
@onready var health_sound: AudioStreamPlayer = $HealthSound
@onready var first_gem_sound: AudioStreamPlayer = $FirstGemSound
@onready var second_gem_sound: AudioStreamPlayer = $SecondGemSound
@onready var third_gem_sound: AudioStreamPlayer = $ThirdGemSound
@onready var fourth_gem_sound: AudioStreamPlayer = $FourthGemSound
@onready var timer = $Timer

var max_speed := 1200.0
var velocity := Vector2(0, 0)
var steering_factor := 3.0
var health : float = 100
var gem_count := 0
var health_decay : float = 4.5
var max_health : float = 100
var gem_streak := 0

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	get_node("Timer").timeout.connect(_on_timer_timeout)

func _process(delta: float) -> void:
	if health > 0:
		set_health(health - health_decay * delta)
	if health >= max_health:
		health = max_health
	
	var direction := Vector2(0, 0)
	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_up", "move_down")

	var is_moving := direction.length() > 0.0
	if is_moving and not thruster_sound_player.playing:
		thruster_sound_player.play()
	elif not is_moving and thruster_sound_player.playing:
		thruster_sound_player.stop()

	if direction.length() > 1.0:
		direction = direction.normalized()

	var desired_velocity := max_speed * direction
	var steering := desired_velocity - velocity
	velocity += steering * steering_factor * delta
	position += velocity * delta

	if velocity.length() > 0.0:
		get_node("Sprite2D").rotation = velocity.angle()
	
	var viewport_size := get_viewport_rect().size
	position.x = wrapf(position.x, 0, viewport_size.x)
	position.y = wrapf(position.y, 0, viewport_size.y)


 # HealthBar Code
func set_health(new_health: float) -> void:
	health = new_health
	get_node("UI/HealthBar").value = health
	if health <= 0:
		get_tree().reload_current_scene()

 # GemCount Code
func set_gem_count(new_gem_count: int) -> void:
	gem_count = new_gem_count
	get_node("UI/GemCount").text = str(gem_count)



func _on_area_entered(area_that_entered: Area2D) -> void:
	if area_that_entered.is_in_group("gem"):
		set_gem_count(gem_count + 1)
		_gem_collected()
	elif area_that_entered.is_in_group("healing_item"):
		health_sound.play()
		set_health(health + 10)


func _gem_collected() -> void:
	if timer.time_left > 0.0:
		gem_streak += 1
	else:
		gem_streak = 0
	
	if gem_streak <= 0:
		first_gem_sound.play()
	elif gem_streak == 1:
		second_gem_sound.play()
	elif gem_streak == 2:
		third_gem_sound.play()
	elif gem_streak >= 3:
		fourth_gem_sound.play()
		await fourth_gem_sound.finished
		gem_streak = 0
		
	timer.start()


func _on_timer_timeout() -> void:
	gem_streak = 0
