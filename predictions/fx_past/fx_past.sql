--
-- fx_past.sql
--

-- I use this script to join 3 types of tables:
-- prices,gains
-- gatt-scores
-- gattn-scores

-- I can pattern off this script:
-- /pt/s/rluck/svm62/qrs2.sql

DROP TABLE fxpst10;
PURGE RECYCLEBIN;
CREATE TABLE fxpst10 COMPRESS AS
SELECT
pair
,ydate
,clse
,prdate
,(LEAD(clse,12*1,NULL)OVER(PARTITION BY pair ORDER BY ydate)-clse)/clse g1n
,(LEAD(clse,12*6,NULL)OVER(PARTITION BY pair ORDER BY ydate)-clse)/clse g6n
,(LEAD(clse,12*1,NULL)OVER(PARTITION BY pair ORDER BY ydate)-clse) g1
,(LEAD(clse,12*6,NULL)OVER(PARTITION BY pair ORDER BY ydate)-clse) g6
,clse price_0hr
,LEAD(clse,12*1,NULL)OVER(PARTITION BY pair ORDER BY ydate) price_1hr
,LEAD(clse,12*6,NULL)OVER(PARTITION BY pair ORDER BY ydate) price_6hr
FROM di5min
WHERE ydate > '2011-01-30'
AND clse > 0
ORDER BY pair,ydate
/

-- Build some indexes so the next join speeds up:
CREATE INDEX svm62scores_i1 ON svm62scores(targ,prdate);
CREATE INDEX fxpst10_i1 ON fxpst10(prdate);

ANALYZE TABLE svm62scores ESTIMATE STATISTICS SAMPLE 22 PERCENT;
ANALYZE TABLE fxpst10 ESTIMATE STATISTICS SAMPLE 22 PERCENT;

DROP TABLE fxpst12;
CREATE TABLE fxpst12 COMPRESS AS
SELECT
m.pair
,m.ydate
,m.clse
,(l.score-s.score)         score_diff
,ROUND(l.score-s.score,1) rscore_diff1
,ROUND(l.score-s.score,2) rscore_diff2
,m.g1
,m.g1n
,m.g6
,m.g6n
,price_0hr
,price_1hr
,price_6hr
,m.g6-m.g1   g5
,m.g6n-m.g1n g5n
,CORR(l.score-s.score,g6)OVER(PARTITION BY l.pair ORDER BY l.ydate ROWS BETWEEN 12*24*1 PRECEDING AND CURRENT ROW)rnng_crr1
FROM svm62scores l,svm62scores s,fxpst10 m
WHERE l.targ='gatt'
AND   s.targ='gattn'
AND l.prdate = s.prdate
AND l.prdate = m.prdate
-- Speed things up:
AND l.ydate > '2011-01-30'
AND s.ydate > '2011-01-30'
/

ANALYZE TABLE fxpst12 ESTIMATE STATISTICS SAMPLE 22 PERCENT;

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
FROM fxpst12
WHERE price_6hr > 0
GROUP BY TO_CHAR(ydate,'WW')
ORDER BY MIN(ydate)
/

-- rpt
SELECT
pair,COUNT(pair)
FROM fxpst12
WHERE price_6hr IS NULL
GROUP BY pair
ORDER BY pair
/

-- This SELECT gives me text for a-tags
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';
SET TIME off TIMING off ECHO off HEADING off
SET MARKUP HTML ON TABLE "id='table_fx_past'" ENTMAP ON
SPOOL /tmp/_fx_past_spool.html.erb

SELECT
'Week: '||MIN(ydate)||' Through '||MAX(ydate) wweek
FROM fxpst12
WHERE price_6hr > 0
GROUP BY TO_CHAR(ydate,'WW')
ORDER BY MIN(ydate)
/
SPOOL OFF
SET MARKUP HTML OFF

-- This SELECT gives me syntax to run a series of SQL scripts.
-- Each script will give me data for 1 week.

SPOOL /tmp/fx_past_week.txt
SELECT
'@fx_past_week.sql '||MIN(ydate) cmd
FROM fxpst12
WHERE price_6hr > 0
-- I only want recent data
AND ydate=(SELECT MAX(ydate)FROM fxpst12 WHERE TO_CHAR(ydate,'Dy')='Sun')
-- AND TO_CHAR(ydate,'Dy')='Sun'
GROUP BY TO_CHAR(ydate,'WW')
ORDER BY MIN(ydate)
/
SPOOL OFF


-- Now create CSV files to be used by my R-script to create a plot on splash page showing fx-DanBot performance.

-- Get bearish CSV data:
SPOOL /tmp/fx_sunday_s.txt

COLUMN sum_g5n FORMAT 9999999.99
COLUMN cum_sum FORMAT 9999999.99
SET COLSEP ","

SELECT
wk
,TO_CHAR(week_of,'YYYY-MM-DD') week_of
,rownum                        rrownum
,prediction_count
,sum_g5n
,SUM(sum_g5n)OVER(ORDER BY wk) cum_sum
FROM
(
  SELECT
  TO_CHAR(ydate,'YYYY-WW') wk
  ,ROUND(MIN(ydate))       week_of
  ,COUNT(g5n)              prediction_count
  ,SUM(g5n)                sum_g5n
  FROM fxpst12
  WHERE rnng_crr1 > 0.1
  AND score_diff < -0.55
  AND g1n > -0.0004
  GROUP BY TO_CHAR(ydate,'YYYY-WW')
  ORDER BY TO_CHAR(ydate,'YYYY-WW')
)
/

SPOOL OFF

-- Get bullish CSV data:
SPOOL /tmp/fx_sunday_l.txt

COLUMN sum_g5n FORMAT 9999999.99
COLUMN cum_sum FORMAT 9999999.99
SET COLSEP ","

SELECT
wk
,TO_CHAR(week_of,'YYYY-MM-DD') week_of
,rownum                        rrownum
,prediction_count
,sum_g5n
,SUM(sum_g5n)OVER(ORDER BY wk) cum_sum
FROM
(
  SELECT
  TO_CHAR(ydate,'YYYY-WW') wk
  ,ROUND(MIN(ydate))       week_of
  ,COUNT(g5n)              prediction_count
  ,SUM(g5n)                sum_g5n
  FROM fxpst12
  WHERE rnng_crr1 > 0.1
  AND score_diff > 0.55
  AND g1n< 0.0004
  GROUP BY TO_CHAR(ydate,'YYYY-WW')
  ORDER BY TO_CHAR(ydate,'YYYY-WW')
)
/

SPOOL OFF

exit
exit


select count(*)from
(
SELECT
pair
,ydate
,rscore_diff2
,g1
,ROUND(rnng_crr1,2)      rnng_crr1
,(sysdate - ydate)*24*60 minutes_age
FROM fxpst12
WHERE rnng_crr1 > 0.1
ORDER BY pair,ydate
)
/

select count(*)from
(
SELECT
pair
,CASE WHEN rscore_diff2<0 THEN'sell'ELSE'buy'END bors
,ROUND(clse,4)clse
,rscore_diff2
,ROUND(g1,4)g1
,ROUND(rnng_crr1,2)      rnng_crr1
,(sysdate - ydate)*24*60 minutes_age
--,ydate + 6/24 cls_date
,TO_CHAR(ydate + 6/24,'YYYYMMDD_HH24:MI:SS')||'_GMT' cls_str
FROM fxpst12
WHERE rnng_crr1 > 0.1
AND ABS(rscore_diff2) > 0.6
ORDER BY pair,ydate
)
/

exit
