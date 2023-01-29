@echo on
set pgversion=15

::echo restoring global options
::"C:\Program Files"\PostgreSQL\%pgversion%\bin\psql.exe -U postgres -h localhost -p 5432 -f "C:\Users\Niclas\Desktop\postgres_backup"\pg_globals.sql

for /r %%i in (C:\Users\Niclas\Desktop\postgres_backup\*) do (
    if not %%i=="pg_globals.sql"
        echo restoring %%i
        "C:\Program Files"\PostgreSQL\%pgversion%\bin\createdb.exe -U postgres -h localhost -p 5432 %%i
        ::"C:\Program Files"\PostgreSQL\%pgversion%\bin\psql.exe -U postgres -h localhost -p 5432 -d %%i -f "C:\Users\Niclas\Desktop"\%%i.sql
)