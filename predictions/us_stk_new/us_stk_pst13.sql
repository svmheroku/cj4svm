--
-- us_stk_pst13.sql
--


DROP TABLE us_stk_pst11;
PURGE RECYCLEBIN;
CREATE TABLE us_stk_pst11 COMPRESS AS
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
WHERE ydate > '2011-01-30'
AND clse > 0
ORDER BY tkr,ydate
/

ANALYZE TABLE us_stk_pst11 ESTIMATE STATISTICS SAMPLE 9 PERCENT;

-- Now join us_stk_pst11 with stkscores

DROP TABLE us_stk_pst13;
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
FROM stkscores l,stkscores s,us_stk_pst11 m
WHERE l.targ='gatt'
AND   s.targ='gattn'
AND l.tkrdate = s.tkrdate
AND l.tkrdate = m.tkrdate
-- Speed things up:
AND l.ydate > '2011-01-30'
AND s.ydate > '2011-01-30'
/

ANALYZE TABLE us_stk_pst13 ESTIMATE STATISTICS SAMPLE 9 PERCENT;

-- This script is called by other scripts.
-- So, dont exit:
-- exit
