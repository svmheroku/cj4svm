--
-- us_stk_sunday.sql
--

-- I use this script to generate a CSV file I use to plot performance of SVM predictions.

-- I need dates to match-up to the second:
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD hh24:mi:ss';

-- This script depends on this script:
-- @../us_stk_past/us_stk_past.sql


-- Get bullish CSV data:
SPOOL /tmp/us_stk_sunday_l.txt

COLUMN sum_g1day FORMAT 9999999.99
COLUMN cum_sum   FORMAT 9999999.99
SET COLSEP ","

SELECT
wk
,rownum rrownum
,prediction_count
,sum_g1day
,SUM(sum_g1day)OVER(ORDER BY wk)cum_sum
FROM
(
  SELECT
  to_char(ydate,'yyyy-ww') wk
  ,COUNT(g1day)              prediction_count
  ,SUM(g1day)                sum_g1day
  FROM us_stk_sunday_l
  WHERE ydate > '2011-01-01'
  GROUP BY TO_CHAR(ydate,'YYYY-WW')
  ORDER BY TO_CHAR(ydate,'YYYY-WW')
)
/

SPOOL OFF

exit
-- Get bearish CSV data:
SPOOL /tmp/us_stk_sunday_s.txt

SELECT
wk
,rownum rrownum
,prediction_count
,sum_g1day
,SUM(sum_g1day)OVER(ORDER BY wk)cum_sum
FROM
(
  SELECT
  to_char(ydate,'yyyy-ww') wk
  ,COUNT(g1day)              prediction_count
  ,SUM(g1day)                sum_g1day
  FROM us_stk_sunday_s
  WHERE ydate > '2011-01-01'
  GROUP BY to_char(ydate,'yyyy-ww')
  ORDER BY to_char(ydate,'yyyy-ww')
)
/

SPOOL OFF

exit



exit

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
FROM ibs5min
GROUP BY tkr,ydate
ORDER BY tkr,ydate
/

CREATE TABLE ibs5min_sun COMPRESS AS
SELECT
tkr,ydate
,(LEAD(clse,6.5*12*1,NULL)OVER(PARTITION BY tkr ORDER BY ydate)-clse) g1day
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
,i.g1day
,score
FROM ibs5min_sun i, stkscores_sunlj s
WHERE i.tkr = s.tkr AND i.ydate = s.ydate
ORDER BY i.tkr,i.ydate
/

-- Now join bearish scores with gains:

CREATE TABLE us_stk_sunday_s COMPRESS AS
SELECT
i.tkr
,i.ydate
,i.g1day
,score
FROM ibs5min_sun i, stkscores_sunsj s
WHERE i.tkr = s.tkr AND i.ydate = s.ydate
ORDER BY i.tkr,i.ydate
/

-- Get bullish CSV data:
SPOOL /tmp/us_stk_sunday_l.txt

COLUMN sum_g1day FORMAT 9999999.99
COLUMN cum_sum   FORMAT 9999999.99
SET COLSEP ","

SELECT
wk
,rownum rrownum
,prediction_count
,sum_g1day
,SUM(sum_g1day)OVER(ORDER BY wk)cum_sum
FROM
(
  SELECT
  to_char(ydate,'yyyy-ww') wk
  ,COUNT(g1day)              prediction_count
  ,SUM(g1day)                sum_g1day
  FROM us_stk_sunday_l
  WHERE ydate > '2011-01-01'
  GROUP BY to_char(ydate,'yyyy-ww')
  ORDER BY to_char(ydate,'yyyy-ww')
)
/

SPOOL OFF

-- Get bearish CSV data:
SPOOL /tmp/us_stk_sunday_s.txt

SELECT
wk
,rownum rrownum
,prediction_count
,sum_g1day
,SUM(sum_g1day)OVER(ORDER BY wk)cum_sum
FROM
(
  SELECT
  to_char(ydate,'yyyy-ww') wk
  ,COUNT(g1day)              prediction_count
  ,SUM(g1day)                sum_g1day
  FROM us_stk_sunday_s
  WHERE ydate > '2011-01-01'
  GROUP BY to_char(ydate,'yyyy-ww')
  ORDER BY to_char(ydate,'yyyy-ww')
)
/

SPOOL OFF

exit
