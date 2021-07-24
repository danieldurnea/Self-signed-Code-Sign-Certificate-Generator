@echo off
pushd "%~dp0"

REM Please run this batch script inside Windows SDK or Visual Studio command prompt.

SET CN=MyCN

if exist CA.cer (
  certutil.exe -user -delstore Root CA.cer
  del /f CA.cer
)
if exist CA.pvk del /f CA.pvk
if exist CodeSigning.pvk del /f CodeSigning.pvk
if exist CodeSigning.cer del /f CodeSigning.cer
if exist CodeSigning.pfx del /f CodeSigning.pfx

echo Generate the root certificate
makecert.exe -r -pe -n "CN=%CN%" -ss CA -sr CurrentUser -a sha1 -cy authority -sky signature -sv CA.pvk CA.cer

echo Add the Root certificate to the user store
certutil.exe -user -addstore Root CA.cer

echo Create the certificate for code signing
makecert.exe -pe -n "CN=%CN%" -eku "1.3.6.1.5.5.7.3.3,1.3.6.1.4.1.311.10.3.13" -a sha1 -cy end -sky signature -ic CA.cer -iv CA.pvk -sv CodeSigning.pvk CodeSigning.cer

echo Convert to certificate to pfx file format
pvk2pfx.exe -pvk CodeSigning.pvk -spc CodeSigning.cer -pfx CodeSigning.pfx

echo Encode pfx into BASE64 and copy to the clipboard
powershell [Convert]::ToBase64String([System.IO.File]::ReadAllBytes('CodeSigning.pfx')) ^| Set-Clipboard

:exit
popd
@echo on