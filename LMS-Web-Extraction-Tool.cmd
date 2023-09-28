:::: LMS Web Application Extraction Tool ::::::::::::::::::::::::::::::::::::

::#############################################################################
::							#DESCRIPTION#
::
::	SCRIPT STYLE: 
::	Program is 
::#############################################################################

:::: Developer ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Author:		David Geeraerts
:: Location:	Olympia, Washington USA
:: E-Mail:		dgeeraerts.evergreen@gmail.com
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::: GitHub :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::	https://github.com/DavidGeeraerts/
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::: License ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Copyleft License(s)
:: GNU GPL v3 (General Public License)
:: https://www.gnu.org/licenses/gpl-3.0.en.html
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::: Versioning Schema ::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::		VERSIONING INFORMATION												 ::
::		Semantic Versioning used											 ::
::		http://semver.org/													 ::
::		Major.Minor.Revision												 ::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:::: Command shell ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@Echo Off
@SETLOCAL enableextensions
SET $PROGRAM_NAME=LMS-Web-Extraction-Tool
SET $Version=1.2.0
SET $BUILD=2023-09-28 0800
Title %$PROGRAM_NAME%
Prompt LWET$G
color 8F
mode con:cols=80 lines=56
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::###########################################################################::
:: Declare Global variables [Defaults]
::###########################################################################::


:: Product ID
SET $PRODUCTID=0
SET $PRODUCTID_LAST=15874


:: Directories
::	Project Directory
SET $DIRECTORY_PROJECT=D:\Projects\LMS-Migration
::	Location for web pages scraped
SET $DIRECTORY_WEB_PAGES=.\data\merci-inventory-web-page-scrape

:: cURL Configuration
SET $CURL_COOKIE_DIRECTORY=D:\Projects\LMS-Migration\config
SET $CURL_COOKIE_FILE=cookies.txt


::	URL's URI's
::	Merci Product URL
SET $URL_MERCI_PRODUCT=https://adminweb.evergreen.edu/sciencesupport/admin/commerce/products


SET $MERCI_STATUS_CHOICES_FILE=.\Config\Merci_Status_Choices.txt


:: Logging
SET $LOG_DIRECTORY_PATH=logs
SET $LOG_FILE=LMS-Web-Application-Extraction-Tool.log



::#############################################################################
::	!!!!	Everything below here is 'hard-coded' [DO NOT MODIFY]	!!!!
::#############################################################################

:: Start Time Start Date
SET $START_TIME=%Time%
SET $START_DATE=%Date%

CD /D %$DIRECTORY_PROJECT%

:fISO8601
:: Function to ensure ISO 8601 Date format yyyy-mmm-dd
:: Easiest way to get ISO date
@powershell Get-Date -format "yyyy-MM-dd"> ".\cache\var_ISO8601_Date.txt"
SET /P $ISO_DATE= < ".\cache\var_ISO8601_Date.txt"


:Start
echo. >> .\%$LOG_DIRECTORY_PATH%\%$LOG_FILE%
Echo %DATE%	%Time%	Start... >> .\%$LOG_DIRECTORY_PATH%\%$LOG_FILE%
Echo %Time%	%$PROGRAM_NAME% >> .\%$LOG_DIRECTORY_PATH%\%$LOG_FILE%
echo %Time%	Version: %$Version% >> .\%$LOG_DIRECTORY_PATH%\%$LOG_FILE%
echo %Time%	Build: %$BUILD% >> .\%$LOG_DIRECTORY_PATH%\%$LOG_FILE%

:param
:: Capture Parameter 1 for properties file
SET $PARAMETER1=%~1
:: If parameter provided set it as the productid
IF DEFINED $PARAMETER1 echo	%Time%	Parameter: 	%$PARAMETER1% >> .\%$LOG_DIRECTORY_PATH%\%$LOG_FILE%
IF DEFINED $PARAMETER1 SET $PRODUCTID=%$PARAMETER1%
IF DEFINED $PARAMETER1 echo %Time%		[DEBUG]	Parameter: %$PARAMETER1% >> .\%$LOG_DIRECTORY_PATH%\%$LOG_FILE%


:scrape
:::: Stopwatch start ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
SET $START_LOAD_TIME=%TIME%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


IF NOT DEFINED $PARAMETER1 SET /A $PRODUCTID+=1
echo %TIME%	Starting scrape for Product-ID: %$PRODUCTID% >> .\%$LOG_DIRECTORY_PATH%\%$LOG_FILE%

::	Check that the product ID exists in the database
REM Check against product ID since that is the primary key
FINDSTR /B /L /C:"%$PRODUCTID%" "%$DIRECTORY_PROJECT%\Data\Merci-DB-Item-export.txt" 2> nul
SET $RECORD_DB_CHECK=%ERRORLEVEL%
echo %TIME%	[DEBUG]	RECORD_CHECK:	%$RECORD_DB_CHECK% >> .\%$LOG_DIRECTORY_PATH%\%$LOG_FILE%
IF %$RECORD_DB_CHECK% NEQ 0 GoTo scrape


:: cURL will fail if the directory path doesn't exist.
IF NOT EXIST .\data\merci-inventory-web-page-scrape\%$PRODUCTID% mkdir .\data\merci-inventory-web-page-scrape\%$PRODUCTID%

:: Get the Merci Inventory Web Page by Product ID
curl --cookie %$CURL_COOKIE_DIRECTORY%\%$CURL_COOKIE_FILE% %$URL_MERCI_PRODUCT%/%$PRODUCTID%> "%$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-Merci-Inventory-Web-Page.txt"

:: Check again if Product-ID exists
FINDSTR /L /C:"<title>Page not found" "%$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-Merci-Inventory-Web-Page.txt"
SET $RECORD_WEB_CHECK=%ERRORLEVEL%
IF %$RECORD_WEB_CHECK% EQU 0 RD /S /Q "%$DIRECTORY_WEB_PAGES%\%$PRODUCTID%"
IF %$RECORD_WEB_CHECK% EQU 0 GoTo scrape 

:: Extracted Fields for Product ID
FINDSTR /R /C:"name=\"sku\" value\=" %$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-Merci-Inventory-Web-Page.txt > "%$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-product-fields.txt"
FINDSTR /R /C:"name=\"title\" value\=" %$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-Merci-Inventory-Web-Page.txt >> "%$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-product-fields.txt"
FINDSTR /R /C:"\"field_quantity\[und\]\[0\]\[value\]\" value=" %$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-Merci-Inventory-Web-Page.txt >> "%$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-product-fields.txt"
FINDSTR /R /C:"\"commerce_price\[und\]\[0\]\[amount\]\" value=" %$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-Merci-Inventory-Web-Page.txt >> "%$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-product-fields.txt"
FINDSTR /R /C:"\"field_vendor\[und\]\[0\]\[value\]\" value=" %$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-Merci-Inventory-Web-Page.txt >> "%$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-product-fields.txt"
FINDSTR /R /C:"\"field_serial_\[und\]\[0\]\[value\]\" value=" %$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-Merci-Inventory-Web-Page.txt >> "%$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-product-fields.txt"
FINDSTR /R /C:"\"field_purchase_date\[und\]\[0\]\[value\]\[date\]\" value=" %$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-Merci-Inventory-Web-Page.txt >> "%$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-product-fields.txt"
REM Merci Status is a dropdown selection with keyword "selected"
FINDSTR /R /C:"selected\=\"selected\"\>" %$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-Merci-Inventory-Web-Page.txt >> "%$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-product-fields.txt"


:: Extracted Element for Product ID
FINDSTR /R /C:"name=\"sku\" value\=" %$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-product-fields.txt> "%$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-element-sku.txt"
FINDSTR /R /C:"name=\"title\" value\=" %$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-product-fields.txt> "%$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-element-title.txt"
FINDSTR /R /C:"\"field_quantity\[und\]\[0\]\[value\]\" value=" %$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-product-fields.txt> "%$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-element-field_quantity.txt"
FINDSTR /R /C:"\"commerce_price\[und\]\[0\]\[amount\]\" value=" %$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-product-fields.txt> "%$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-element-commerce_price.txt"
FINDSTR /R /C:"\"field_vendor\[und\]\[0\]\[value\]\" value=" %$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-product-fields.txt> "%$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-element-field_vendor.txt"
FINDSTR /R /C:"\"field_serial_\[und\]\[0\]\[value\]\" value=" %$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-product-fields.txt> "%$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-element-field_serial.txt"
FINDSTR /R /C:"\"field_purchase_date\[und\]\[0\]\[value\]\[date\]\" value=" %$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-product-fields.txt> "%$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-element-field_purchase_date.txt"
REM Merci Status is a dropdown selection with keyword "selected"
FINDSTR /R /C:"selected\=\"selected\"\>" %$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-product-fields.txt> "%$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-element-merci_status.txt"


:: Value Pair

:: Doesn't work
::FOR /F %L IN (%$DIRECTORY_WEB_PAGES%\Merci-Fields.txt) DO (
::	SET $ELEMENT=%S & FOR /F "tokens=5 delims= " %%P IN (%$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-%$ELEMENT%-element-product.txt) DO echo %%P> %$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-%$ELEMENT%-value_pair-product.txt
::

FOR /F "tokens=5 delims= " %%P IN (%$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-element-sku.txt) DO echo %%P> %$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-value_pair-sku.txt
FOR /F "tokens=5 delims==" %%P IN (%$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-element-title.txt) DO echo value=%%P> %$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-value_pair-title.txt
FOR /F "tokens=5 delims= " %%P IN (%$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-element-field_quantity.txt) DO echo %%P> %$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-value_pair-field_quantity.txt
FOR /F "tokens=5 delims= " %%P IN (%$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-element-commerce_price.txt) DO echo %%P> %$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-value_pair-commerce_price.txt
FOR /F "tokens=6 delims==" %%P IN (%$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-element-field_vendor.txt) DO echo %%P> %$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-value_pair-field_vendor.txt
:: has to account for vendors with multiple words
:: check against last token would return "size="
SET /P $STRING_VENDOR= < %$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-value_pair-field_vendor.txt
echo value=%$STRING_VENDOR%> %$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-value_pair-field_vendor.txt

:: No longer needed; using "=" as delimeter
::FOR /F "tokens=7 delims= " %%P IN (%$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-element-field_vendor.txt) DO echo %%P> %$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-vendor-word-1.txt
::FOR /F "tokens=8 delims= " %%P IN (%$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-element-field_vendor.txt) DO echo %%P> %$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-vendor-word-2.txt
::(FIND /I "size=" "%$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-vendor-word-2.txt" 2> nul) && (GoTo skipvendorKey)
::FOR /F "tokens=9 delims= " %%P IN (%$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-element-field_vendor.txt) DO echo %%P> %$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-vendor-word-3.txt
::SET $VENDOR-WORD-1=
::FIND /I "size=" %$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-vendor-word-1.txt 2>nul || SET /P $VENDOR-WORD-1= < %$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-vendor-word-1.txt
::SET $VENDOR-WORD-2=
::FIND /I "size=" %$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-vendor-word-2.txt 2>nul || SET /P $VENDOR-WORD-2= < %$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-vendor-word-2.txt
::SET $VENDOR-WORD-3=
::FIND /I "size=" %$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-vendor-word-3.txt 2>nul || SET /P $VENDOR-WORD-3= < %$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-vendor-word-3.txt

::IF DEFINED $VENDOR-WORD-2 SET "$VENDOR-KEY=%$VENDOR-WORD-1% %$VENDOR-WORD-2%"
::IF DEFINED $VENDOR-WORD-3 SET "$VENDOR-KEY=%$VENDOR-WORD-1% %$VENDOR-WORD-2% %$VENDOR-WORD-3%"
::echo %$VENDOR-KEY%> %$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-value_pair-field_vendor.txt
:skipvendorKey
FOR /F "tokens=6 delims==" %%P IN (%$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-element-field_serial.txt) DO echo %%P> %$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-value_pair-field_serial.txt
SET /P $STRING_SERIAL= < %$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-value_pair-field_serial.txt
echo value=%$STRING_SERIAL%> %$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-value_pair-field_serial.txt

FOR /F "tokens=7 delims= " %%P IN (%$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-element-field_purchase_date.txt) DO echo %%P> %$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-value_pair-field_purchase_date.txt

	
:subMPS
:: Merci Parse Status
REM need to find the token with "selected" keyword
::	Use FINDSTR REGX for Merci Status

::	if nothing is found it defaults to none
SET $MERCI_STATUS="none"

:: NOT WORKING
::FOR /F %%P IN (%$MERCI_STATUS_CHOICES_FILE%) DO (FINDSTR /I /R /C:"selected\".%%P*" "%$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-element-merci_status.txt"
::	SET $MERCI_STATUS_ERR=%ERRORLEVEL%
::	IF %$MERCI_STATUS_ERR% EQU 0 SET $MERCI_STATUS=%%P
::	)

:: available
SET $CONDITION=available
FINDSTR /I /R /C:"selected\".%$CONDITION%*" "%$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-element-merci_status.txt"
SET $MERCI_STATUS_ERR=%ERRORLEVEL%
IF %$MERCI_STATUS_ERR% EQU 0 SET $MERCI_STATUS=%$CONDITION%

:: lost
SET $CONDITION=lost
FINDSTR /I /R /C:"selected\".%$CONDITION%*" "%$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-element-merci_status.txt"
SET $MERCI_STATUS_ERR=%ERRORLEVEL%
IF %$MERCI_STATUS_ERR% EQU 0 SET $MERCI_STATUS=%$CONDITION%

:: broken
SET $CONDITION=broken
FINDSTR /I /R /C:"selected\".%$CONDITION%*" "%$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-element-merci_status.txt"
SET $MERCI_STATUS_ERR=%ERRORLEVEL%
IF %$MERCI_STATUS_ERR% EQU 0 SET $MERCI_STATUS=%$CONDITION%

:: retired
SET $CONDITION=retired
FINDSTR /I /R /C:"selected\".%$CONDITION%*" "%$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-element-merci_status.txt"
SET $MERCI_STATUS_ERR=%ERRORLEVEL%
IF %$MERCI_STATUS_ERR% EQU 0 SET $MERCI_STATUS=%$CONDITION%

:: surplus
SET $CONDITION=surplus
FINDSTR /I /R /C:"selected\".%$CONDITION%*" "%$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-element-merci_status.txt"
SET $MERCI_STATUS_ERR=%ERRORLEVEL%
IF %$MERCI_STATUS_ERR% EQU 0 SET $MERCI_STATUS=%$CONDITION%



::	status "selected" will be in second token for the pair, so the value_pair is the first token
::	Key value pair token
::	Token 2		none
::	Token 4		available
::	Token 6		lost
::	Token 8		broken
::	Token 10	retired
::	Token 12	surplus

IF %$MERCI_STATUS%==available SET $MERCI_STATUS_TOKEN=4
IF %$MERCI_STATUS%==lost SET $MERCI_STATUS_TOKEN=6
IF %$MERCI_STATUS%==broken SET $MERCI_STATUS_TOKEN=8
IF %$MERCI_STATUS%==retired SET $MERCI_STATUS_TOKEN=10
IF %$MERCI_STATUS%==surplus SET $MERCI_STATUS_TOKEN=12
:: assigning the key value pair to %$PRODUCTID%-value_pair-merci_status.txt file and cleaning it up
FOR /F "tokens=%$MERCI_STATUS_TOKEN% delims=>" %%P IN (%$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-element-merci_status.txt) DO echo %%P> %$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-value_pair-merci_status.txt 
FOR /F "tokens=2-3 delims== " %%R IN (%$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-value_pair-merci_status.txt) DO ECHO %%R=%%S> %$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-value_pair-merci_status.txt


:: SET the key pair value as variable
::	sku	title	field_quantity	commerce_price	field_vendor	field_serial	field_purchase_date	merci_status
FOR /F "tokens=2 delims==" %%P IN (%$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-value_pair-sku.txt) DO SET $SKU=%%P
FOR /F "tokens=2 delims==" %%P IN (%$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-value_pair-title.txt) DO SET $TITLE=%%P
FOR /F "tokens=2 delims==" %%P IN (%$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-value_pair-field_quantity.txt) DO SET $QUANTITY=%%P
FOR /F "tokens=2 delims==" %%P IN (%$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-value_pair-commerce_price.txt) DO SET $PURCHASE_PRICE=%%P
FOR /F "tokens=2 delims==" %%P IN (%$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-value_pair-field_vendor.txt) DO SET $VENDOR=%%P
FOR /F "tokens=2 delims==" %%P IN (%$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-value_pair-field_serial.txt) DO SET $SERIAL=%%P
FOR /F "tokens=2 delims==" %%P IN (%$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-value_pair-field_purchase_date.txt) DO SET $PURCHASE_DATE=%%P
FOR /F "tokens=2 delims==" %%P IN (%$DIRECTORY_WEB_PAGES%\%$PRODUCTID%\%$PRODUCTID%-value_pair-merci_status.txt) DO SET $MERCI_STATUS=%%P


::	Need to clean up title.
:: Title should be encased in "<title>"
::FIND "%$SKU%" "%$DIRECTORY_PROJECT%\Data\Merci-DB-Item-export.txt"> "%$DIRECTORY_PROJECT%\cache\%$PRODUCTID%-Title.txt"
::FOR /F "skip=2 tokens=3 delims=	" %%P IN (%$DIRECTORY_PROJECT%\cache\%$PRODUCTID%-Title.txt) DO SET "$TITLE=%%P"

:::: Stopwatch start ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
SET $STOP_LOAD_TIME=%TIME%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@PowerShell.exe -c "$span=([datetime]'%Time%' - [datetime]'%$START_LOAD_TIME%'); '{0:00}:{1:00}:{2:00}.{3:00}' -f $span.Hours, $span.Minutes, $span.Seconds, $span.Milliseconds" > ".\cache\var_Load_Time.txt"
SET /P $LOAD_TIME= < ".\cache\var_Load_Time.txt"
echo %TIME%	Product-ID: %$PRODUCTID%	Load Time: %$LOAD_TIME% >> .\%$LOG_DIRECTORY_PATH%\%$LOG_FILE%

:: Headers
IF NOT EXIST "%$DIRECTORY_PROJECT%\Data\Merci-Inventory-Extraction.txt" Echo #PRODUCTID;SKU;TITLE;QUANTITY;PURCHASE_PRICE;VENDOR;SERIAL;PURCHASE_DATE;MERCI_STATUS> "%$DIRECTORY_PROJECT%\Data\Merci-Inventory-Extraction.txt"
REM FINDSTR works, but FIND doesn't work
FINDSTR /B /C:"%$PRODUCTID%" "%$DIRECTORY_PROJECT%\Data\Merci-Inventory-Extraction.txt" 2> nul
REM Check against product ID since that is the primary key
::FIND "%$SKU%" "%$DIRECTORY_PROJECT%\Data\Merci-Inventory-Extraction.txt" 2> nul
SET $RECORD_CHECK=%ERRORLEVEL%
IF %$RECORD_CHECK% EQU 0 GoTo skipRecord
echo %$PRODUCTID%;%$SKU%;%$TITLE%;%$QUANTITY%;%$PURCHASE_PRICE%;%$VENDOR%;%$SERIAL%;%$PURCHASE_DATE%;%$MERCI_STATUS% >> "%$DIRECTORY_PROJECT%\Data\Merci-Inventory-Extraction.txt"
FIND "%$PRODUCTID%" "%$DIRECTORY_PROJECT%\Data\Merci-Inventory-Extraction.txt" 2>nul
SET $RECORD_WRITE=%ERRORLEVEL%
IF %$RECORD_WRITE% EQU 1 (echo %TIME%	[ERROR]	Writing record for {%$PRODUCTID%} failed! >> .\%$LOG_DIRECTORY_PATH%\%$LOG_FILE%)
echo %TIME%	[DEBUG]	RECORD_WRITE:	%ERRORLEVEL% >> .\%$LOG_DIRECTORY_PATH%\%$LOG_FILE%
:skipRecord
IF DEFINED $PARAMETER1 GoTo stop
IF %$PRODUCTID% NEQ %$PRODUCTID_LAST% GoTo scrape

:stop

@PowerShell.exe -c "$span=([datetime]'%Time%' - [datetime]'%$START_TIME%'); '{0:00}:{1:00}:{2:00}' -f $span.Hours, $span.Minutes, $span.Seconds" > ".\cache\var_Lapse_Time_Total.txt"
SET /P $LAPSE_TIME_TOTAL= < ".\cache\var_Lapse_Time_Total.txt"
echo	%Time%	Lapse Time Total:	%$LAPSE_TIME_TOTAL% >> .\%$LOG_DIRECTORY_PATH%\%$LOG_FILE%
Echo	%Date%	%Time%	Stop. >> .\%$LOG_DIRECTORY_PATH%\%$LOG_FILE%

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Exit the tool
:exit
Exit /B
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::