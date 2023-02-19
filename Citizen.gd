extends KinematicBody2D

enum CharacterType {
	Artist,
	Captain,
	Child,
	Compost,
	Engineer,
	Farmer,
	Fighter,
	Medic,
	Pilot,
	Priest,
	Teacher
}

export(CharacterType) var characterType = CharacterType.Child

var rng = RandomNumberGenerator.new()

var age = 0
var ageTimer = Timer.new()

var thingTimer = Timer.new()

var isActive : bool = false
var maxCharactersInGroup : int = 30
var charactersInGroup : int = 0
var charactersRepresentative : int = 5

var target_direction : Vector2
var navAgent : NavigationAgent2D

var boundary : Vector2
var boundaryOffset : Vector2

var velocity : Vector2
export (float) var speed = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	navAgent = $"NavigationAgent2D"
	navAgent.set_target_location(position)

	thingTimer.connect("timeout", self, "idle")
	thingTimer.wait_time = 0.01
	thingTimer.one_shot = true
	add_child(thingTimer)
	thingTimer.start()

	# ageTimer.connect("timeout", self, "newYear")
	# ageTimer.wait_time = $"root/Stats".yearLength
	# ageTimer.one_shot = false
	# add_child(ageTimer)
	# ageTimer.start

	pass

# func newYear():
# 	age += 1

# 	if age == 18:
# 		var careers = CharacterType.keys()
# 		var EventType = $"root/Stats".EventType
# 		if !$"root/Stats".currentEvent.has(EventType.Religion):
# 			careers.erase(9)
# 		careers.erase(2)

# 		characterType = careers[randi() % CharacterType.size()]

# 		$"../..".spawnCitizen("random", charactersInGroup)

func idle():
	var pos = Vector2(rng.randi_range(-boundary.x, boundary.x), rng.randi_range(-boundary.y, boundary.y))
	navAgent.set_target_location(boundaryOffset + pos)

func _input(event):
	if isActive and event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		navAgent.set_target_location(event.position)
		isActive = false;
		thingTimer.stop()
		$"Light2D".enabled = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var charsToShow = int(floor(charactersInGroup / charactersRepresentative))
	
	if charsToShow >= 1:
		$"Character_Collection/Character1".visible = true
	if charsToShow >= 2:
		$"Character_Collection/Character2".visible = true
	if charsToShow >= 3:
		$"Character_Collection/Character3".visible = true
	if charsToShow >= 4:
		$"Character_Collection/Character4".visible = true
	if charsToShow >= 5:
		$"Character_Collection/Character5".visible = true
	if charsToShow >= 6:
		$"Character_Collection/Character6".visible = true
	
	if navAgent.is_navigation_finished():
		if thingTimer.is_stopped():
			thingTimer.wait_time = rng.randf_range(0.5, 2.0)
			thingTimer.start()
	else:
		target_direction = position.direction_to(navAgent.get_next_location())
		velocity = target_direction * speed * 10
		velocity = move_and_slide(velocity)
		navAgent.set_velocity(velocity)
	

func _on_Citizen_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		isActive = true;
		$"Light2D".enabled = true
		
