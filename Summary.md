# 赛后总结

## 项目构建

- 不得不说，使用各家的启动器来制作整合包还是过于繁琐了，
- packwiz 这种基于现代编程项目管理的整合包软件应该更合适。

## 模组

### 去除

- NeoKuayue
  - 现在模组还不是很完善，1.20.1 的流程缺失比较多，有奇怪的 Bug 和潜在的性能问题
  - 说实话不是很搭
  - 在实际游玩中，车头的构建非常复杂
- Always Eat
  - 很多类似胡萝卜的作物会因此难以种植，而且烹饪锅的奖励与之功能重复了
- Inventory Profile Next
  - 在大量物品整理的场景下经常卡死。
- Par cool
  - 难用。
- Ore Excavation
  - 现在基本用 FTB Ultimine 替代了，有可视化，能动态修改配置
- Biome Makeover
  - 停更了，并且与其他模组都没啥关联
- Scorched Guns
  - 使用率非常低，不如铁魔法
- The Outer End
  - 也是和其他模组八竿子打不着。
- Caupona
  - 分茶三个方向的完成率都不是很高。

- Earth Mobs
  - 比较鸡肋，部分生物可以提供一些量产途径，但是总体的使用率不是很高



### 可选

- Create: Balanced Flight (Angel Ring)
  - 提供了另一种飞行的方式
  - 配方需要改得更贵，最好与l2的五大锭相关
  
- Carry on
  - 搬一些生物方便不少，在厨房用也更符合实际
  - 不过潜在的 bug 比较多，还是要谨慎
  - 可以搬的东西需要去掉铁魔法的炼药锅，在 `/src/overrides/config/carryon-common.toml`的`black.forbiddenTiles` 加上 `irons_spellbooks:alchemist_cauldron`
  
- Ultramarine
  - 模组本身不错，就是比较吃玩家本身的建筑水平
  
- When Dungeons Arise
  - 前期怪强适合摸金完成原始积累，后期基本无用
  - 本身没什么性能问题，算是补充
  
- FTB Essentials
  - 服务器用的传送，因为有 FTBQ 就用这个了
  
- Trade Refresh
  - 刷村民附魔书用，后期用处不大
  
- Tweakerge/Forgematica/Curtain
  - 生电用模组
  
- AllMusic/Simple Voice Chat/Chat Image/Sakura Sign
  - 服务器保留项目，单人不需要
  
- Exposure/Exposure Catalog
  - 步骤有点繁琐，看个人喜好
  
- Village Spawn Point
  - 单人比较好使，但是服务器会提升卡顿
  
- Advancement Plaques
  - 需要双端，不敢恭维
  
- Water Frames
  - 需要 WebDAV 服务器，放视频要求有点高
  - 和 Immersive Paintings 互换
  
- FTB Backup 2
  - 同样单人好用，服务器难使
  
- Create: Pattern Schematics
  - 同样火车用的，但是没什么人会用



### 保留

- Create: Crystal Clear / Create Misc and things
  - 火车机器的外饰
  - [c0nnor263/Crystal-Clear-Arch at mc1.20.1/6.0.4-c0nnor263](https://github.com/c0nnor263/Crystal-Clear-Arch/tree/mc1.20.1/6.0.4-c0nnor263)
- Create: Enchantment Industry
  - 提供经验和各种附魔书相关的自动化，并减轻 l2 的压力
- Create: More Drill Heads
  - 在矿机上的应用并不高，但是在开火车隧道上意外得多
  - 相较于 1.19.2 的版本，1.20.1 的版本稳定不少
  - [MinecraftDevCompilation/CreateMoreDrillHeads](https://github.com/MinecraftDevCompilation/CreateMoreDrillHeads/tree/forge/1.20.1)
- Create Liquid Fuel
  - 和无限岩浆配合烧岩浆

- Create halitosis
  - 提供龙息的配方，也可以写到 Caged mobs 里面
- Explorers Compass
  - 直接找结构用，降低服务器的跑图压力
  - 经过优化后性能优化了不少
  - 当然配方要改 `src/overrides/config/openloader/data/tsng5_datapack/data/explorerscompass/recipes`
- Appleskin
- **Full Grown Crop Marker**
  - 作物种类一多，看哪些作物成熟就比较头疼；
  - 这个模组能直观看到
  - 就是需要根据作物的贴图调整，对整合包作者压力比较大
- Simply Create Model
  - 降低渲染卡顿
- Jecharacters
- FTB Ultimine
- Chunk Sending
  - 优化
- [Majobroom](https://github.com/MinecraftDevCompilation/majobroom_forge)
  - 用作毕业装备，正常生存用 [ponyofshadows/majobroom_forge: forge version of majo's broom mod](https://github.com/ponyofshadows/majobroom_forge)
- **Smart Pot**
  - 很多人不会玩烹饪锅，这个模组可以辅助
- Advancements Tracker
  - 主要用来做收集类的成就
- Configured/Catalogue
  - JEI 管理用的
- Icterine
  - 意外得提供不错优化的模组
- **Caged mobs**
  - 解决了所有需要通过生物获取的资源，各种掉落物以及 l2 的材料，补全了很多材料的量产
  - 速度升级、提取器和空刷怪蛋需要改得更贵
  - 死者之王的产出需要调整

- Dungeons Arise Seven Seas
  - 填补了海上结构的空白

- **JAVD/JAMD**
  - 提供了建机器与挖矿的场所，避免直接破坏主世界风景，也能降低卡顿
  - 机器炸了删区块也方便

- Create railways navigator
  - 车站列车时刻表的显示屏，建车站很好用
  - 上手难度比较高

- Structure credits/Draggable lists/Chat Shot/Cycle Title Screen Splash/Explosive enhancement
  - 都是些比较细节的功能模组
  - Explosive enhancement 降低 TNT 的

## 平衡

- 凝灰岩
  - 一灰烬两圆石出俩凝灰岩更合适，树的产量普遍低
- 方解石
  - 随意，骨粉产量很大
- Solcarrot: baseHeart change to 4, milestones added, minimumFoodValue change to 1
  - 目前是 [8, 16, 24, 32, 40, 48, 56, 64, 72, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 180, 200, 220, 240, 260, 280, 300, 320, 340, 360, 380, 400, 420, 440, 460, 480, 500]，将奇数位置的去掉
- Starter Kit: Add Eternium Hoe
  - 使用率同样不是很高
- L2 Backpack: initialRows Change to 8, startupBackpackCondition Change to 1
  - 这个配置也会影响合成出来的背包，所以还是改成 6 或者 4
- Diamond: 69 charcoal
  - 补足钻石没法量产的问题，实际来看这个配方是足够贵的，木炭很难大量量产
- Crushing blackstone could get blackstone dust
  - 旧问题，炸黑石太蠢了
- 四苔藓合成一泥土
  - 更新日志里面解释过，这个配方是原版的可行路径，只是流程很繁琐，这里简化了
- 石砖合成磁石
  - 这个也是从原版来的配方
- 禁止小黑搬方块
  - 小黑经常会把地形搬得乱七八糟，导致机器损坏；
  - 在原版是通过伪和平解决的，但是模组显然不行
- JEI cannot display smithing recipes correctly
  - JEI 的神金 bug，已经提 PR 了

