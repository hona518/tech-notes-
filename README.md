# 折腾笔记 / tech-notes

一个给自己用的排障手册：黑苹果安装、OCI 实例救砖、桌面工具配置……
组织原则只有一条：**以后遇到同样的问题，30 秒内翻到那一篇**。所以按「场景 / 报错」分类，不按时间线写博客。

## 目录结构

```
tech-notes/
├── README.md                 ← 你正在看的这份说明
└── docs/                     ← GitHub Pages 发布这个目录
    ├── index.html            ← Docsify 配置（搜索、侧边栏、主题）
    ├── .nojekyll             ← 不能删，见下方
    ├── README.md             ← 站点首页
    ├── _sidebar.md           ← 侧边栏 / 目录（新增文章要在这里登记）
    ├── KEYWORDS.md           ← 报错、命令、型号 → 文档的速查表
    ├── troubleshooting-template.md
    ├── hackintosh/           ← 黑苹果
    ├── oci/                  ← OCI / 云主机
    └── misc/                 ← 桌面工具、路由器等
```

## 三步上线

1. GitHub 新建一个 **public** 仓库（名字随意，比如 `tech-notes`），把本目录内容推上去：

```bash
git init
git add .
git commit -m "init: 折腾笔记"
git branch -M main
git remote add origin https://github.com/<用户名>/<仓库名>.git
git push -u origin main
```

2. 仓库 → `Settings` → 左侧 `Pages` → `Build and deployment` → `Source` 选 **Deploy from a branch** → Branch 选 `main`、文件夹选 **`/docs`** → Save。

3. 等 1–2 分钟，访问 `https://<用户名>.github.io/<仓库名>/`。
   如果仓库直接命名为 `<用户名>.github.io`，地址就是 `https://<用户名>.github.io/`，更短更好记。

> 全程不用装 Node / Python / Ruby，不用跑构建命令：Docsify 在浏览器里直接读 Markdown 渲染，改完 `git push` 刷新就生效。

## 绝对不要删

- `docs/.nojekyll`：GitHub Pages 从分支发布时默认走 Jekyll，而 Jekyll 会忽略下划线开头的文件，导致线上 `_sidebar.md` 丢失、侧边栏消失，本地却一切正常。这个文件就是用来关掉 Jekyll 的。

## 怎么写

- 用 VS Code 打开整个文件夹写 `.md`：`Ctrl+Shift+V` 整页预览，`Ctrl+K V` 侧边预览。中文界面装 Chinese Language Pack 即可。
- 文件名一律**小写英文 + 短横线**（`vnic-cleanup.md`），中文放标题里，避免 URL 转义和分享链接出问题。
- 复制 `docs/troubleshooting-template.md` 改。关键是**把报错原文、命令、型号原样留着**——那才是以后搜索能命中的关键词。
- 新文章记得在 `docs/_sidebar.md` 加一行（站内搜索靠侧边栏发现页面），并顺手在 `KEYWORDS.md` 补 2–3 个关键词。
- 提交：`git add . && git commit -m "add: xxx" && git push`。

## 怎么找

1. 网页左上角搜索框，会索引全部 Markdown 原文。
2. `docs/KEYWORDS.md`：只记得大概症状时，翻关键词对照表。
3. GitHub 仓库页按 `/` 聚焦搜索，或用 `repo:<用户名>/<仓库名> <关键词>`、`path:docs/oci/ <关键词>` 兜底。GitHub 不索引 Pages 网页本身，但会索引仓库默认分支里的源文件。

## ⚠️ 公开警告

GitHub Free 的 Pages 只能挂在 **public** 仓库上，而且**生成的网页任何人都能访问**；即便以后升级到 Pro 把仓库设成私有，站点依然是公开的。所以：

- 不写 OCI 的 OCID、租户名、邮箱、API 私钥、密钥指纹
- 不写黑苹果的序列号、ROM、MLB、SystemUUID、Apple ID
- 不贴未打码的控制台截图

统一用 `<OCID>`、`<SERIAL>`、`<VNIC_ID>` 这类占位符代替。
