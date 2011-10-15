--
-- jpng.sql
--

-- I use this as a script to help me develop sql which I intend to eventually add to fx_past.sql

-- Get bearish CSV data:
SPOOL /tmp/fx_sunday_s.txt

COLUMN sum_g5n FORMAT 9999999.99
COLUMN cum_sum   FORMAT 9999999.99
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
COLUMN cum_sum   FORMAT 9999999.99
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

