---
name: 业绩重算入口
type: wayfinder:task
blocks: []
blocked_by:
  - 第二期非算法部分
status: open
created: 2026-09-29
---

## Question

ADR-0001 决议第 6 条「重算历史能力 = 手工重算按钮」。要做：

1. **接口**：`POST /api/v1/performance/recompute`，body 含 `period`（YYYY-MM 或日期范围）、`account_ids`（可选）、`mode`（dry-run / actual）。
2. **页面**：在「业绩报表」页面右上角加「重算本月 / 重算上月」按钮。dry-run 模式先弹窗"将重算 X 条，预计 Y 秒"，点确认后真跑；actual 模式需要管理员二次确认。
3. **调度**：「手工重算」按钮触发 Spring `@Async` 任务，跑完写一条 `recompute_log`（期间、重算条数、耗时、失败账户数）。
5. **接哪类业务凭证**：点动作靠谁控制？仅「管理员」能点。其他角色看报表不点。
7. **限算逻辑**：
   - dry-run：只算不算库，返回预计金额。
   - actual：UPSERT 到 `account_performance_daily`、`product_performance_daily`、`plan_performance_daily` 三张表。不动原始 `report_daily`。
6. **告警**：重算报错（估报报表、报表报表）走「第三期告警UI」推送、给接「重算」换原动者。

**期望产出**：
- 1 接口 × 1 页面 × 1 调度 × 1 log 表
- 「重算本月」「重算上月」按钮
- 「完成」提示需含「重算 X 跳」

**依赖**：本票需在「第二期非算法部分」完成后进行（该表才存报表、业绩列）。