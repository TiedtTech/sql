declare 
	-- Variaveis a serem informadas		
	@Base varchar(255),
	-- Variaveis utilizadas na rotina
	@PastaDestino nvarchar(255),
	@ComandoSQL nvarchar(max)	

set @PastaDestino = 'C:\Base SQL Server\';
-- Informe aqui os valores
set @Base = 'MEGA_OMIE';

execute ('use ' + @Base);

set @ComandoSQL = 
	'backup database ' + @Base + ' to disk = N''' + @PastaDestino + @Base  + '.bak'' ' +
	'with format, medianame = ''BACKUP_FULL_' + @Base + ''' , name = ''Backup Full Base ' + @Base + '''';

execute (@ComandoSQL);