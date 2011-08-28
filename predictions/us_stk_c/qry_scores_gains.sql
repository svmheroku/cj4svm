--
-- qry_scores_gains.sql
--

-- I use this script to help me answer the question,
-- "How useful is the 1 hour gain, g1hr, of a prediction?"

-- Create a useful view:

CREATE OR REPLACE VIEW scores_gains AS
SELECT
tkr
,ydate
,price_0hr
,score_diff score
,g1hr
,g24hr
,(g24hr - g1hr) g23hr
,CASE WHEN SIGN(score_diff)>0 THEN'Bullish'ELSE'Bearish'END bullbear
,CASE WHEN SIGN(g1hr * g24hr)>0 THEN'Same_Direction'ELSE'Diff_Direction'END g1g24_directions
,STDDEV(g1hr)OVER(PARTITION BY tkr ORDER BY ydate ROWS BETWEEN 1234 PRECEDING AND CURRENT ROW) g1hr_stddev
FROM us_stk_pst13
WHERE ABS(score_diff) > 0.55
AND rnng_crr1 > 0
AND price_24hr > 0
AND ydate > sysdate - 120
/

-- rpt
SET LINES 55
DESC scores_gains
SET LINES 188
SELECT COUNT(g1hr)FROM scores_gains;

COLUMN bullbear         FORMAT A11     HEADING 'Bullish|or Bearish'
COLUMN g1g24_directions FORMAT A16     HEADING 'g1hr Direction|Same as g24hr?'
COLUMN corr_g1_g23      FORMAT 9.99    HEADING 'Corr. between|g1hr and g23hr'
COLUMN g1hr_size        FORMAT A7     HEADING 'g1hr|Size'
COLUMN sharpe_ratio     FORMAT 9.99    HEADING 'Sharpe|Ratio'
COLUMN prediction_count FORMAT 9999999 HEADING 'Predection|Count'

-- Look for CORR() between score and g23hr.
-- Look for CORR() between g1hr and g23hr.
SELECT
bullbear
,ROUND(CORR(g1hr,g23hr),2) corr_g1_g23
,ROUND(AVG(g23hr)/STDDEV(g23hr),3) sharpe_ratio
,COUNT(g23hr) prediction_count
,TO_CHAR(MIN(ydate),'YYYY-MM-DD') min_date
,TO_CHAR(MAX(ydate),'YYYY-MM-DD') max_date
FROM scores_gains
GROUP BY bullbear
ORDER BY bullbear
/

-- Look at SPY ETF at min and max dates
SELECT price_0hr 
FROM scores_gains
WHERE tkr = 'SPY'
AND ydate = (SELECT MIN(ydate)FROM scores_gains WHERE tkr = 'SPY')
/

SELECT price_0hr 
FROM scores_gains
WHERE tkr = 'SPY'
AND ydate = (SELECT MAX(ydate)FROM scores_gains WHERE tkr = 'SPY')
/

-- Look for CORR() between score, and g23hr
-- Look for CORR() between g1hr, and g23hr
-- Constrain g1g24_directions
-- And
-- Constrain g1hr_size
SELECT
bullbear
,g1g24_directions
,g1hr_size
,ROUND(CORR(g1hr,g23hr),2) corr_g1_g23
,ROUND(AVG(g23hr)/STDDEV(g23hr),3) sharpe_ratio
,COUNT(g23hr) prediction_count
FROM
(
SELECT
bullbear
,ydate
,score
,g1g24_directions
,g1hr
,g23hr
,CASE WHEN ABS(g1hr)>g1hr_stddev THEN'Large'ELSE'Normal'END g1hr_size
FROM scores_gains
)
GROUP BY bullbear,g1g24_directions,g1hr_size
ORDER BY bullbear,g1g24_directions,g1hr_size
/

exit
