--
-- a1_fx_new.sql
--

DROP TABLE a1_fx_new10;
PURGE RECYCLEBIN;
CREATE TABLE a1_fx_new10 COMPRESS AS
SELECT
pair
,ydate
,clse
,prdate
,(LEAD(clse,12*1,NULL)OVER(PARTITION BY pair ORDER BY ydate)-clse)/clse g1
,(LEAD(clse,12*6,NULL)OVER(PARTITION BY pair ORDER BY ydate)-clse)/clse g6
,clse price_0hr
,LEAD(clse,12*1,NULL)OVER(PARTITION BY pair ORDER BY ydate) price_1hr
,LEAD(clse,12*6,NULL)OVER(PARTITION BY pair ORDER BY ydate) price_6hr
FROM di5min
WHERE ydate > '2011-01-30'
AND clse > 0
ORDER BY pair,ydate
/

ANALYZE TABLE a1_fx_new10 ESTIMATE STATISTICS SAMPLE 9 PERCENT;

DROP TABLE a1_fx_new12;
CREATE TABLE a1_fx_new12 COMPRESS AS
SELECT
m.pair
,m.ydate
,m.clse
,(l.score-s.score)         score_diff
,ROUND(l.score-s.score,1) rscore_diff1
,ROUND(l.score-s.score,2) rscore_diff2
,m.g1
,m.g6
,price_0hr
,price_1hr
,price_6hr
,m.g6-m.g1 g5
,CORR(l.score-s.score,g6)OVER(PARTITION BY l.pair ORDER BY l.ydate ROWS BETWEEN 12*30*1 PRECEDING AND CURRENT ROW)rnng_crr1
FROM svm62scores l,svm62scores s,a1_fx_new10 m
WHERE l.targ='gatt'
AND   s.targ='gattn'
AND l.prdate = s.prdate
AND l.prdate = m.prdate
-- Speed things up:
AND l.ydate > '2011-01-30'
AND s.ydate > '2011-01-30'
/

ANALYZE TABLE a1_fx_new12 ESTIMATE STATISTICS SAMPLE 9 PERCENT;

COLUMN pair          FORMAT A8  HEADING     'Currency|Pair'    
COLUMN timestamp_0hr FORMAT A11   HEADING 'GMT Time|at hour 0' 
COLUMN danbot_score FORMAT 9.99   HEADING 'DanBot|Score|at hour 0' 
COLUMN score_type FORMAT A5        HEADING 'Score|Type'
COLUMN price_0hr    FORMAT 999.9999 HEADING 'Price at|hour 0'
COLUMN price_1hr    FORMAT 999.9999 HEADING 'Price after|1 hour'
COLUMN normalized_gain_1hr FORMAT 9.9999 HEADING 'Normalized|1hr gain'
COLUMN gmt_time_at_hr6 FORMAT A25  HEADING 'GMT Time|at hour 6|(Time to Close Position)' 

SET TIME off TIMING off ECHO off PAGESIZE 1234 LINESIZE 188
SET MARKUP HTML ON TABLE "class='table_a1_fx_new'"
SPOOL /tmp/_a1_fx_new_spool.html.erb

SELECT
pair
,ydate timestamp_0hr
,ROUND(score_diff,4) danbot_score
,CASE WHEN score_diff<0 THEN'Sell'ELSE'Buy'END score_type
,ROUND(price_0hr,4)  price_0hr
,ROUND(price_1hr,4)  price_1hr
,ROUND((price_1hr-price_0hr)/price_0hr,4)normalized_gain_1hr
,CASE WHEN TO_CHAR(ydate,'Dy')='Fri'AND TO_CHAR(ydate,'HH24:MI')>'14:55'
 THEN ydate+6/24+2 ELSE ydate+6/24 END gmt_time_at_hr6
FROM a1_fx_new12
WHERE rnng_crr1 > 0.1
AND ABS(score_diff) > 0.55
AND price_6hr IS NULL
ORDER BY SIGN(score_diff),pair,ydate
/

SPOOL OFF

exit
