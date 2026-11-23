<!-- meta
title: 从零上线：代理、凭据串号与 Pages 设置
category: 站点 / 维护
keywords: Recv failure: Connection was reset, Permission denied to, http.proxy, cmdkey /delete, Verified domains, .nojekyll, Everything up-to-date, 403
slug: pages-deploy
updated: 2026-11-23
-->

# 从零上线：代理、凭据串号与 Pages 设置

> 关键词：`Recv failure: Connection was reset`、`Permission ... denied to`、`http.proxy`、`socks5://127.0.0.1:10808`、`cmdkey /delete`、`403`、`Verified domains`、`.nojekyll`、`Everything up-to-date`
>
> 分类：站点 / 维护 ｜ 首次记录：2026-11-23 ｜ 最后验证：2026-11-23
> 适用环境：Windows 11 + PowerShell 5.1 + git for Windows + GitHub Free / Public 仓库 / GitHub Pages 从 `main /docs` 发布

## 症状 / 我要解决什么

第一次把本地 Docsify 笔记站推上 GitHub Pages，`git push` 连着卡了三轮：先静默无输出，再 `Connection was reset`，最后 `403`。另外在网页上找 Pages 设置时，进到了一个只有「Verified domains」的页面，找不到「Deploy from a branch」。

```
fatal: unable to access 'https://github.com/...': Recv failure: Connection was reset
info: Permission hona518/tech-notes-git denied to Alph18.
fatal: ... The requested URL returned error: 403
```

## 结论（先写答案）

这是**三个独立问题叠在一起**，别混为一谈：

1. **网络**：浏览器走代理，命令行 git 不走 → 要单独给 git 配 `http.proxy`。
2. **凭据**：GCM 缓存了另一个账号的登录态 → 清旧凭据 + 把用户名写进 remote。
3. **设置层级**：`github.com/settings/pages` 是**账号级**（只管域名验证），开站点要去**仓库级** `github.com/<用户>/<仓库>/settings/pages`。

按这个顺序解，一次就通。

## 环境（脱敏）

- 账号 / 仓库：`<USER>` / `<REPO>`（Public）
- 本地路径：`C:\Users\<用户>\Downloads\tech-notes-starter\...`
- 代理：本机 SOCKS5 `127.0.0.1:<端口>`（端口看代理软件设置，别照抄）
- Pages 发布源：`Deploy from a branch` → `main` / `/docs`

## 操作步骤

**1. 先判断是网络还是认证。** 另开 PowerShell：

```powershell
Test-NetConnection github.com -Port 443
git config --show-origin --get http.proxy
```

`TcpTestSucceeded : True` 但 push 报 RST → TCP 通了、HTTPS 被掐断，是**网络/代理**问题，不是 token 没建好。

**2. 让 git 走代理**（端口以代理软件的 HTTP/SOCKS 混合端口为准）：

```powershell
git config --global http.proxy  socks5://127.0.0.1:<端口>
git config --global https.proxy socks5://127.0.0.1:<端口>
curl.exe -I https://github.com --connect-timeout 10
```

`HTTP/1.1 200 OK` 就说明这层通了，代理配置别再动。

**3. 清掉缓存的旧凭据，把用户名钉死：**

```powershell
cmdkey /list | findstr /i github
cmdkey /delete:git:https://github.com
git remote set-url origin https://<USER>@github.com/<USER>/<REPO>.git
git remote -v
```

只加用户名，**不要**把 token 塞进 URL（会明文留在 `.git/config`）。

**4. 重新推：**

```powershell
git push -u origin main
```

弹认证时：Username 填 `<USER>`，Password 填 PAT 或走浏览器授权。**授权页当前登录的账号必须和仓库所有者一致**，同时开着两个 GitHub 账号最容易反复 403。

**5. 开 Pages 要去仓库级设置：**

```
https://github.com/<USER>/<REPO>/settings/pages
```

`Build and deployment → Source` 选 `Deploy from a branch`，Branch `main`、文件夹 `/docs`，Save。

## 踩过的坑

- **静默无输出 ≠ 连不上**。可能是 GCM 授权窗口开在后台，或 TLS 握手被代理掐住；看有没有明确报错再判断。
- **`curl 200 OK` 之后还报 403**，不是网络了，是凭据。报错里 `Permission ... denied to <另一个账号>` 就是铁证。
- **账号级 Pages 页面**：`github.com/settings/pages` 只有 `Verified domains / Add a domain`，那是自有域名验证，不用点。仓库级才有 `Build and deployment`。
- **`Everything up-to-date` ≠ 文件传上去了**。文件拷进目录但没 `git add` / `commit`，git 根本不知道。先看 `git status`。
- **隐藏文件 `.nojekyll` 不能删**：从分支发布时 Pages 默认跑 Jekyll，会忽略下划线开头的文件，线上 `_sidebar.md` 会消失（本地正常、上线侧边栏没了，就是这个）。
- **仓库名末尾的连字符**：`<REPO>` 叫 `tech-notes-` 时，remote 少一个 `-` 就是 `Repository not found`。
- **Add README 别勾**：勾了远端先有初始提交，本地第一次 push 会被 non-fast-forward 拒绝。
- **第一次要自己账号 push**：由 `GITHUB_TOKEN` 提交触发的部署不会再拉起 Pages 构建。

## 修正页面时怎么改

| 要改什么 | 改哪里 | 会不会影响别的文章 |
| --- | --- | --- |
| 某篇的错别字 / 补命令 | 那篇自己的 `posts/<文件夹>/README.md` | 不会 |
| 页面颜色、字号、代码块样式 | `docs/index.html` 的「外观修正区」 | 不会 |
| 侧边栏 / 关键词表 | **不要手改**，跑一次工具自动重建 | —— |
| 删掉一整篇 | 删掉 `posts/<文件夹>/` → 跑工具 | 不会，死链自动消失 |

## 验证方式

```powershell
git push -u origin main
curl.exe -I https://<USER>.github.io/<REPO>/
```

预期：`Writing objects: 100%`、`branch 'main' set up to track 'origin/main'`，网址返回 `200`。

网页上四项验收：Docsify 渲染正常、左侧边栏在、搜索框能命中报错原文、`.nojekyll` 生效（侧边栏没消失）。

## 关联

- [创建 GitHub Personal access token（HTTPS 推送用）](posts/github-pat-token/README.md)
- [关键词速查表](KEYWORDS.md)

## 参考

- GitHub Docs · Configuring a publishing source for your GitHub Pages site
- GitHub Docs · Caching your GitHub credentials in Git
