import json

with open("en_us.json", "r", encoding="utf-8") as f:
    main_json = json.load(f)

with open("zh_cn.json", "r", encoding="utf-8") as f:
    sub_json = json.load(f)

# 插入不存在的键值
for key, value in sub_json.items():
    if key not in main_json:
        main_json[key] = value

# 排序
main_json = dict(sorted(main_json.items()))

# 保存结果
with open("merge.json", "w", encoding="utf-8") as f:
    json.dump(main_json, f, ensure_ascii=False, indent=4)
