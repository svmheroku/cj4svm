--
-- a1_fx_past_week.sql
--

-- usage: @a1_fx_past_week.sql 2011-07-17

-- I use this script to get 1 week's worth of fx-prediction data.
-- This script depends on tables created by fx_past.sql
-- So, I should run fx_past.sql before I run a1_fx_past_week.sql

-- Start by showing summarized data for each pair:

COLUMN pair             FORMAT A8  HEADING     'Currency|Pair'
COLUMN avg_danbot_score FORMAT 9.99 HEADING    'Avg|DanBot|Score' 
COLUMN sharpe_ratio     FORMAT 9999.99 HEADING 'Sharpe|Ratio'  
COLUMN avg_5hr_n_gain   FORMAT 99.9999 HEADING 'Avg of|normalized|5hr gains'   
COLUMN prediction_count   FORMAT 9999  HEADING   'Count of|predictions'  
COLUMN sum_5hr_n_gain   FORMAT 99.9999 HEADING 'Sum of|normalized|5hr gains'   

BREAK ON REPORT

COMPUTE SUM LABEL 'Sum:' OF sum_5hr_n_gain ON REPORT
COMPUTE SUM LABEL 'Sum:' OF prediction_count ON REPORT

SET TIME off TIMING off ECHO off PAGESIZE 123 LINESIZE 188
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

COLUMN anote FORMAT A120 HEADING 'Note:'

SELECT anote FROM
(
SELECT'When I sell, I want the gain to be negative, and when I buy I want it be positive.'anote FROM dual
UNION
SELECT'The table above displays negative DanBot scores which were signals to sell.'anote FROM dual
UNION
SELECT'Below, are positive DanBot scores which were signals to buy.'anote FROM dual
)
ORDER BY anote DESC
/

SELECT
pair
,ROUND(AVG(score_diff),2) avg_danbot_score
,ROUND(AVG(g5n) / STDDEV(g5n),2) sharpe_ratio
,ROUND(AVG(g5n),4)   avg_5hr_n_gain
,COUNT(g5n)          prediction_count
,ROUND(SUM(g5n),4)   sum_5hr_n_gain
FROM fxpst12
WHERE rnng_crr1 > 0.1
AND score_diff > 0.55
AND ydate > '&1'
AND ydate - 7 < '&1'
AND g1 < 0.0004
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
