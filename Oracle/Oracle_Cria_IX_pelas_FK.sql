/*
  Alter @OWNER for your owner database
*/

create or replace function COLUNAS_FK(tabela varchar) return varchar2 is
  colunas varchar2(4000);  
  cursor CUR_COLUNAS is
    select * from ALL_CONS_COLUMNS where OWNER = '@OWNER' and CONSTRAINT_NAME =  tabela order by POSITION;
begin
  colunas := '';
  for c1 in CUR_COLUNAS loop
    if (LENGTH(colunas) > 0) then
      colunas := colunas || ',';
    end if;
    colunas := colunas || c1.COLUMN_NAME;
  end loop;
  return colunas;
end;  
/

create or replace function COLUNAS_IX(indexe varchar) return varchar2 is
  colunas varchar2(4000);  
  cursor CUR_COLUNAS is
    select * from ALL_IND_COLUMNS where INDEX_OWNER = '@OWNER' and INDEX_NAME =  indexe order by COLUMN_POSITION;
begin
  colunas := '';
  for c1 in CUR_COLUNAS loop
    if (LENGTH(colunas) > 0) then
      colunas := colunas || ',';
    end if;
    colunas := colunas || c1.COLUMN_NAME;
  end loop;
  return colunas;
end;  
/

create table FK
(
   FK varchar(50),
   TABELA varchar(50),
   COLUNAS varchar(4000)
);

create table IX 
(
   IX varchar(50),
   TABELA varchar(50),
   COLUNAS varchar(4000)
);

insert into FK (FK, TABELA, COLUNAS)
select CONSTRAINT_NAME, TABLE_NAME, COLUNAS_FK(CONSTRAINT_NAME)  from ALL_CONSTRAINTS where OWNER = '@OWNER' and CONSTRAINT_TYPE = 'R';

insert into IX (IX, TABELA, COLUNAS)
select 
  a.INDEX_NAME as IX, a.TABLE_NAME as Tabela, COLUNAS_IX(a.INDEX_NAME) Colunas
from 
  ALL_IND_COLUMNS a 
  left join ALL_CONSTRAINTS b on b.OWNER = a.INDEX_OWNER and b.CONSTRAINT_NAME = a.INDEX_NAME
where 
  a.INDEX_OWNER = '@OWNER'
  and a.INDEX_NAME not like 'BIN$%'
  and a.INDEX_NAME not like 'SYS_%'
  and b.CONSTRAINT_NAME is null
group by
  a.INDEX_NAME, a.TABLE_NAME;

commit;

select 
   'create index @OWNER.A_' || substr(a.FK, 1, 26) || '_I on @OWNER.' || a.TABELA || ' (' || a.COLUNAS || ')@' as SQL
from 
  FK a
  left join IX b on b.COLUNAS = a.COLUNAS
where
  b.IX is null;
