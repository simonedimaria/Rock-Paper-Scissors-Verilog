@echo off
setlocal enabledelayedexpansion

set "outputFile=simulate8b.script"

rem Clear the existing output file
type nul > "%outputFile%"

rem Loop through all binary numbers from 0 to 255 (2^8 - 1)
for /L %%i in (0, 1, 255) do (
    set "binaryNumber="
    
    rem Convert the decimal number to binary
    set /a "decimalNumber=%%i"
    for /L %%j in (7, -1, 0) do (
        set /a "bit=(decimalNumber >> %%j) & 1"
        set "binaryNumber=!binaryNumber! !bit!"
    )

    rem Append the modified line to the output file
    echo simulate !binaryNumber! >> "%outputFile%"
    rem Add three new lines at the end of each line
    echo. >> "%outputFile%"
    echo. >> "%outputFile%"
    echo. >> "%outputFile%"
)

echo "Modified lines generated and saved to %outputFile%"
