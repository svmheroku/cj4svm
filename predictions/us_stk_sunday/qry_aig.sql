--
-- qry_aig.sql
--

SELECT * FROM ibs5min_sun1
WHERE tkr = 'AIG'
AND TRUNC(ydate) = '2011-02-15'


SELECT * FROM ibs5min_sun1
WHERE tkr = 'AIG'
AND TRUNC(ydate) = '2011-02-16'


SELECT * FROM ibs5min_sun
WHERE tkr = 'AIG'
AND TRUNC(ydate) = '2011-02-15'

SELECT * FROM stkscores_sunl
WHERE tkr = 'AIG'
AND TRUNC(ydate) = '2011-02-15'

SELECT * FROM stkscores_suns
WHERE tkr = 'AIG'
AND TRUNC(ydate) = '2011-02-15'


SELECT * FROM stkscores_sunlj
WHERE tkr = 'AIG'
AND TRUNC(ydate) = '2011-02-15'

SELECT * FROM stkscores_sunsj
WHERE tkr = 'AIG'
AND TRUNC(ydate) = '2011-02-15'
/


exit
