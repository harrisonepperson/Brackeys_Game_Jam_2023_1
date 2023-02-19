shader_type canvas_item;

uniform highp vec2 mask_position;
uniform highp vec2 mask_size;
uniform highp vec2 sprite_size;

uniform mat4 global_transform;

uniform sampler2D palette_swap : hint_albedo;
uniform sampler2D palette_with : hint_albedo;
uniform sampler2D palette_swap_mask : hint_white;
uniform sampler2D palette_swap_with : hint_white;

int size(sampler2D tex) {
	return int(textureSize(tex, 0).x);
}

vec4 lookupPaletteSwap(sampler2D swap, sampler2D with, vec4 currcol, vec2 TEXTURE_PIXEL_SIZE_yo) {
	for (int i = 0; i < size(swap); i++) {
		vec2 lookup = vec2(float(i) / float(size(swap)), 0.0);
		vec4 color = texture(swap, lookup);
		vec4 rcolor = texture(with, lookup);
		
		if (currcol == color) {
			return rcolor;
		}
	}
	
	return currcol;
}

void fragment() {
	vec4 currcol = lookupPaletteSwap(palette_swap, palette_with, texture(TEXTURE, UV), TEXTURE_PIXEL_SIZE);
	
	vec2 origin = vec2(global_transform[3][0], global_transform[3][1]) - sprite_size;
	
	vec2 rect1Pos = (origin + mask_position) * SCREEN_PIXEL_SIZE;
	vec2 rect1Size = mask_size * SCREEN_PIXEL_SIZE;

	vec2 normUV = vec2(SCREEN_UV.x, 1.0-SCREEN_UV.y);
	
	if (normUV.x > rect1Pos.x && normUV.x < (rect1Pos + rect1Size).x) {
		if (normUV.y > rect1Pos.y && normUV.y < (rect1Pos + rect1Size).y) {
			currcol = lookupPaletteSwap(palette_swap_mask, palette_swap_with, texture(TEXTURE, UV), TEXTURE_PIXEL_SIZE);
		}
	}
	
	COLOR = currcol;
}