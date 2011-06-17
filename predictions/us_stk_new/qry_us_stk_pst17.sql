--
-- qry_us_stk_pst17.sql
--

SELECT
tkr
,MIN(ydate)
,COUNT(tkr)
,MAX(ydate)
FROM us_stk_pst17
GROUP BY tkr
ORDER BY MAX(ydate),tkr
/

SELECT
tkr
,targ
,MIN(ydate)
,COUNT(tkr)
,MAX(ydate)
FROM stkscores17
GROUP BY targ,tkr
ORDER BY targ,MAX(ydate),tkr
/

EXIT


