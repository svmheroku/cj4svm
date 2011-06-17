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
,price_0hr
,price_24hr
,g24hr
,selldate
,price_1hr
,g1hr
-- us_stk_pst17 is created by expdp_us_stk_new_prep.sql
FROM us_stk_pst17
ORDER BY tkrdate
/

ANALYZE TABLE us_stk_pst11 ESTIMATE STATISTICS SAMPLE 9 PERCENT;

-- Now join us_stk_pst11 with stkscores17.
-- stkscores17 is created by expdp_us_stk_new_prep.sql

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
,COVAR_POP(l.score-s.score,m.g24hr)OVER(PARTITION BY l.tkr ORDER BY l.ydate ROWS BETWEEN 12*24*5 PRECEDING AND CURRENT ROW)rnng_crr1
FROM stkscores17 l,stkscores17 s,us_stk_pst11 m
WHERE l.targ='gatt'
AND   s.targ='gattn'
AND l.tkrdate = s.tkrdate
AND l.tkrdate = m.tkrdate
/

ANALYZE TABLE us_stk_pst13 ESTIMATE STATISTICS SAMPLE 9 PERCENT;

-- This script is called by other scripts.
-- So, dont exit:
-- exit
