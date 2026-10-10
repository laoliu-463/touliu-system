---
name: 七天token看门狗
type: wayfinder:task
blocks: []
blocked_by:
  - 燃星数据迁SmartAdmin
status: closed
created: 2026-09-29
closed_at: 2026-09-29
resolution: see ADR-0002

---

## Resolution（2026-09-29 grilling 12 题完结）

设计决议写入 ADR：`qianchuan-mvp-smartadmin/docs/adr/0002-token看门狗.md`。

**核心 8 项**：
1. 全 MySQL，不引 Redis
2. status 4 值 + phase 实时算（`TokenPhaseEvaluator`）
3. Spring Scheduler 3 分钟一轮，与第三期监控同 cron
4. 失败重试 3 次（30s/2min/5min 退避），中间告警，最终 EXPIRED
5. 商家提示：剩 1 天站内+飞书；剩 6 小时再追加一次
6. 心跳表 `watchdog_heartbeat`，10 分钟超时告警
7. 主表 + `token_history` 归档
8. 报表不动，账户表加 `last_synced_at`

**留给 `/implement` 的非设计项**：
- MySQL 连接池 ≥ 30（Q6 同 cron 衍生）
- 状态机阈值（access ≤ 1h / refresh ≤ 3d）实现时验证

ADR 跨期影响已写明：本票代码实现需与「燃星数据迁 SmartAdmin」对齐 schema、与「第三期告警 UI」共用 webhook 通道、与「第一期看板升级」联动 `last_synced_at`。
---

## Question

需求文档 1-2「凭证自动续期」：长凭证 7 天过期，到底怎么监控 + 怎么提醒 + 什么时候重做授权？

**银发规则（已定）**：
- short_token 剩 1 小时 → 自动用 refresh_token 换发（静默）
- long_token 剩 1 小时 → 自动用 refresh_token 换发（静默）
- refresh_token 剩 1 天 → 告警（站内收件箱 + 飞书 webhook）
- refresh_token 剩 3 天 → 提醒（站内收件箱）
- refresh_token 已过期 → 账户标红「需商家重授权」，看板顶部弹窗

**待解决问题**：

1. **状态定义**：表中需要哪些状态字段？`token_status`（VALID / EXPIRING_SOON / EXPIRED / REVOKED）是否够？
3. **调度怎么推**：Spring Boot 后台任务 每 3 分钟扫一轮所有 token 还是每次查询时检查？两者解耦出哪个最省钱？
4. **重授权流程**：商家重新授权后，老凭证怎么处理？双源快表中占位 还是直接废？
5. **看门狗自己要不要设快捷键个保证**：看门狗本身挂了怎么办？Spring Boot Actuator / 外部 ping？

**期望产出**：
- 数据库：新增 `token_status`、`token_last_refreshed_at`、`token_expires_at`、`refresh_token_expires_at`
- 调度任务：`TokenWatchdogService.java` 读 top_n + 调整状态
- 看门狗页面：管理员看 4 名状态表
- 看板顶部弹窗：账号列表 + 「提醒商家重授权」

**依赖**：本票需在「燃星数据迁 SmartAdmin」完成后进行（代码才动数据表）。