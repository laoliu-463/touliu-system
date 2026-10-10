---
name: 业绩算法ADR
type: wayfinder:grilling
blocks:
  - 第二期非算法部分
blocked_by: []
status: closed
created: 2026-09-29
claimed_by: caojianing (本会话 wayfinder work-through-map)
closed_at: 2026-09-29
resolution: see ADR

---

## Resolution

已决议，写入 ADR：`qianchuan-mvp-smartadmin/docs/adr/0001-业绩算法.md`。

| # | 项 | 决议 |
|---|---|---|
| 1 | 佣金率从哪来 | 人工录入（`account.commission_rate_pct`） |
| 2 | 退款是否扣 | 整笔扣：业绩 = (成交金额 − 退款金额) × 结算率 × 佣金率 |
| 3 | 结算率怎么进业绩 | × 1（`settlement_rate`，缺值按 1） |
| 4 | 代投服务费率 | 按消耗提成（`account.service_fee_rate_pct`） |
| 5 | 保本 ROI 公式 | 1 ÷ 毛利率（`product.gross_margin_pct`，毛利率 = 0 时保本 ROI = ∞） |
| 6 | 重算历史能力 | 手工重算按钮 → `/api/v1/performance/recompute` |

**业绩公式统一口径**：

```
分佣业绩 = max(0, 成交金额 − 退款金额) × settlement_rate × commission_rate
代投业绩 = 代投消耗 × service_fee_rate
保本ROI  = 1 / gross_margin_pct
```

**新增浮现票**：「业绩重算入口」（task）—— ADR 决议第 6 条「手工重算按钮」需要具体接口实现，归到第二期非算法部分票并行推进。
---

## Question

第二期的业绩怎么算？六件事要书面定下来，写成 ADR，归档到 `docs/adr/`。

| # | 待定项 | 关键问题 |
|---|---|---|
| 1 | **佣金率从哪来** | 账户表上人工录 vs 平台抽点回查 vs 商家授权时同步？三种方案哪个适合 11 个现有账户？ |
| 2 | **退款是否扣** | 整笔扣 / 按退款率扣 / 不扣？影响「扣退款后的 ROI」指标列。 |
| 3 | **结算率怎么进业绩** | 业绩按 `成交金额 × 佣金率` 直接算，还是按 `成交金额 × 结算率 × 佣金率`？结算率从哪查？ |
| 4 | **保本 ROI 算法** | 仅 `1 ÷ 毛利率`？还是要算进运费险 / 退货率 / 平台抽佣？ |
| 5 | **代投服务费率** | 按月包 vs 按消耗提成？与分佣业绩的口径差异是什么？ |
| 6 | **重算历史能力** | 需求文档第六章明令原始数与业绩分列存放。ADR 要规定怎么触发历史重算（手工按钮？定时任务？） |

**约束**：
- 第二期其他代码部分先做完，本 ADR 是最后一步。
- 算法列在重算之前全是 NULL；ADR 通过后由独立任务批量填。
- ADR 通过后改成 `wayfinder:decision` 标签、status 关闭，挂在地图的 `Decisions so far`。

**期望产出**：`docs/adr/NNNN-业绩算法.md`，含上下文 / 决策 / 权衡 / 反例。