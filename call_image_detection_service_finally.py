
#This code can generate Figure 1a and 1b.
#Using the developed model, outline the animal's weight, and further refine the animal's contour manually using Labelme


import requests,sys
import json
import os

path = []

def file_name_find(file_dir):
    for root,dirs,files in os.walk(file_dir):
        for onefile in files:
            if onefile.endswith('.JPG'):
                path.append(str(onefile))
address = "F:/sheep/1101" #Change the file path
file_name_find(address)

print(path)
# RPC 
# url = 'http://218.202.104.82:5806/picService'
url = 'http://218.202.104.82:5806/image_detection_service'
# url = 'http://218.202.104.82:5806'


basepath = os.path.dirname(os.path.abspath(__file__))  # 获取脚本路径
for name in path:

    #上传图像文件名
    upload_image_path = name

    #输出json文件名
    export_path_json=name.split('.')[0]+'.json'

    if not os.path.exists(upload_image_path):
        print("File does not exist, upload_image_path:" + upload_image_path)
    files = {'file': open(upload_image_path, 'rb')}

    response = requests.post(url, files=files)
    print(response.text)

    #读取自动识别结果的json数据，并写入json文件
    json_data=json.loads(response.text)

    if  json_data['shapes'] != []:
        with open(export_path_json, 'w') as writer:
            json.dump(json_data, writer,ensure_ascii=False, indent=2)
            print("json file saved:",export_path_json)