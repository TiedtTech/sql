/* 
	Variavel de entrada
	@CaminhoOrigem - 'C:\backup.bak'
	@BaseDestino   - 'TESTE'
	RESTORE FILELISTONLY FROM DISK = 'C:\Megasul\160119155341.bak'
	
	use master
	execute (
	'  CREATE DATABASE ' + @BaseDestino + ' ON  PRIMARY ' +
	'  ( NAME = ''' + @BaseDestino + ''', FILENAME = ''C:\Megasul\Bases\' + @BaseDestino + '.mdf'' ) ' +
	'   LOG ON  ' +
	'  ( NAME = ''' + @BaseDestino + '_log'', FILENAME = ''C:\Megasul\Bases\' + @BaseDestino + '_log.ldf'' ) ');

*/

declare 
	-- Variaveis a serem informadas
	@CaminhoOrigem nvarchar(255),
	@BaseDestino varchar(255),
	-- Variaveis utilizadas na rotina
	@ComandoSQL nvarchar(max),
	@physical_name varchar(255),
	@physical_namelog varchar(255),
	@logicalName varchar(255),
	@logicalNameLog varchar(255)	

-- Informe aqui os valores
set @CaminhoOrigem = 'C:\Base SQL Server\170510070023.bak';
set @BaseDestino = 'MEGA_25944';

use master

-- Verifica se existe a base de dados
if (select count(*) from sys.Databases where name = @BaseDestino) = 0
begin
	execute (
	'  CREATE DATABASE ' + @BaseDestino + ' ON  PRIMARY ' +
	'  ( NAME = ''' + @BaseDestino + ''', FILENAME = ''C:\Megasul\Bases\' + @BaseDestino + '.mdf'' ) ' +
	'   LOG ON  ' +
	'  ( NAME = ''' + @BaseDestino + '_log'', FILENAME = ''C:\Megasul\Bases\' + @BaseDestino + '_log.ldf'' ) ');	
end

execute ('ALTER DATABASE ' + @BaseDestino + ' SET SINGLE_USER WITH ROLLBACK IMMEDIATE');

-- Buscando o caminho do arquivo do mdf
select @physical_name = a.FileName from sys.sysaltfiles a
	inner join sys.databases b on (b.database_id = a.dbid)
where b.name = @BaseDestino
	and a.FileID = 1;
-- Buscando o caminho do arquivo do log
select @physical_namelog = a.FileName from sys.sysaltfiles a
	inner join sys.databases b on (b.database_id = a.dbid)
where b.name = @BaseDestino
	and a.FileID = 2;

--print @physical_name
--print @physical_namelog

if (select object_id('BackupScript')) > 0
  drop table BackupScript;

create table BackupScript
(
   LogicalName NVARCHAR(128)
 , PhysicalName NVARCHAR(260)
 , Type CHAR(1)
 , FileGroupName NVARCHAR(128)
 , Size numeric(20,0)
 , MaxSize numeric(20,0)
 , FileId bigint
 , CreateLSN numeric(25,0)
 , DropLSN numeric(25,0)
 , UniqueId uniqueidentifier
 , ReadOnlyLSN numeric(25,0)
 , ReadWriteLSN numeric(25,0)
 , BackupSizeInBytes bigint
 , SourceBlockSize bigint
 , FilegroupId bigint
 , LogGroupGUID uniqueidentifier
 , DifferentialBaseLSN numeric(25)
 , DifferentialBaseGUID uniqueidentifier
 , IsReadOnly bigint
 , IsPresent bigint
 , TDEThumbprint varbinary(32)
);

-- Montando o comando para buscar os dados para o backup
set @ComandoSQL = 'RESTORE FILELISTONLY FROM DISK = ''' + @CaminhoOrigem + ''' ';

insert into BackupScript
execute (@ComandoSQL);

select @logicalName = logicalName from BackupScript where Type = 'D'
select @logicalNameLog = logicalName from BackupScript where Type = 'L'

--print @logicalName;
--print @logicalNameLog;
--RESTRICTED_USER


set @ComandoSQL = 
	N' RESTORE DATABASE ' + @BaseDestino +
	 ' FROM  DISK = N''' + @CaminhoOrigem + ''' ' +
	 ' WITH  FILE = 1, ' +
	 ' MOVE N''' + @logicalName + ''' ' +
	 ' TO N''' + @physical_name + ''',' +
	 ' MOVE N''' + @logicalNameLog + ''' ' +
     ' TO N''' + @physical_namelog + ''' , NOUNLOAD, REPLACE,  STATS = 5 ';

--print @ComandoSQL;
execute (@ComandoSQL);

drop table BackupScript

execute ('use ' + @BaseDestino + ';DROP USER automa');
execute ('use ' + @BaseDestino + ';CREATE USER AUTOMA FOR LOGIN AUTOMA WITH DEFAULT_SCHEMA = dbo');
execute ('use ' + @BaseDestino + ';EXEC sp_addrolemember ''db_owner'', ''AUTOMA''');
