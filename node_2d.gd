extends Node2D

var speed = 300
var direction = Vector2(1,0)
var screen_size = Vector2()
var window_size = Vector2(200, 200)
var idle_timer = 0.0
var is_idling = false
var r = randi() % 3 

@onready  var animated_sprite = $AnimatedSprite2D
@onready var area = $Area2D

func _ready() -> void:
	OS.shell_open("https://www.instagram.com")
	screen_size = Vector2(DisplayServer.screen_get_size())
	animated_sprite.scale = Vector2(2,2)
	animated_sprite.play("walk")
	
	area.input_event.connect(_on_area_input)
	
	area.mouse_entered.connect(func():
		var scale_tween = create_tween()
		scale_tween.tween_property(animated_sprite, "scale", Vector2(2.5, 2.5), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	)
	
	area.mouse_exited.connect(func():
		var scale_tween = create_tween()
		scale_tween.tween_property(animated_sprite, "scale", Vector2(2.0, 2.0), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	)
	
	var tween = create_tween()
	tween.tween_property(animated_sprite, "offset", Vector2(0, -30.0), 0.15)
	tween.tween_property(animated_sprite, "offset", Vector2(0, 0.0), 0.15)

func _physics_process(delta: float) -> void:
	if is_idling:
		idle_timer -= delta
		if idle_timer <= 0:
			is_idling = false
			speed = 300
			animated_sprite.play("walk")
		else:
			return 
			
	var window_position = Vector2(DisplayServer.window_get_position())
	var next_position = window_position + direction * speed * delta
	
	if next_position.x <= 0:
		direction = Vector2(1 , randf_range(-0.7, 0.7)).normalized() 
		animated_sprite.flip_h = false
		maybe_idle()
	elif next_position.x >= screen_size.x - window_size.x:
		direction = Vector2(-1, randf_range(-0.7 , 0.7)).normalized()
		animated_sprite.flip_h = true
		maybe_idle()
		
	if next_position.y <= 0:
		var target_x = -1 if animated_sprite.flip_h else 1
		direction = Vector2(target_x + randf_range(-0.3, 0.3), 1).normalized()
		maybe_idle()
	elif next_position.y >= screen_size.y - window_size.y:
		var target_x = -1 if animated_sprite.flip_h else 1
		direction = Vector2(target_x + randf_range(-0.3 , 0.3), -1).normalized()
		maybe_idle()
	
	window_position += direction * speed * delta
	window_position.x = clamp(window_position.x ,0, screen_size.x - window_size.x)
	window_position.y = clamp(window_position.y , 0, screen_size.y - window_size.y)
	DisplayServer.window_set_position(Vector2i(window_position))


func maybe_idle():
	if randf() <  0.3:
		is_idling = true
		idle_timer = randf_range(1.0 , 3.0)
		animated_sprite.play("idle")
		speed = 0
		

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			DisplayServer.window_start_drag()

func _on_area_input(_viewport, event , _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			DisplayServer.window_start_drag()
