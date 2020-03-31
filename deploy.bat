:: Usage: ./deplay.bat "Changes message"

set WORKSHOP_ID=523399678

"%GMOD_HOME%\bin\gmad.exe" create -folder . -out .\_temp.gma
"%GMOD_HOME%\bin\gmpublish.exe" update -addon .\_temp.gma -id "%WORKSHOP_ID%" -changes %*
del .\_temp.gma
pause
