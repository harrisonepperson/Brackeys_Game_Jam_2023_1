extends Node2D

var population
var citizen = load("res://Citizen.tscn")

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

var eventsHandled = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	population = $"/root/Stats".population

	for pop_type in population:
		spawnCitizen(pop_type, population[pop_type]["Current"])

func spawnCitizen(type, amount):
	if amount == 0:
		return

	var dude = citizen.instance()
	var targetPos = Vector2(50.0, 50.0)
	var boundary
	
	if type == "Artist":
		dude.characterType = CharacterType.Artist
		targetPos = $Population/Artist_Target.position
		boundary = $Population/Artist_Target/CollisionShape2D
	if type == "Captain":
		dude.characterType = CharacterType.Captain
		targetPos = $Population/Captain_Target.position
		boundary = $Population/Captain_Target/CollisionShape2D
	if type == "Child":
		dude.characterType = CharacterType.Child
		targetPos = $Population/Child_Target.position
		boundary = $Population/Child_Target/CollisionShape2D
	if type == "Compost":
		dude.characterType = CharacterType.Compost
		targetPos = $Population/Compost_Target.position
		boundary = $Population/Compost_Target/CollisionShape2D
	if type == "Engineer":
		dude.characterType = CharacterType.Engineer
		targetPos = $Population/Engineer_Target.position
		boundary = $Population/Engineer_Target/CollisionShape2D
	if type == "Farmer":
		dude.characterType = CharacterType.Farmer
		targetPos = $Population/Farmer_Target.position
		boundary = $Population/Farmer_Target/CollisionShape2D
	if type == "Fighter":
		dude.characterType = CharacterType.Fighter
		targetPos = $Population/Fighter_Target.position
		boundary = $Population/Fighter_Target/CollisionShape2D
	if type == "Medic":
		dude.characterType = CharacterType.Medic
		targetPos = $Population/Medic_Target.position
		boundary = $Population/Medic_Target/CollisionShape2D
	if type == "Pilot":
		dude.characterType = CharacterType.Pilot
		targetPos = $Population/Pilot_Target.position
		boundary = $Population/Pilot_Target/CollisionShape2D
	if type == "Priest":
		dude.characterType = CharacterType.Priest
		targetPos = $Population/Teacher_Target.position
		boundary = $Population/Teacher_Target/CollisionShape2D
	if type == "Teacher":
		dude.characterType = CharacterType.Teacher
		targetPos = $Population/Teacher_Target.position
		boundary = $Population/Teacher_Target/CollisionShape2D
	
	dude.charactersInGroup += amount
	dude.position = targetPos
	dude.boundary = boundary.get_shape().get_extents()
	dude.boundaryOffset = boundary.global_position
	
	$NavigationPolygonInstance.add_child(dude)
	
func onEventEnd():
	var score = "Events Handled: %s"
	
	eventsHandled += 1
	$CanvasLayer/Control/RichTextLabel.text = score % eventsHandled
