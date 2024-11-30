

<div align="center">
<a href="version">
    <img src="./icon.png" alt="icon" style="zoom:200%;">
</a>
# Tsuri No Gatsu5

<a href="./LICENSE">
    <img src="https://img.shields.io/github/license/FDCraft/TsuriNoGatsu5" alt="license">
</a>

<a href="./LICENSE2">
    <img src="https://img.shields.io/badge/license2-CC--BY--NC--SA--4.0-8A2BE2" alt="license">
</a>

<a href="version">
    <img src="https://img.shields.io/badge/version-5.1.8-8A2BE2" alt="version">
</a>

</div>

## 这是什么？

>  本社团（复旦大学基岩社）有使用 Tsuri No Gatsu5 作为长期服的打算。但由于月见清兰淡出互联网，Tsuri No Gatsu 5 处于长期停止更新状态；此外 Tsuri No Gatsu 5 也并不完全符合本社团的现实情况。作为 Tsuri No Gatsu 4 的贡献者之一，本社团决定开设此项目以接手更新。

Tsuri No Gatsu5 是一个注重田园体验的综合整合包，目标是给予玩家一个休闲惬意的游戏体验。

原整合包地址：[https://www.mcmod.cn/modpack/626.html](https://www.mcmod.cn/modpack/626.html)

## 如何使用

为了防止服务端与客户端不匹配，本项目采用 mrpack 结构格式。

要获得客户端，将`src` 文件夹中所有文件压缩为`zip`文件后修改文件名为`TsuriNoGatsu.mrpack`。

要获得服务端，将`src` 文件夹中所有文件压缩为`zip`文件后修改文件名为`TsuriNoGatsu-v5.2.2.mrpack`。下载 [forge-1.20.1-47.3.7-installer.jar](https://maven.minecraftforge.net/net/minecraftforge/forge/1.20.1-47.3.7/forge-1.20.1-47.3.7-installer.jar) 、相应平台的 [mrpack-install](https://github.com/nothub/mrpack-install/releases/tag/v0.16.10) 与`server-installer`文件夹中相应平台的脚本，与`TsuriNoGatsu.mrpack`置于同一文件夹中，执行脚本。

其余操作同原整合包，可以参考项目内的提示文件。

## 开发

本项目下有两个分项目：

- Tsuri No Gatsu 5 整合包
- Mandalas GUI - Dark Mode TSNG Compat：适配 Tsuri No Gatsu 5 整合包的 Mandalas GUI - Dark Mode 资源包拓展

如果想要对本项目进行修改/PR，可以 Fork 本项目后 Clone 到本地进行修改。

>  需要注意，原整合包中有大量配方的修改使用数据包驱动而非常规的 CrT/KubeJS 驱动，这些配方位于 `src/overrides/config/openloader/data/tsng5_datapack/data`中。

本整合包接受如下 PR：

- 对于模组的增删修改，并说明如此修改的理由；
- 对于整合包配方的增加，并说明增加的理由；
- 对于整合包配置文件的修改，并说明修改的理由；
- 为整合包添加 FTB 任务；
- 对整合包内置资源包与 Mandalas GUI - Dark Mode TSNG Compat 的补充。

## 协议

本项目中 Tsuri No Gatsu 5 整合包使用 AGPL-v3 协议，Mandalas GUI - Dark Mode TSNG Compat 资源包使用 CC-BY-NC-SA 4.0 协议。如果你想要使用本项目去实现一些特殊需求，则你需要接受许可。

以下为一些情况的具体说明：

你被允许做的，但需要保留作者、原作信息与本项目地址（月见清兰 & 复旦大学基岩社，Tsuri No Gatsu5）：

- 在不修改整合包或资源包自身的情况下，使用本整合包进行视频制作等多媒体创作。
- 在不修改整合包或资源包自身的情况下，将整合包或资源包进行转载、存储、供其他玩家下载或开设公益服务器。
- 二次修改整合包或资源包，或将已被修改的整合包或资源包的包体进行分发或开设公益服务器。但你必须公开经过修改的整合包或资源包，并以相同协议分发。本社不会为被二次修改的包体提供任何帮助支持。

你被禁止做的：

- 使用整合包或资源包进行任何形式的商业目的，如需付费下载或需付费才可获得某道具。
- 未经授权上传至 Curseforge 或 Modrinth 等可获益平台。

## 修改理念

- 如果一个物品可再生，那么它就一定可以使用红石/机械动力/传统科技等工具类模组量产。只是很多人不敢想罢了。
- 如果一个物品不可再生或者难以量产，那就修改配方让它由其他可以量产的物品来得到。
- 通过在量产的数量上进行堆砌来延长整合包生命是不可取的；更应当关注量产的思路。
- 注重模组之间的结合，一个模组中的某个物品可以极大简化另一个模组的流程。
