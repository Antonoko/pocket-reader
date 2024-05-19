# 📖 pocket reader | 口袋阅读器

专为 Playdate 掌上设备设计，支持中文的电子书阅读器。

A ebook reader supports Chinese on Playdate console.

## 如何安装
从 Release 下载 [pocket_reader.pdx.zip](https://github.com/Antonoko/pocket-reader/releases)，sideload 侧载安装到 Playdate。

## 如何导入文本
1. 下载格式转换器：
- Windows 用户：从 Release 下载 [pocket_reader_convertor.exe.zip](https://github.com/Antonoko/pocket-reader/releases)
- macOS 用户：即将推出，可先使用 python 手动运行转换器👇
- 如果你不想执行可执行文件，可安装 python，下载代码仓库中的 convertor/convertor.py，通过 `python convertor.py` 执行转换器；

2. 打开转换器，根据操作指引，将 txt 文件转换为 PRT 文件；
3. 将 PRT 文件拷贝至 Playdate 中的`Data\com.haru.pocketreader`下即可阅读；

## 其他
Q： 如何关闭翻页音效？

A：将 playdate 中 com.haru.pocketreader/data.json 的`"trun_on_paper_sfx":true`更改为`"trun_on_paper_sfx":false`，保存即可。

## 致谢
- Playdate 中文支持项目：https://github.com/Antonoko/Chinese-font-for-playdate
- PlayBook：https://github.com/IdreesInc/PlayBook