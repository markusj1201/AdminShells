@echo off

SETLOCAL ENABLEDELAYEDEXPANSION
cd /d %~dp0%
set SITE_BASE=%cd%

set PATH=%SITE_BASE%\..\.bin\svn-win32-1.6.15\bin;%PATH%
set LANG=en_US.UTF-8
set LC_CTYPE=en_US.UTF-8

pushd "%SITE_BASE%\repo-win"
for %%i in (*.cfg.cmd) do (
    echo.
    echo ================================================================================
    echo Start: !date! !time! *******
    call %%i
    echo _REPO_DIR = !_REPO_DIR!
    echo _SVN_URL = !_SVN_URL!
    echo ================================================================================
    REM echo _SVN_SYNC_U = !_SVN_SYNC_U!
    REM echo _SVN_SYNC_P = !_SVN_SYNC_P!
    
    set _REPO_URL=!_REPO_DIR:\=/!
    IF NOT EXIST "!_REPO_DIR!" (
        echo !_REPO_URL! not initialized, begin to initialize ...
        mkdir "!_REPO_DIR!"
        pushd "!_REPO_DIR!"
        svnadmin create .
        echo ::It's blank > ./hooks/pre-revprop-change.bat
        svnsync initialize --non-interactive --source-username=!_SVN_SYNC_U! --source-password=!_SVN_SYNC_P! file:///!_REPO_URL! !_SVN_URL!
			set _ERR_CODE=!ERRORLEVEL!
			IF NOT "!_ERR_CODE!"=="0" (
				echo ">>> svnsync initialize ERROR: !_ERR_CODE!"
			    exit /b !_ERR_CODE!
			)
        popd
    )
    echo !_REPO_URL!: begin to sync ...
    REM ��ֹ svnsync �ظ�����
    wmic process where "name='svnsync.exe' and commandline like '%%!_REPO_URL!%%'" call terminate
    REM ��� sync ����(��Ϊǿ�йر� svnsync ������ԭ�����)
    svn propdel svn:sync-lock --revprop -r0 file:///!_REPO_URL!
    REM �޸� SVN ͬ������Դ URL, ���Զ�֧����Դ URL �ı�����
    svn propset svn:sync-from-url --revprop -r0 !_SVN_URL! file:///!_REPO_URL!
    REM ִ�� SVN ��ͬ��
    svnsync sync --non-interactive --source-username=!_SVN_SYNC_U! --source-password=!_SVN_SYNC_P! file:///!_REPO_URL!
		set _ERR_CODE=!ERRORLEVEL!
		IF NOT "!_ERR_CODE!"=="0" (
			echo ">>> svnsync sync ERROR: !_ERR_CODE!"
			exit /b !_ERR_CODE!
		)
    echo Finish: !date! !time! *******
)
popd


ENDLOCAL
