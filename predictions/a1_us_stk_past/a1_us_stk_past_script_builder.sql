--
-- a1_us_stk_past_script_builder.sql
--

-- This SELECT gives me syntax to run a series of SQL scripts.
-- Each script will give me data for 1 week.

ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';

SPOOL /tmp/a1_us_stk_past_weeks.txt

SELECT
'@a1_us_stk_past_week.sql '||MIN(ydate) cmd
FROM us_stk_sunday_s
WHERE price_24hr > 0
AND rnng_crr1 > 0
GROUP BY TO_CHAR(ydate,'WW')
ORDER BY MIN(ydate)
/
SPOOL OFF

exit
