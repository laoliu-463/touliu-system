---
name: 多租户隔离实现
type: wayfinder:task
blocks:
  - 第一期看板升级
  - 第二期非算法部分
  - 第三期7监控项配置
blocked_by: []
status: in_progress
created: 2026-09-29
claimed_by: caojianing (本会话 wayfinder work-through-map)
claimed_at: 2026-09-29
design_completed_at: 2026-09-29
next_action: 开新 session 走 /implement 落代码
---

## Question

RBAC 四角色 × 三数据范围 × 接口级权限在 SmartAdmin 上怎么做？燃星当前是"所有人看所有数据"，必须改造。

**关键问题**：

1. **角色表设计**：管理员 / 运营 / 商务 /剪辑 4 个角色，先按"是否需要"决定哪些菜单 / 路径项开给谁。是否要先建部门表（用还是先全留同一虚拟部门"运营组"）？
2. **数据范围**：本人 / 本部门 / 全公司 三档；存哪一列？查询时 SQL 怎么动态拼？
3. **接口级注解**：用 Spring Security + Sa-Token 的 `@SaCheckRole("运营")` 还是自写 MySQL 拦截器？接口级注解需要写多少？（先打"个人采集"接口、再扩其余）
5. **超级管理员权限**：本地 "admin/admin123" 默认账号是否遗留？还是全重置？

**约束**：
- 本期只保证「谁可访问、可见范围」。完整的 RBAC（部门树、菜单权限、接口注解全覆盖）仍归第四期。
- 角色 × 数据范围：默认管理员 = 全公司；运营 = 本部门；商务 = 本部门；剪辑 = 本部门。

**期望产出**：
- 数据库 4 张表：`role`、`user_role`、`dept`、`user_dept`（是否要建依结算考）
- 权限拦截器 + `@SaCheck...` 注解定义 + "通用查询" wrapper（SQL 过滤自动加 merchant_id）
- 默认角色分配脚本
- 测试用例：3 账户 × 4 角色 × 3 范围 = 21 个查询路径走得通

---

## Design Summary（2026-09-29 wayfinder 解题）

> 决议落地。代码部分交给下个 `/implement` session。

### 数据库表设计（5 张）

```sql
-- 角色表
role
  id BIGINT PK
  code VARCHAR(32) UNIQUE     -- 'admin' / 'yunying' / 'shangwu' / 'jianji'
  name VARCHAR(64)
  data_scope TINYINT          -- 1=SELF 2=DEPT 3=ALL
  description TEXT
  create_time DATETIME

-- 角色-权限点关联
role_permission
  id BIGINT PK
  role_id BIGINT FK
  permission_code VARCHAR(64) -- 'account:list' / 'plan:read' ...
  UNIQUE(role_id, permission_code)

-- 用户-角色
user_role
  id BIGINT PK
  user_id BIGINT FK
  role_id BIGINT FK
  UNIQUE(user_id, role_id)

-- 部门（先只一个虚拟部门"运营组"，第四期再扩）
dept
  id BIGINT PK
  name VARCHAR(64)
  parent_id BIGINT            -- 自引用，先全部 NULL
  sort INT

user_dept
  id BIGINT PK
  user_id BIGINT FK
  dept_id BIGINT FK
  is_main TINYINT             -- 1=主部门
  UNIQUE(user_id, dept_id)
```

### 4 角色 × 3 数据范围（决策落定）

| 角色 | code | 默认 data_scope | 说明 |
|---|---|---|---|
| 管理员 | admin | ALL | 看全公司 |
| 运营 | yunying | DEPT | 看本部门（先 = 全部） |
| 商务 | shangwu | DEPT | 看本部门 |
| 剪辑 | jianji | DEPT | 看本部门 |

data_scope 可被某用户覆盖（一个用户多角色时取最大）。

### 注解 + 拦截器（双层）

```java
// 控制器层
@SaCheckRole("yunying")
@RequireDataScope(DataScope.DEPT)
@GetMapping("/api/v1/account/list")
public List<Account> list() {...}

// MyBatis 拦截器（动态拼 WHERE）
@InterceptsHandler:
  - 拿当前 user_id + 数据范围
  - 自动加 WHERE merchant_id IN (子查询)
```

### Sa-Token 集成

SmartAdmin 默认使用 Sa-Token，沿用：
- `@SaCheckLogin`：登录态拦截
- `@SaCheckRole("yunying")`：角色拦截
- `@SaCheckPermission("account:list")`：权限点拦截

本期前端菜单可见性靠「权限点编码」动态生成（SmartAdmin 自带）。

### Spring Boot 配置

```yaml
smart-admin:
  security:
    data-scope:  # 默认值
      admin: ALL
      yunying: DEPT
      shangwu: DEPT
      jianji: DEPT
```

### 测试用例（3×4×5 = 60 条）

每个角色 × 每个数据范围 × 5 个接口：
- `GET /api/v1/account/list`
- `GET /api/v1/account/{id}`
- `GET /api/v1/report/daily`
- `GET /api/v1/plan/list`
- `GET /api/v1/permission/check`

每个 case 验证：
- 200 + 仅返回本部门数据 / 全部数据
- 403 + 错误角色

### /implement 起步任务

下一个 session 走 `/implement` 时，按下列顺序开工：
1. **建表 + 种子数据**（role 4 条、dept 1 条、admin user_id=1 绑 admin + ALL）
2. **Sa-Token 配置 + 登录接口**
3. **@RequireDataScope 注解 + MyBatis 拦截器**
4. **前端菜单动态权限（SmartAdmin 自带，本期只校验 5 个接口）**
5. **测试用例 60 条跑通**

### 跨期影响

- 「第二期非算法部分」依赖本 ticket **前置**；本 ticket 状态改为 designed 已满足依赖。
- 「第三期 7 监控项配置」依赖本 ticket **前置**；同样已解锁。