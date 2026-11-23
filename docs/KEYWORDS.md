# 关键词速查

> 站内搜不到时翻这里。左边尽量写**报错原文 / 命令 / 英文术语**——那是半年后你最可能还记得的东西。

| 关键词 / 症状 | 去哪篇 |
| --- | --- |
| `journalctl -xe`、`systemctl --failed`、`active (running)`、`oci-worker`、部署脚本提示「立即查看日志」 | [systemd 日志与提示排查](oci/systemd-log-check.md) |
| `404 NotAuthorizedOrNotFound`、VNIC、Bastion、VCN 删不掉、`oci network vnic get`、Network Sources | [Bastion 残留 VNIC 删除报 404](oci/vnic-cleanup.md) |
| OpenCore、`config.plist`、EFI、USB 定制、黑苹果安装、`OC` 引导 | [安装流程记录](hackintosh/install-notes.md) |
| `.md` 排版、VS Code 中文、Markdown 预览、等宽字体、Notepad3 | [Markdown 编辑器与排版](misc/markdown-editor-setup.md) |
| `Personal access token`、`PAT`、`github_pat_`、`ghp_`、`repo` scope、`Contents: Read and write`、`Git Credential Manager`、Windows 凭据管理器、`fatal: Authentication failed`、`Support for password authentication was removed` | [创建 GitHub Personal access token](github-pat-token.md) |
| `Recv failure: Connection was reset`、`Test-NetConnection github.com -Port 443`、`http.proxy`、命令行 git 不走浏览器代理 | [创建 PAT 教程 · 踩过的坑](github-pat-token.md) |

## 仓库内兜底搜索

GitHub 仓库页按 `/` 聚焦搜索框，例如：

```
repo:<用户名>/<仓库名> "404 NotAuthorizedOrNotFound"
repo:<用户名>/<仓库名> journalctl path:docs/oci/
```

GitHub 不索引 Pages 生成的网页，但会索引仓库默认分支里的源文件，所以 `.md` 原文一定搜得到。`content:` 限定只搜内容，`path:` 限定目录，`""` 做精确短语匹配。

## 维护习惯

每写一篇，回来补一行。**关键词表比目录更值钱**——目录是你按当时理解分的类，关键词才是你出问题时脑子里蹦出来的词。
