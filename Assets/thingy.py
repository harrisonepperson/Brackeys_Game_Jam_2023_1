from PIL import Image

img = Image.open("skin.png")

max_colors = 10000

print(img.getcolors(max_colors))