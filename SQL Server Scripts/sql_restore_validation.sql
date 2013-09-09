USE [master];
GO

-- Backup database
BACKUP DATABASE [INISReference] TO
	DISK = 'C:\TEMP\INISReference.bck'
WITH INIT, CHECKSUM;
GO
/*
Processed 568 pages for database 'INISReference', file 'INISReference' on file 1.
Processed 2 pages for database 'INISReference', file 'INISReference_log' on file 1.
BACKUP DATABASE successfully processed 570 pages in 0.189 seconds (23.553 MB/sec).
*/

-- Validate backup
RESTORE VERIFYONLY FROM
	DISK = 'C:\TEMP\INISReference.bck'
WITH CHECKSUM;
GO
/*
The backup set on file 1 is valid.
*/

-- Now restore database using another name
RESTORE DATABASE [INISReference1] FROM
	DISK = 'C:\TEMP\INISReference.bck'
WITH CHECKSUM,
	MOVE 'INISReference' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.SQLEXPRESS\MSSQL\DATA\INISReference1.mdb',
	MOVE 'INISReference_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.SQLEXPRESS\MSSQL\DATA\INISReference1_log.ldf';
GO
/*
Processed 568 pages for database 'INISReference1', file 'INISReference' on file 1.
Processed 2 pages for database 'INISReference1', file 'INISReference_log' on file 1.
RESTORE DATABASE successfully processed 570 pages in 0.195 seconds (22.829 MB/sec).
*/

/*
-- Clean-up
DROP DATABASE [INISReference1];
GO
*/