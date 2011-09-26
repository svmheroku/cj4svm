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
/

-- Do I have recent data?
SELECT
tkr
,MIN(ydate)
,MAX(ydate)
,COUNT(score)
FROM stkscores23
GROUP BY tkr
ORDER BY MAX(ydate),tkr
/

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
/

-- Do I have recent data?
SELECT
tkr
,MIN(ydate)
,MAX(ydate)
,COUNT(clse)
FROM ibs5min
GROUP BY tkr
ORDER BY MAX(ydate),tkr
/

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
/

-- look at data:
SELECT
ydate
,SUM(g1day)
,COUNT(g1day)
FROM us_stk_sundayt1
WHERE 1+ydate = '2011-09-23 19:55:00'
AND score > 0.55
GROUP BY ydate
/

exit
