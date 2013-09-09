USE master;
GO
-- Create the database with the default data
-- filegroup and a log file. Specify the
-- growth increment and the max size for the
-- primary data file.
CREATE DATABASE MyDB
ON PRIMARY
  ( NAME='MyDB_Primary',
    FILENAME=
       'C:\Program Files\Microsoft SQL Server\MSSQL10.SQLEXPRESS\MSSQL\DATA\MyDB_Prm.mdf',
    SIZE=4MB,
    MAXSIZE=10MB,
    FILEGROWTH=1MB),
FILEGROUP MyDB_FG1
  ( NAME = 'MyDB_FG1_Dat1',
    FILENAME =
       'C:\Program Files\Microsoft SQL Server\MSSQL10.SQLEXPRESS\MSSQL\DATA\MyDB_FG1_1.ndf',
    SIZE = 1MB,
    MAXSIZE=10MB,
    FILEGROWTH=1MB),
  ( NAME = 'MyDB_FG1_Dat2',
    FILENAME =
       'C:\Program Files\Microsoft SQL Server\MSSQL10.SQLEXPRESS\MSSQL\DATA\MyDB_FG1_2.ndf',
    SIZE = 1MB,
    MAXSIZE=10MB,
    FILEGROWTH=1MB)
LOG ON
  ( NAME='MyDB_log',
    FILENAME =
       'C:\Program Files\Microsoft SQL Server\MSSQL10.SQLEXPRESS\MSSQL\DATA\MyDB.ldf',
    SIZE=1MB,
    MAXSIZE=10MB,
    FILEGROWTH=1MB);
GO
ALTER DATABASE MyDB 
  MODIFY FILEGROUP MyDB_FG1 DEFAULT;
GO

-- Create a table on primary.
CREATE TABLE MyTable
  ( cola int PRIMARY KEY,
    colb char(8) )
ON [PRIMARY];
GO

-- Create a table in the user-defined filegroup.
USE MyDB;
CREATE TABLE MyTable1
  ( cola int PRIMARY KEY,
    colb char(8) )
ON [MyDB_FG1]
GO

-- 'ON MyDB_FG1'  because this is the default group
CREATE TABLE MyTable2
  ( cola int PRIMARY KEY,
    colb char(8) )
GO

-- show MyTable2 file group
-- (see: How to get the File Group of a Table or an Index? http://tinyurl.com/plqczpp)
SELECT d.name AS FileGroup
 FROM sys.filegroups d
 JOIN sys.indexes i
   ON i.data_space_id = d.data_space_id
 JOIN sys.tables t
   ON t.object_id = i.object_id
WHERE i.index_id<2                     -- could be heap or a clustered table
 AND t.name= 'MyTable2'
 AND t.schema_id = schema_id('dbo');
GO

/*
-- Clean-up
USE [master];
GO
DROP DATABASE [MyDB];
GO
*/