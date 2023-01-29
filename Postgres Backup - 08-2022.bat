@echo off
set PGBINDIR="C:\Program Files\PostgreSQL\10\bin"
set PGBACKUPDIR="C:\Postgres Backups"
set LogDir="C:\Postgres Backups\Logs\"

FOR /f %%a IN ('WMIC OS GET LocalDateTime ^| FIND "."') DO SET DTS=%%a
SET DateTime=%DTS:~0,4%%DTS:~4,2%%DTS:~6,2%_%DTS:~8,2%%DTS:~10,2%%DTS:~12,2%

rem create a text file listing all databases
rem adjust here if you want to exclude a database
rem "%PGBINDIR%\psql.exe" -X -U postgres -c "select datname from pg_database where not datistemplate" -A -t -o dblist.txt -d template1

rem create directory for daily backup files
echo %date% %time%: Creating backup directory > %LogDir%BackupLog%datetime%.log
echo. >> %LogDir%BackupLog%datetime%.log

mkdir %PGBACKUPDIR%\%DATE% >> %LogDir%BackupLog%datetime%.log

rem dump all user accounts and roles
echo %date% %time%: Starting backup process >> %LogDir%BackupLog%datetime%.log
echo. >> %LogDir%BackupLog%datetime%.log
echo %date% %time%: Backing up: Global options >> %LogDir%BackupLog%datetime%.log

%PGBINDIR%\pg_dumpall.exe --globals-only -U postgres -c -f %PGBACKUPDIR%\%DATE%\pg_globals.sql >> %LogDir%BackupLog%datetime%.log
for /f %%i in (dblist.txt) do (
  echo Backing up: %%i
  echo %date% %time%: Backing up: %%i >> %LogDir%BackupLog%datetime%.log
  %PGBINDIR%\pg_dump.exe -U postgres -c -f %PGBACKUPDIR%\%DATE%\%%i.sql %%i
)
echo. >> %LogDir%BackupLog%datetime%.log

rem zipping backup directory and files
echo %date% %time%: Zipping Backup File >> %LogDir%BackupLog%datetime%.log
echo. >> %LogDir%BackupLog%datetime%.log

C:\Users\Administrator\Documents\7za.exe a %PGBACKUPDIR%\pg_backup_%DATE%.zip %PGBACKUPDIR%\%DATE% >> %LogDir%BackupLog%datetime%.log

rem Deleting unzipped backup directory
echo %date% %time%: Deleting unzipped Backup Directory >> %LogDir%BackupLog%datetime%.log
echo. >> %LogDir%BackupLog%datetime%.log

rmdir %PGBACKUPDIR%\%DATE% /s /q >> %LogDir%BackupLog%datetime%.log

rem Cleaning zipped backup directories older than 60 days
echo %date% %time%: Cleaning old Zipped Backup Directories >> %LogDir%BackupLog%datetime%.log
echo. >> %LogDir%BackupLog%datetime%.log

forfiles /P %PGBACKUPDIR% /S /M *.* /D -60 /C "cmd /c del @PATH /q" >> %LogDir%BackupLog%datetime%.log

rem starting script to synchronize local backup directory with file server
echo %date% %time%: Starting script to sync backup to file server with winscp >> %LogDir%BackupLog%datetime%.log
echo. >> %LogDir%BackupLog%datetime%.log

"C:\Program Files (x86)\WinSCP"\winscp /console /script=C:\Users\Administrator\Documents\postgres-backup-upload-winscp.txt >> %LogDir%BackupLog%datetime%.log