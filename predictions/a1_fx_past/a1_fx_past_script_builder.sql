--
-- a1_fx_past_script_builder.sql
--

SPOOL /tmp/a1_fx_past_weeks.txt
SELECT '@/tmp/a1_fx_past_week.sql '||MIN(ydate) cmd
FROM fxpst12
WHERE price_6hr > 0
GROUP BY TO_CHAR(ydate,'WW')
ORDER BY MIN(ydate)
/
SPOOL OFF


exit
