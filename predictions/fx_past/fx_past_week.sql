--
-- fx_past_week.sql
--

-- Usage: @fx_past_week.sql 2011-01-30

-- I use this script to get 1 week's worth of fx-prediction data.
-- This script depends on tables created by fx_past.sql
-- So, I should run fx_past.sql before I run fx_past_week.sql

-- Start by showing summarized data for each pair:

COLUMN pair             FORMAT A8  HEADING     'Currency|Pair'    
COLUMN avg_danbot_score FORMAT 9.99 HEADING    'Avg|DanBot|Score' 
COLUMN sharpe_ratio     FORMAT 9999.99 HEADING 'Sharpe|Ratio'  
COLUMN avg_1hr_n_gain   FORMAT 99.9999 HEADING 'Avg of|normalized|1hr gains'   
COLUMN avg_5hr_n_gain   FORMAT 99.9999 HEADING 'Avg of|normalized|5hr gains'   
COLUMN position_count   FORMAT 9999  HEADING   'Count of|positions'  
COLUMN sum_5hr_n_gain   FORMAT 99.9999 HEADING 'Sum of|normalized|5hr gains'   
COLUMN min_5hr_n_gain   FORMAT 99.9999 HEADING 'Min of|normalized|5hr gains'
COLUMN max_5hr_n_gain   FORMAT 99.9999 HEADING 'Max of|normalized|5hr gains'   
COLUMN stddev_5hr_n_gain FORMAT 99.9999 HEADING'Standard|Deviation|of normalized|5hr gains'

BREAK ON REPORT

COMPUTE SUM LABEL 'Sum:' OF sum_5hr_n_gain ON REPORT
COMPUTE SUM LABEL 'Sum:' OF position_count ON REPORT

SET TIME off TIMING off ECHO off PAGESIZE 123 LINESIZE 188
SET MARKUP HTML ON TABLE "class='table_fx_past_week'"
SPOOL /tmp/tmp_fx_past_week_&1

SELECT
pair
,ROUND(AVG(score_diff),2) avg_danbot_score
,ROUND(AVG(g5) / STDDEV(g5),2) sharpe_ratio
,ROUND(AVG(g1),4)   avg_1hr_n_gain
,ROUND(AVG(g5),4)   avg_5hr_n_gain
,COUNT(g5)          position_count
,ROUND(SUM(g5),4)   sum_5hr_n_gain
,ROUND(MIN(g5),4)   min_5hr_n_gain
,ROUND(MAX(g5),4)   max_5hr_n_gain
,ROUND(STDDEV(g5),4)stddev_5hr_n_gain
FROM fxpst12
WHERE rnng_crr1 > 0.1
AND score_diff < -0.55
AND ydate > '&1'
AND ydate - 7 < '&1'
AND g1 > -0.0004
AND price_6hr > 0
GROUP BY pair
HAVING(STDDEV(g5) > 0)
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
,ROUND(AVG(g5) / STDDEV(g5),2) sharpe_ratio
,ROUND(AVG(g1),4)   avg_1hr_n_gain
,ROUND(AVG(g5),4)   avg_5hr_n_gain
,COUNT(g5)          position_count
,ROUND(SUM(g5),4)   sum_5hr_n_gain
,ROUND(MIN(g5),4)   min_5hr_n_gain
,ROUND(MAX(g5),4)   max_5hr_n_gain
,ROUND(STDDEV(g5),4)stddev_5hr_n_gain
FROM fxpst12
WHERE rnng_crr1 > 0.1
AND score_diff > 0.55
AND ydate > '&1'
AND ydate - 7 < '&1'
AND g1 < 0.0004
AND price_6hr > 0
GROUP BY pair
HAVING(STDDEV(g5) > 0)
ORDER BY pair
/

SELECT anote FROM
(
SELECT'The above tables are summaries of predictions.'anote FROM dual
UNION
SELECT
'Individual high-confidence-predictions are displayed below should you want to load them into a spreadsheet.'
anote FROM dual
)
ORDER BY anote DESC
/

COLUMN timestamp_0hr FORMAT A11   HEADING 'GMT Time|at hour 0' 
COLUMN danbot_score FORMAT 9.99   HEADING 'DanBot|Score|at hour 0' 
COLUMN price_0hr    FORMAT 999.9999 HEADING 'Price at|hour 0'
COLUMN price_1hr    FORMAT 999.9999 HEADING 'Price after|1 hour'
COLUMN price_6hr    FORMAT 999.9999 HEADING 'Price after|6 hours'
COLUMN gain_1hr0hr  FORMAT  99.9999 HEADING '1 hour gain|between|hr0 and hr1'
COLUMN gain_6hr1hr  FORMAT  99.9999 HEADING '5 hour gain|between|hr1 and hr6'
COLUMN normalized_gain_5hr FORMAT 9.9999 HEADING 'Normalized|5hr gain'
COLUMN normalized_gain_1hr FORMAT 9.9999 HEADING 'Normalized|1hr gain'

SELECT
pair
,ydate timestamp_0hr
,ROUND(score_diff,4) danbot_score
,ROUND(price_0hr,4)  price_0hr
,ROUND(price_1hr,4)  price_1hr
,ROUND(price_6hr,4)  price_6hr
,ROUND(g1,4)         gain_1hr0hr
,ROUND(g5,4)         gain_6hr1hr
,ROUND(g1/price_0hr,4)normalized_gain_1hr
,ROUND(g5/price_0hr,4)normalized_gain_5hr
FROM fxpst12
WHERE rnng_crr1 > 0.1
AND score_diff < -0.55
AND ydate > '&1'
AND ydate - 7 < '&1'
AND g1 > -0.0004
AND price_6hr > 0
ORDER BY pair,ydate
/

SELECT
pair
,ydate timestamp_0hr
,ROUND(score_diff,4) danbot_score
,ROUND(price_0hr,4)  price_0hr
,ROUND(price_1hr,4)  price_1hr
,ROUND(price_6hr,4)  price_6hr
,ROUND(g1,4)         gain_1hr0hr
,ROUND(g5,4)         gain_6hr1hr
,ROUND(g1/price_0hr,4)normalized_gain_1hr
,ROUND(g5/price_0hr,4)normalized_gain_5hr
FROM fxpst12
WHERE rnng_crr1 > 0.1
AND score_diff > 0.55
AND ydate > '&1'
AND ydate - 7 < '&1'
AND g1 < 0.0004
AND price_6hr > 0
ORDER BY pair,ydate
/


SPOOL OFF
SET MARKUP HTML OFF

-- This is called by other sql scripts.
-- So, comment out exit:
-- exit
