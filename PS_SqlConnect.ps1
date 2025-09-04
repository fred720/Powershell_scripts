$query = "
    SELECT d.[Name],r.[SP_MajorRevisionNumber]
    FROM [TEST_PLANTpid].[T_Drawing] AS d
    FULL JOIN [TEST_PLANTpid].[T_Revision] AS r
    ON d.SP_ID = r.SP_DrawingID
    order by Name"

$instance = "ogc-pid-sql-01"
$db = "TEST_PLANT"


Invoke-Sqlcmd -query $query -ServerInstance $instance -Database $db