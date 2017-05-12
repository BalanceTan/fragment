
@echo off

route print -4 "10.0.0.0" | find "10.0.0.0" > route_list
set gw=

for /F "tokens=1-5" %%a in ('type route_list') do (
 if not "%%c" == "" ( set gw=%%c )
)

if "%gw%" == "" ( echo "fail to get eth0 default gw" && goto error)


route print -4 100.64.0.0 | find "%gw%" > NUL
if not "%errorlevel%" == "0" (
	route -p add 100.64.0.0 mask 255.192.0.0 %gw% > NUL 2>&1
)
if not "%errorlevel%" == "0" ( echo "faild to add route 100.64.0.0/10" && goto error)

:success
del route_list
echo "add 100.64.0.0/10 success !"
timeout 10
exit 0

:error
timeout 10
exit 1

