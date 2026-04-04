import PIL.Image
import PIL.ImageDraw

def create_square(filename, color):
    img = PIL.Image.new('RGBA', (64, 64), (0, 0, 0, 0))
    draw = PIL.ImageDraw.Draw(img)
    draw.rectangle([0, 0, 63, 63], fill=color)
    img.save(filename)

create_square('assets/images/head.png', (0, 255, 0, 255))
create_square('assets/images/body.png', (0, 200, 0, 255))
create_square('assets/images/food.png', (255, 0, 0, 255))
