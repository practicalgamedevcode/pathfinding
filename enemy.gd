extends CharacterBody2D

@onready var player: CharacterBody2D = $"../Player"
@export var movement_speed: float = 50.0
@onready var navigation_agent: NavigationAgent2D = get_node("NavigationAgent2D")

var dist_to_target = Vector2.ZERO

func _ready() -> void:
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))

func set_movement_target(movement_target: Vector2):
	navigation_agent.set_target_position(movement_target)

func _physics_process(delta):
	dist_to_target = (position - player.global_position).length()
	
	if dist_to_target > 200:
		velocity = Vector2.ZERO
	elif dist_to_target > 30 and dist_to_target < 200:
		set_movement_target(player.global_position)
		
		# Do not query when the map has never synchronized and is empty.
		if NavigationServer2D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
			return
		if navigation_agent.is_navigation_finished():
			return

		var next_path_position: Vector2 = navigation_agent.get_next_path_position()
		var new_velocity: Vector2 = global_position.direction_to(next_path_position) * movement_speed
		if navigation_agent.avoidance_enabled:
			navigation_agent.set_velocity(new_velocity)
		else:
			_on_velocity_computed(new_velocity)
		#velocity = new_velocity
	else:
		velocity = Vector2.ZERO
		#pass
		#avoid_mobs()
		form_circle(player.global_position)
		#form_circle(player.global_position)
		#for a in $NavigationAgent2D.max_neighbors:
		#	position = player.global_position + Vector2.RIGHT.rotated(a * 10)*10
			
	move_and_slide()

func _on_velocity_computed(safe_velocity: Vector2):
	velocity = velocity.move_toward(safe_velocity, 0.25)

func avoid_mobs():
	var my_array = get_tree().get_nodes_in_group("enemy")
	for d in range(my_array.size()):
		if my_array[d] != self:
			var newdist = (position - my_array[d].position)
			if newdist.length() <50:
				velocity += newdist.normalized()

func form_circle(target):
		#var count = 10
	var radius = 24
	var center = target
	var pos
	# Get how much of an angle objects will be spaced around the circle.
	# Angles are in radians so 2.0*PI = 360 degrees
	#var angle_step = 2.0*PI / count
	
	var angle = 2
	
	var my_array = get_tree().get_nodes_in_group("enemy")
	var angle_step = 2.0*PI / my_array.size()
	
	for d in range(my_array.size()):
		var direction = Vector2(cos(angle), sin(angle))
		pos = center - direction * radius
		# Rotate one step
		angle += angle_step
		
	velocity = (position - pos).normalized()
	
