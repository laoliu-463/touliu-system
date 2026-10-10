---
name: 第一期看板升级
type: wayfinder:task
blocks: []
blocked_by:
  - 燃星数据迁SmartAdmin
  - 多租户隔离实现
status: open
created: 2026-09-29
---

## Question

燃星现有看板只是 Jinja2 单页「按商户和账户展示消耗、成交、ROI」。SmartAdmin 要全面重写。第一期看板需求文档第四章 1-5 要求：

- 按商户 × 账户二维展示
- 指标：消耗、成交金额、成交单数、ROI、可选日期范围

**待解决**：

1. **日期范围组件**：Vue 3 + TS + Ant Design Vue 下的 `RangePicker`、预设对照表还是大表？首期看板是否留预设（今日/昨日/近 7/近 30/本月）？
2. **下钻**：从账户下钻到计划？需求是 2-3 需 要，本期只做到计划列表可看、点击看详情。还是本期只到账户层？
3. **导出**：是否要 Excel / CSV 导出？需看板是否需包含图表导航（折线 / 柱状）？
4. **商家隔离**：完全靠「多租户隔离实现」票产生的 RBAC。
5. **状态**：页面别让空数据崩溃（需求文档第七章）。
6. **「数据截至 X 日」提示**：哪些场景要表诉？账户被划掉、数据被限走 / 拉取失败。

**期望产出**：
- Vue 页面：`/dashboard/account-consume` + `/dashboard/account-detail/:id`
- 后端接口：`GET /api/v1/dashboard/account-consume`、`GET /api/v1/dashboard/account-detail`
- 报表 SQL：按 `period × aggregate` 的查询模板填充
- 测试用例：11 账户 × 30 天 × 7 名状态路径

**依赖**：燃星迁完后可接。多租户隔离实现完成后可拍RBAC。