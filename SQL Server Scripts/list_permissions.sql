/***
	Purpose: Return all permissions
	Uses:
		sys.system_views	- Contains one row for each system view shipped with SQL Server.
		sys.objects			- Contains a row for each user-defined, schema-scoped object that is created 
							  within a database.
	    sys.columns 		- Returns a row for each column of an object that has columns, such as views or tables.
	    sys.database_principals - Returns a row for each principal in a database.	                      
		sys.database_permissions - Returns a row for every permission or column-exception permission in the 
		                      database. For columns, there is a row for every permission that is different from 
		                      the corresponding object-level permission. If the column permission is the same as 
		                      the corresponding object permission, there will be no row for it and the actual 
		                      permission used will be that of the object.
   	Related:
		sys.sysusers		- Contains one row for each Microsoft Windows user, Windows group, 
				              Microsoft SQL Server user, or SQL Server role in the database
		sys.parameters		- Contains a row for each parameter of an object that accepts parameters. If the object 
							  is a scalar function, there is also a single row describing the return value. That row 
							  will have a parameter_id value of 0. 
   	See also: [Views].[System Views]
    Note: 
    	1) Selection below uses Common Table Expression (CTE) 
    	2) Uses
    			select name from sys.database_principals where principal_id = grantor_principal_id
    	   instead of
	    	   select name from sys.sysusers where uid = grantor_principal_id

*/
with PermissionTable
as
(
	select
		class,
		class_desc,
		-- object type (extension): S-system object, U-user-defined or schema-scoped object
		object_type = (case when major_id < 0 then 'S' when major_id > 0 then 'U' else '' end), 
		-- major_id,
		name = isnull((
			select name from sys.system_views where object_id = major_id
			union
			select name from sys.objects where object_id = major_id
		), ''),
		-- minor_id,
		supl_name = isnull((select name from sys.columns where object_id = major_id and column_id = minor_id), ''),
		-- grantee_principal_id,
		grantee_name = (select name from sys.database_principals where principal_id = grantee_principal_id),
		-- grantor_principal_id,
		grantor_name = (select name from sys.database_principals where principal_id = grantor_principal_id),
		type,
		permission_name,
		state,
		state_desc
	from sys.database_permissions
)
select * from PermissionTable
--where 
--   name = 'fn_getMetadataTag'
--   grantee_name = 'INISReadonly'
--   grantor_name = 'dbo'
--   permission_name = 'execute'