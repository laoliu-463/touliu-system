SELECT '== A. 10-01 各状态的时间夹区间 ==' AS section;
SELECT status, COUNT(*) AS accounts,
       MIN(fetched_at) AS first_at, MAX(fetched_at) AS last_at
FROM qianchuan_report_sync_coverage
WHERE stat_date = '2026-10-01' GROUP BY status ORDER BY last_at;

SELECT '== B. 按 fetched_at 每 10 分钟看状态走向 ==' AS section;
SELECT DATE_FORMAT(fetched_at, '%H:%i') AS minute_bucket, status, COUNT(*) AS cnt
FROM qianchuan_report_sync_coverage
WHERE stat_date = '2026-10-01' AND fetched_at IS NOT NULL
GROUP BY 1,2 ORDER BY 1,2;

SELECT '== C. 失败账户的 FAILED 时间是否晚于其最后一个 SUCCESS ==' AS section;
SELECT SUM(f.fail_at > s.ok_at) AS fail_after_success,
       SUM(f.fail_at < s.ok_at) AS fail_before_success,
       COUNT(*) AS accounts_with_both
FROM (SELECT advertiser_id, MAX(fetched_at) AS fail_at
      FROM qianchuan_report_sync_coverage WHERE status='FAILED' GROUP BY advertiser_id) f
JOIN (SELECT advertiser_id, MAX(fetched_at) AS ok_at
      FROM qianchuan_report_sync_coverage WHERE status='SUCCESS' GROUP BY advertiser_id) s
  ON f.advertiser_id = s.advertiser_id;

SELECT '== D. 账户覆盖天数汇总（成功几天） ==' AS section;
SELECT days_covered, COUNT(*) AS accounts FROM (
  SELECT advertiser_id, SUM(status='SUCCESS') AS days_covered
  FROM qianchuan_report_sync_coverage GROUP BY advertiser_id
) t GROUP BY 1 ORDER BY 1 DESC;

SELECT '== E. 有失败记录的账户，其成功记录是否也存在 ==' AS section;
SELECT SUM(fail_only) AS accounts_fail_only, SUM(mixed) AS accounts_both, SUM(ok_only) AS accounts_ok_only
FROM (
  SELECT advertiser_id,
         SUM(status='FAILED') > 0 AND SUM(status='SUCCESS') = 0 AS fail_only,
         SUM(status='FAILED') > 0 AND SUM(status='SUCCESS') > 0 AS mixed,
         SUM(status='FAILED') = 0 AS ok_only
  FROM qianchuan_report_sync_coverage GROUP BY advertiser_id
) x;
