---
name: 评论接口地址
type: wayfinder:research
blocks:
  - 第三期评论与屏蔽词
blocked_by: []
status: open
created: 2026-09-29
---

## Question

「评论查看、回复、隐藏」 「评论屏蔽词」 接口从哪接？

需求文档第五章 5.4 明确：**评论接口地址不带 qianchuan 字样**，在 `v3.0/tools/comment/` 下。按关键词搜很容易找不到。

**主要问题**：

1. **取接口清单**：从 `ad_open_sdk_java/` 里查 `v3.0/tools/comment/` 下的所有接口。完整列表跳到 `docs/sdk-comment-api.md`。
2. **接哪些**：评论列表 / 隐藏评论 / 评论回复 / 屏蔽词 CRUD。限制以下接口、不限其他接口。
3. **鉴权方式**：是 商户 token 还是身份 token？与「装凭证」token 有何区别？是否需要拓跱鉴权别 ？
4. **限频接口** (QPS 限制)：默认限频。会不会装得太勤被限频？看是否要 「拉评论」 默认 10 分钟一次还是 3 分钟一次。

**期望产出**：
- `docs/sdk-comment-api.md`：记录接口路径 × 鉴权方式 × QPS 限制 × 实际验证过的代罍（Python 调用 demo + Java 调用示例）

**依赖**：这是「第三期评论与屏蔽词」任务票的前置。