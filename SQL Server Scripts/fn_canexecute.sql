/***
	Purpose  :	Check if execute permission is granted
	Parmeters:
		@procedure_name	- procedure name
		@username		- user name
	Returns  :  1-execute permission is granted otherwise null
	Example  :
		if [dbo].[fn_canexecute]('fn_getMetadataTag', 'INISReadonly') = 1
			print 'execute permission is granted'
		else
			print 'execute permission is NOT granted'
*/
CREATE FUNCTION [dbo].[fn_canexecute](
	@procedure_name varchar(255), 
	@username varchar(255)
)
RETURNS bit
BEGIN
	DECLARE @has_execute_permissions bit

	/* Explicit permission */
	SELECT @has_execute_permissions = 1
	FROM sys.database_permissions p
	INNER JOIN sys.all_objects o ON p.major_id = o.[object_id] AND o.[name] = @procedure_name
	INNER JOIN sys.database_principals dp ON p.grantee_principal_id = dp.principal_id AND dp.[name] = @username

	IF @has_execute_permissions <> 1
		/* Role-based permission */
		SELECT @has_execute_permissions = 1
		FROM sys.database_permissions p
		INNER JOIN sys.all_objects o ON p.major_id = o.[object_id]
		INNER JOIN sys.database_principals dp ON p.grantee_principal_id = dp.principal_id AND o.[name] = @procedure_name
		INNER JOIN sys.database_role_members drm ON dp.principal_id = drm.role_principal_id
		INNER JOIN sys.database_principals dp2 ON drm.member_principal_id = dp2.principal_id AND dp2.[name] = @username
	RETURN @has_execute_permissions
END
