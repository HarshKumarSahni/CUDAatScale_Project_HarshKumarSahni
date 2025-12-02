# scripts/generate_data.py
import os
from PIL import Image, ImageDraw, ImageFont
import random
import math

OUT = "data_in"
os.makedirs(OUT, exist_ok=True)

def make_ppm(path, w=256, h=256, seed=0):
    random.seed(seed)
    img = Image.new("RGB", (w,h))
    draw = ImageDraw.Draw(img)
    for y in range(h):
        for x in range(w):
            r = (x * 255) // w
            g = (y * 255) // h
            b = (int(127 + 127*math.sin((x+y+seed)/10.0)) ) & 255
            img.putpixel((x,y), (r,g,b))
    # Write PPM binary
    with open(path, "wb") as f:
        f.write(b"P6\n%d %d\n255\n" % (w,h))
        f.write(img.tobytes())

if __name__ == "__main__":
    count = 300   # generate 300 images for scale test
    os.makedirs(OUT, exist_ok=True)
    for i in range(count):
        p = os.path.join(OUT, f"img_{i:04d}.ppm")
        make_ppm(p, w=256, h=256, seed=i)
    print("Generated", count, "images in", OUT)
