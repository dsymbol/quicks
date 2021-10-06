#NoEnv
FileCreateDir, %A_AppData%\Quicks
SetWorkingDir %A_AppData%\Quicks
SetBatchLines -1
#SingleInstance Force
SetTitleMatchMode, 3
global ver := "1.0", dir, delay, exitfl, exitp, accpick, accountsListBox, ListAccs

ProcessExist(Name){
	Process,Exist,%Name%
	return Errorlevel
}

FillAcc(fmail,fpass)
{
	gameN := "Overwatch"
    If !WinExist(gameN) 
	{
		Run, %dir%\Overwatch.exe, , Max UseErrorLevel
			if (ErrorLevel = "ERROR")
			{
				MsgBox, 4112, Error, Wrong directory`, check where Overwatch is installed.
			    return
			}
		WinWaitActive, Overwatch
		Sleep, %delay% 
    }
    IfWinExist %gameN%
    WinActivate %gameN%
    WinWaitActive, %gameN%
    sleep, 500
	SendRaw,%fmail%
	Sleep, 100
	SendEvent, {Tab}
    Sleep, 300
    SendRaw,%fpass%
    Sleep, 300
    SendEvent,{Enter}
	; Checkbox Settings:
	; Exits all bnet processes after Overwatch is launched if checked
	if exitp = 1
	{
		WinWait, Overwatch
		Process, Close, Agent.exe
		Loop
		{
			prev := ErrorLevel
			Process, Close, Battle.net.exe
			Process, Exist, Battle.net.exe
		}
		until !ErrorLevel or (prev = ErrorLevel)	
	}
	;Exits Quicks after Overwatch is launched if checked
	if exitfl = 1
	{
		ExitApp
	}
}

if(!FileExist("settings.ini"))
{
	IniWrite, "C:\Program Files (x86)\Overwatch\_retail_", settings.ini, Settings, dir
	IniWrite, 3500, settings.ini, Settings, delay
}

;Traybar
gosub, updateSettings
gosub, updateAccounts
Menu, Tray, Tip, Quicks Launcher`nVersion: %ver%
Menu, Tray, NoStandard
Menu, Tray, Add , Open, Open
Menu, Tray, Add , Exit, Esc

;GUI
Gui, Add, GroupBox, x15 y9 w268 h86, Launch
Gui, Add, Text, x37 y31 w280 h18, Choose the account that you want to play on.
Gui, Add, DropDownList, x36 y53 w160 h36 R6 vaccpick, % ListAccs
Gui, Add, Button, x201 y51 w62 h25 gLaunch, Launch
Gui, Add, GroupBox, x15 y100 w268 h113, Settings
Gui, Add, Button, x36 y125 w103 h25 gManager, Account Manager
Gui, Add, Button, x144 y125 w65 h25 gDirectory, Directory
Gui, Add, Button, x214 y125 w48 h25 gDelay, Delay
Gui, Add, Checkbox, x37 y161 w305 vexitfl gexitfl Checked%2ch%, Close quicks after launch
Gui, Add, Checkbox, x37 y181 w305 vexitp gexitp Checked%1ch%, Close all Battle.net processes after launch
Gui, Show, Center w298 h228, Quicks Launcher
return

; Account code 

Launch:
	Gui,Submit,NoHide
	IniRead, mailC, accounts.ini, %accpick%, mail
	IniRead, passC, accounts.ini, %accpick%, pass
	FillAcc(mailC,passC)
return

Manager:
	Gui accountMan:Add, ListBox, x24 y24 w231 h160 vaccountsListBox, % ListAccs
	Gui accountMan:Add, GroupBox, x16 y8 w251 h186, Accounts
	Gui accountMan:Add, GroupBox, x272 y8 w121 h186, Actions
	Gui accountMan:Add, Button, x280 y32 w104 h23 gnewAcc, Add
	Gui accountMan:Add, Button, x280 y64 w104 h23 geditAcc, Edit
	Gui accountMan:Add, Button, x280 y96 w104 h23 gdeleteAcc, Delete
	Gui accountMan:Show, w401 h202, Account Manager
return

newAcc:
	Gui newAccount:Add, Text, x16 y16 w58 h23 +0x200, Username:
	Gui newAccount:Add, Text, x16 y48 w48 h23 +0x200, Mail:
	Gui newAccount:Add, Text, x16 y80 w58 h23 +0x200, Password:
	Gui newAccount:Add, Edit, x80 y16 w120 h21 vuser,
	Gui newAccount:Add, Edit, x80 y48 w120 h21 vmail, 
	Gui newAccount:Add, Edit, x80 y80 w120 h21 +Password vpass, 
	Gui newAccount:Add, Button, x64 y112 w80 h23 gsaveNew, Save
	Gui newAccount:Show, w208 h144, Add 
	Gui newAccount: +AlwaysOnTop
return

saveNew:
	Gui, newAccount:Submit, NoHide
	IniWrite, %mail%, accounts.ini, %user%, mail
	IniWrite, %pass%, accounts.ini, %user%, pass
	Gui, newAccount:Destroy
	gosub, updateAccounts
	GuiControl, accountMan:, accountsListBox, % "|" ListAccs
return

editAcc:
	Gui, accountMan:Submit, NoHide
	IniRead, mailEdit, accounts.ini, %accountsListBox%, mail
	IniRead, passEdit, accounts.ini, %accountsListBox%, pass
	Gui editAccount:Add, Text, x16 y16 w58 h23 +0x200, Username:
	Gui editAccount:Add, Text, x16 y48 w48 h23 +0x200, Mail:
	Gui editAccount:Add, Text, x16 y80 w58 h23 +0x200, Password:
	Gui editAccount:Add, Edit, x80 y16 w120 h21 vuser, %accountsListBox%
	Gui editAccount:Add, Edit, x80 y48 w120 h21 vmail, %mailEdit%
	Gui editAccount:Add, Edit, x80 y80 w120 h21 +Password vpass, %passEdit%
	Gui editAccount:Add, Button, x64 y112 w80 h23 geditFile, Save
	Gui editAccount:Show, w208 h144, Edit
	Gui editAccount: +AlwaysOnTop
return

editFile:
	Gui, editAccount:submit, NoHide
	IniDelete, accounts.ini, %accountsListBox%
	IniWrite, %mail%, accounts.ini, %user%, mail
	IniWrite, %pass%, accounts.ini, %user%, pass
	gosub, updateAccounts
	GuiControl,accountMan:,accountsListBox, % "|" ListAccs
	Gui, editAccount:Destroy
return

deleteAcc:
	Gui, accountMan:Submit, NoHide
	IniDelete, accounts.ini, %accountsListBox%
	gosub, updateAccounts
	GuiControl, accountMan:, accountsListBox, % "|" ListAccs 
return

updateAccounts:
	; extract sections from accounts.ini
	ListAccs := ""
    FileRead, OutputVar, accounts.ini
    Loop Parse, OutputVar, [
    {
    If InStr(A_LoopField, "]")
        {
        StringSplit, Field, A_LoopField, ] 
        ListAccs .= Field1 . "|"
        }
    }
    GuiControl,, accpick, %ListAccs%
	GuiControl, accountMan:, accountsListBox, %ListAccs% 
return

; Settings code

exitp:
	Gui,Submit,NoHide
	IniWrite, %exitp%, settings.ini, Settings, exitp
	gosub, updateSettings
return

exitfl:
	Gui,Submit,NoHide
	IniWrite, %exitfl%, settings.ini, Settings, exitfl
	gosub, updateSettings
return

Directory:
	Gui dirUpdate: Add, Text, x8 y10 w400 h30,Please enter path of _retail_\Overwatch.exe, no need to`nchange if installed in default directory.
	Gui dirUpdate: Add, Edit, x10 y50 w282 h25 vdir, %dir%
	Gui dirUpdate: Add, Button, x110 y85 w80 h25 gdirSave, Save
	Gui dirUpdate: Show, Center w300 h120, Change Directory
return

dirSave:
	Gui, dirUpdate:submit, NoHide
	IniDelete, settings.ini, Settings, dir
	IniWrite, %dir%, settings.ini, Settings, dir
	Gui, dirUpdate:Destroy
	gosub, updateSettings
return

Delay:
	Gui delayGui: Add, Text, x10 y10 w400 h30, Change delay in milliseconds to the time it takes for login`nscreen to load after launched.
	Gui delayGui: Add, Edit, x10 y50 w282 h25 vdelay, %delay%
	Gui delayGui: Add, Button, x110 y85 w80 h25 gdelaySave, Save
	Gui delayGui: Show, Center w300 h120, Change Delay
return

delaySave:
	Gui, delayGui:submit, NoHide
	IniDelete, settings.ini, Settings, delay
	IniWrite, %delay%, settings.ini, Settings, delay
	Gui, delayGui:Destroy
	gosub, updateSettings
return

updateSettings:
	IniRead, 1ch, settings.ini, Settings, exitp
	IniRead, 2ch, settings.ini, Settings, exitfl
	IniRead, dir, settings.ini, Settings, dir
	IniRead, delay, settings.ini, Settings, delay
return

Open:
	Gui, Show
return

Esc:
GuiEscape:
GuiClose:
ExitApp

newAccountGuiEscape:
newAccountGuiClose:
	Gui, newAccount:Destroy
return

accountManGuiEscape:
accountManGuiClose:
	GuiControl, 1:, accpick, % "|" ListAccs
	Gui, accountMan:Destroy
return

editAccountGuiEscape:
editAccountGuiClose:
	Gui, editAccount:Destroy
return

dirupdateGuiEscape:
dirupdateGuiClose:
	Gui, dirupdate:Destroy
return

delayGuiGuiEscape:
delayGuiGuiClose:
	Gui, delayGui:Destroy
return
