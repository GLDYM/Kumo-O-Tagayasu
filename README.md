
<div align="center">
<a href="version">
    <img src="./icon.png" alt="icon" style="zoom:200%;">
</a>

# Tsuri No Gatsu 5 - FDCraft Version

<a href="./LICENSE">
    <img src="https://img.shields.io/github/license/FDCraft/TsuriNoGatsu5" alt="license">
</a>

<a href="./LICENSE2">
    <img src="https://img.shields.io/badge/license2-CC--BY--NC--SA--4.0-8A2BE2" alt="license2">
</a>

<a href="./Changelog.md">
    <img src="https://img.shields.io/badge/version-5.2.7-9999FF" alt="version">
</a>

</div>

## 简介

继承于月见清兰的同名整合包，Tsuri No Gatsu 5 - FDCraft Version 是一个注重田园体验的综合整合包，旨在给予玩家一个休闲惬意的游戏体验。

原整合包地址：[https://www.mcmod.cn/modpack/626.html](https://www.mcmod.cn/modpack/626.html)

## 如何使用

为了防止服务端与客户端不匹配，本项目的文件结构采用 Modrinth 整合包格式。

要获得客户端，将`src` 文件夹中所有文件压缩为`zip`文件后修改文件名为`TsuriNoGatsu.mrpack`。

要获得服务端，将`src` 文件夹中所有文件压缩为`zip`文件后修改文件名为`TsuriNoGatsu-v5.2.2.mrpack`。下载 [forge-1.20.1-47.3.7-installer.jar](https://maven.minecraftforge.net/net/minecraftforge/forge/1.20.1-47.3.7/forge-1.20.1-47.3.7-installer.jar) 、相应平台的 [mrpack-install](https://github.com/nothub/mrpack-install/releases/tag/v0.16.10) 与`server-installer`文件夹中相应平台的脚本，与`TsuriNoGatsu.mrpack`置于同一文件夹中，执行脚本。

其余操作同原整合包，可以参考项目内的提示文件。

## 修改方向

- 如果一个物品可再生，一定可以使用红石 / 机械动力等工具类模组量产它。
- 如果一个物品不可再生或者难以量产，构建已有配方的合理延伸使之能量产。
- 思路比数量更重要。
- 注重模组之间的结合，一个模组中的某个物品可以极大简化另一个模组的流程。

## 开发

本项目下有两个分项目：

- Tsuri No Gatsu 5 - FDCraft Fork 整合包
- Mandalas GUI - Dark Mode TSNG Compat：适配 Tsuri No Gatsu 5 整合包的 Mandalas GUI - Dark Mode 资源包拓展

如果想要对本项目进行修改/PR，可以 Fork 本项目后 Clone 到本地进行修改。

>  需要注意，原整合包中有大量配方的修改使用数据包驱动而非常规的 CrT/KubeJS 驱动，这些配方位于 `src/overrides/config/openloader/data/tsng5_datapack/data`中。

本整合包接受如下 PR：

- 对于模组的增删修改，并说明如此修改的理由；
- 对于整合包配方与tag的修改，并说明修改的理由；
- 对于整合包配置文件的修改，并说明修改的理由；
- 对整合包内置资源包与 Mandalas GUI - Dark Mode TSNG Compat 的补充。

## 关于任务

本整合包的任务为社团内部分发，不对外公布。如果想为整合包制作任务，请 Fork 本项目制作，并注明任务是面向新手还是专家向。

- 面向新手：模组的介绍或全流程引导。[这是](https://github.com/FDCraft/TsuriNoGatsu5/tree/master/quests-example/chapters/crockpot-beginner.snbt)一个针对烹饪锅模组的示例。
- 专家向：各类量产挑战。[这是](https://github.com/FDCraft/TsuriNoGatsu5/tree/master/quests-example/chapters/crockpot-expert.snbt)一个烹饪锅模组的示例。

## 协议

本项目中 Tsuri No Gatsu 5 - FDCraft Fork 整合包使用 AGPL-v3 协议，Mandalas GUI - Dark Mode TSNG Compat 资源包使用 CC-BY-NC-SA 4.0 协议。如果你想要使用本项目去实现一些特殊需求，则你需要接受许可。

以下为一些情况的具体说明：

你被允许做的，但需要保留作者、原作信息与本项目地址（月见清兰 & 复旦大学基岩社，Tsuri No Gatsu 5）：

- 在不修改整合包或资源包自身的情况下，使用本整合包进行视频制作等多媒体创作并获利。
- 在不修改整合包或资源包自身的情况下，将整合包或资源包进行转载、存储、供其他玩家下载或开设公益服务器。
- 二次修改整合包或资源包，或将已被修改的整合包或资源包的包体进行分发或开设公益服务器。但你必须公开经过修改的整合包或资源包，并以相同协议分发。本社不会为被二次修改的包体提供任何帮助支持。
- 开设公益服务器并接受赞助。

你被禁止做的：

- 未经授权售卖本整合包与资源包。
- 未经授权将本整合包与资源包上传至 Curseforge 或 Modrinth 等平台，以获取平台的利益。

## 特别感谢

- [Modrinth](https://modrinth.com/)
- [innnky/majobroom_forge](https://github.com/innnky/majobroom_forge)
- [Gu-ZT/Curtain](https://github.com/Gu-ZT/Curtain)
- [KasugaLibGroup/KasugaLib](https://github.com/KasugaLibGroup/KasugaLib)
- [KuaYueTeam/NeoKuayue](https://github.com/KuaYueTeam/NeoKuayue)
- [Nova-Committee/Ultramarine-unofficial](https://github.com/Nova-Committee/Ultramarine-unofficial)
- [baguchi/TofuCreate](https://github.com/baguchi/TofuCreate)
