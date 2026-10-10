SELECT '== F. 账户按授权 state 分布 ==' AS section;
SELECT a.state, auth.merchant_name, auth.auth_status, COUNT(a.advertiser_id) AS accounts
FROM qianchuan_account a LEFT JOIN qianchuan_authorization auth ON auth.state = a.state
GROUP BY 1,2,3 ORDER BY accounts DESC;

SELECT '== G. 各 state 的成功/失败覆盖账户数 ==' AS section;
SELECT a.state, c.status, COUNT(DISTINCT c.advertiser_id) AS accounts
FROM qianchuan_report_sync_coverage c JOIN qianchuan_account a ON a.advertiser_id = c.advertiser_id
GROUP BY 1,2 ORDER BY 1,2;

SELECT '== H. 每条授权名下账户数（从 advertiser_ids_json 数） ==' AS section;
SELECT id, state, merchant_name, auth_status,
       JSON_LENGTH(advertiser_ids_json) AS ids_len,
       access_expires_at, refresh_expires_at, LEFT(COALESCE(last_error,''),70) AS last_err
FROM qianchuan_authorization ORDER BY id;

SELECT '== I. topic_supported 按 state 分布 ==' AS section;
SELECT state, IFNULL(topic_supported,'NULL') AS topic_supported, COUNT(*) AS accounts
FROM qianchuan_account GROUP BY 1,2 ORDER BY 1,2;
