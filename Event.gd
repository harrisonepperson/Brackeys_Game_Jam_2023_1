extends Area2D

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

export(Texture) var texture

export(EventType) var eventType = EventType.Famine

var eventActive = false
var resolves

signal eventDone

# Called when the node enters the scene tree for the first time.
func _ready():
	resolves = $"/root/Stats".events[eventType]["Resolves"]
	$"/root/Stats".connect("eventStarted", self, "onEventStart")
	connect("eventDone", get_parent().get_parent(), "onEventEnd")
	
	if texture:
		$Sprite.texture = texture
		$Sprite.offset = position * -1

func onEventStart(event):
	if event == eventType:
		resolves = [] + $"/root/Stats".events[eventType]["Resolves"]
		eventActive =true
		visible = true

func _on_Event_body_entered(body):
	if eventActive && resolves.has(body.CharacterType.keys()[body.characterType]):
		resolves.erase(body.CharacterType.keys()[body.characterType])
	
	if eventActive && resolves.size() == 0:
		emit_signal("eventDone")
		eventActive = false
		visible = false
