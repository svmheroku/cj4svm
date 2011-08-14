--
-- qry_morn_after.sql
--

-- I use this query to study the effectiveness of combining a 
-- recent-market-close prediction with a morning-after price inspection.

-- For example, if I have a bullish-recent-market-close prediction on WMT at $49.66
-- and WMT opens the next day at $49.60, 
-- should I expect the prediction to still have predictive power?

-- Assume us_stk_pst13 was built by us_stk_past.sql


-- First look at all predictions distributed through the day,

SELECT
CASE WHEN SIGN(score_diff)>0 THEN'Bullish'ELSE'Bearish'END bullbear     
,ROUND(AVG(score_diff),2) avg_score_diff
,ROUND(AVG(g1hr),2)       avg_1hr_gain
,ROUND(AVG(g24hr),2)      avg_24hr_gain
,ROUND(SUM(g24hr),2)      sum_24hr_gain
,ROUND(AVG(g24hr)/STDDEV(g24hr),2) sharpe_ratio
,COUNT(g24hr)             prediction_count
FROM us_stk_pst13
WHERE ABS(score_diff) > 0.55
AND rnng_crr1 > 0
AND price_24hr > 0
AND ydate > sysdate - 120
GROUP BY SIGN(score_diff)
ORDER BY SIGN(score_diff)
/

-- Next look at all predictions distributed through the day,
-- Where I see "quiet" prices after 1 hour.

SELECT
CASE WHEN SIGN(score_diff)>0 THEN'Bullish'ELSE'Bearish'END bullbear     
,ROUND(AVG(score_diff),2) avg_score_diff
,ROUND(AVG(g1hr),2)      avg_1hr_gain
,ROUND(AVG(g24hr),2)      avg_24hr_gain
,ROUND(SUM(g24hr),2)      sum_24hr_gain
,ROUND(AVG(g24hr)/STDDEV(g24hr),2) sharpe_ratio
,COUNT(g24hr)             prediction_count
FROM us_stk_pst13
WHERE ABS(score_diff) > 0.55
AND rnng_crr1 > 0
AND price_24hr > 0
AND ydate > sysdate - 120
-- Specify "quiet"price here:
AND ABS(g1hr / price_0hr)< 1/100
GROUP BY SIGN(score_diff)
ORDER BY SIGN(score_diff)
/

-- Next look at all predictions distributed through the day,
-- Where I see improved prices after 1 hour.

SELECT
CASE WHEN SIGN(score_diff)>0 THEN'Bullish'ELSE'Bearish'END bullbear     
,ROUND(AVG(score_diff),2) avg_score_diff
,ROUND(AVG(g1hr),2)      avg_1hr_gain
,ROUND(AVG(g24hr),2)      avg_24hr_gain
,ROUND(SUM(g24hr),2)      sum_24hr_gain
,ROUND(AVG(g24hr)/STDDEV(g24hr),2) sharpe_ratio
,COUNT(g24hr)             prediction_count
FROM us_stk_pst13
WHERE ABS(score_diff) > 0.55
AND rnng_crr1 > 0
AND price_24hr > 0
AND ydate > sysdate - 120
-- Specify price improvement here:
AND g1hr * SIGN(score_diff)<0
GROUP BY SIGN(score_diff)
ORDER BY SIGN(score_diff)
/

-- Next look at all predictions distributed through the day,
-- Where I see un-improved prices after 1 hour.

SELECT
CASE WHEN SIGN(score_diff)>0 THEN'Bullish'ELSE'Bearish'END bullbear     
,ROUND(AVG(score_diff),2) avg_score_diff
,ROUND(AVG(g1hr),2)      avg_1hr_gain
,ROUND(AVG(g24hr),2)      avg_24hr_gain
,ROUND(SUM(g24hr),2)      sum_24hr_gain
,ROUND(AVG(g24hr)/STDDEV(g24hr),2) sharpe_ratio
,COUNT(g24hr)             prediction_count
FROM us_stk_pst13
WHERE ABS(score_diff) > 0.55
AND rnng_crr1 > 0
AND price_24hr > 0
AND ydate > sysdate - 120
-- Specify price un-improvement here:
AND g1hr * SIGN(score_diff)>0
GROUP BY SIGN(score_diff)
ORDER BY SIGN(score_diff)
/

-- Next look at all recent-market-close predictions

SELECT
CASE WHEN SIGN(score_diff)>0 THEN'Bullish'ELSE'Bearish'END bullbear     
,ROUND(AVG(score_diff),2) avg_score_diff
,ROUND(AVG(g1hr),2)       avg_1hr_gain
,ROUND(AVG(g24hr),2)      avg_24hr_gain
,ROUND(SUM(g24hr),2)      sum_24hr_gain
,ROUND(AVG(g24hr)/STDDEV(g24hr),2) sharpe_ratio
,COUNT(g24hr)             prediction_count
FROM us_stk_pst13
WHERE ABS(score_diff) > 0.55
AND rnng_crr1 > 0
AND price_24hr > 0
AND ydate > sysdate - 120
-- Specify recent-market-close here:
AND 0+TO_CHAR(ydate,'HH24') > 18
GROUP BY SIGN(score_diff)
ORDER BY SIGN(score_diff)
/

-- Next look at all recent-market-close predictions
-- Where I see "quiet" prices after 1 hour.

SELECT
CASE WHEN SIGN(score_diff)>0 THEN'Bullish'ELSE'Bearish'END bullbear     
,ROUND(AVG(score_diff),2) avg_score_diff
,ROUND(AVG(g1hr),2)      avg_1hr_gain
,ROUND(AVG(g24hr),2)      avg_24hr_gain
,ROUND(SUM(g24hr),2)      sum_24hr_gain
,ROUND(AVG(g24hr)/STDDEV(g24hr),2) sharpe_ratio
,COUNT(g24hr)             prediction_count
FROM us_stk_pst13
WHERE ABS(score_diff) > 0.55
AND rnng_crr1 > 0
AND price_24hr > 0
AND ydate > sysdate - 120
-- Specify "quiet"price here:
AND ABS(g1hr / price_0hr)< 1/100
-- Specify recent-market-close here:
AND 0+TO_CHAR(ydate,'HH24') > 18
GROUP BY SIGN(score_diff)
ORDER BY SIGN(score_diff)
/

-- Next look at all recent-market-close predictions
-- Where I see improved prices after 1 hour.

SELECT
CASE WHEN SIGN(score_diff)>0 THEN'Bullish'ELSE'Bearish'END bullbear     
,ROUND(AVG(score_diff),2) avg_score_diff
,ROUND(AVG(g1hr),2)      avg_1hr_gain
,ROUND(AVG(g24hr),2)      avg_24hr_gain
,ROUND(SUM(g24hr),2)      sum_24hr_gain
,ROUND(AVG(g24hr)/STDDEV(g24hr),2) sharpe_ratio
,COUNT(g24hr)             prediction_count
FROM us_stk_pst13
WHERE ABS(score_diff) > 0.55
AND rnng_crr1 > 0
AND price_24hr > 0
AND ydate > sysdate - 120
-- Specify price improvement here:
AND g1hr * SIGN(score_diff)<0
-- Specify recent-market-close here:
AND 0+TO_CHAR(ydate,'HH24') > 18
GROUP BY SIGN(score_diff)
ORDER BY SIGN(score_diff)
/

-- Next look at all recent-market-close predictions
-- Where I see un-improved prices after 1 hour.

SELECT
CASE WHEN SIGN(score_diff)>0 THEN'Bullish'ELSE'Bearish'END bullbear     
,ROUND(AVG(score_diff),2) avg_score_diff
,ROUND(AVG(g1hr),2)      avg_1hr_gain
,ROUND(AVG(g24hr),2)      avg_24hr_gain
,ROUND(SUM(g24hr),2)      sum_24hr_gain
,ROUND(AVG(g24hr)/STDDEV(g24hr),2) sharpe_ratio
,COUNT(g24hr)             prediction_count
FROM us_stk_pst13
WHERE ABS(score_diff) > 0.55
AND rnng_crr1 > 0
AND price_24hr > 0
AND ydate > sysdate - 120
-- Specify price un-improvement here:
AND g1hr * SIGN(score_diff)>0
-- Specify recent-market-close here:
AND 0+TO_CHAR(ydate,'HH24') > 18
GROUP BY SIGN(score_diff)
ORDER BY SIGN(score_diff)
/

exit
