# MPV 懒人安装包

三步即可直接使用：打开上次文件（夹），播放上（下）一个，窗口固定尺寸等。

## 实现效果

更详细内容查看文章：[MPV 视频播放器 新手入门和懒人安装包](https://evgo2017.com/blog/mpv-beginner-and-mpv-lazy-easy)。

### 主页面

![2026-01-06_064346](https://github.com/evgo2017/mpv-lazy-easy/raw/main/assets/2026-01-06_064346.png)

### 常用功能

* 会话管理器（历史记录）。

![2026-01-06_062648](https://github.com/evgo2017/mpv-lazy-easy/raw/main/assets/2026-01-06_062648.png)

* 鼠标or键盘：播放上（下）一个视频。
* 窗口固定尺寸：切换不同尺寸视频、音乐。
* 右键：打开播放列表。
* and so on.

![2026-01-06_063520](https://github.com/evgo2017/mpv-lazy-easy/raw/main/assets/2026-01-06_063520.png)

## 操作步骤

### 第一步

下载 [Release](https://github.com/evgo2017/mpv-lazy-easy/releases) 中的 `懒人包.zip` 并解压文件到 `C:\Softwares\mpv`。

### 第二步

双击运行 `C:\Softwares\mpv` 目录下的：

*   `mpv-register.bat` 脚本（用途：能从 Windows 搜索到这个软件）
*   `fonts` 文件夹下的所有字体（用途：字体美化）
*   `copyConfToAppData.bat`脚本（用途：复制配置文件到配置目录）

输出示例：

```shell
==========================================
Copying MPV Configuration...
Source: C:\Softwares\mpv\
Destination: C:\Users\WDAGUtilityAccount\AppData\Roaming\mpv
==========================================

Copying configuration files from AppData...
C:\Softwares\mpv\AppData\input.conf
C:\Softwares\mpv\AppData\mpv.conf
复制了 2 个文件

==========================================
Copy Configuration Complete!
You can now start MPV.
==========================================
请按任意键继续. . .
```

### 第三步

重新启动 MPV 即生效。


## 额外说明

当前懒人包采用：

[mpv-v0.41.0-x86_64-w64-mingw32.zip](https://github.com/mpv-player/mpv/releases/tag/v0.41.0)

[ModernZ v0.2.8](https://github.com/Samillion/ModernZ/releases/tag/v0.2.8)

若有问题联系我： 

1. [GitHub Issues](https://github.com/evgo2017/mpv-lazy-easy/issues)

2. [evgo2017 个人网站](https://evgo2017.com/about)

