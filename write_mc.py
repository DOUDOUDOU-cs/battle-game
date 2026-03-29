path = r'C:\Users\38389\Documents\battle-game\scripts\inventory_ui.gd'
with open(path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

keep_top = lines[:143]
keep_bottom = lines[169:]

new_sec = []
def L(s):
    new_sec.append(s + '\n')

L('var _sel_item : ItemData = null')
L('var _sel_src  : String = ""')
L('var _sel_idx  : int = -1')
L('')
L('var _drag_active    : bool       = false')
L('var _drag_slots     : Array      = []')
L('var _drag_origin    : Dictionary = {}')
L('')
L('var _last_click_time : float      = -1.0')
L('var _last_click_slot : Dictionary = {}')
L('const DOUBLE_CLICK_SEC := 0.35')
L('')
L('')
L('func _ready() -> void:')
L('\tlayer = 10')
L('\tprocess_mode = Node.PROCESS_MODE_ALWAYS')
L('\t_vp = get_viewport().get_visible_rect().size')
L('\t_build_hotbar()')
L('\t_build_bag()')
L('\t_build_drag_icon()')
L('\tInventory.inventory_changed.connect(_refresh)')
L('\t_refresh()')
L('')
L('')
