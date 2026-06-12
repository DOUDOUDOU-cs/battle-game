# Battle Game 美术风格规范与生成提示词

本文档用于生成一组风格一致的 2D 像素美术资产，目标是让角色、怪物、场景、背景和 UI 看起来属于同一个游戏世界。

推荐使用方式：先复制“统一风格锚点”，再复制具体资产提示词。每次只生成一个资产类别，不要一次要求模型生成所有内容。

---

## 1. 核心方向

### 风格定位

- 横版 2D 像素动作游戏。
- 参考方向：类 Terraria 的清晰像素结构、侧视平台世界、可读性强的角色轮廓。
- 融合中世纪奇幻元素：皮革护具、铁质武器、纹章、石堡、木梁、火把、藤蔓、蘑菇森林、古旧地牢。
- 整体气质：冒险、潮湿森林、旧王国遗迹、轻微黑暗但不恐怖。

### 必须保留

- 必须是 pixel art。
- 必须有清晰像素块感。
- 必须使用有限色板。
- 必须保持横版侧视视角。
- 角色、怪物、地形必须使用同一套光照方向和同一套颜色逻辑。
- 轮廓和阴影必须足够清楚，适合游戏中快速识别。
- 玩家角色本体不要画死具体武器，武器必须作为独立 sprite 生成，方便后续武器系统替换。

### 必须避免

- 避免照片质感。
- 避免 3D 渲染感。
- 避免柔滑厚涂、概念插画、油画、水彩。
- 避免过多渐变和模糊光效。
- 避免现代科幻元素。
- 避免过细线条、过多小噪点、不可读的细节。
- 避免 Q 版过度圆润，也避免写实比例过高。
- 避免把角色、怪物、背景做成不同画风。
- 避免把剑、斧、弓、法杖等武器永久画在玩家身体动画里。

---

## 2. 统一视觉规则

### 分辨率与比例

建议基础规格：

- 主角单帧：`96x96 px` 或 `96x84 px`
- 小型怪物单帧：`64x64 px` 或 `80x64 px`
- 中型怪物单帧：`96x96 px`
- 地形 tile：`16x16 px` 或 `32x32 px`
- 物品图标：`32x32 px`
- UI 图标：`32x32 px`
- 背景图：`384x216 px`、`768x432 px` 或 `1536x864 px`

角色和怪物在游戏内视觉比例：

- 主角高度约等于 2.5 到 3 个 32px tile。
- 小型怪物高度约等于 1.2 到 1.8 个 32px tile。
- 中型怪物高度约等于 2 到 2.5 个 32px tile。
- 武器和攻击动作可以稍微夸张，但不能破坏清晰轮廓。

### 轮廓

- 外轮廓使用深色描边。
- 描边颜色不要纯黑，建议使用深棕、深紫、深蓝灰。
- 轮廓厚度保持一致，通常为 1 到 2 像素。
- 重要部位可以用深色分隔：头盔、肩甲、武器、眼睛、手部。

### 光照

统一光源方向：

- 光源来自左上方。
- 高光在左上边缘。
- 阴影在右下方。
- 脚底和接触地面处要有暗部，避免角色漂浮。

### 玩家与武器拆分规则

为了后续武器系统，玩家角色本体和武器必须分离。

玩家本体可以包含：

- 兜帽、斗篷、皮甲、肩甲、靴子、腰带、背带、空剑鞘。
- 空手握持姿势。
- 明确的手部握点。
- 适合挂载武器的攻击/待机姿势。

玩家本体不能包含：

- 固定在手里的剑。
- 固定在身体动画里的斧、弓、法杖、匕首。
- 固定攻击轨迹或剑气。
- 无法替换的武器外观。

武器应当作为单独 sprite：

- 每把武器独立文件。
- 武器图片围绕统一握点绘制。
- 攻击动画中由代码旋转、平移或切换武器 sprite。
- 初始短剑也是独立武器，不画死在玩家身上。

### 色板

推荐主色板方向：

- 森林绿：苔藓、藤蔓、草地。
- 暖棕：木头、皮革、泥土。
- 石灰灰：古堡、地牢、岩石。
- 暗金：中世纪装饰、UI 边框、纹章。
- 锈红：布料、旗帜、危险提示。
- 暗紫蓝：夜色、阴影、地牢深处。

统一限制：

- 单个角色建议 16 到 32 个主要颜色。
- 单个怪物建议 12 到 24 个主要颜色。
- 地形 tile 每组建议 24 到 40 个主要颜色。
- 背景可以颜色更多，但不要抢过角色和地形。

---

## 3. Gemini 使用守则

Gemini 可能会把像素风格做成“看起来像像素但实际很糊”的插画，所以提示词必须强硬。

每次生成都要强调：

- `strict pixel art`
- `low resolution sprite`
- `hard pixel edges`
- `no anti-aliasing`
- `no painterly rendering`
- `no 3D`
- `limited color palette`
- `side-view 2D platformer game asset`

如果需要透明背景，但模型不能直接输出透明 PNG：

- 让模型使用纯色背景，例如 `solid #ff00ff chroma key background`。
- 角色和怪物主体不能使用该背景颜色。
- 后续再用抠图工具把纯色背景去掉。

强烈建议不要一次说“生成完整游戏素材包”。更好的流程：

1. 先生成主角 idle 单帧。
2. 确认风格。
3. 如果已经有满意的角色概念图，先把它转换成真正可用的低分辨率游戏 sprite。
4. 用同一风格生成主角动作表。
5. 再生成怪物。
6. 最后生成地形、背景和 UI。

---

## 4. 统一风格锚点

下面这段应当复制到每一个具体提示词前面。

```text
Create a strict pixel art asset for a side-view 2D action platformer game.
The art style should feel like a Terraria-inspired pixel game, but with medieval fantasy elements.
Use hard pixel edges, crisp readable silhouettes, limited color palette, clear 1-2 pixel dark outlines, and no painterly blending.
Lighting must come from the upper-left, with shadows on the lower-right.
The world mood is a damp medieval forest ruin: moss, old stone, wood, leather, iron, vines, mushrooms, torches, and ancient kingdom relics.
No photorealism, no 3D render, no vector art, no smooth illustration, no modern objects, no sci-fi elements, no blurry gradients.
Keep all assets visually consistent with the same pixel density, contrast, outline weight, and color palette.
```

---

## 5. 主角提示词

### 5.1 主角设定单帧

用途：先确定主角最终风格。

```text
Create one full-body player character sprite.

Asset type: player character concept sprite
View: side-view 2D platformer, facing right
Canvas: 96x96 pixels
Background: solid #ff00ff chroma key background, no shadow on background

Character:
A young medieval forest adventurer wearing a short dark-green hooded cloak, worn leather armor, small iron shoulder guard, brown boots, belt pouches, and an empty weapon hand ready to hold interchangeable weapons.
The character should feel agile, brave, and slightly rugged, not royal and not overly heroic.
The actual weapon must not be drawn as part of the character body.

Pixel requirements:
Strict pixel art, hard pixel edges, limited palette, readable silhouette, 1-2 pixel dark outline, no anti-aliasing, no painterly shading.
Use upper-left lighting and lower-right shadow.

Avoid:
No anime face detail, no realistic rendering, no 3D, no fixed sword in hand, no oversized weapon, no modern clothing, no glowing neon.
```

### 5.2 从概念图转换为游戏精灵

用途：当你已经有一张满意的角色概念图时，复制这一段给 Gemini，让它把概念图变成真正能进游戏的低分辨率 sprite。

建议：把角色概念图作为参考图上传给 Gemini，然后复制下面提示词。

```text
Use the provided character image as the design reference, but convert it into a game-ready side-view pixel art sprite.

Asset type: player character sprite
Canvas: 96x96 pixels
View: pure side-view 2D platformer view, facing right
Background: solid #ff00ff chroma key background

Keep the same character identity:
Green hooded cloak, brown leather armor, small metal shoulder guard, belt pouches, brown boots, empty weapon hand, medieval forest adventurer.

Important conversion rules:
The reference image is a concept design, not the final sprite scale.
Simplify the small armor straps, face details, belts, and cloth folds so the character remains readable at 96x96 pixels.
Keep the hood, cloak silhouette, leather chest armor, shoulder guard, and hand grip clearly recognizable.
Make the pose suitable for a side-view action platformer idle stance.
Feet must sit on one clear ground baseline.
The body should not be 3/4 view; make it a clean side-view sprite.
Remove any visible sword blade or fixed weapon from the body sprite.
An empty belt sheath, back strap, or weapon loop is allowed, but the actual weapon must be separate.
The weapon hand should be readable as a grip point for interchangeable weapon sprites.

Pixel requirements:
Strict low-resolution pixel art.
Hard square pixel edges.
Limited color palette.
Clear 1-2 pixel dark outline.
Upper-left lighting, lower-right shadow.
No anti-aliasing.
No painterly shading.
No smooth gradients.
No 3D lighting.

Avoid:
No redesigning the character.
No adding new weapons.
No changing the green hooded cloak.
No fixed sword in hand.
No permanent weapon attached to the body.
No oversized anime sword.
No realistic face rendering.
No watermark, no logo, no decorative star mark, no text.
```

### 5.3 从概念图生成 Idle 精灵表

用途：当 96x96 单帧已经满意后，再用这段生成 idle 动作表。

建议：上传“已经转换好的 96x96 单帧 sprite”作为参考图，而不是上传原始大概念图。

```text
Use the provided 96x96 player sprite as the exact design reference.
Create a horizontal idle animation sprite sheet for the same character.

Asset type: player idle animation sprite sheet
Frame count: 6 frames
Frame size: 96x96 pixels
Sheet layout: 6 columns x 1 row
Background: solid #ff00ff chroma key background
View: pure side-view, facing right

Animation:
Subtle breathing idle pose.
The green hood and cloak move slightly.
The empty weapon hand, belt pouch, and leather straps barely move.
Feet must remain grounded on the exact same baseline in every frame.

Consistency:
Do not redesign the character.
Keep the same green hooded cloak, brown leather armor, small metal shoulder guard, belt pouches, brown boots, empty weapon hand, and visible grip point.
Keep the head height, foot position, body proportions, outline thickness, and color palette consistent across all frames.
Do not draw any sword blade or fixed weapon in the body animation.
The hand should remain suitable for attaching separate weapon sprites in-game.

Pixel requirements:
Strict low-resolution pixel art.
Hard square pixel edges.
Limited color palette.
Clear 1-2 pixel dark outline.
No anti-aliasing.
No painterly shading.
No 3D lighting.
No fixed sword in hand, no permanent weapon, no watermark, no logo, no decorative star mark.
```

### 5.4 主角 Idle 精灵表

```text
Create a horizontal sprite sheet for the same medieval forest adventurer player character.

Asset type: player idle animation sprite sheet
Frame count: 6 frames
Frame size: 96x96 pixels
Sheet layout: 6 columns x 1 row
Background: solid #ff00ff chroma key background
View: side-view, facing right

Animation:
Subtle breathing idle pose. Cloak moves slightly. Empty weapon hand and belt pouch barely move. Feet remain grounded in the same position in every frame.

Consistency:
Same exact character design in all frames: dark-green hooded cloak, leather armor, small iron shoulder guard, brown boots, belt pouches, empty weapon hand.
Keep the head height, foot position, body proportions, outline thickness, and color palette consistent across all frames.
Do not draw a fixed sword, axe, bow, staff, or dagger as part of the body sprite.

Pixel requirements:
Strict pixel art, hard pixel edges, no anti-aliasing, no painterly blending, limited palette, upper-left lighting.
```

### 5.5 主角 Run 精灵表

```text
Create a horizontal sprite sheet for the same medieval forest adventurer player character.

Asset type: player run animation sprite sheet
Frame count: 8 frames
Frame size: 96x96 pixels
Sheet layout: 8 columns x 1 row
Background: solid #ff00ff chroma key background
View: side-view, facing right

Animation:
Fast readable side-scrolling run cycle. Cloak trails backward. Boots contact the ground clearly. Empty weapon hand and pouch bounce slightly.
Feet must align to the same ground baseline in every frame.
The weapon hand should stay readable as an empty grip point for a separate weapon sprite.

Consistency:
Same exact character design, same palette, same outline weight, same pixel density as the idle sprite.
Do not draw any fixed weapon in the run animation.

Avoid:
No motion blur, no smeared painterly limbs, no inconsistent armor, no fixed sword, no changing weapon shape.
```

### 5.6 主角 Attack 身体动作表

```text
Create a horizontal sprite sheet for the same medieval forest adventurer player character.

Asset type: player attack body animation sprite sheet
Frame count: 6 frames
Frame size: 96x96 pixels
Sheet layout: 6 columns x 1 row
Background: solid #ff00ff chroma key background
View: side-view, facing right

Animation:
A weapon-swing body motion without drawing the weapon itself. The character shifts weight, raises the empty weapon hand, swings through, and recovers.
The pose should be dynamic but readable.
Feet stay near the same ground baseline.
The hand must clearly show the grip point where a separate weapon sprite can be attached in-game.

Consistency:
Same character design and same medieval forest palette as idle and run.
Do not draw a sword blade, axe head, bow, staff, dagger, weapon trail, or slash effect in the body animation.

Avoid:
No fixed sword in hand, no huge anime slash effect, no bright neon, no 3D weapon trail, no camera perspective change.
```

### 5.7 主角 Hurt / Death

```text
Create a horizontal sprite sheet for the same medieval forest adventurer player character.

Asset type: player hurt and death animation sprite sheet
Frame count: 8 frames
Frame size: 96x96 pixels
Sheet layout: 8 columns x 1 row
Background: solid #ff00ff chroma key background
View: side-view, facing right

Animation:
Frames 1-3: hurt recoil, body leans backward, cloak flips slightly.
Frames 4-8: fall and collapse onto the ground, readable but not gory.
No weapon should be drawn as part of the body.

Consistency:
Same exact outfit, same palette, same outline, same pixel density.

Avoid:
No blood splash, no realistic gore, no dramatic illustration lighting.
```

### 5.8 初始短剑武器 Sprite

用途：初始武器单独生成，不画在角色身体里。

```text
Create a separate pixel art weapon sprite for a side-view 2D medieval forest platformer.

Asset type: starting short sword weapon sprite
Canvas: 48x48 pixels
Background: solid #ff00ff chroma key background
View: side-view weapon, angled slightly from lower-left grip to upper-right blade

Weapon:
A simple medieval short sword for a forest adventurer. Iron blade, small worn crossguard, brown leather grip, slightly old but reliable.

Important:
The weapon must be separate from the player body.
Place the grip near the lower-left area so it can be attached to the player's hand pivot.
Keep the silhouette readable at small size.

Style:
Strict pixel art, hard square pixel edges, limited palette, 1-2 pixel dark outline, upper-left lighting.

Avoid:
No hand holding it, no character body, no slash effect, no glow, no 3D render, no watermark, no text.
```

### 5.9 可替换武器组

用途：后续武器系统的基础武器包。

```text
Create a pixel art weapon sprite sheet for a side-view 2D medieval forest platformer.

Asset type: interchangeable weapon sprite sheet
Frame size: 48x48 pixels
Sheet layout: 6 columns x 1 row
Background: solid #ff00ff chroma key background

Weapons, one per frame:
1. worn iron short sword
2. small forest axe
3. rusty dagger
4. wooden hunter bow
5. apprentice oak staff
6. heavy iron mace

Important:
All weapons must be separate from the player body.
All weapons must share a consistent grip anchor point near the lower-left of each 48x48 frame.
Keep scale consistent so they can be attached to the same player hand pivot.

Style:
Strict pixel art, hard square pixel edges, limited palette, 1-2 pixel dark outline, medieval forest fantasy palette, upper-left lighting.

Avoid:
No hands, no character body, no attack trails, no glow effects, no 3D, no text, no watermark.
```

---

## 6. 怪物提示词

### 6.1 蘑菇怪

```text
Create a strict pixel art mushroom monster for a side-view 2D medieval forest platformer.

Asset type: enemy character sprite
Canvas: 80x64 pixels
Background: solid #ff00ff chroma key background
View: side-view, facing left

Monster:
A hostile walking mushroom creature from a damp medieval forest ruin. Large cap with mossy spots, small angry eyes, stubby legs, root-like arms, slightly rotten texture, but still cute enough for an action platformer.

Style:
Terraria-inspired pixel art, medieval fantasy forest palette, dark outline, upper-left lighting, lower-right shadow, readable silhouette.

Avoid:
No realistic mushroom photo texture, no horror gore, no 3D, no smooth painting, no excessive tiny details.
```

### 6.2 蘑菇怪动作表

```text
Create a horizontal sprite sheet for the same mushroom monster.

Asset type: mushroom enemy animation sprite sheet
Frame size: 80x64 pixels
Sheet layout: 32 frames total in one horizontal row
Background: solid #ff00ff chroma key background
View: side-view, facing left

Frame groups:
Frames 1-6: idle bounce
Frames 7-14: walk cycle
Frames 15-22: attack bite or headbutt
Frames 23-26: hit reaction
Frames 27-32: death collapse into spores

Consistency:
Same monster design, same size, same ground baseline, same palette, same outline weight in every frame.

Avoid:
No motion blur, no changing cap shape between frames, no inconsistent lighting.
```

### 6.3 史莱姆怪

```text
Create a strict pixel art slime enemy for a side-view 2D medieval forest platformer.

Asset type: slime enemy sprite
Canvas: 64x64 pixels
Background: solid #ff00ff chroma key background
View: side-view

Monster:
A green-blue forest slime with a small medieval relic trapped inside its body, such as a rusty coin, tiny broken arrowhead, or old bronze buckle.
It should look bouncy and magical but still belong in a mossy medieval ruin.

Style:
Terraria-inspired pixel art, hard pixel edges, limited palette, dark outline, upper-left lighting, no smooth transparency-heavy rendering.

Important:
Use only simple pixel highlights. Do not make it look like a glossy 3D blob.
```

### 6.4 史莱姆动作表

```text
Create a horizontal sprite sheet for the same forest slime enemy.

Asset type: slime enemy animation sprite sheet
Frame size: 64x64 pixels
Sheet layout: 36 frames total in one horizontal row
Background: solid #ff00ff chroma key background
View: side-view

Frame groups:
Frames 1-8: idle wobble
Frames 9-18: hop or wiggle movement
Frames 19-26: attack stretch
Frames 27-30: hit squish
Frames 31-36: death splat into small harmless pixels

Consistency:
Same slime shape language, same relic inside, same palette, same ground baseline.

Avoid:
No liquid realism, no high-resolution gel texture, no 3D shader look, no excessive transparency effects.
```

---

## 7. 地形与 Tileset 提示词

### 7.1 森林地表 Tileset

```text
Create a pixel art tileset for a side-view medieval forest platformer.

Asset type: terrain tileset
Tile size: 32x32 pixels
Sheet layout: 8 columns x 6 rows
Background: transparent if possible, otherwise solid #ff00ff chroma key background

Theme:
Mossy forest ground with medieval ruin influence. Grass top tiles, dirt fill, stone blocks, cracked stone edges, roots, vines, small mushrooms, and old carved brick fragments.

Required tiles:
Top-left corner, top surface, top-right corner,
left wall, dirt fill, right wall,
bottom-left corner, bottom edge, bottom-right corner,
single floating platform left cap, center, right cap,
stone block variants, cracked stone, mossy stone, vine overlay, small decorative mushrooms.

Style:
Terraria-inspired pixel art, crisp 32x32 tiles, limited palette, upper-left lighting, no painterly blending.

Important:
Tiles must connect cleanly with no visible seams.
Each tile must be grid-aligned and same pixel density.
```

### 7.2 地牢 Tileset

```text
Create a pixel art dungeon tileset for a side-view medieval fantasy platformer.

Asset type: dungeon tileset
Tile size: 32x32 pixels
Sheet layout: 8 columns x 6 rows
Background: transparent if possible, otherwise solid #ff00ff chroma key background

Theme:
Old medieval stone dungeon under a forest ruin. Mossy stone bricks, cracked blocks, dark mortar, iron rings, torch holders, worn steps, broken arch fragments.

Required tiles:
Stone floor top, left wall, right wall, fill block, corners, underside, cracked variants, moss variants, arch edge, small torch decoration, iron chain decoration.

Style:
Strict pixel art, limited palette, readable tile shapes, upper-left lighting, dark lower-right shadows.

Avoid:
No realistic stone photo texture, no smooth 3D bricks, no non-grid perspective.
```

---

## 8. 背景与场景提示词

### 8.1 远景森林背景

```text
Create a pixel art background for a side-view medieval forest platformer.

Asset type: parallax far background
Canvas: 1536x864 pixels
View: side-view landscape

Scene:
A damp ancient forest with distant dark green trees, misty blue-gray depth, old medieval stone tower silhouettes, broken castle arches, hanging vines, and faint warm torch lights in the distance.

Style:
Terraria-inspired pixel art background, limited palette, clear pixel clusters, no painterly brushwork, no photorealism.

Composition:
Leave the lower 35 percent less busy so gameplay platforms and characters remain readable.
Use atmospheric depth but keep hard pixel edges.

Avoid:
No giant foreground character, no UI, no text, no modern buildings, no smooth digital painting.
```

### 8.2 中景森林废墟层

```text
Create a pixel art parallax midground layer for a side-view medieval forest platformer.

Asset type: parallax midground layer
Canvas: 1536x432 pixels
Background: transparent if possible, otherwise solid #ff00ff chroma key background

Scene:
Mossy tree trunks, hanging vines, broken medieval stone walls, small ruined arches, wooden fence fragments, mushrooms, and roots.

Style:
Strict pixel art, Terraria-inspired, medieval forest ruin, limited palette, hard pixel edges.

Composition:
Objects should be spread horizontally for parallax scrolling. Do not fill the entire image with solid blocks. Leave transparent gaps.

Avoid:
No playable platforms in this layer, no characters, no UI, no text.
```

### 8.3 前景装饰层

```text
Create a pixel art foreground decoration strip for a side-view medieval forest platformer.

Asset type: foreground decoration layer
Canvas: 1536x256 pixels
Background: transparent if possible, otherwise solid #ff00ff chroma key background

Scene:
Dark silhouettes of grass, hanging vines, roots, small leaves, broken wooden stakes, and low stone fragments.

Style:
Strict pixel art, dark foreground colors, same medieval forest palette.

Purpose:
This layer will sit in front of gameplay to add depth, so it must be sparse and not hide the player.

Avoid:
No large opaque blocks, no bright colors, no characters, no text.
```

---

## 9. 物品与掉落提示词

### 9.1 蘑菇材料

```text
Create a pixel art item icon.

Asset type: inventory item icon
Canvas: 32x32 pixels
Background: transparent if possible, otherwise solid #ff00ff chroma key background

Item:
A small glowing forest mushroom cap material, harvested from a mushroom monster. Medieval fantasy forest style, mossy red-brown cap, pale underside, tiny golden spores.

Style:
Strict pixel art, readable at 32x32, dark outline, limited palette, upper-left lighting.

Avoid:
No realistic mushroom photo, no 3D render, no smooth illustration.
```

### 9.2 史莱姆凝胶

```text
Create a pixel art item icon.

Asset type: inventory item icon
Canvas: 32x32 pixels
Background: transparent if possible, otherwise solid #ff00ff chroma key background

Item:
A small green-blue slime gel drop with a tiny medieval bronze speck inside. It should look magical but still pixelated.

Style:
Strict pixel art, readable at 32x32, simple highlights, dark outline, limited palette.

Avoid:
No glossy 3D gel, no realistic liquid, no excessive transparency.
```

---

## 10. UI 提示词

### 10.1 HUD 框

```text
Create a pixel art HUD frame for a medieval forest action platformer.

Asset type: UI HUD frame
Canvas: 256x96 pixels
Background: transparent if possible, otherwise solid #ff00ff chroma key background

Design:
A compact medieval fantasy UI frame made from dark carved wood, mossy vines, small iron corners, and subtle worn gold trim.
It should hold a player portrait and health bar.

Style:
Strict pixel art, crisp edges, limited palette, no smooth gradients, no 3D bevels.

Avoid:
No text, no numbers, no modern UI, no glossy mobile-game style.
```

### 10.2 背包格子

```text
Create a pixel art inventory slot UI tile.

Asset type: inventory UI slot
Canvas: 64x64 pixels
Background: transparent if possible, otherwise solid #ff00ff chroma key background

Design:
A medieval forest inventory slot made of dark wood, iron corner nails, mossy vine details, and subtle worn gold rim.
The center should be dark and empty for item icons.

Style:
Strict pixel art, crisp 1-2 pixel outline, limited palette, readable border.

Variants:
Normal slot, selected slot, crafting slot.

Avoid:
No text, no glossy gradients, no modern rounded app button style.
```

---

## 11. 生成顺序建议

推荐顺序：

1. 主角设定单帧。
2. 如果已有满意概念图，用“5.2 从概念图转换为游戏精灵”生成 96x96 单帧。
3. 用“5.3 从概念图生成 Idle 精灵表”生成 idle 动作。
4. 主角 run / attack body / hurt death，注意身体动画不要包含固定武器。
5. 初始短剑和可替换武器组。
6. 蘑菇怪单帧。
7. 蘑菇怪动作表。
8. 史莱姆单帧。
9. 史莱姆动作表。
10. 森林地表 tileset。
11. 地牢 tileset。
12. 远景背景。
13. 中景层和前景层。
14. 物品图标。
15. UI 框和背包格子。

每一步都应当用上同一段“统一风格锚点”。

---

## 12. 质量检查清单

生成后检查：

- 是否仍然是清晰 pixel art？
- 是否出现了柔滑插画或 3D 渲染感？
- 角色和怪物脚底是否能对齐地面？
- 光源是否统一来自左上？
- 外轮廓厚度是否一致？
- 色板是否像同一个世界？
- 角色、怪物和地形放在一起时，是否像同一个图层？
- 背景是否太抢眼，影响角色可读性？
- sprite sheet 的每一帧尺寸是否一致？
- sprite sheet 的每一帧地面基线是否一致？
- 玩家身体动画是否没有画死固定武器？
- 武器 sprite 是否有统一握点，能挂到玩家手上？
- 是否有多余文字、水印或现代元素？

如果不合格，优先重新生成，不要强行塞进项目。

---

## 13. 给 Gemini 的强制短句

当 Gemini 开始跑偏时，把下面短句追加到提示词末尾：

```text
Important correction:
This must be actual game-ready pixel art, not a pixel-art-inspired illustration.
Use hard square pixels, no soft brush, no anti-aliasing, no 3D lighting, no realistic material rendering.
Keep the asset clean, grid-aligned, readable at small size, and consistent with a Terraria-like medieval fantasy platformer.
Do not change the requested frame count, frame size, sheet layout, camera view, or background color.
```
