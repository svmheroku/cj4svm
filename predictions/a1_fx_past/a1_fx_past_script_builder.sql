--
-- a1_fx_past_script_builder.sql
--

ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';

SPOOL /tmp/a1_fx_past_weeks.txt
SELECT '@/tmp/a1_fx_past_week.sql '||MIN(ydate) cmd
FROM fxpst12
WHERE price_6hr > 0
-- I only want recent data
-- AND ydate=(SELECT MAX(ydate)FROM fxpst12 WHERE TO_CHAR(ydate,'Dy')='Sun')
GROUP BY TO_CHAR(ydate,'WW')
ORDER BY MIN(ydate)
/
SPOOL OFF

exit
