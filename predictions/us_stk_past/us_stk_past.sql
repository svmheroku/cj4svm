--
-- us_stk_past.sql
--

-- I use this script to join gains with scores.

-- This script depends on ibs5min_cpy.bash
-- which fills ibs5min_cpy with recent data from ibs5min from both z2, z3.

-- I need dates to match-up to the second:
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD hh24:mi:ss';

-- Start by getting a copy of stkscores:

PURGE RECYCLEBIN;
DROP TABLE ibs5min_sun1;

DROP TABLE ibs5min_sun;

DROP TABLE stkscores_sunl;

DROP TABLE stkscores_suns;

DROP TABLE stkscores_sunlj;

DROP TABLE stkscores_sunsj;

DROP TABLE us_stk_sunday_l;

DROP TABLE us_stk_sunday_s;

CREATE TABLE ibs5min_sun1 COMPRESS AS
SELECT
tkr,ydate
,AVG(clse)clse
FROM ibs5min_cpy
GROUP BY tkr,ydate
ORDER BY tkr,ydate
/

TRUNCATE TABLE ibs5min_cpy;
INSERT INTO ibs5min_cpy(tkr,ydate,clse)SELECT tkr,ydate,clse FROM ibs5min_sun1;

CREATE TABLE ibs5min_sun COMPRESS AS
SELECT
tkr
,ydate
,clse                                                           price_0hr
, LEAD(clse,12*1,NULL)OVER(PARTITION BY tkr ORDER BY ydate)     price_1hr
,(LEAD(clse,12*1,NULL)OVER(PARTITION BY tkr ORDER BY ydate)-clse) g1hr
,LEAD(clse, 6.5*12*1,NULL)OVER(PARTITION BY tkr ORDER BY ydate) price_24hr
,LEAD(ydate,6.5*12*1,NULL)OVER(PARTITION BY tkr ORDER BY ydate) selldate
,(LEAD(clse,6.5*12*1,NULL)OVER(PARTITION BY tkr ORDER BY ydate)-clse) g24hr
FROM ibs5min_sun1
ORDER BY tkr,ydate
/

CREATE TABLE stkscores_sunl COMPRESS AS
SELECT
tkr
,ydate
,AVG(score)score
FROM stkscores
WHERE targ = 'gatt'
GROUP BY tkr,ydate
ORDER BY tkr,ydate
/

CREATE TABLE stkscores_suns COMPRESS AS
SELECT
tkr
,ydate
,AVG(score)score
FROM stkscores
WHERE targ = 'gattn'
GROUP BY tkr,ydate
ORDER BY tkr,ydate
/

-- Now join em to get bullish scores:

CREATE TABLE stkscores_sunlj COMPRESS AS
SELECT
l.tkr
,l.ydate
,l.score - s.score score
FROM stkscores_sunl l, stkscores_suns s
WHERE l.tkr||l.ydate = s.tkr||s.ydate
AND l.score - s.score > 0.55
AND l.score > 0.55
AND s.score < 0.45
ORDER BY s.tkr,s.ydate
/

-- Now join em to get bearish scores:

CREATE TABLE stkscores_sunsj COMPRESS AS
SELECT
l.tkr
,l.ydate
,l.score - s.score score
FROM stkscores_sunl l, stkscores_suns s
WHERE l.tkr||l.ydate = s.tkr||s.ydate
AND l.score - s.score < -0.55
AND s.score > 0.55
AND l.score < 0.45
ORDER BY s.tkr,s.ydate
/

-- Indexes help speed up future joins:
CREATE INDEX ibs5min_suni1 ON ibs5min_sun(tkr,ydate);
CREATE INDEX stkscores_sunsji1 ON stkscores_sunsj(tkr,ydate);
CREATE INDEX stkscores_sunlji1 ON stkscores_sunlj(tkr,ydate);

-- Statistics help speed up future joins:
ANALYZE TABLE ibs5min_sun     ESTIMATE STATISTICS SAMPLE 11 PERCENT;
ANALYZE TABLE stkscores_sunsj ESTIMATE STATISTICS SAMPLE 11 PERCENT;
ANALYZE TABLE stkscores_sunlj ESTIMATE STATISTICS SAMPLE 11 PERCENT;

-- rpt
SELECT MIN(ydate),                      COUNT(ydate),MAX(ydate)FROM ibs5min_sun;
SELECT MIN(ydate),MIN(score),MAX(score),COUNT(ydate),MAX(ydate)FROM stkscores_sunlj;
SELECT MIN(ydate),MIN(score),MAX(score),COUNT(ydate),MAX(ydate)FROM stkscores_sunsj;

-- Now join bullish scores with gains:

CREATE TABLE us_stk_sunday_l COMPRESS AS
SELECT
i.tkr
,i.ydate
,price_0hr
,price_1hr
,g1hr
,price_24hr
,selldate
,g24hr
,score
,COVAR_POP(score,g24hr)OVER(PARTITION BY s.tkr ORDER BY s.ydate ROWS BETWEEN 12*24*5 PRECEDING AND CURRENT ROW)rnng_crr1
FROM ibs5min_sun i, stkscores_sunlj s
WHERE i.tkr = s.tkr AND i.ydate = s.ydate
ORDER BY i.tkr,i.ydate
/

-- Now join bearish scores with gains:

CREATE TABLE us_stk_sunday_s COMPRESS AS
SELECT
i.tkr
,i.ydate
,price_0hr
,price_1hr
,g1hr
,price_24hr
,selldate
,g24hr
,score
,COVAR_POP(score,g24hr)OVER(PARTITION BY s.tkr ORDER BY s.ydate ROWS BETWEEN 12*24*5 PRECEDING AND CURRENT ROW)rnng_crr1
FROM ibs5min_sun i, stkscores_sunsj s
WHERE i.tkr = s.tkr AND i.ydate = s.ydate
ORDER BY i.tkr,i.ydate
/

-- Get bullish CSV data:
SPOOL /tmp/us_stk_sunday_l.txt

COLUMN sum_g24hr FORMAT 9999999.99
COLUMN cum_sum   FORMAT 9999999.99
SET COLSEP ","

SELECT
wk
,TO_CHAR(week_of,'YYYY-MM-DD')  week_of
,rownum                         rrownum
,prediction_count
,sum_g24hr
,SUM(sum_g24hr)OVER(ORDER BY wk)cum_sum
FROM
(
  SELECT
  TO_CHAR(ydate,'YYYY-WW') wk
  ,MIN(ydate)              week_of
  ,COUNT(g24hr)            prediction_count
  ,SUM(g24hr)              sum_g24hr
  FROM us_stk_sunday_l
  WHERE ydate > '2011-01-01'
  AND rnng_crr1 > 0
  GROUP BY TO_CHAR(ydate,'YYYY-WW')
  ORDER BY TO_CHAR(ydate,'YYYY-WW')
)
/

SPOOL OFF

-- Get bearish CSV data:
SPOOL /tmp/us_stk_sunday_s.txt

SELECT
wk
,TO_CHAR(week_of,'YYYY-MM-DD')  week_of
,rownum                         rrownum
,prediction_count
,sum_g24hr
,SUM(sum_g24hr)OVER(ORDER BY wk)cum_sum
FROM
(
  SELECT
  TO_CHAR(ydate,'YYYY-WW') wk
  ,MIN(ydate)              week_of
  ,COUNT(g24hr)            prediction_count
  ,SUM(g24hr)              sum_g24hr
  FROM us_stk_sunday_s
  WHERE ydate > '2011-01-01'
  AND rnng_crr1 > 0
  GROUP BY TO_CHAR(ydate,'YYYY-WW')
  ORDER BY TO_CHAR(ydate,'YYYY-WW')
)
/

SPOOL OFF


-- This SELECT gives me text for a-tags
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';
SET TIME off TIMING off ECHO off HEADING off
SET MARKUP HTML ON TABLE "id='table_us_stk_past'" ENTMAP ON
SPOOL /tmp/_us_stk_past_spool.html.erb

SELECT
'Week: '||MIN(ydate)||' Through '||MAX(ydate) wweek
FROM us_stk_sunday_s
WHERE price_24hr > 0
AND rnng_crr1 > 0
GROUP BY TO_CHAR(ydate,'WW')
ORDER BY MIN(ydate)
/

SPOOL OFF
SET MARKUP HTML OFF

-- This SELECT gives me syntax to run a series of SQL scripts.
-- Each script will give me data for 1 week.

SPOOL /tmp/us_stk_past_week.txt
SELECT
'@us_stk_past_week.sql '||MIN(ydate) cmd
FROM us_stk_sunday_s
WHERE price_24hr > 0
AND rnng_crr1 > 0
GROUP BY TO_CHAR(ydate,'WW')
ORDER BY MIN(ydate)
/
SPOOL OFF

exit
