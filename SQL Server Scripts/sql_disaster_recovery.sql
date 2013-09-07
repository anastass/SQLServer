USE [master];
GO
IF DATABASEPROPERTYEX (N'DBMaint2012', N'VERSION') > 0
BEGIN
	ALTER DATABASE [DBMaint2012] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
		DROP DATABASE [DBMaint2012];
END
GO

-- Create the database
CREATE DATABASE [DBMaint2012];
GO

USE [DBMaint2012];
GO

ALTER DATABASE [DBMaint2012]
	SET RECOVERY FULL;
GO

-- Create table
CREATE TABLE [TestTable] (
	[c1] INT IDENTITY,
	[c2] VARCHAR(100));
GO
CREATE CLUSTERED INDEX [TestTable_CL]
	ON [TestTable] ([c1]);
GO
	
INSERT INTO [TestTable] 
	VALUES ('Initial data: transaction 1');
GO

-- And take a full backup
BACKUP DATABASE [DBMaint2012] TO
	DISK = 'C:\TEMP\DBMaint2012.bck'
WITH INIT;
GO
/*
Processed 280 pages for database 'DBMaint2012', file 'DBMaint2012' on file 1.
Processed 6 pages for database 'DBMaint2012', file 'DBMaint2012_log' on file 1.
BACKUP DATABASE successfully processed 286 pages in 0.328 seconds (6.789 MB/sec).
*/

-- Now add some more data
INSERT INTO [TestTable] 
	VALUES ('Transaction 2');
GO
INSERT INTO [TestTable] 
	VALUES ('Transaction 3');
GO
SELECT * FROM [TestTable] 

-- Simulate a crash
SHUTDOWN WITH NOWAIT;
GO

-- Delete the data file and restart SQL
-- C:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\DBMaint2012.mdb

USE [DBMaint2012];
GO
/*
Msg 233, Level 20, State 0, Line 0
A transport-level error has occurred when sending the request to the server. (provider: Shared Memory Provider, error: 0 - No process is on the other end of the pipe.)
*/

-- The backup doesn't have the most recent
-- transactions - if we restore it we'll
-- lose them.

-- Take a log backup?
BACKUP LOG [DBMaint2012] TO
	DISK = 'C:\TEMP\DBMaint2012_tail.bck'
WITH INIT;
GO
/*
Msg 945, Level 14, State 2, Line 1
Database 'DBMaint2012' cannot be opened due to inaccessible files or insufficient memory or disk space.  See the SQL Server errorlog for details.
Msg 3013, Level 16, State 1, Line 1
BACKUP LOG is terminating abnormally.
*/

-- Use the special syntax
BACKUP LOG [DBMaint2012] TO
	DISK = 'C:\TEMP\DBMaint2012_tail.bck'
WITH INIT, NO_TRUNCATE;
GO
/*
Processed 7 pages for database 'DBMaint2012', file 'DBMaint2012_log' on file 1.
BACKUP LOG successfully processed 7 pages in 0.019 seconds (2.595 MB/sec).
*/

-- Now restore
RESTORE DATABASE [DBMaint2012] FROM
	DISK = 'C:\TEMP\DBMaint2012.bck'
WITH REPLACE, NORECOVERY;
GO
/*
Processed 280 pages for database 'DBMaint2012', file 'DBMaint2012' on file 1.
Processed 5 pages for database 'DBMaint2012', file 'DBMaint2012_log' on file 1.
RESTORE DATABASE successfully processed 285 pages in 0.191 seconds (11.634 MB/sec).
*/

RESTORE DATABASE [DBMaint2012] FROM
	DISK = 'C:\TEMP\DBMaint2012_tail.bck'
WITH REPLACE, NORECOVERY;
GO
/*
Processed 0 pages for database 'DBMaint2012', file 'DBMaint2012' on file 1.
Processed 7 pages for database 'DBMaint2012', file 'DBMaint2012_log' on file 1.
RESTORE LOG successfully processed 7 pages in 0.074 seconds (0.666 MB/sec).
*/

RESTORE DATABASE [DBMaint2012] WITH RECOVERY;
GO
/*
RESTORE DATABASE successfully processed 0 pages in 0.908 seconds (0.000 MB/sec).
*/

-- Is everything there?
SELECT * FROM [DBMaint2012].[dbo].[TestTable] 

/*
-- Clean-up
USE [master]
GO
DROP DATABASE [DBMaint2012];
GO
*/

