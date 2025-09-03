# 服务端搭建指南 & 自定义游戏指南

## 服务端搭建

### 前言

本指南假定阅读者已经拥有了最基本的服务端搭建技能，如果你没有相应技能，请阅读[笨蛋开服教程 | 笨蛋 MC 开服教程](https://nitwikit.8aka.org/intro/)。

从 v5.2.8 开始，服务端的游戏内容与单人游戏将会 **出现差异** ，开服时请务必说明这点。

如果你只是想与你的好友联机，请使用 **内网穿透** 。服务端搭建的步骤较为繁琐，更适合大型服务器。

### 获取服务端

- 下载 Release 中的 `mrpack` 文件。
- 下载 [forge-1.20.1-47.4.6-installer.jar](https://maven.minecraftforge.net/net/minecraftforge/forge/1.20.1-47.4.6/forge-1.20.1-47.4.6-installer.jar)  与 相应平台的 [mrpack-install](https://github.com/nothub/mrpack-install/releases) ，与`mrpack` 文件置于同一文件夹。
- 启动命令行。
- 运行 `java -jar forge-1.20.1-47.4.6-installer.jar --installServer`
- 运行 `mrpack-install-linux <filename>.mrpack --server-file ./forge-1.20.1-47.4.6-installer.jar --server-dir ./`，其中 `<filename>`是你下载的`mrpack` 文件的文件名。

### 关于 Java 版本

建议使用 **Java 21** 而非 **Java 17**，更高的 Java 版本号通常拥有更好的性能。发行版随意，可以使用 Zulu JDK，相对易用。

### 备份

服务端并没有自带备份模组，请自行选择方案备份。有如下几种方案可供选择：

- 使用 [FTBBackup2]([FTB Backups 2 - Minecraft Mods - CurseForge](https://www.curseforge.com/minecraft/mc-mods/ftb-backups-2)) 进行备份。优点：简单易懂 缺点：速度慢，占用大，无回档指令
- 使用 [Advanced Backups](https://modrinth.com/plugin/advanced-backups) 进行备份。优点：占用小 缺点：回档较为麻烦，对技术要求高
- 搭建 MCDR ，使用 [Prime Backup](https://tisunion.github.io/PrimeBackup/zh/) 进行备份。优点：占用小，可以快速回档 缺点：需要 Python3 环境
- 使用 [RClone](https://rclone.org/) 上传至网盘。优点：稳定！缺点：配置较为麻烦，需要完整环境
- 全盘 / 全机的异地备份。优点：稳定！缺点：需要另一台内容存储服务器


## 自定义游戏指南

我们注意到很多玩家游玩织彩钓月和耕云钓月时为单人游玩，而非预设的多人联机/服务器游玩。在单人游玩时部分玩家可能会遇到严重的性能问题，因此本指南旨在通过自定义本整合包的方式来减少单人游玩的压力。

### 单人游玩

这些模组完全为多人游玩设计，单人游玩这些模组将几乎不起作用，建议直接禁用。多人联机也可以考虑禁用这些模组。

- Allmusic
- Chat Heads
- Chat Image
- Let Me Feed You
- Waterframe 及其前置 Watermedia
- Immersive painting
- Simple Voice Chat
- Open Parties and Claims
- Emote Craft
- Dimension Viewer
- Exposure 及其附属 Exposure Catalog
- World preview
- Create: railways navigator
- Zetter 及其附属 Zetter Gallery

### 不造建筑

如果选择完全不造建筑，可以考虑去除下面的模组。

- Amendments
- Another Furniture
- Beautify
- Create: Interiors
- 一切 Macaw 系列模组
- Ultramarine
- Night Lights

### 不玩冒险

尽管在改版后冒险要素已经大幅降低，你仍然可以考虑去除以下模组。注意这并不代表不需要跑图。

- Integrated 系列模组
- 地牢浮现之时-七海

### 不玩机械动力

你应该去看看原版织彩钓月，并参照上文。

### 不玩农业模组

你应该去成为帷幕彼端中的求知者，我说真的。
