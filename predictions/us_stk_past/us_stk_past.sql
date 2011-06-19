--
-- us_stk_past.sql
--

-- This script creates tables used by:
-- us_stk_past_week.sql
-- which is called by:
-- /tmp/run_us_stk_past_week.sql
-- which is both created and called by us_stk_past/index_spec.rb

-- Assume that us_stk_pst21 table exists due to an earlier import of data from other DBs:
INSERT INTO us_stk_pst21
(
tkr
,ydate
,tkrdate
,price_0hr
,price_24hr
,g24hr
,selldate
,price_1hr
,g1hr
)
SELECT
tkr
,ydate
,tkrdate
,clse  price_0hr
,clse2 price_24hr
,gain1day g24hr
,selldate
,LEAD(clse,12*1,NULL)OVER(PARTITION BY tkr ORDER BY ydate) price_1hr
,(LEAD(clse,12*1,NULL)OVER(PARTITION BY tkr ORDER BY ydate)-clse) g1hr
FROM di5min_stk_c2
WHERE clse > 0
ORDER BY tkr,ydate
/

exit

-- Now filter duplicates out of us_stk_pst21 into us_stk_pst11

DROP TABLE us_stk_pst11;
CREATE TABLE us_stk_pst11 COMPRESS AS
SELECT
tkrdate
,MAX(tkr)tkr
,MAX(ydate)ydate
,MAX(selldate)selldate
,AVG(price_0hr)price_0hr
,AVG(price_24hr)price_24hr
,AVG(g24hr)g24hr
,AVG(price_1hr)price_1hr
,AVG(g1hr)g1hr
FROM us_stk_pst21
GROUP BY tkrdate
ORDER BY tkrdate
/

ANALYZE TABLE us_stk_pst11 ESTIMATE STATISTICS SAMPLE 9 PERCENT;

-- Assume that stkscores21 table exists due to an earlier import of data from other DBs:
INSERT INTO stkscores21
(
tkr
,ydate
,tkrdate
,targ
,score
)
SELECT
tkr
,ydate
,tkrdate
,targ
,score
FROM stkscores
ORDER BY tkrdate,targ
/

-- Now merge scores into stkscores23:
DROP TABLE stkscores23;
CREATE TABLE stkscores23 COMPRESS AS
SELECT
tkrdate
,targ
,MAX(tkr)tkr
,MAX(ydate)ydate
,AVG(score)score
FROM stkscores21
GROUP BY targ,tkrdate
ORDER BY targ,tkrdate
/

-- Now join us_stk_pst11 with stkscores23

DROP TABLE us_stk_pst13;
PURGE RECYCLEBIN;
CREATE TABLE us_stk_pst13 COMPRESS AS
SELECT
m.tkr
,m.ydate
,(l.score-s.score)        score_diff
,ROUND(l.score-s.score,1) rscore_diff1
,ROUND(l.score-s.score,2) rscore_diff2
,m.g1hr
,m.g24hr
,m.selldate
,m.price_0hr
,m.price_1hr
,m.price_24hr
-- ,CORR(l.score-s.score,m.g24hr)OVER(PARTITION BY l.tkr ORDER BY l.ydate ROWS BETWEEN 12*24*5 PRECEDING AND CURRENT ROW)rnng_crr1
,COVAR_POP(l.score-s.score,m.g24hr)OVER(PARTITION BY l.tkr ORDER BY l.ydate ROWS BETWEEN 12*24*5 PRECEDING AND CURRENT ROW)rnng_crr1
FROM stkscores23 l,stkscores23 s,us_stk_pst11 m
WHERE l.targ='gatt'
AND   s.targ='gattn'
AND l.tkrdate = s.tkrdate
AND l.tkrdate = m.tkrdate
-- Speed things up:
AND l.ydate > '2011-01-30'
AND s.ydate > '2011-01-30'
/

ANALYZE TABLE us_stk_pst13 ESTIMATE STATISTICS SAMPLE 9 PERCENT;

-- rpt
-- This SELECT gives me a list of recent week-names.
-- I use minday, maxday to help me understand the contents of each week.
SELECT
TO_CHAR(ydate,'WW')
,MIN(ydate)
,TO_CHAR(MIN(ydate),'Dy')minday
,COUNT(ydate)
,MAX(ydate)
,TO_CHAR(MAX(ydate),'Dy')maxday
FROM us_stk_pst13
WHERE price_24hr > 0
GROUP BY TO_CHAR(ydate,'WW')
ORDER BY MIN(ydate)
/

-- This SELECT gives me text for a-tags
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';
SET TIME off TIMING off ECHO off HEADING off
SET MARKUP HTML ON TABLE "id='table_us_stk_past'" ENTMAP ON
SPOOL /tmp/_us_stk_past_spool.html.erb

SELECT
'Week: '||MIN(ydate)||' Through '||MAX(ydate) wweek
FROM us_stk_pst13
WHERE price_24hr > 0
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
FROM us_stk_pst13
WHERE price_24hr > 0
GROUP BY TO_CHAR(ydate,'WW')
ORDER BY MIN(ydate)
/
SPOOL OFF

exit
