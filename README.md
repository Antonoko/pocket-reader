![screenshot](https://github.com/Antonoko/pocket-reader/blob/main/__asset__/header.jpg)
# 📖 pocket reader | 口袋阅读器

专为 Playdate 掌上设备设计，支持中文的电子书阅读器。

A ebook reader supports Chinese on Playdate console.

## 功能
- 自带 4 种字体：思源黑体、思源宋体、霞鹜文楷、融合像素。可通过自行生成与编译应用来添加更多字体；
- 横向与纵向的阅读显示、夜间模式；
- 通过曲柄快速翻阅与定位文本；
- 支持自动翻页，可自定义翻页时间；

## 如何安装
> [!IMPORTANT]  
> **该应用不支持通过在线方式 sideload 安装，只能通过 USB 传输安装。**

1. 将 playdate® 设置为“数据传输模式”：Settings → System → Reboot to Data Disk → 通过数据线连接到电脑上
2. 从 Release 下载 [pocket_reader.pdx.zip](https://github.com/Antonoko/pocket-reader/releases)，解压成 `pocket_reader.pdx` 的文件夹。
    - **需要注意，打开 pocket_reader.pdx 文件夹后，里边应该有多个文件，而不是又一个 pocket_reader.pdx 的文件夹；**
3. 将 `pocket_reader.pdx 文件夹` 复制到 `Games` 文件夹中；
4. 弹出你的 playdate 设备，按 A 重启，这时应该可以在 sideload 中看到该应用了；


## 如何导入文本
1. 下载格式转换器：
- Windows：从 Release 下载 [pocket_reader_convertor_windows.exe](https://github.com/Antonoko/pocket-reader/releases)
- macOS：从 Release 下载 [pocket_reader_convertor_macos.zip](https://github.com/Antonoko/pocket-reader/releases)
- 手动挡：如果不想执行可执行文件，可安装 python 后，下载代码仓库中的 convertor/convertor.py，通过 `python convertor.py` 执行转换器；
- 在线版：即将推出？

2. 打开转换器，根据操作指引，将 txt 文件转换为 PRT 文件；
    - txt 文件内容需要为 utf-8 编码，如果不确定，可以新建一个 txt 后复制原文粘贴保存，默认即为 utf-8 编码了；
3. 将 PRT 文件拷贝至 Playdate 中的 `Data\com.haru.pocket_reader` 下即可阅读；

## 其他
Q： 如何关闭翻页音效？

A：将 playdate 中 `com.haru.pocketreader/data.json` 的 `"trun_on_paper_sfx":true` 更改为`"trun_on_paper_sfx":false`，保存即可。

Q： 遇到 bug、且导致应用无法正常启动使用？

A：在 Playdate `Setting → Games` 中删除游戏数据（Delete Game Data）即可重置应用。同时欢迎在 issue 提交反馈报告（在应用崩溃后，按 A 可查看出错原因）。

## 致谢
- Playdate 中文支持项目：https://github.com/Antonoko/Chinese-font-for-playdate
- PlayBook：https://github.com/IdreesInc/PlayBook

| 欢迎前往 [作者的 GitHub 仓库](https://github.com/Antonoko?tab=repositories) 发现更多 Playdate 相关应用😺