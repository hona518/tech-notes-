# 折腾笔记 / tech-notes

一个给自己用的排障手册：黑苹果安装、OCI 实例救砖、桌面工具配置……
组织原则只有一条：**以后遇到同样的问题，30 秒内翻到那一篇**。

## 目录

```
tech-notes/
├── README.md                ← 你正在看的这份说明
├── 双击打开.bat             ← 【日常入口】双击它：建文章 / 删文章 / 重建目录
├── tools/
│   └── notes-tool.ps1       ← 工具本体（UTF-8 带 BOM，别改编码）
└── docs/                    ← GitHub Pages 发布这个目录
    ├── index.html           ← Docsify 配置；「外观修正区」改页面长相
    ├── .nojekyll            ← 不能删，见下
    ├── README.md            ← 站点首页
    ├── _sidebar.md          ← 【自动生成】别手改
    ├── KEYWORDS.md          ← 【自动生成】别手改
    └── posts/               ← 每篇文章一个文件夹
        ├── _template/       ← 模板：复制它就能新建一篇
        ├── hackintosh-install/
        │   ├── README.md    ← 正文
        │   └── images/      ← 只属于这篇的图
        └── ...
```

## 上线（已经配好，这里只是备忘）

仓库 → `Settings` → `Pages` → `Deploy from a branch` → `main` / `/docs`。
访问 `https://<用户名>.github.io/<仓库名>/`。改完 `git push` 刷新即生效，不用装 Node / Python / Ruby。

`docs/.nojekyll` 不能删：从分支发布时 Pages 默认跑 Jekyll，会忽略下划线开头的文件，线上 `_sidebar.md` 会消失，表现为「本地正常、上线后侧边栏没了」。

## 日常

双击 **`双击打开.bat`**：

- `1` 新建文章：填标题、分类、关键词、英文文件夹名 → 自动建 `posts/<名>/README.md` + `images/`
- `2` 重建目录 + 体检：改完 meta / 加了图 / 手工删了文件夹后跑一次
- `3` 删除文章：删整个文件夹并自动重建目录，**其他页面不受影响**

然后：

```powershell
git add .
git commit -m "add: xxx"
git push
```

## 写文章的规矩

1. 每篇顶部 `<!-- meta ... -->` 填 `title / category / keywords / slug / updated`，关键词尽量用**报错原文、命令、英文术语**。
2. 正文用 `docs/posts/_template/README.md` 的骨架：**结论先行**，报错原样保留，命令别写「执行相关命令」这种废话。
3. 图片放本文件夹 `images/`，写 `![说明](images/x.png)`；站内链接写 `KEYWORDS.md` 或 `posts/xxx/README.md`。
4. 文件名/文件夹名一律**小写英文 + 短横线**，中文放标题里。
5. 删文章走工具选项 `3`，别只删文件不改目录。

## 怎么找

站内搜索框 → [KEYWORDS.md](docs/KEYWORDS.md) → 侧边栏 → GitHub 仓库内 `repo:<用户>/<仓库> <关键词>` 兜底（GitHub 不索引 Pages 网页，但索引仓库源文件）。

## ⚠️ 公开警告

GitHub Free 的 Pages 只能挂 **public** 仓库，而且**生成的网页任何人都能访问**；即便升级 Pro 把仓库设私有，站点依旧公开。所以：

- 不写 OCI 的 OCID、租户名、邮箱、API 私钥
- 不写黑苹果的序列号、ROM、MLB、SystemUUID、Apple ID
- 不贴未打码的控制台截图、不写真实 token

统一用 `<OCID>`、`<SERIAL>`、`<TOKEN>` 占位。
