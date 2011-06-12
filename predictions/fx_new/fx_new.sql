--
-- fx_new.sql
--

@fxpst12.sql

COLUMN pair          FORMAT A8  HEADING     'Currency|Pair'    
COLUMN timestamp_0hr FORMAT A11   HEADING 'GMT Time|at hour 0' 
COLUMN danbot_score FORMAT 9.99   HEADING 'DanBot|Score|at hour 0' 
COLUMN score_type FORMAT A5        HEADING 'Score|Type'
COLUMN price_0hr    FORMAT 999.9999 HEADING 'Price at|hour 0'
COLUMN rnng_crr1 FORMAT 9.99 HEADING '1 Day|Running|Correlation|Between|DanBot|Score|and|6hr Gain'
COLUMN price_1hr    FORMAT 999.9999 HEADING 'Price after|1 hour'
COLUMN price_6hr    FORMAT 999.9999 HEADING 'Price after|6 hours'
COLUMN gain_6hr1hr  FORMAT  99.9999 HEADING '5 hour gain|between|hr1 and hr6'
COLUMN normalized_gain_5hr FORMAT 9.9999 HEADING 'Normalized|5hr gain'
COLUMN normalized_gain_1hr FORMAT 9.9999 HEADING 'Normalized|1hr gain'
COLUMN gmt_time_at_hr6 FORMAT A25  HEADING 'GMT Time|at hour 6|(Time to Close Position)' 

SET TIME off TIMING off ECHO off PAGESIZE 1234 LINESIZE 188
SET MARKUP HTML ON TABLE "class='table_fx_new'"
SPOOL /tmp/_fx_new_spool.html.erb

SELECT
pair
,ydate timestamp_0hr
,ROUND(score_diff,4) danbot_score
,CASE WHEN score_diff<0 THEN'Sell'ELSE'Buy'END score_type
,ROUND(price_0hr,4)  price_0hr
-- ,rnng_crr1
,ROUND(price_1hr,4)  price_1hr
,ROUND((price_1hr-price_0hr)/price_0hr,4)normalized_gain_1hr
-- ,ROUND(price_6hr,4)  price_6hr
-- ,ROUND(price_6hr-price_1hr,4)gain_6hr1hr
-- ,ROUND((price_6hr-price_1hr)/price_0hr,4)normalized_gain_5hr
,ydate+6/24 gmt_time_at_hr6
FROM fxpst12
WHERE rnng_crr1 > 0.1
AND ABS(score_diff) > 0.55
AND price_6hr IS NULL
ORDER BY SIGN(score_diff),pair,ydate
/

SPOOL OFF

exit
