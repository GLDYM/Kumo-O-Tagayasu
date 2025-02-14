# TSNG 服务端搭建指南

## 前言

本指南假定阅读者已经拥有了最基本的服务端搭建技能，如果你没有相应技能，请阅读[笨蛋开服教程 | 笨蛋 MC 开服教程](https://nitwikit.8aka.org/intro/)。

从 TSNG v5.2.8 开始，服务端的游戏内容与单人游戏将会 **出现差异** ，开服时请务必说明这点。

如果你只是想与你的好友联机，请使用 **内网穿透** 。服务端搭建的步骤较为繁琐，更适合大型服务器。

## 获取服务端

- 下载 Release 中的 `mrpack` 文件。
- 下载 [forge-1.20.1-47.3.7-installer.jar](https://maven.minecraftforge.net/net/minecraftforge/forge/1.20.1-47.3.7/forge-1.20.1-47.3.7-installer.jar)  与 相应平台的 [mrpack-install](https://github.com/nothub/mrpack-install/releases) ，与`mrpack` 文件置于同一文件夹。
- 启动命令行。
- 运行 `java -jar forge-1.20.1-47.3.7-installer.jar --installServer`
- 运行 `mrpack-install-linux <filename>.mrpack --server-file ./forge-1.20.1-47.3.7-installer.jar --server-dir ./`，其中 `<filename>`是你下载的`mrpack` 文件的文件名。

## 关于 Java 版本

建议使用 **Java 21** 而非 **Java 17**，更高的 Java 版本号通常拥有更好的性能。发行版随意，可以使用 Zulu JDK，相对易用。

## 关于备份

服务端并没有自带备份模组，请自行备份。有如下几种方案可供选择：

- 搭建 MCDR ，使用 [Prime Backup](https://tisunion.github.io/PrimeBackup/zh/) 进行备份。
- 使用 [RClone](https://rclone.org/) 上传至网盘。
- 全盘 / 全机的异地备份。

## 关于差异

- 铁魔法：单人游戏中在一件装备上最大可使用 10 个升级法球，而服务端为 3 个。
- 村庄出生点：单人游戏出生点在村庄，而服务端不在，以减少出生点卡顿。
