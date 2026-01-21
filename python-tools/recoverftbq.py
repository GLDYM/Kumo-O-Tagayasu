import os
import json

# 路径配置
snbt_folder = "./chapters"
translation_json_path = "./zh_cn.json"
output_folder = "./chapters_original"

# 加载翻译字典
with open(translation_json_path, "r", encoding="utf-8") as f:
    translations = json.load(f)

# 确保输出目录存在
os.makedirs(output_folder, exist_ok=True)

# 遍历文件夹中的 SNBT 文件
for filename in os.listdir(snbt_folder):
    if filename.endswith(".snbt"):
        input_path = os.path.join(snbt_folder, filename)
        output_path = os.path.join(output_folder, filename)

        # 读取 SNBT 文件内容
        with open(input_path, "r", encoding="utf-8") as f:
            content = f.read()

        # 替换翻译键
        for key, value in translations.items():
            # 简单替换：如果 SNBT 中有这个键，就替换成翻译值
            content = content.replace('{' + key + '}', value)

        # 写入输出文件
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(content)

print("翻译完成，结果已输出到:", output_folder)
