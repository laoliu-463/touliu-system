---
name: 飞书webhook最佳实践
type: wayfinder:research
blocks:
  - 第三期告警UI
blocked_by: []
status: open
created: 2026-09-29
---

## Question

飞书 webhook 推送「告警」 怎么调？能调什么？需装 token 还是 只调 URL？

**主要问题**：

1. **webhook 两种**：机器人 webhook（任意 URL） vs 应用 webhook（需装 token）。选哪个？
2. **消息类型**：文本 / 富文本卡片 / 交互卡片。选哪个? 哪种能 「点击跳转 SmartAdmin 告警中心详情」？
3. **签名验证**：是否需要 ？企业微信有签名。飞书是否需要 ？需装什么？
4. **富文本卡片 能调 “多个 badge + 多个文本” 吗？」：如「消耗告警」× 「Token 过期」 × 「评论命中」 能不能用同一发卡片？
6. **限频限制**：是否限频？是否需手动重试？

**期望产出**：
- `docs/feishu-webhook-implementation.md`：记录 webhook 类型 × 消息格式 × 限制 × Java 发送示例

**依赖**：这是「第三期告警UI」任务票的前置。