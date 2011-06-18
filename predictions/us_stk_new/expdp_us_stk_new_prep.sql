--
-- expdp_us_stk_new_prep.sql
--

-- I use this script to prepare some data for expdp.
-- I intend for the data to be merged with data from other DBs.
-- After the merge, I will then use the data when I publish /predictions/us_stk_new/
-- Also note that the data prepared here is destined for use by us_stk_pst13.sql
-- which is the script which does the data-merge.

DROP TABLE us_stk_pst17;

PURGE RECYCLEBIN;

CREATE TABLE us_stk_pst17 COMPRESS AS
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
-- us_stk_pst13 needs 5 days of data, I will give it 7:
WHERE ydate > sysdate - 7
AND clse > 0
ORDER BY tkr,ydate
/

DROP TABLE stkscores17;

PURGE RECYCLEBIN;

CREATE TABLE stkscores17 COMPRESS AS
SELECT
tkr
,ydate
,tkrdate
,targ
,score
FROM stkscores
WHERE ydate > sysdate - 7
ORDER BY tkrdate,targ
/

EXIT
