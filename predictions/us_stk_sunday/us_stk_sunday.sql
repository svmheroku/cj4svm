--
-- us_stk_sunday.sql
--

-- I use this script to generate a CSV file I use to plot performance of SVM predictions.

-- This script depends on ../us_stk_past/us_stk_past.sql
-- @../us_stk_past/us_stk_past.sql

-- Start by reporting on stkscores23

-- How far do the ydates go back?
SELECT
tkr
,MIN(ydate)
,MAX(ydate)
,COUNT(score)
FROM stkscores23
GROUP BY tkr
ORDER BY MIN(ydate),tkr
-- /

-- Do I have recent data?
SELECT
tkr
,MIN(ydate)
,MAX(ydate)
,COUNT(score)
FROM stkscores23
GROUP BY tkr
ORDER BY MAX(ydate),tkr
-- /

-- Next, report on prices.

-- How far do the ydates go back?
SELECT
tkr
,MIN(ydate)
,MAX(ydate)
,COUNT(clse)
FROM ibs5min
GROUP BY tkr
ORDER BY MIN(ydate),tkr
-- /

-- Do I have recent data?
SELECT
tkr
,MIN(ydate)
,MAX(ydate)
,COUNT(clse)
FROM ibs5min
GROUP BY tkr
ORDER BY MAX(ydate),tkr
-- /

-- join on tkrdate
-- CREATE OR REPLACE VIEW us_stk_sundayv1 AS

PURGE RECYCLEBIN;

-- debug
-- DROP TABLE us_stk_sundayt1;
-- debug

CREATE TABLE us_stk_sundayt1 COMPRESS AS
SELECT
i.tkr
,i.ydate
,i.clse
,(LEAD(i.clse,6.5*12*1,NULL)OVER(PARTITION BY i.tkr ORDER BY i.ydate)-i.clse) g1day
,l.score - s.score score
FROM stkscores23 l, stkscores23 s, ibs5min i
WHERE l.targ = 'gatt'
AND   s.targ = 'gattn'
AND   l.tkr||l.ydate = s.tkr||s.ydate
AND   l.tkr||l.ydate = i.tkr||i.ydate
ORDER BY i.tkr,i.ydate
/

-- look at data:
SELECT
tkr
,ydate
,clse
,g1day
,score
FROM us_stk_sundayt1
WHERE 1+ydate = '2011-09-23 19:55:00'
AND tkr = 'YUM'
-- /

-- look at data:

COLUMN sum_g1day FORMAT 9999999.99
COLUMN cum_sum   FORMAT 9999999.99
SET COLSEP ","

SELECT
tdate
,prediction_count
,sum_g1day
,SUM(sum_g1day)OVER(ORDER BY tdate)cum_sum
FROM
(
  SELECT
  trunc(ydate)  tdate
  ,COUNT(g1day) prediction_count
  ,SUM(g1day)   sum_g1day
  FROM us_stk_sundayt1
  WHERE ydate > '2011-01-01'
  AND score > 0.55
  GROUP BY trunc(ydate)
)
ORDER BY tdate
/

-- Look at Sharpe Ratio:
SELECT
AVG(g1day)/STDDEV(g1day) sharpe_ratio
FROM us_stk_sundayt1
WHERE ydate > '2011-01-01'
AND score > 0.55
/

-- What is the avg count of predictions each day?
SELECT MAX(count_g1day)/MAX(count_dst_date) avg_count_per_day
FROM
(
SELECT COUNT(g1day)count_g1day,NULL                 count_dst_date FROM us_stk_sundayt1 WHERE ydate>'2011-01-01'
  AND score > 0.55
UNION
SELECT NULL count_g1day,COUNT(DISTINCT TRUNC(ydate))count_dst_date FROM us_stk_sundayt1 WHERE ydate>'2011-01-01'
)
/

SELECT
tdate
,rownum rrownum
,prediction_count
,sum_g1day
,SUM(sum_g1day)OVER(ORDER BY tdate)cum_sum
FROM
(
  SELECT
  trunc(ydate)  tdate
  ,COUNT(g1day) prediction_count
  ,SUM(g1day)   sum_g1day
  FROM us_stk_sundayt1
  WHERE ydate > '2011-01-01'
  AND score < -0.55
  GROUP BY trunc(ydate)
  ORDER BY trunc(ydate)
)
/

-- Look at Sharpe Ratio:
SELECT
AVG(g1day)/STDDEV(g1day) sharpe_ratio
FROM us_stk_sundayt1
WHERE ydate > '2011-01-01'
AND score < -0.55
/

-- What is the avg count of predictions each day?
SELECT MAX(count_g1day)/MAX(count_dst_date) avg_count_per_day
FROM
(
SELECT COUNT(g1day)count_g1day,NULL                 count_dst_date FROM us_stk_sundayt1 WHERE ydate>'2011-01-01'
  AND score < -0.55
UNION
SELECT NULL count_g1day,COUNT(DISTINCT TRUNC(ydate))count_dst_date FROM us_stk_sundayt1 WHERE ydate>'2011-01-01'
)
/

exit
