--
-- us_stk_past_week.sql
--

-- Usage: @us_stk_past_week.sql 2011-05-02

-- I use this script to get 1 week's worth of us_stk-prediction data.
-- This script depends on tables created by us_stk_past.sql
-- So, I should run us_stk_past.sql before I run us_stk_past_week.sql

-- Start by showing summarized data for each tkr:

COLUMN tkr FORMAT A8  HEADING  'Stock|Ticker'
COLUMN avg_tkr_price    FORMAT 9999.99  HEADING 'Avg|Ticker|Price|at Hour 0'
COLUMN avg_danbot_score FORMAT 9.99    HEADING 'Avg|DanBot|Score|at Hour 0'
COLUMN sharpe_ratio     FORMAT 9999.99 HEADING 'Sharpe|Ratio'  
COLUMN avg_24hr_gain    FORMAT 999.99  HEADING 'Avg|24hr|Gain'
COLUMN position_count   FORMAT 99999   HEADING 'Count of|positions'  
COLUMN sum_24hr_gain    FORMAT 99999.99 HEADING 'Sum of|24hr gains'   
COLUMN avg_1hr_gain     FORMAT 999.99  HEADING 'Avg|1hr|Gain'
COLUMN stddev_24hr_gain FORMAT 999.99 HEADING 'Standard|Deviation|of 24hr gains'   

BREAK ON REPORT

COMPUTE SUM LABEL 'Sum:' OF sum_24hr_gain ON REPORT
COMPUTE SUM LABEL 'Sum:' OF position_count ON REPORT

SET TIME off TIMING off ECHO off PAGESIZE 9999 LINESIZE 188
SET MARKUP HTML ON TABLE "class='table_us_stk_past_week'"
SPOOL /tmp/tmp_us_stk_past_week_&1

SELECT
tkr
,ROUND(AVG(price_0hr),2)  avg_tkr_price
,ROUND(AVG(score_diff),2) avg_danbot_score
,CASE WHEN STDDEV(g24hr)=0 THEN ROUND((AVG(g24hr)/0.01),2)
 ELSE ROUND((AVG(g24hr)/STDDEV(g24hr)),2) END sharpe_ratio
,ROUND(AVG(g1hr),2)    avg_1hr_gain
,ROUND(AVG(g24hr),2)   avg_24hr_gain
,COUNT(g24hr)          position_count
,ROUND(SUM(g24hr),2)   sum_24hr_gain
,ROUND(STDDEV(g24hr),2)stddev_24hr_gain
FROM us_stk_pst13
WHERE rnng_crr1 > 0
AND score_diff < -0.55
AND ydate > '&1'
AND ydate - 7 < '&1'
AND g24hr != 0
GROUP BY tkr
ORDER BY tkr
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
tkr
,ROUND(AVG(price_0hr),2)  avg_tkr_price
,ROUND(AVG(score_diff),2) avg_danbot_score
,CASE WHEN STDDEV(g24hr)=0 THEN ROUND((AVG(g24hr)/0.01),2)
 ELSE ROUND((AVG(g24hr)/STDDEV(g24hr)),2) END sharpe_ratio
,ROUND(AVG(g1hr),2)    avg_1hr_gain
,ROUND(AVG(g24hr),2)   avg_24hr_gain
,COUNT(g24hr)          position_count
,ROUND(SUM(g24hr),2)   sum_24hr_gain
,ROUND(STDDEV(g24hr),2)stddev_24hr_gain
FROM us_stk_pst13
WHERE rnng_crr1 > 0
AND score_diff > 0.55
AND ydate > '&1'
AND ydate - 7 < '&1'
AND g24hr != 0
GROUP BY tkr
ORDER BY tkr
/

SELECT anote FROM
(
SELECT'The above tables are summaries of predictions.'anote FROM dual
UNION
SELECT
'Individual high-confidence-predictions are displayed below should you want to load them into a spreadsheet.'anote FROM dual
)
ORDER BY anote DESC
/

COLUMN tkr FORMAT A10  HEADING  'Stock|Ticker'
COLUMN gmt_time_at_hr0 FORMAT A19  HEADING 'GMT Time|at hour 0' 
COLUMN price_at_hr0 FORMAT 9999.99 HEADING 'Price|at|Hour 0'
COLUMN danbot_score FORMAT 9.99    HEADING 'DanBot|Score at|Hour 0'
COLUMN gain_at_hr1  FORMAT 9999.99 HEADING 'Gain|at|Hour 1'
COLUMN gain_at_hr24 FORMAT 9999.99 HEADING 'Gain|at|Hour 24'

BREAK ON tkr
COMPUTE SUM LABEL 'Subtotal:' OF gain_at_hr24 ON tkr

SELECT
tkr
,ydate gmt_time_at_hr0
,ROUND(price_0hr,2)  price_at_hr0           
,ROUND(score_diff,2) danbot_score           
,ROUND(g1hr,2)       gain_at_hr1            
,ROUND(g24hr,2)      gain_at_hr24           
FROM us_stk_pst13
WHERE rnng_crr1 > 0
AND ABS(score_diff) > 0.55
AND ydate > '&1'
AND ydate - 7 < '&1'
AND g24hr != 0
ORDER BY SIGN(score_diff),tkr,ydate
/

SPOOL OFF
SET MARKUP HTML OFF

-- This is called by other sql scripts.
-- So, comment out exit:
-- exit
