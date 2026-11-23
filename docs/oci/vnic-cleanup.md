# Bastion 残留 VNIC 删不掉、报 404 NotAuthorizedOrNotFound

> 关键词：`404 NotAuthorizedOrNotFound`、VNIC、Bastion、VCN 删不掉、`oci network vnic get --vnic-id`、Network Sources
> 分类：OCI / 云主机 ｜ 首次记录：YYYY-MM-DD ｜ 最后验证：YYYY-MM-DD
> 适用环境：OCI 控制台 + OCI CLI

## 症状 / 我要解决什么

清理账号残留资源时，控制台里找不到 Bastion 入口；删 VNIC 时返回 `404 NotAuthorizedOrNotFound`，VCN 因此一直删不掉。

```
<把当时的报错原文原样贴这里>
```

## 结论（先写答案）

`<把最终有效路径写这里：先从哪个资源反查 VNIC ID，再按什么顺序解除附着 / 删除>`。这里的 404 通常不是资源已不在，就是不在当前 compartment / region，先核对 ID 与作用域，别急着提权限工单。

## 环境（脱敏）

- 租户 / compartment：`<TENANCY>` / `<COMPARTMENT_ID>`
- 区域：`<REGION>`
- 资源 ID：`<VNIC_ID>` / `<VCN_ID>` / `<BASTION_ID>`

## 操作步骤

```bash
# 按 ID 反查 VNIC 是否还在、挂在哪个 compartment
oci network vnic get --vnic-id <VNIC_ID>

# <后续：解除附着 / 删 Bastion / 删子网 / 删 VCN 的实际命令>
```

## 踩过的坑

- 在 `Identity & Security > Network Sources` 里找 Bastion → 不在这个位置，正确入口是 `<补上>`
- 控制台与 CLI 不在同一 region / compartment → 表现成 404，先核对 `--region` 与 compartment
- 

## 验证方式

VCN 能正常删除，控制台列表不再出现残留 VNIC。

## 关联

- [systemd 日志与提示排查](systemd-log-check.md)
- [关键词速查表](../KEYWORDS.md)
