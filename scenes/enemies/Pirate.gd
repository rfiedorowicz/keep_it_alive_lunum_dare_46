extends KinematicBody2D

onready var bullet_scene = load("res://scenes/enemies/Bullet.tscn")
onready var score_popup_scene = load("res://scenes/UI/ScorePopup.tscn")

var shoot_time = 6
var score_points = 15

var is_dead = false

signal enemy_dead

# Called when the node enters the scene tree for the first time.
func _ready():
	var it_node = get_parent().find_node("It")
	if !it_node:
		return
	
	set_frames(it_node.find_node("Head"))
	
	var err = connect("enemy_dead", get_parent(), "on_enemy_died", [score_points])
	if err != OK:
		print(err)
	
	start_aiming()

func _on_BowAiming_timeout():
	var it_node = get_parent().find_node("It")
	if !it_node:
		return

	$Sprite/Bow.rotation = $ShootStartPosition.global_position.angle_to_point(it_node.find_node("Head").global_position)

func _on_BulletDetector_body_entered(_body):
	die()

func _on_ShootTimer_timeout():
	if !is_dead:

		$AnimationPlayer.play("Shoot")

func start_aiming():
	# shoot time can't be shorter than animation
	$ShootTimer.start(max(1, shoot_time - 1))
		


func shoot():
	# invoked from animation player
	$Samples.stream = load("res://assets/audio/samples/arrow_start.wav")
	$Samples.play()
	$AnimationPlayer.play("Idle")
	var bullet = bullet_scene.instance()
	
	var it_node = get_parent().find_node("It")
	if !it_node:
		return
	bullet.position = $ShootStartPosition.global_position
	var it_head = it_node.find_node("Head")
	bullet.target = it_head.global_position
	get_parent().add_child(bullet)
	
	set_frames(it_head)
	start_aiming()

	

func set_frames(it_head):
	var is_flip = true if it_head.global_position.x > global_position.x else false
	$Sprite.flip_h = is_flip

func call_die():
	call_deferred("die")
	
func die():
	if !is_dead:
		is_dead = true
		$AnimationPlayer.play("Die")
		emit_signal("enemy_dead")
		$ShootTimer.stop()
		$BowAiming.stop()
		
		var score_popup = score_popup_scene.instance()
		score_popup.position = Vector2(0, -16)
		score_popup.set_score(score_points)
		add_child(score_popup)



