path = r'C:\Users\38389\Documents\battle-game\scripts\inventory_ui.gd'
with open(path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Remove lines 168-199 (0-indexed 167-198) which are the first (stale) _build_hotbar duplicate
# These were inserted by the previous session and are now duplicated
del lines[167:199]

with open(path, 'w', encoding='utf-8') as f:
    f.writelines(lines)
print('done, total lines:', len(lines))
