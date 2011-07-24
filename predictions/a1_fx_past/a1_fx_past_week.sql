--
-- a1_fx_past_week.sql
--

-- usage: @a1_fx_past_week.sql 2011-07-17
SET MARKUP HTML ON TABLE "class='table_a1_fx_past_week'"
SPOOL /tmp/tmp_a1_fx_past_week_&1

SELECT
pair
,ROUND(AVG(score_diff),2) avg_danbot_score
,ROUND(AVG(g5n) / STDDEV(g5n),2) sharpe_ratio
,ROUND(AVG(g5n),4)   avg_5hr_n_gain
,COUNT(g5n)          prediction_count
,ROUND(SUM(g5n),4)   sum_5hr_n_gain
FROM fxpst12
WHERE rnng_crr1 > 0.1
AND score_diff < -0.55
AND ydate > '&1'
AND ydate - 7 < '&1'
AND g1 > -0.0004
AND price_6hr > 0
GROUP BY pair
HAVING(STDDEV(g5n) > 0)
ORDER BY pair
/


SPOOL OFF
SET MARKUP HTML OFF

-- This is called by other sql scripts.
-- So, comment out exit:
-- exit
