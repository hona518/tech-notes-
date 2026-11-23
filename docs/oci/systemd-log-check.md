# oci-worker 部署后提示「立即查看 systemd 日志」怎么判

> 关键词：`journalctl -xe`、`systemctl --failed`、`systemctl list-units "*oci*" --all`、`journalctl -u oci-worker.service`、`active (running)`、部署脚本提示
> 分类：OCI / 云主机 ｜ 首次记录：YYYY-MM-DD ｜ 最后验证：YYYY-MM-DD
> 适用环境：OCI 实例 / Linux + systemd，部署 oci-manager / oci-worker

## 症状 / 我要解决什么

部署脚本跑完弹出「立即查看 systemd 日志」，不确定是真挂了，还是脚本的固定提示。

## 结论（先写答案）

先别急着改配置：按下面四条查完，若 `oci-worker.service` 为 `active (running)` 且 `systemctl --failed` 为空，就是**部署脚本的通用提示，不是故障**。

## 环境（脱敏）

- 实例：`<INSTANCE_ID>` / `<REGION>` / `<OS 版本>`
- 服务：oci-worker.service、oci-manager.service
- 账号标识：`<TENANCY>` / `<COMPARTMENT_ID>`

## 操作步骤

```bash
# 1. 最近全局日志，快速看有没有炸
journalctl -xe --no-pager -n 80

# 2. 有没有处于 failed 的单元
systemctl --failed

# 3. 找出所有 oci 相关单元
systemctl list-units "*oci*" --all

# 4. 盯住目标服务：先看历史，再实时跟
journalctl -u oci-worker.service -n 50 --no-pager
journalctl -u oci-worker.service -f
```

## 踩过的坑

- 只看脚本提示就以为服务挂了，实际 `active (running)`、无失败单元
- 日志刷太快 → 先加 `--no-pager -n 50` 截断，别一上来就 `-f` 从头追
- 服务名猜错 → 用 `list-units "*oci*" --all` 先把真实单元名捞出来
-

## 验证方式

`systemctl --failed` 无输出，且 `systemctl is-active oci-worker.service` 返回 `active`。

## 关联

- [Bastion 残留 VNIC 删除报 404](vnic-cleanup.md)
- [关键词速查表](../KEYWORDS.md)
