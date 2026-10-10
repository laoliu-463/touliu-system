---
name: 燃星数据迁SmartAdmin
type: wayfinder:task
blocks:
  - 第一期看板升级
  - 多租户隔离实现
blocked_by: []
status: open
created: 2026-09-29
---

## Question

11 个千川账户的真实数据从 `燃星-千川系统/`（Python + FastAPI + SQLite）迁到 SmartAdmin（Java 17 + TS + MySQL）要怎么做？

**关键问题**：

1. **凭证迁移**：燃星的 `refresh_token` + `access_token` + `expires_in` + `state`（即 `real-merchant-001`）怎么导到 SmartAdmin 的 `token` 表？约束：迁完时 token 剩余有效期必须 ≥ 7 天（否则触发续授权流程）。
2. **账户表对齐**：燃星 `advertiser` 表字段（`advertiser_id`、`state`、`name`、`company`、`industry`、`raw_json`）映射到需求文档第六章的"账户表"需要补哪些列？（合作方式、运营人、商务人、授权到期时间、余额 — 燃星当前没存）
3. **日报表数据保留**：燃星 `report_daily` 现有 8-29~8-31 三天的 12 条数据是否迁？还是只迁表结构、重新拉历史？哪种更可控？
4. **OAuth 流程切换**：迁完后商家授权回调要切到 SmartAdmin 的 `/api/oauth/callback`。新发的授权链接要带 SmartAdmin 的 `state` 标识，区分「这是 SmartAdmin 发的、不是燃星发的」。
5. **过渡期双写？单写？**：迁完后燃星是否冻结为只读（决策 #3）？期间是否有重叠跑数据？

**操作类（不是答案，列在工作清单上）**：
- A. 写迁移脚本（Python 读 SQLite → 生成 MySQL INSERT 脚本）
- B. 改 SmartAdmin 数据库 schema，对齐需求文档第六章
- C. OAuth 链路接通并测试
- D. 回滚预案（迁完发现回不去怎么办？保留燃星能反向同步回去）

**期望产出**：
- 一个迁移脚本 + 一份回滚脚本（落在 `qianchuan-mvp-smartadmin/smart-admin-api-java17-springboot3/scripts/`）
- 11 个账户迁移完成清单（账户名、迁完时间、token 剩余有效期）
- 文档：迁移日期、操作人、失败账户、后续续授权提醒日期