extends Area2D

@onready var BulletHit = preload("res://BulletHit.tscn")
@onready var EnemyDie = preload("res://EnemyDie.tscn")
@onready var EnemyBullet = preload("res://EnemyBullet.tscn")

@onready var nav_2d : Navigation2D = get_node("/root/Main/Level1/Navigation2D")
var path : PackedVector2Array() = setget set_path

@onready var player = get_node("../Player")

var health = 100
var target = Vector2.ZERO
var velocity = Vector2.ZERO
var speed = 40

var move_dist = 200

onready var look = $RayCast2D

var can_shoot = true
var aimangle = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	target = player

func set_path(value : PoolVector2Array) -> void:
	if value.size() == 0:
		return
	path = value
	path.remove(0)
	set_process(true)

func move_along_path(distance : float) -> void:
	var last_point : = position
	for index in range(path.size()):
		var distance_to_next = last_point.distance_to(path[0])
		if distance <= distance_to_next and distance >= 0.0:
			position = last_point.linear_interpolate(path[0], distance / distance_to_next)
			break
		elif path.size() == 0:
			position = path[0]
			set_process(false)
			break
		distance -= distance_to_next
		last_point = path[0]
		path.remove(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target:
		if (player.position - position).length() < move_dist:
			look.cast_to = (player.position - position)
			look.force_raycast_update()
			if look.is_colliding():
				var object_collided_with = look.get_collider()
				if object_collided_with == player:
					var new_path : = nav_2d.get_simple_path(position, target.global_position, false)
					path = new_path
				
					var move_distance = speed * delta
					move_along_path(move_distance)
