SELECT '== 1. 授权状态 ==' AS section;
SELECT auth_status, merchant_account_type, merchant_account_role, COUNT(*) AS cnt
FROM qianchuan_authorization GROUP BY 1,2,3;

SELECT '== 2. 账户总数与 topic_supported 分布 ==' AS section;
SELECT COUNT(*) AS total_accounts,
       SUM(topic_supported = 'YES') AS topic_yes,
       SUM(topic_supported = 'NO')  AS topic_no,
       SUM(topic_supported IS NULL) AS topic_unknown
FROM qianchuan_account;

SELECT '== 3. 账户类型/状态分布 ==' AS section;
SELECT account_status, account_role, COUNT(*) AS cnt
FROM qianchuan_account GROUP BY 1,2 ORDER BY cnt DESC;

SELECT '== 4. 有报表数据的账户 ==' AS section;
SELECT COUNT(DISTINCT advertiser_id) AS accounts_with_rows,
       COUNT(*) AS total_rows,
       MIN(stat_time_hour) AS earliest,
       MAX(stat_time_hour) AS latest,
       SUM(stat_cost) AS sum_stat_cost,
       SUM(pay_order_gmv) AS sum_gmv
FROM qianchuan_report_hour;

SELECT '== 5. 覆盖表按状态汇总（近 14 天） ==' AS section;
SELECT stat_date, status, COUNT(*) AS accounts, SUM(row_count) AS rows_sum
FROM qianchuan_report_sync_coverage
WHERE stat_date >= DATE_SUB(CURDATE(), INTERVAL 14 DAY)
GROUP BY 1,2 ORDER BY 1 DESC, 3 DESC;

SELECT '== 6. 覆盖表状态全局分布 ==' AS section;
SELECT status, COUNT(*) AS cnt, COUNT(DISTINCT advertiser_id) AS accounts
FROM qianchuan_report_sync_coverage GROUP BY 1;

SELECT '== 7. 非成功原因的 Top 错误 ==' AS section;
SELECT LEFT(COALESCE(error_message,'(null)'),90) AS err, COUNT(*) AS cnt
FROM qianchuan_report_sync_coverage
WHERE status <> 'SUCCESS'
GROUP BY 1 ORDER BY cnt DESC LIMIT 12;

SELECT '== 8. 每个账户的最新覆盖状态 ==' AS section;
SELECT c.status, COUNT(*) AS accounts
FROM qianchuan_report_sync_coverage c
JOIN (SELECT advertiser_id, MAX(stat_date) AS md
      FROM qianchuan_report_sync_coverage GROUP BY advertiser_id) t
  ON c.advertiser_id = t.advertiser_id AND c.stat_date = t.md
GROUP BY 1;

SELECT '== 9. 最近 10 个同步任务 ==' AS section;
SELECT id, sync_type, status, account_count, row_count,
       start_time, end_time, LEFT(COALESCE(error_message,''),60) AS err
FROM qianchuan_sync_job ORDER BY id DESC LIMIT 10;

SELECT '== 10. 目录数据落库情况 ==' AS section;
SELECT (SELECT COUNT(*) FROM qianchuan_plan) AS plans,
       (SELECT COUNT(DISTINCT advertiser_id) FROM qianchuan_plan) AS plan_accounts,
       (SELECT COUNT(*) FROM qianchuan_product) AS products,
       (SELECT COUNT(DISTINCT advertiser_id) FROM qianchuan_product) AS product_accounts,
       (SELECT COUNT(*) FROM qianchuan_material) AS materials,
       (SELECT COUNT(DISTINCT advertiser_id) FROM qianchuan_material) AS material_accounts,
       (SELECT COUNT(*) FROM qianchuan_account_balance) AS balances;
