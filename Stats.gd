extends Node

var annualTimer = Timer.new()

var minPopulation : int = 100
var targetPopulation : int = 1000
var maxPopultation : int = 2000
var populationTotal : int = 0
var maxAge : int = 100

var epoch : int = 0
var generation : int = 0
var year : int = 0

var yearLength : int = 5
var yearsPerEvent : int = 2
var yearsPerGeneration : int = 20
var generationsPerEpoch : int = 2

var currentEvent = []

signal eventStarted

# minimum: 100, maximum: 2000, target: 1000
var population = {
	"Artist": { "Minimum": 0, "Current": 10 },
	"Captain": { "Minimum": 1, "Current": 2 },
	"Child": { "Minimum": 0, "Current": 50 },
	"Compost": { "Minimum": 2, "Current": 10 },
	"Engineer": { "Minimum": 10, "Current": 20 },
	"Farmer": { "Minimum": 5, "Current": 10 },
	"Fighter": { "Minimum": 0, "Current": 20 },
	"Medic": { "Minimum": 2, "Current": 10 },
	"Pilot": { "Minimum": 0, "Current": 10 },
	"Priest": { "Minimum": 0, "Current": 0 },
	"Teacher": { "Minimum": 2, "Current": 10 }
}

var civilization = {
	"PhysicalDiversity": 100,
	"Cohesion": 80,
	"ShipIntegrity": 100,
	"Religion": false,
	"HadRebelion": false,
	"Propaganda": 20
}

enum EventType {
	Famine,
	Disease,
	Invasion,
	Boarding,
	# Trade,
	Scavenge,
	Insurrection,
	# Religion
}

var events = {
	EventType.Famine: {
		"Description": "Disease is ravaging our hydroponics.",
		"Resolves":  [ "Engineer", "Medic" ],
		"Prompt": false,
		"Result": {
			"Success": { "Description": "We quarentined the affected systems and are cultivating a resistant strain." },
			"Failure": { "Description": "The disease has escaped our quarentine efforts and we have lost significant food production." }
		}
	},
	EventType.Disease: {
		"Description": "A funky space disease is spreading through our population.",
		"Resolves":  [ "Medic" ],
		"Prompt": false,
		"Result": {
			"Success": { "Description": "Our fearless scientists have developed a vacine and disseminated it throughout our ranks." },
			"Failure": { "Description": "We were unable to contain the disease and have suffered great population loss." }
		}
	},
	EventType.Invasion: {
		"Description": "Space worms are crawling around our hull!",
		"Resolves":  [ "Pilot" ],
		"Prompt": false,
		"Result": {
			"Success": { "Description": "The proverbial \"Space Bird\" got the space worms!" },
			"Failure": { "Description": "The space worms have slimed through the hull causing significant physical damage." }
		}
	},
	EventType.Boarding: {
		"Description": "Aliens are boarding the Phoenix!",
		"Resolves":  [ "Fighter" ],
		"Prompt": false,
		"Result": {
			"Success": { "Description": "Our brave fighters staved of the invasion and restored peace!" },
			"Failure": { "Description": "The aliens have beaten our best efforts and we've lost food resources and some people" }
		}
	},
#	EventType.Trade: {
#		"Description": "A traveling ship is the vicinity do you want to hail them?",
#		"Resolves":  { "Captain": 1, "Pilot": 5, "Artist": 1 },
#		"Prompt": true,
#		"Result": {
#			"Success": { "Description": "You hail the ship and offer a trade. You're pilots return with fresh resources." },
#			"Failure": { "Description": "You watch as the ship passes you by and continue on your way." }
#		}
#	},
	EventType.Scavenge: {
		"Description": "A decrepit ship is drifting in parts in front of us.  Do you want to scavenge it for resources?",
		"Resolves":  [ "Captain", "Pilot", "Fighter" ],
		"Prompt": false,
		"Result": {
			"Success": { "Description": "Our pilots found some resources among the rubble and brought them on board." },
			"Failure": { "Description": "We could not find a safe way to dock on the ship and return empty handed." }
		}
	},
	EventType.Insurrection: {
		"Description": "The people are suffering! They are grabbing what they can and are trying to take over the ship",
		"Resolves":  [ "Fighter" ],
		"Prompt": false,
		"Result": {
			"Success": { "Description": "We have squashed the puny rebels with only minimal losses!" },
			"Failure": { "Description": "Glory to the rebelion! Through our blood we have seized the glut of resources our former \"betters\" kept for themselves!" }
		}
	},
#	EventType.Religion: {
#		"Description": "The people have found new gods! Perhaps we could use this to our advantage . . .",
#		"Resolves": { "Artist": 50 },
#		"Prompt": false,
#		"Result": {
#			"Success": { "Descritpion": "The people have turned their backs on the preists." },
#			"Failure": { "Description": "The people have accepted the guidance of the gods." }
#		}
#	}
}

var deadWaste = 125000
# maxCapacity = daily * maxPopulation
var ration = {
	# megaCal
	"Food": { "Daily": 2, "Current": 0, "Capacity": 2000 },
	"SolidWaste": { "Daily": .2, "Current": 0, "Capacity": 0 },

	# liter
	"Water": { "Daily": 2, "Current": 0, "Capacity": 2000 },
	"LiquidWaste": { "Daily": 2, "Current": 0, "Capacity": 0 }
}

func _ready():
	for popType in population:
		populationTotal += population[popType]["Current"]

	annualTimer.connect("timeout", self, "newYear")
	annualTimer.wait_time = yearLength
	annualTimer.one_shot = false
	add_child(annualTimer)
	annualTimer.start()

func newYear():
	year += 1
	
	if year % yearsPerGeneration == 0:
		generation += 1

		if generation % generationsPerEpoch == 0:
			epoch += 1

			if epoch == 1:
				checkWin()
				return
	
	if year % yearsPerEvent == 0:
		triggerEvent()

func getPopulation(popType):
	return population[popType]["Current"]

func adjustPopulation(popType, amount):
	population[popType]["Current"] += amount

	if amount < 0:
		ration["SolidWaste"]["Current"] += amount & deadWaste

func endDay():
	for need in ration:
		ration[need]["Current"] += ration[need]["Daily"] * populationTotal

func triggerEvent():
	# build out Event State Machine
	var latestEvent = events.keys()[ randi() % events.size() ]
	currentEvent.push_back(latestEvent)
	
	emit_signal("eventStarted", latestEvent)
		
func checkWin():
	if civilization["ShipIntegrity"] == 0:
		handleFailure("shipIntegrity")
		return

	var currentTotal : int = 0
	var minimumReachedPerRole : bool = true
	for popType in population:
		if population[popType]["Current"] < population[popType]["Minimum"]:
			minimumReachedPerRole = false
		
		currentTotal += population[popType]["Current"]

	if currentTotal > minPopulation && minimumReachedPerRole:
		handleWin()
	else: 
		handleFailure()

func handleWin(prefferedType = null):
	var winTypes = {
		"Religion": { "Condition": civilization["Religion"], "Scene": ""},
		"Insurrection": { "Condition": civilization["HadRebelion"], "Scene": ""},
		"Propaganda": { "Condition": civilization["Propaganda"] > 80, "Scene": ""},
		"Cohesion": { "Condition": civilization["Cohesion"] > 80, "Scene": ""},
		"Diversity": { "Condition": civilization["PhysicalDiversity"] > 50, "Scene": ""},
		"Default": { "Condition": true, "Scene": "" }
	}

	if prefferedType:
		switchScene(winTypes[prefferedType]["Scene"])
	
	for type in winTypes:
		if winTypes[type]["Condition"]:
			switchScene(winTypes[type]["Scene"])

func handleFailure(prefferedReason = null):
	var failureReasons = {
		"Starvation": { "Condition": true, "Scene": ""},
		"Thirst": { "Condition": true, "Scene": ""},
		"Disease": { "Condition": true, "Scene": ""},
		"Invasion": { "Condition": true, "Scene": ""},
		"ShipIntegrity": { "Condition": true, "Scene": ""},
		"Underpopulation": { "Condition": true, "Scene": ""},
		"Default": { "Condition": true, "Scene": "" }
	}
	
	if prefferedReason:
		switchScene(failureReasons[prefferedReason]["Scene"])

	for reason in failureReasons:
		if failureReasons[reason]["Condition"]:
			switchScene(failureReasons[reason]["Scene"])

func switchScene(scene):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
