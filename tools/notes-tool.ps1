<#
  折腾笔记 · 小工具  (兼容 PowerShell 2.0 / 3.0 / 5.1 / 7)
  只做三件事：建文章、删文章、重建目录 + 体检。
  运行方式：双击仓库根目录的「双击打开.bat」。
  注意：本文件必须保存为「UTF-8 带 BOM」，否则中文会乱码。
#>
$ErrorActionPreference = 'Stop'
$OutputEncoding = [System.Text.Encoding]::UTF8
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }
try { [Console]::InputEncoding  = [System.Text.Encoding]::UTF8 } catch { }

# $PSScriptRoot 是 PS 3.0 才有的，老版本用 $MyInvocation 回退
if (-not $PSScriptRoot) {
    $PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
}

$Root     = Split-Path -Parent $PSScriptRoot
$Docs     = Join-Path $Root 'docs'
$Posts    = Join-Path $Docs 'posts'
$Sidebar  = Join-Path $Docs '_sidebar.md'
$Keywords = Join-Path $Docs 'KEYWORDS.md'
$Template = Join-Path $Posts '_template'

# 分类显示顺序；新分类会自动排到最后，不会丢
$CategoryOrder = @('黑苹果', 'OCI / 云主机', '桌面工具', 'GitHub / 认证', '站点 / 维护')

$PsMajor = 2
if ($PSVersionTable -and $PSVersionTable.PSVersion) { $PsMajor = $PSVersionTable.PSVersion.Major }


function Write-Utf8NoBom($Path, $Text) {
    # 不用 ::new()，那是 PS 5 才有的语法
    $enc = New-Object System.Text.UTF8Encoding -ArgumentList $false
    [System.IO.File]::WriteAllText($Path, $Text, $enc)
}

function Read-PostMeta($File) {
    $txt = [System.IO.File]::ReadAllText($File, [System.Text.Encoding]::UTF8)
    $m = [regex]::Match($txt, '(?s)^<!--\s*meta\s*(.*?)-->')
    if (-not $m.Success) { return $null }
    $meta = @{}
    foreach ($line in ($m.Groups[1].Value -split "`r?`n")) {
        if ($line -match '^\s*([a-zA-Z]+)\s*:\s*(.+?)\s*$') {
            $meta[$Matches[1].ToLower()] = $Matches[2]
        }
    }
    return $meta
}

function Get-SubDirs($Path) {
    # 不用 -Directory：它是 PS 3.0 的 FileSystem 动态参数，在老版本/非文件
    # 系统 provider 下会报 "A parameter cannot be found that matches parameter name 'Directory'"
    if (-not (Test-Path -LiteralPath $Path)) { return @() }
    return @(Get-ChildItem -LiteralPath $Path | Where-Object { $_.PSIsContainer })
}

function Get-Posts {
    $list = @()
    foreach ($dir in @(Get-SubDirs $Posts | Sort-Object Name)) {
        if ($dir.Name -eq '_template') { continue }
        $f = Join-Path $dir.FullName 'README.md'
        if (-not (Test-Path -LiteralPath $f)) { continue }
        $obj = New-Object PSObject -Property @{
            Slug = $dir.Name
            File = $f
            Dir  = $dir.FullName
            Meta = (Read-PostMeta $f)
            Text = [System.IO.File]::ReadAllText($f, [System.Text.Encoding]::UTF8)
        }
        $list += $obj
    }
    return $list
}

function Test-PathsOk {
    $ok = $true
    if (-not (Test-Path -LiteralPath $Root)) {
        Write-Host "  [问题] 找不到仓库根目录：$Root" -ForegroundColor Red
        $ok = $false
    }
    if (-not (Test-Path -LiteralPath $Docs)) {
        Write-Host "  [问题] 找不到 docs 目录：$Docs" -ForegroundColor Red
        Write-Host '         v2 包里的 docs/ 没有拷进仓库根目录，请重新覆盖一次。' -ForegroundColor Yellow
        $ok = $false
    }
    if (-not (Test-Path -LiteralPath $Posts)) {
        Write-Host "  [问题] 找不到 posts 目录：$Posts" -ForegroundColor Red
        Write-Host '         v2 包里的 docs/posts/ 没有拷进来（只拷了 tools 和 bat 也会这样）。' -ForegroundColor Yellow
        $ok = $false
    }
    if (-not (Test-Path -LiteralPath $Template)) {
        Write-Host "  [问题] 找不到模板目录：$Template" -ForegroundColor Red
        $ok = $false
    }
    return $ok
}

function Invoke-Rebuild {
    Write-Host ''
    Write-Host '=== 重建目录 + 体检 ===' -ForegroundColor Cyan
    if (-not (Test-PathsOk)) {
        Write-Host ''
        Write-Host '  路径没对齐，已停止。按上面的 [问题] 补文件后再跑一次选 2。' -ForegroundColor Yellow
        Write-Host ''
        return
    }
    $posts = @(Get-Posts)
    $warn  = 0

    # ---------- 体检 ----------
    foreach ($p in $posts) {
        $tag = $p.Slug
        if ($null -eq $p.Meta) {
            Write-Host "  [问题] $tag : 缺 <!-- meta ... --> 块" -ForegroundColor Red; $warn++
            continue
        }
        foreach ($k in @('title','category','keywords','slug','updated')) {
            if (-not $p.Meta.ContainsKey($k)) {
                Write-Host "  [问题] $tag : meta 缺少 $k" -ForegroundColor Red; $warn++
            }
        }
        if ($p.Meta.ContainsKey('slug') -and $p.Meta['slug'] -ne $p.Slug) {
            Write-Host "  [问题] $tag : meta 里的 slug 与文件夹名不一致" -ForegroundColor Red; $warn++
        }
        # 图片：按「当前文章文件夹」解析
        foreach ($m in [regex]::Matches($p.Text, '!\[[^\]]*\]\(([^)]+)\)')) {
            $ref = $m.Groups[1].Value
            if ($ref -match '^https?://') { continue }
            $full = [System.IO.Path]::GetFullPath((Join-Path $p.Dir $ref))
            if (-not (Test-Path -LiteralPath $full)) {
                Write-Host "  [问题] $tag : 图片不存在 -> $ref" -ForegroundColor Red; $warn++
            }
        }
        # 站内链接：按 docs 根目录解析
        foreach ($m in [regex]::Matches($p.Text, '(?<!!)\[[^\]]*\]\(([^)]+)\)')) {
            $ref = $m.Groups[1].Value
            if ($ref -match '^https?://' -or $ref -match '^#' -or $ref -match '^/') { continue }
            $full = [System.IO.Path]::GetFullPath((Join-Path $Docs $ref))
            if (-not (Test-Path -LiteralPath $full)) {
                Write-Host "  [问题] $tag : 站内链接不存在 -> $ref" -ForegroundColor Red; $warn++
            }
        }
    }
    foreach ($dir in @(Get-SubDirs $Posts)) {
        if ($dir.Name -eq '_template') { continue }
        if (-not (Test-Path -LiteralPath (Join-Path $dir.FullName 'README.md'))) {
            Write-Host "  [问题] $($dir.Name) : 文件夹里没有 README.md" -ForegroundColor Red; $warn++
        }
    }

    # ---------- 生成 _sidebar.md ----------
    $cats = @()
    foreach ($p in $posts) {
        if ($null -eq $p.Meta -or -not $p.Meta.ContainsKey('category')) { continue }
        if ($cats -notcontains $p.Meta['category']) { $cats += $p.Meta['category'] }
    }
    $ordered = @()
    foreach ($c in $CategoryOrder) { if ($cats -contains $c) { $ordered += $c } }
    foreach ($c in $cats) { if ($ordered -notcontains $c) { $ordered += $c } }

    $sb = @()
    $sb += '<!-- 本文件由 tools/notes-tool.ps1 自动生成，请勿手工编辑 -->'
    $sb += '<!-- 新增/删除文章后：双击根目录的「双击打开.bat」→ 选 2 -->'
    $sb += ''
    $sb += '- [首页](/)'
    foreach ($c in $ordered) {
        $sb += ''
        $sb += "- $c"
        foreach ($p in $posts) {
            if ($null -eq $p.Meta) { continue }
            if ($p.Meta['category'] -ne $c) { continue }
            $sb += "  - [$($p.Meta['title'])](posts/$($p.Slug)/README.md)"
        }
    }
    $sb += ''
    $sb += '- 索引与模板'
    $sb += '  - [关键词速查表](KEYWORDS.md)'
    $sb += '  - [排障记录模板](posts/_template/README.md)'
    Write-Utf8NoBom $Sidebar (($sb -join "`n") + "`n")

    # ---------- 生成 KEYWORDS.md ----------
    $kw = @()
    $kw += '<!-- 本文件由 tools/notes-tool.ps1 自动生成，请勿手工编辑 -->'
    $kw += ''
    $kw += '# 关键词速查'
    $kw += ''
    $kw += '> 站内搜不到时翻这里。左边尽量写**报错原文 / 命令 / 英文术语**——那是半年后你最可能还记得的东西。'
    $kw += ''
    $kw += '| 关键词 / 症状 | 去哪篇 |'
    $kw += '| --- | --- |'
    foreach ($p in $posts) {
        if ($null -eq $p.Meta -or -not $p.Meta.ContainsKey('keywords')) { continue }
        foreach ($k in ($p.Meta['keywords'] -split ',')) {
            $k = $k.Trim()
            if ($k -eq '') { continue }
            $kw += "| ``$k`` | [$($p.Meta['title'])](posts/$($p.Slug)/README.md) |"
        }
    }
    $tail = @'
## 仓库内兜底搜索

GitHub 仓库页按 `/` 聚焦搜索框，例如：

```
repo:<用户名>/<仓库名> "404 NotAuthorizedOrNotFound"
repo:<用户名>/<仓库名> journalctl path:docs/posts/
```

GitHub 不索引 Pages 生成的网页，但会索引仓库默认分支里的源文件，所以 `.md` 原文一定搜得到。`content:` 限定只搜内容，`path:` 限定目录，`""` 做精确短语匹配。

## 维护习惯

关键词写在每篇文章顶部的 `<!-- meta ... -->` 里，这张表由工具自动汇总。**关键词表比目录更值钱**——目录是你按当时理解分的类，关键词才是你出问题时脑子里蹦出来的词。
'@
    $kw += $tail
    Write-Utf8NoBom $Keywords (($kw -join "`n") + "`n")

    Write-Host "  已更新 _sidebar.md / KEYWORDS.md，共 $($posts.Count) 篇文章、$($ordered.Count) 个分类" -ForegroundColor Green
    if ($warn -eq 0) {
        Write-Host '  体检通过：meta、图片、站内链接全部正常' -ForegroundColor Green
    } else {
        Write-Host "  体检发现 $warn 个问题，按上面 [问题] 逐条改，再跑一次选 2" -ForegroundColor Yellow
    }
    Write-Host ''
}

function New-Post {
    Write-Host ''
    Write-Host '=== 新建一篇文章 ===' -ForegroundColor Cyan
    if (-not (Test-PathsOk)) { Write-Host '  路径没对齐，已取消' -ForegroundColor Yellow; return }
    $title = (Read-Host '  标题（一句话，例如：黑苹果升级后 USB 全失效）').Trim()
    if ($title -eq '') { Write-Host '  已取消' -ForegroundColor Yellow; return }

    Write-Host '  分类编号：' -ForegroundColor Gray
    for ($i = 0; $i -lt $CategoryOrder.Count; $i++) { Write-Host "    $($i+1)) $($CategoryOrder[$i])" }
    $catInput = (Read-Host '  选编号（直接回车 = 1，也可自己输入新分类名）').Trim()
    $cat = $CategoryOrder[0]
    if ($catInput -match '^\d+$' -and [int]$catInput -ge 1 -and [int]$catInput -le $CategoryOrder.Count) {
        $cat = $CategoryOrder[[int]$catInput - 1]
    } elseif ($catInput -ne '') { $cat = $catInput }

    $keywords = (Read-Host '  关键词（逗号隔开，尽量写报错原文/命令）').Trim()
    if ($keywords -eq '') { $keywords = '待补关键词' }
    $slug = (Read-Host '  文件夹名（小写英文+短横线，例如 oci-rescue）').Trim()

    if ($slug -notmatch '^[a-z0-9]+(-[a-z0-9]+)*$') {
        Write-Host '  文件夹名不合规：只能用小写字母、数字和短横线。已取消。' -ForegroundColor Red; return
    }
    $target = Join-Path $Posts $slug
    if (Test-Path -LiteralPath $target) { Write-Host '  这个文件夹已存在，已取消。' -ForegroundColor Red; return }

    New-Item -ItemType Directory -Path (Join-Path $target 'images') -Force | Out-Null
    New-Item -ItemType File -Path (Join-Path $target 'images/.gitkeep') -Force | Out-Null

    $body = @'
<!-- meta
title: {{TITLE}}
category: {{CATEGORY}}
keywords: {{KEYWORDS}}
slug: {{SLUG}}
updated: {{DATE}}
-->

# {{TITLE}}

> 关键词：{{KEYWORDS}}
>
> 分类：{{CATEGORY}} ｜ 首次记录：{{DATE}} ｜ 最后验证：{{DATE}}
> 适用环境：<系统版本 / 机型 / 版本>

## 症状 / 我要解决什么

原样贴报错，**别改写、别润色**——以后就是靠这串字符搜回来的。

```
<粘贴报错原文>
```

## 结论（先写答案）

下次再来只看这一段就够。三行以内写清「是什么原因 / 该做哪一步」。

## 环境（脱敏）

- 机型 / 系统 / 版本：
- 关键标识：`<OCID>` / `<SERIAL>` / `<INSTANCE_ID>` / `<TOKEN>`

## 操作步骤

1.
2.

```bash
# 原样保留能跑通的命令
```

## 配图（可选）

图片放进本文件夹的 `images/`，正文写 `![说明](images/文件名.png)`，不用带文件夹名。

## 踩过的坑

- 现象 → 真实原因 → 怎么绕开
-

## 验证方式

```bash
<一条能判定成功与否的命令>
```

预期输出 / 预期状态：

## 关联

- [关键词速查表](KEYWORDS.md)
'@
    $body = $body.Replace('{{TITLE}}', $title).Replace('{{CATEGORY}}', $cat)
    $body = $body.Replace('{{KEYWORDS}}', $keywords).Replace('{{SLUG}}', $slug)
    $body = $body.Replace('{{DATE}}', (Get-Date -Format 'yyyy-MM-dd'))
    Write-Utf8NoBom (Join-Path $target 'README.md') ($body + "`n")

    Write-Host "  已创建 docs/posts/$slug/README.md" -ForegroundColor Green
    Invoke-Rebuild
    Write-Host '  下一步：用 VS Code 打开那篇 README.md 写内容，然后 git add . / commit / push' -ForegroundColor Gray
}

function Remove-Post {
    Write-Host ''
    Write-Host '=== 删除一篇文章 ===' -ForegroundColor Cyan
    if (-not (Test-PathsOk)) { Write-Host '  路径没对齐，已取消' -ForegroundColor Yellow; return }
    $posts = @(Get-Posts)
    if ($posts.Count -eq 0) { Write-Host '  没有文章可删' -ForegroundColor Yellow; return }
    for ($i = 0; $i -lt $posts.Count; $i++) {
        $t = '(无标题)'
        if ($null -ne $posts[$i].Meta -and $posts[$i].Meta.ContainsKey('title')) { $t = $posts[$i].Meta['title'] }
        Write-Host "  $($i+1)) $($posts[$i].Slug)  -  $t"
    }
    $n = (Read-Host '  输入编号（直接回车取消）').Trim()
    if ($n -eq '') { return }
    if ($n -notmatch '^\d+$' -or [int]$n -lt 1 -or [int]$n -gt $posts.Count) {
        Write-Host '  编号无效，已取消' -ForegroundColor Red; return
    }
    $p = $posts[[int]$n - 1]
    $ok = (Read-Host "  确认删除整个 docs/posts/$($p.Slug)/ ？(y/N)").Trim()
    if ($ok -ne 'y' -and $ok -ne 'Y') { Write-Host '  已取消' -ForegroundColor Yellow; return }
    Remove-Item -Path $p.Dir -Recurse -Force
    Write-Host "  已删除 $($p.Slug)，并自动重建目录（其他页面不受影响）" -ForegroundColor Green
    Invoke-Rebuild
}

# ---------------- 菜单 ----------------
Write-Host ('  当前 PowerShell 版本: v' + $PsMajor + '  （本工具 v2.1 兼容 v2.0 及以上）') -ForegroundColor Gray
while ($true) {
    Write-Host ''
    Write-Host '========================================' -ForegroundColor DarkCyan
    Write-Host '  折腾笔记 · 小工具 v2.1' -ForegroundColor Cyan
    Write-Host '========================================' -ForegroundColor DarkCyan
    Write-Host '  1) 新建一篇文章（自动建文件夹 + 写模板）'
    Write-Host '  2) 重建目录 + 体检（改完文章 / 手工删文件夹后跑）'
    Write-Host '  3) 删除一篇文章（删文件夹 + 自动重建）'
    Write-Host '  4) 退出'
    $c = (Read-Host '  选 1-4').Trim()
    switch ($c) {
        '1' { New-Post }
        '2' { Invoke-Rebuild }
        '3' { Remove-Post }
        '4' { Write-Host '  再见' -ForegroundColor Cyan; exit }
        default { Write-Host '  请输入 1-4' -ForegroundColor Yellow }
    }
}
