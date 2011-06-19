--
-- expdp_us_stk_past_prep.sql
--

-- I use this script to prepare some data for expdp.
-- I intend for the data to be merged with data from other DBs.
-- After the merge, I will then use the data when I publish /predictions/us_stk_past/
-- Also note that the data prepared here is destined for use by:
-- us_stk_past.sql and us_stk_past_week.sql
-- The actual merge of the data happens inside of us_stk_past.sql

-- # Gather the data I need into 2 tables:
-- # us_stk_pst21
-- # stkscores21
-- From: 
-- di5min_stk_c2
-- stkscores

DROP TABLE us_stk_pst21;

CREATE TABLE us_stk_pst21 COMPRESS AS
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
-- Assume I only need data which is younger than a week:
WHERE ydate > sysdate - 7
AND clse > 0
ORDER BY tkr,ydate
/

DROP TABLE stkscores21;

PURGE RECYCLEBIN;

CREATE TABLE stkscores21 COMPRESS AS
SELECT
tkr
,ydate
,tkrdate
,targ
,score
FROM stkscores
-- Assume I only need data which is younger than a week:
WHERE rundate > sysdate - 7
ORDER BY tkrdate,targ
/

exit
