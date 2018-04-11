select 'DROP TABLE AUTOMA.'||TABLE_NAME||' CASCADE CONSTRAINTS;' FROM all_tables where owner='AUTOMA' union
select 'DROP SEQUENCE '||SEQUENCE_NAME||';' FROM all_sequences where sequence_owner='AUTOMA' union
select 'DROP VIEW '||VIEW_NAME||';' FROM all_views where owner='AUTOMA' union
select 'DROP TRIGGER '||TRIGGER_NAME||';' FROM all_triggers where owner='AUTOMA' union
select 'DROP SYNONYM '||OBJECT_NAME||';' FROM ALL_OBJECTS where owner='AUTOMA' and object_type = 'SYNONYM' union
select 'DROP PROCEDURE '||OBJECT_NAME||';' FROM ALL_PROCEDURES where owner='AUTOMA' and object_type = 'PROCEDURE' union
select 'DROP FUNCTION '||OBJECT_NAME||';' FROM ALL_PROCEDURES where owner='AUTOMA' and object_type = 'FUNCTION' union
select 'DROP PROCEDURE '||OBJECT_NAME||';' FROM ALL_OBJECTS where owner='AUTOMA' and object_type = 'PROCEDURE' union
select 'DROP FUNCTION '||OBJECT_NAME||';' FROM ALL_OBJECTS where owner='AUTOMA' and object_type = 'FUNCTION' union
select 'DROP PACKAGE '||OBJECT_NAME||';' FROM ALL_OBJECTS where owner='AUTOMA' and object_type = 'PACKAGE' union
select 'EXECUTE sys.dbms_scheduler.drop_job(''' ||   OBJECT_NAME || ''');' FROM ALL_OBJECTS where owner='AUTOMA' and object_type = 'JOB' union
select 'EXECUTE sys.dbms_scheduler.drop_schedule(''' ||   OBJECT_NAME || ''');' FROM ALL_OBJECTS where owner='AUTOMA' and object_type = 'SCHEDULE';