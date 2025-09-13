Invoke-WebRequest -Uri https://raw.githubusercontent.com/domtronn/all-the-icons.el/master/fonts/all-the-icons.ttf -OutFile all-the-icons/all-the-icons.ttf
Invoke-WebRequest -Uri https://raw.githubusercontent.com/domtronn/all-the-icons.el/master/fonts/file-icons.ttf -OutFile all-the-icons/file-icons.ttf
Invoke-WebRequest -Uri https://raw.githubusercontent.com/domtronn/all-the-icons.el/master/fonts/fontawesome.ttf -OutFile all-the-icons/fontawesome.ttf
Invoke-WebRequest -Uri https://raw.githubusercontent.com/domtronn/all-the-icons.el/master/fonts/material-design-icons.ttf -OutFile all-the-icons/material-design-icons.ttf
Invoke-WebRequest -Uri https://raw.githubusercontent.com/domtronn/all-the-icons.el/master/fonts/octicons.ttf -OutFile all-the-icons/octicons.ttf
Invoke-WebRequest -Uri https://raw.githubusercontent.com/domtronn/all-the-icons.el/master/fonts/weathericons.ttf -OutFile all-the-icons/weathericons.ttf


$InstallFontsFolder = ".\all-the-icons"
$SystemFontFolder = "C:\Windows\Fonts"

Copy-Item -Path "$InstallFontsFolder\*.*" -Destination $SystemFontFolder -Exclude "*.reg"


Regedit /s "$InstallFontsFolder\InstallFonts.reg"