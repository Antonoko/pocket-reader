import os
import subprocess
import json
import datetime
import shutil
from typing import Literal
import pandas as pd
from openpyxl import Workbook
from openpyxl.utils.dataframe import dataframe_to_rows

MAX_CHAR_PER_TXT = 30000

# PRT: pocket reader text
def print_title():
    clear_screen()
    print("""

    Pocket Reader 是一款运行在 playdate® 上的中文阅读器。

    本工具可以将 txt 转换为支持阅读的 .PRT 文件（可以先使用 calibre 将电子书转为 txt）
    接着通过以下步骤导入到 playdate®：

    1. 将 playdate® 设置为“数据传输模式”：
        Settings → System → Reboot to Data Disk → 通过数据线连接到电脑上

    2. 将转换完成的 json 文件放于 Data/com.haru.pocketreader 中
          
    3. 退出“数据传输模式”，打开 Pocket Reader 即可阅读

    -------------------------------------------------------------------
""")
    
def clear_screen():
    os.system('cls' if os.name == 'nt' else 'clear')

def press_any_key_to_continue():
    input("\n按任意键继续...")


def save_dict_as_json_to_path(data: dict, filepath):
    """将 dict 保存到 json"""
    with open(filepath, "w", encoding="utf-8") as f:
        json.dump(data, f)


def read_json_as_dict_from_path(filepath):
    """从 json 读取 dict"""
    if not os.path.exists(filepath):
        return None

    with open(filepath, "r", encoding="utf-8") as f:
        data = json.load(f)
    return data


def turn_str_lst(str:str):
    lst = []
    str = str.replace("\\n", "嚻")
    for i in str:
        lst.append(i)

    lst2 = []
    for i in lst:
        if i == "嚻":
            lst2.append("\\n")
        else:
            lst2.append(i)
    return lst2

# --------------------------------------------------------------------------------------

def json_to_xls():
    while(True):
        print_title()
        print(f"""
        请将 txt 文件拖入到窗口中，然后回车确认：
        （超过 {MAX_CHAR_PER_TXT} 字将会自动拆分为多个文件）
            
        """)
        input_txt_filepath = input("> ").strip('\"')
        if not os.path.exists(input_txt_filepath):
            print("""
            似乎文件不存在……
""")
            print(input_txt_filepath)
            press_any_key_to_continue()
        elif not input_txt_filepath.endswith(".txt"):
            print("""
            似乎文件不是 txt 格式。
""")
            press_any_key_to_continue()
        else:
            break
    

    try:
        with open(input_txt_filepath, 'r', encoding='utf-8') as file:  
            text = file.read()
        if len(text) == 0:
            print("""
            似乎文本为空。
""")
            raise FileNotFoundError
        
        counter = 0
        counter_file = 1
        convert_json = {
            "text":[]
        }
        saved_name_lst = []
        last_char = ""

        for char in text:
            convert_json["text"].append(char)
            counter += 1
            if counter > MAX_CHAR_PER_TXT:
                saved_name = os.path.basename(input_txt_filepath).split(".")[0] + "_" + str(counter_file) + ".PRT"
                save_dict_as_json_to_path(convert_json, saved_name)
                saved_name_lst.append(saved_name)
                counter_file += 1
                counter = 0
                convert_json = {
                    "text":[]
                }
        
        if counter_file > 1:
            saved_name = os.path.basename(input_txt_filepath).split(".")[0] + "_" + str(counter_file) + ".PRT"
        else:
            saved_name = os.path.basename(input_txt_filepath).split(".")[0] + ".PRT"
        save_dict_as_json_to_path(convert_json, saved_name)
        saved_name_lst.append(saved_name)

        print(f"""

            转换完成！请查看目录下的文件:
""")
        for i in saved_name_lst:
            print(f"            - {i}")
    except Exception as e:
        print(f"转换似乎失败了，报错原因：{e}")
    
    press_any_key_to_continue()


if __name__ == "__main__":
    while(True):
        json_to_xls()