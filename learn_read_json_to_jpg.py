#The images processed again with Labelme can be used to identify the animal's weight through an algorithm, and the results can be output in jpg format


import json
import os
import numpy as np
from PIL import Image, ImageDraw ,ImageFont

def annotate_image(json_file, image_file):
    with open(json_file, 'r') as f:
        data = json.load(f)

    image = Image.open(image_file)
    draw = ImageDraw.Draw(image)
    for shape in data["shapes"]:
        points = shape["points"]
        animal_class = shape["label"]
        xmin, ymin = np.amin(points, axis=0)
        xmax, ymax = np.amax(points, axis=0)
        head_body_length = get_head_body_length(xmax, xmin, ymax, ymin)
        animal_weight = get_animal_weight(animal_class, head_body_length)

        formatted_points = [(point[0], point[1]) for point in points]
        # Draw polygon with a thicker outline for better visibility
        draw.polygon(formatted_points, outline="black", fill=None, width=3)

        # Annotate with head_body_length and animal_weight in a larger font for better readability
        font_path = "C:/Windows/Fonts/times.ttf"  # 根据实际路径修改
        font = ImageFont.truetype(font_path, size=45)  # 调整为合适的字体大小
        text = f"{animal_class.capitalize()} : {animal_weight:.2f} kg"
        draw.text((xmin-90, ymin-40), text, fill="black" , font=font)

    return image

def get_head_body_length(xmax, xmin, ymax, ymin):
    head_body_length_in_pixel = np.sqrt((xmax - xmin) ** 2 + (ymax - ymin) ** 2)
    flight_height = 100
    ground_sampling_distance = 0.00027412 * flight_height
    return ground_sampling_distance * head_body_length_in_pixel

def get_animal_weight(animal_class, head_body_length):
    if animal_class == "cattle":
        animal_weight = 376.5 * head_body_length - 454.09
        return max(animal_weight, 100)
    elif animal_class == "sheep":
        animal_weight = 55.523 * head_body_length - 34.042
        return max(animal_weight, 15)
    return 0

def main(json_path, image_path):
    
    annotated_image = annotate_image(json_path, image_path)
    annotated_image.save(f"annotated_{image_path}")
    print(f"Annotated image saved as: annotated_{image_path}")

if __name__ == "__main__":
    json_path =  "F:/sheep/json/new_cattle.json"
    image_dir =  "cattle.JPG"  # Update this path to your images directory
    main(json_path, image_dir)
