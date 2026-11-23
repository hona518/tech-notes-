# PAT 教程增量包 · 怎么放进仓库

这是给已上线的 `tech-notes` 仓库补的一篇图文教程，**不用重建站点、不用改 `index.html`**。

## 文件清单

```
pat-addon/
├── README-ADDON.md          ← 本说明，不用放进仓库
└── docs/
    ├── github-pat-token.md  ← 新增：教程正文（放 docs 根目录，别放子目录）
    ├── _sidebar.md          ← 覆盖：多了一行「GitHub / 认证」
    ├── KEYWORDS.md          ← 覆盖：多了两行关键词
    └── images/              ← 新增目录：3 张配图
        ├── pat-step1-path.png
        ├── pat-step2-form.png
        └── pat-step3-use.png
```

## 操作

1. 解压，把 `docs/` 里的内容按同样路径拷进本地仓库的 `docs/` 目录。
2. `_sidebar.md` 和 `KEYWORDS.md` 是**覆盖**。如果你已经往这两个文件里加过自己的条目，别直接覆盖，手工把新增的那一行/两行合并进去。
3. 推送：

```powershell
git add .
git commit -m "docs: 新增 GitHub PAT 创建教程与配图"
git push
```

4. 等 1–2 分钟刷新网页，侧边栏出现「GitHub / 认证 → 创建 Personal access token」，点开看三张图是否正常显示。

## 两个刻意的设计

- **教程 md 放在 `docs/` 根目录而不是 `docs/misc/`**：Docsify 对子目录 Markdown 里的相对图片路径处理有历史坑，`relativePath` 开不开行为不一致。放在根目录时，`images/xxx.png` 无论按哪种规则解析都指向 `docs/images/`，不用改 `index.html`、不用加配置。以后新写带图文章也照这个位置放。
- **配图是示意图，不是真实截图**：GitHub 界面会改版，示意图只标点击路径和字段名，不会因按钮位置变化而误导。想更精确可以自己截 3 张真图替换 `docs/images/` 里的同名文件，md 不用改。

## 提醒

教程里所有 token 都写成 `<TOKEN>`，用户名/仓库名用占位符。这个仓库是 Public、网页全网可见，**真实 token 永远不要出现在这里**。
