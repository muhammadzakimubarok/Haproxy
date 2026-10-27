@echo off

echo Menambahkan record hosts...

echo 172.16.15.199 zakismkn4.local >> C:\Windows\System32\drivers\etc\hosts
echo 172.16.15.199 www.zakismkn4.local >> C:\Windows\System32\drivers\etc\hosts

ipconfig /flushdns

echo.
echo Selesai
pause