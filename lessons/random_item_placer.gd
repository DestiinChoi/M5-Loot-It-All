extends Node2D

var items_spawned := 0
var item_scenes := [
	preload("gem.tscn"),
	preload("health_pack.tscn")
	]


func _ready() -> void:
	get_node("Timer").timeout.connect(_on_timer_timeout)
	

func _on_timer_timeout() -> void:
	if items_spawned >= 8:
		return
	elif items_spawned < 8:
		var random_item_scene: PackedScene = item_scenes.pick_random()
		var item_instance := random_item_scene.instantiate()
		add_child(item_instance)
		var viewport_size := get_viewport_rect().size
		var random_position := Vector2(0.0, 0.0)
		random_position.x = randf_range(0.0, viewport_size.x)
		random_position.y = randf_range(0.0, viewport_size.y)
		item_instance.position = random_position
		items_spawned += 1
		item_instance.tree_exited.connect(item_destroyed)
	
func item_destroyed():
	items_spawned -= 1
