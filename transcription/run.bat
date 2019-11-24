echo "Batch script running TurboTranscriber"

: run all .jar files in directory

@echo off

for /F %%f in ('dir /b %cd%') do (
	if "%%~xf" == ".jar" (
		java -jar %%f
		)
	)

pause
