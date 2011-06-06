--
-- fxpst12.sql
--

-- I use this script to share SQL between other scripts.

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

ANALYZE TABLE fxpst10 ESTIMATE STATISTICS SAMPLE 9 PERCENT;

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
,m.g6
,price_0hr
,price_1hr
,price_6hr
,m.g6-m.g1 g5
,CORR(l.score-s.score,g6)OVER(PARTITION BY l.pair ORDER BY l.ydate ROWS BETWEEN 12*30*1 PRECEDING AND CURRENT ROW)rnng_crr1
FROM svm62scores l,svm62scores s,fxpst10 m
WHERE l.targ='gatt'
AND   s.targ='gattn'
AND l.prdate = s.prdate
AND l.prdate = m.prdate
-- Speed things up:
AND l.ydate > '2011-01-30'
AND s.ydate > '2011-01-30'
/

ANALYZE TABLE fxpst12 ESTIMATE STATISTICS SAMPLE 9 PERCENT;

-- dont exit:
-- exit
