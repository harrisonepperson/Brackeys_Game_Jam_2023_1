extends Sprite

export(GradientTexture2D) var skinTone
export(GradientTexture2D) var eyeColor

var rng = RandomNumberGenerator.new()

func generate_image(colors):
	var swap = Image.new();
	swap.create(colors.size(), 1, false, Image.FORMAT_RGBA8);
	
	for i in range(0, colors.size()):
		var color = colors[i];
		swap.lock()
		swap.set_pixel(i, 0, color)
		swap.unlock()
		
	var texture = ImageTexture.new()
	texture.create_from_image(swap, 0);
	
	return texture;

func convertRange(OldValue, OldMax, OldMin, NewMax, NewMin):
	var OldRange = (OldMax - OldMin)  
	var NewRange = (NewMax - NewMin)  
	var NewValue = (((OldValue - OldMin) * NewRange) / OldRange) + NewMin
	return NewValue

func getOffsetFromDiversity():
	var diversityRange = 15
	
	var diversity = convertRange(Stats.civilization['PhysicalDiversity'], 100, 0, 100, 50)
	var newValue = clamp(diversity + rng.randi_range(-diversityRange, diversityRange), 0, 100)

	var countBackward = rng.randi_range(0, 1)

	if (countBackward == 0):
		return (100 - newValue) / 100.0

	return newValue / 100.0

func generate_palettes():
	var swaps = [
		Color.red,
		Color.green,
	]
	
	var withs = [
		skinTone.gradient.interpolate(getOffsetFromDiversity()),
		eyeColor.gradient.interpolate(getOffsetFromDiversity()),
	]
	
	set_shader("palette_swap", generate_image(swaps))
	set_shader("palette_with", generate_image(withs))
	
func set_shader(param, value, silent = true):
	var mat = get_material().duplicate()
	mat.set_shader_param(param, value)
	set_material(mat)

func init_shader():
	set_shader("sprite_size", get_rect().size, false)
	set_shader("global_transform", get_global_transform())

func _ready():
	rng.randomize()
	generate_palettes()
	init_shader()
	
	var CharacterType = $"../..".CharacterType;
	var characterType = $"../..".characterType;
	
	if characterType == CharacterType.Artist:
		$Hat.texture = load("res://Character/Artist.png")
	if characterType == CharacterType.Captain:
		$Hat.texture = load("res://Character/Captain.png")
	if characterType == CharacterType.Child:
		pass
	if characterType == CharacterType.Compost:
		$Hat.texture = load("res://Character/Compost.png")
	if characterType == CharacterType.Engineer:
		$Hat.texture = load("res://Character/Engineer.png")
	if characterType == CharacterType.Farmer:
		$Hat.texture = load("res://Character/Farmer.png")
	if characterType == CharacterType.Fighter:
		$Hat.texture = load("res://Character/Fighter.png")
	if characterType == CharacterType.Medic:
		$Hat.texture = load("res://Character/Medic.png")
	if characterType == CharacterType.Pilot:
		$Hat.texture = load("res://Character/Pilot.png")
	if characterType == CharacterType.Priest:
		$Hat.texture = load("res://Character/Priest.png")
	if characterType == CharacterType.Teacher:
		$Hat.texture = load("res://Character/Teacher.png")

func _process(delta):
	set_shader("global_transform", get_global_transform())
