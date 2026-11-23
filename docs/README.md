# 折腾笔记

> 给自己看的排障手册。目标只有一个：**以后遇到同样的问题，30 秒内翻到那一篇。**

## 怎么找东西

| 方式 | 什么时候用 |
| --- | --- |
| 左上搜索框 | 记得报错原文、命令、型号时，直接搜 |
| [KEYWORDS.md](KEYWORDS.md) | 只记得个大概症状，先看关键词对照表 |
| GitHub 仓库搜索 | 网页打不开 / 站内搜不到时，用 `repo:用户名/仓库名 关键词` 兜底 |

## 分类

- **黑苹果**：安装、OpenCore 引导、EFI、驱动、升级踩坑
- **OCI / 云主机**：实例救砖、账号与资源清理、systemd 服务排查
- **桌面工具**：Markdown 编辑器、路由器固件、Windows 小工具

## 写新的一篇

1. 复制 [troubleshooting-template.md](troubleshooting-template.md)
2. 文件名用小写英文短横线，放进对应目录
3. 在 [_sidebar.md](_sidebar.md) 加一行链接（不加的话站内搜索索引不到）
4. 顺手在 [KEYWORDS.md](KEYWORDS.md) 补 2–3 个关键词
5. `git push` 完事，不用构建

> ⚠️ 仓库是公开的：OCID / 序列号 / 密钥 / 未打码截图一律写成 `<OCID>` 这类占位符。
