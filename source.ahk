;;Запуск от имени администратора
if !A_IsAdmin && !%False%
{
if A_OSVersion not in WIN_2003,WIN_XP,WIN_2000
{
Run *RunAs "%A_ScriptFullPath%" ,, UseErrorLevel
if !ErrorLevel
ExitApp
}
ExitApp
}

#NoEnv
#SingleInstance, Force
Process, Priority, , High
global hotkey_ini := A_MyDocuments "\adminBinder.ini"

ListLines
WinWaitActive ahk_class AutoHotkey
Sleep, 50
Send {LControl Down}{Shift}{LControl Up}
sleep 20
Send {LAlt Down}{Shift}{LAlt Up}
Sleep 400
WinMinimize

;Скрипт для обновления
vers=0.13Beta
buildscr = 7 ;НОМЕР БИЛДА. ОБЯЗАТЕЛЬНО ЦЕЛОЧИСЛЕННЫЙ
downlurl := "https://github.com/TuskarMA/adminsahk/blob/main/updtr.exe?raw=true"
downllen := "https://github.com/TuskarMA/adminsahk/blob/main/verlen.ini?raw=true"
Utf8ToAnsi(ByRef Utf8String, CodePage = 1251)
{
    If (NumGet(Utf8String) & 0xFFFFFF) = 0xBFBBEF
        BOM = 3
    Else
        BOM = 0

    UniSize := DllCall("MultiByteToWideChar", "UInt", 65001, "UInt", 0
                    , "UInt", &Utf8String + BOM, "Int", -1
                    , "Int", 0, "Int", 0)
    VarSetCapacity(UniBuf, UniSize * 2)
    DllCall("MultiByteToWideChar", "UInt", 65001, "UInt", 0
                    , "UInt", &Utf8String + BOM, "Int", -1
                    , "UInt", &UniBuf, "Int", UniSize)

    AnsiSize := DllCall("WideCharToMultiByte", "UInt", CodePage, "UInt", 0
                    , "UInt", &UniBuf, "Int", -1
                    , "Int", 0, "Int", 0
                    , "Int", 0, "Int", 0)
    VarSetCapacity(AnsiString, AnsiSize)
    DllCall("WideCharToMultiByte", "UInt", CodePage, "UInt", 0
                    , "UInt", &UniBuf, "Int", -1
                    , "Str", AnsiString, "Int", AnsiSize
                    , "Int", 0, "Int", 0)
    Return AnsiString
}
WM_HELP(){
    IniRead, vupd, %a_temp%/verlen.ini, UPD, v
    IniRead, desupd, %a_temp%/verlen.ini, UPD, des
    desupd := Utf8ToAnsi(desupd)
    IniRead, updupd, %a_temp%/verlen.ini, UPD, upd
    updupd := Utf8ToAnsi(updupd)
    msgbox, , Список изменений версии %vupd%, %updupd%
    return
}

OnMessage(0x53, "WM_HELP")
Gui +OwnDialogs

SplashTextOn, , 60,Автообновление, Запуск скрипта. Ожидайте..`nПроверяем наличие обновлений.
URLDownloadToFile, %downllen%, %a_temp%/verlen.ini
IniRead, buildupd, %a_temp%/verlen.ini, UPD, build
if buildupd =
{
    SplashTextOn, , 60,Автообновление, Запуск скрипта. Ожидайте..`nОшибка. Нет связи с сервером.
    sleep, 2000
}
if buildupd > % buildscr
{
    IniRead, vupd, %a_temp%/verlen.ini, UPD, v
    SplashTextOn, , 60,Автообновление, Запуск скрипта. Ожидайте..`nОбнаружено обновление до версии %vupd%!
    sleep, 2000
    IniRead, desupd, %a_temp%/verlen.ini, UPD, des
    desupd := Utf8ToAnsi(desupd)
    IniRead, updupd, %a_temp%/verlen.ini, UPD, upd
    updupd := Utf8ToAnsi(updupd)
    SplashTextoff
        msgbox, 1, Обновление скрипта до версии %vupd%, Хотите ли Вы обновиться?
        IfMsgBox OK
        {
            put2 := % A_ScriptFullPath
            RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\SAMP ,put2 , % put2
            SplashTextOn, , 60,Автообновление, Обновление. Ожидайте..`nОбновляем скрипт до версии %vupd%!
            URLDownloadToFile, %downlurl%, %a_temp%/updt.exe
            sleep, 1000
            run, %a_temp%/updt.exe
            exitapp
        }

}
SplashTextoff

;Если запущен первый раз и нет значений недели репортов ВАЖНО! Блок обновления клиентов до 5 билда
IniRead, existSb, %hotkey_ini%, reportsWeek
if(!existSB){
Iniwrite, 0, %hotkey_ini%, reportsWeek, Вс
Iniwrite, 0, %hotkey_ini%, reportsWeek, Пн
Iniwrite, 0, %hotkey_ini%, reportsWeek, Вт
Iniwrite, 0, %hotkey_ini%, reportsWeek, Ср
Iniwrite, 0, %hotkey_ini%, reportsWeek, Чт
Iniwrite, 0, %hotkey_ini%, reportsWeek, Пт
Iniwrite, 0, %hotkey_ini%, reportsWeek, Сб
IniWrite, 0 , %hotkey_ini%, reportsWeek, history
IniWrite, 0 , %hotkey_ini%, GuiPosition, bindsX
IniWrite, 0 , %hotkey_ini%, GuiPosition, bindsY
IniWrite, 0 , %hotkey_ini%, GuiPosition, reportsX
IniWrite, 0 , %hotkey_ini%, GuiPosition, reportsY
}



;;Отрисовка кастомного трея
FileEncoding,
Menu, Tray, NoStandard
Menu, Tray, DeleteAll
Menu, Tray, Color, FFE4C4
Menu, Tray, add, Развернуть, show_my_gui
Menu, Tray, Default, Развернуть
Menu, Tray, Add, Перезагрузить, relog
Menu, Tray, Add, Закрыть, exit
TrayTip, GTA5RP Admin AHK v%vers%, GTA5RP.COM
Gui  reportsGUI: +AlwaysOnTop -Caption +ToolWindow
Gui, reportsGUI:Color, 000000
Gui, reportsGUI:Font, Courier new s14
Gui, reportsGUI:Add, text, cLime w150 h55 vReportsText
Gui  bindsGUI: +AlwaysOnTop -Caption +ToolWindow
Gui, bindsGUI:Color, 000000
Gui, bindsGUI:Font, Courier new s14



;;TEST
OnMessage(0x201, "WM_LBUTTONDOWN")
WM_LBUTTONDOWN()
{
   PostMessage 0xA1, 2
}


;;Инициализация config.ini файла
e=1
loop 32
{
;default Read в цикле 32
IniRead, Checkstat%e%, %hotkey_ini%, checkboxes, checkbox%e%
IniRead, varKey%e%, %hotkey_ini%, HotKey, Key%e%
IniRead, DEditR%e%, %hotkey_ini%, Text, DEditR%e%, text
IniRead, space%e%, %hotkey_ini%, checkboxes, spacebox%e%
;Отрисовка строк для GUI Binds в цикле
if(!varKey%e%) {
} else {
    if(DEditR%e% = "text"){
    } else {
    if(!DEditR%e%){
    } else {
        StringReplace, keyObj, varkey%e%, ^, Ctrl + , All
        StringReplace, keyObj, keyObj, +, Shift + , All
        StringReplace, keyObj, keyObj, !, Alt + , All
        if(e=1){
            Gui, bindsGUI:Add, text, cLime, % StrLen(DEditR%e%)<=7? keyObj "     " DEditR%e% : keyObj "     " SubStr(DEditR%e%, 1, 7) "..."
        } else {
            Gui, bindsGUI:Add, text, cLime, % StrLen(DEditR%e%)<=7? keyObj "     " DEditR%e% : keyObj "     " SubStr(DEditR%e%, 1, 7) "..."
        }
    }
    }
}

e:=e+1
}
sleep 500

;Прочтение и отрисовка значений в GUI
IniRead, ovBinder, %hotkey_ini%, checkboxes, OverlayBinder
IniRead, ovReports, %hotkey_ini%, checkboxes, OverlayReports
IniRead, ovShowHide, %hotkey_ini%, HotKey, OverlayShow
IniRead, ovDrag, %hotkey_ini%, HotKey, OverlayDrag
IniRead, ovAddRep, %hotkey_ini%, HotKey, ReportsAdd
IniRead, ovRemRep, %hotkey_ini%, HotKey, ReportsRemove
HotKey, %ovShowHide%, ovrShowHide, On, UseErrorLevel
HotKey, %ovDrag%, ovrDrag, On, UseErrorLevel
HotKey, %ovAddRep%, reportAdd, On, UseErrorLevel
HotKey, %ovRemRep%, reportRemove, On, UseErrorLevel



;Gui bindsGUI:+LastFound +AlwaysOnTop -Caption +ToolWindow
;Gui, bindsGUI:Color, 0000
;Gui, bindsGUI:Font, Courier new s14
;
;WinSet, TransColor, 0000, binds
;OnMessage(0x201, "WM_LBUTTONDOWN")
;return
;WM_LBUTTONDOWN()
;{
;   PostMessage 0xA1, 2
;}



;Отрисовка GUI основного окна
Gui, font, s8 , Arial
Gui, Default
Gui, Color, D3D3D3
Gui, Add, groupbox, x328 y1 w145 h25
gui, font, bold s9 , Arial
Gui, add, text,x334 y10, GTA5RP.COM Admin AHK
Gui, font, s8 , Arial
Gui, add, button, x30 y573 gsave, Сохранить
Gui, add, button, x200 y573 gdel, Сброс
Gui, add, button, x400 y573 greboot, Перезагрузка
Gui, add, button, x580 y573 gexit, Закрыть
Gui, Add, Tab, x3 y30 w795 h540 , 1|2|Оверлэй|Репорты
Gui, Tab, 1
gui, font, bold s9 , Arial
Gui, add, text,x20 y60, Клавиша:
Gui, add, text,x355 y60, Текст бинда:
Gui, add, text,x758 y60, Enter
Gui, add, text,x708 y60, Пробел
gui, font, s8 , Arial
Gui, Add, Hotkey, x10 y80 w80 h20 vEditKey1, %varKey1%
Gui, Add, Edit, x100 y80 w620 h20 vDEditR1, %DEditR1%
Gui, Add, CheckBox, x765 y83 Checked%Checkstat1% vCheck1,
Gui, Add, Hotkey, x10 y110 w80 h20 vEditKey2, %varKey2%
Gui, Add, Edit, x100 y110 w620 h20 vDEditR2, %DEditR2%
Gui, Add, CheckBox, x765 y113 Checked%Checkstat2% vCheck2,
Gui, Add, Hotkey, x10 y140 w80 h20 vEditKey3, %varKey3%
Gui, Add, Edit, x100 y140 w620 h20 vDEditR3, %DEditR3%
Gui, Add, CheckBox, x765 y143 Checked%Checkstat3% vCheck3,
Gui, Add, Hotkey, x10 y170 w80 h20 vEditKey4, %varKey4%
Gui, Add, Edit, x100 y170 w620 h20 vDEditR4, %DEditR4%
Gui, Add, CheckBox, x765 y173 Checked%Checkstat4% vCheck4,
Gui, Add, Hotkey, x10 y200 w80 h20 vEditKey5, %varKey5%
Gui, Add, Edit, x100 y200 w620 h20 vDEditR5, %DEditR5%
Gui, Add, CheckBox, x765 y203 Checked%Checkstat5% vCheck5,
Gui, Add, Hotkey, x10 y230 w80 h20 vEditKey6, %varKey6%
Gui, Add, Edit, x100 y230 w620 h20 vDEditR6, %DEditR6%
Gui, Add, CheckBox, x765 y233 Checked%Checkstat6% vCheck6,
Gui, Add, Hotkey, x10 y260 w80 h20 vEditKey7, %varKey7%
Gui, Add, Edit, x100 y260 w620 h20 vDEditR7, %DEditR7%
Gui, Add, CheckBox, x765 y263 Checked%Checkstat7% vCheck7,
Gui, Add, Hotkey, x10 y290 w80 h20 vEditKey8, %varKey8%
Gui, Add, Edit, x100 y290 w620 h20 vDEditR8, %DEditR8%
Gui, Add, CheckBox, x765 y293 Checked%Checkstat8% vCheck8,
Gui, Add, Hotkey, x10 y320 w80 h20 vEditKey9, %varKey9%
Gui, Add, Edit, x100 y320 w620 h20 vDEditR9, %DEditR9%
Gui, Add, CheckBox, x765 y323 Checked%Checkstat9% vCheck9,
Gui, Add, Hotkey, x10 y350 w80 h20 vEditKey10, %varKey10%
Gui, Add, Edit, x100 y350 w620 h20 vDEditR10, %DEditR10%
Gui, Add, CheckBox, x765 y353 Checked%Checkstat10% vCheck10,
Gui, Add, Hotkey, x10 y380 w80 h20 vEditKey11, %varKey11%
Gui, Add, Edit, x100 y380 w620 h20 vDEditR11, %DEditR11%
Gui, Add, CheckBox, x765 y383 Checked%Checkstat11% vCheck11,
Gui, Add, Hotkey, x10 y410 w80 h20 vEditKey12, %varKey12%
Gui, Add, Edit, x100 y410 w620 h20 vDEditR12, %DEditR12%
Gui, Add, CheckBox, x765 y413 Checked%Checkstat12% vCheck12,
Gui, Add, Hotkey, x10 y440 w80 h20 vEditKey13, %varKey13%
Gui, Add, Edit, x100 y440 w620 h20 vDEditR13, %DEditR13%
Gui, Add, CheckBox, x765 y443 Checked%Checkstat13% vCheck13,
Gui, Add, Hotkey, x10 y470 w80 h20 vEditKey14, %varKey14%
Gui, Add, Edit, x100 y470 w620 h20 vDEditR14, %DEditR14%
Gui, Add, CheckBox, x765 y473 Checked%Checkstat14% vCheck14,
Gui, Add, Hotkey, x10 y500 w80 h20 vEditKey15, %varKey15%
Gui, Add, Edit, x100 y500 w620 h20 vDEditR15, %DEditR15%
Gui, Add, CheckBox, x765 y503 Checked%Checkstat15% vCheck15,
Gui, Add, Hotkey, x10 y530 w80 h20 vEditKey16, %varKey16%
Gui, Add, Edit, x100 y530 w620 h20 vDEditR16, %DEditR16%
Gui, Add, CheckBox, x765 y533 Checked%Checkstat16% vCheck16,
Gui, Add, CheckBox, x727 y83 Checked%space1% vCheckspace1,
Gui, Add, CheckBox, x727 y113 Checked%space2% vCheckspace2,
Gui, Add, CheckBox, x727 y143 Checked%space3% vCheckspace3,
Gui, Add, CheckBox, x727 y173 Checked%space4% vCheckspace4,
Gui, Add, CheckBox, x727 y203 Checked%space5% vCheckspace5,
Gui, Add, CheckBox, x727 y233 Checked%space6% vCheckspace6,
Gui, Add, CheckBox, x727 y263 Checked%space7% vCheckspace7,
Gui, Add, CheckBox, x727 y293 Checked%space8% vCheckspace8,
Gui, Add, CheckBox, x727 y323 Checked%space9% vCheckspace9,
Gui, Add, CheckBox, x727 y353 Checked%space10% vCheckspace10,
Gui, Add, CheckBox, x727 y383 Checked%space11% vCheckspace11,
Gui, Add, CheckBox, x727 y413 Checked%space12% vCheckspace12,
Gui, Add, CheckBox, x727 y443 Checked%space13% vCheckspace13,
Gui, Add, CheckBox, x727 y473 Checked%space14% vCheckspace14,
Gui, Add, CheckBox, x727 y503 Checked%space15% vCheckspace15,
Gui, Add, CheckBox, x727 y533 Checked%space16% vCheckspace16,
Gui, Tab, 2
gui, font, bold s9 , Arial
Gui, add, text,x20 y60, Клавиша:
Gui, add, text,x355 y60, Текст бинда:
Gui, add, text,x758 y60, Enter
Gui, add, text,x708 y60, Пробел
gui, font, s8 , Arial
Gui, Add, Hotkey, x10 y80 w80 h20 vEditKey17, %varKey17%
Gui, Add, Edit, x100 y80 w620 h20 vDEditR17, %DEditR17%
Gui, Add, CheckBox, x765 y83 Checked%Checkstat17% vCheck17,
Gui, Add, Hotkey, x10 y110 w80 h20 vEditKey18, %varKey18%
Gui, Add, Edit, x100 y110 w620 h20 vDEditR18, %DEditR18%
Gui, Add, CheckBox, x765 y113 Checked%Checkstat18% vCheck18,
Gui, Add, Hotkey, x10 y140 w80 h20 vEditKey19, %varKey19%
Gui, Add, Edit, x100 y140 w620 h20 vDEditR19, %DEditR19%
Gui, Add, CheckBox, x765 y143 Checked%Checkstat19% vCheck19,
Gui, Add, Hotkey, x10 y170 w80 h20 vEditKey20, %varKey20%
Gui, Add, Edit, x100 y170 w620 h20 vDEditR20, %DEditR20%
Gui, Add, CheckBox, x765 y173 Checked%Checkstat20% vCheck20,
Gui, Add, Hotkey, x10 y200 w80 h20 vEditKey21, %varKey21%
Gui, Add, Edit, x100 y200 w620 h20 vDEditR21, %DEditR21%
Gui, Add, CheckBox, x765 y203 Checked%Checkstat21% vCheck21,
Gui, Add, Hotkey, x10 y230 w80 h20 vEditKey22, %varKey22%
Gui, Add, Edit, x100 y230 w620 h20 vDEditR22, %DEditR22%
Gui, Add, CheckBox, x765 y233 Checked%Checkstat22% vCheck22,
Gui, Add, Hotkey, x10 y260 w80 h20 vEditKey23, %varKey23%
Gui, Add, Edit, x100 y260 w620 h20 vDEditR23, %DEditR23%
Gui, Add, CheckBox, x765 y263 Checked%Checkstat23% vCheck23,
Gui, Add, Hotkey, x10 y290 w80 h20 vEditKey24, %varKey24%
Gui, Add, Edit, x100 y290 w620 h20 vDEditR24, %DEditR24%
Gui, Add, CheckBox, x765 y293 Checked%Checkstat24% vCheck24,
Gui, Add, Hotkey, x10 y320 w80 h20 vEditKey25, %varKey25%
Gui, Add, Edit, x100 y320 w620 h20 vDEditR25, %DEditR25%
Gui, Add, CheckBox, x765 y323 Checked%Checkstat25% vCheck25,
Gui, Add, Hotkey, x10 y350 w80 h20 vEditKey26, %varKey26%
Gui, Add, Edit, x100 y350 w620 h20 vDEditR26, %DEditR26%
Gui, Add, CheckBox, x765 y353 Checked%Checkstat26% vCheck26,
Gui, Add, Hotkey, x10 y380 w80 h20 vEditKey27, %varKey27%
Gui, Add, Edit, x100 y380 w620 h20 vDEditR27, %DEditR27%
Gui, Add, CheckBox, x765 y383 Checked%Checkstat27% vCheck27,
Gui, Add, Hotkey, x10 y410 w80 h20 vEditKey28, %varKey28%
Gui, Add, Edit, x100 y410 w620 h20 vDEditR28, %DEditR28%
Gui, Add, CheckBox, x765 y413 Checked%Checkstat28% vCheck28,
Gui, Add, Hotkey, x10 y440 w80 h20 vEditKey29, %varKey29%
Gui, Add, Edit, x100 y440 w620 h20 vDEditR29, %DEditR29%
Gui, Add, CheckBox, x765 y443 Checked%Checkstat29% vCheck29,
Gui, Add, Hotkey, x10 y470 w80 h20 vEditKey30, %varKey30%
Gui, Add, Edit, x100 y470 w620 h20 vDEditR30, %DEditR30%
Gui, Add, CheckBox, x765 y473 Checked%Checkstat30% vCheck30,
Gui, Add, Hotkey, x10 y500 w80 h20 vEditKey31, %varKey31%
Gui, Add, Edit, x100 y500 w620 h20 vDEditR31, %DEditR31%
Gui, Add, CheckBox, x765 y503 Checked%Checkstat31% vCheck31,
Gui, Add, Hotkey, x10 y530 w80 h20 vEditKey32, %varKey32%
Gui, Add, Edit, x100 y530 w620 h20 vDEditR32, %DEditR32%
Gui, Add, CheckBox, x765 y533 Checked%Checkstat32% vCheck32,
Gui, Add, CheckBox, x727 y83 Checked%space17% vCheckspace17,
Gui, Add, CheckBox, x727 y113 Checked%space18% vCheckspace18,
Gui, Add, CheckBox, x727 y143 Checked%space19% vCheckspace19,
Gui, Add, CheckBox, x727 y173 Checked%space20% vCheckspace20,
Gui, Add, CheckBox, x727 y203 Checked%space21% vCheckspace21,
Gui, Add, CheckBox, x727 y233 Checked%space22% vCheckspace22,
Gui, Add, CheckBox, x727 y263 Checked%space23% vCheckspace23,
Gui, Add, CheckBox, x727 y293 Checked%space24% vCheckspace24,
Gui, Add, CheckBox, x727 y323 Checked%space25% vCheckspace25,
Gui, Add, CheckBox, x727 y353 Checked%space26% vCheckspace26,
Gui, Add, CheckBox, x727 y383 Checked%space27% vCheckspace27,
Gui, Add, CheckBox, x727 y413 Checked%space28% vCheckspace28,
Gui, Add, CheckBox, x727 y443 Checked%space29% vCheckspace29,
Gui, Add, CheckBox, x727 y473 Checked%space30% vCheckspace30,
Gui, Add, CheckBox, x727 y503 Checked%space31% vCheckspace31,
Gui, Add, CheckBox, x727 y533 Checked%space32% vCheckspace32,
;Оверлэй
Gui, Tab, Оверлэй
gui, font, bold s11 , Arial
Gui, add, text, x5 y60, Общие настройки:
gui, font, s8, Arial
Gui, add, text,x5 y90, Скрыть/Показать:
Gui, Add, Hotkey, x10 y110 w80 vHotKeyVisibleOverlay, %ovShowHide%
Gui, add, text,x5 y140, Перенести элементы:
Gui, Add, Hotkey, x10 y160 w80 vHotKeyDragOverlay, %ovDrag%
Gui, Add, CheckBox, x5 y185 w180 h23 Checked%ovBinder% vOverlayVisibleBinder, Подсказки по биндеру
Gui, Add, CheckBox, x5 y215 w195 h23 Checked%ovReports% vOverlayVisibleReports , Счетчик репортов
;Репорты
Gui, Tab, Репорты
gui, font, bold s10 , Arial
Gui, add, text, x10 y60, Текущая неделя:
Gui, Add, ListView, lvtest hWndhLvItems x10 y80 w250 h50 +LV0x4000 -LV0x10 +Disabled, Вс|Пн|Вт|Ср|Чт|Пт|Сб
LV_ModifyCol(1, "35")
LV_ModifyCol(2, "35")
LV_ModifyCol(3, "35")
LV_ModifyCol(4, "35")
LV_ModifyCol(5, "35")
LV_ModifyCol(6, "35")
LV_ModifyCol(7, "35")
IniRead, vsk, %hotkey_ini%, reportsWeek, Вс
IniRead, pnd, %hotkey_ini%, reportsWeek, Пн
IniRead, vtr, %hotkey_ini%, reportsWeek, Вт
IniRead, srd, %hotkey_ini%, reportsWeek, Ср
IniRead, cht, %hotkey_ini%, reportsWeek, Чт
IniRead, ptn, %hotkey_ini%, reportsWeek, Пт
IniRead, sub, %hotkey_ini%, reportsWeek, Сб
LV_Insert(1 , , vsk, pnd, vtr, srd, cht, ptn, sub)
Gui, add, text, x440 y60, История:
Gui Add, Edit, x440 y80 w345 h480 +ReadOnly +Multi vHistoryList

gui, font, bold s9 , Arial
Gui, add, text, x10 y140, Добавить репорт:
Gui, Add, Hotkey, x10 y160 w80 vHotKeyAddReport, %ovAddRep%
Gui, add, text, x10 y190, Убрать репорт:
Gui, Add, Hotkey, x10 y210 w80 vHotKeyRemoveReport, %ovRemRep%
DllCall("UxTheme.dll\SetWindowTheme", "Ptr", hLvItems, "WStr", "Explorer", "Ptr", 0)

Gui, Show, x100 y100 w800 h600, GTA5RP Admin AHK v%vers%
Gui, Submit, NoHide,
SetTimer, reportsWorker, 200

h=1
loop 32
{
varKey:=varKey%h%
HotKey, %varKey%, MyKey%h%, On, UseErrorLevel
h:=h+1
}

return

reportAdd:
today:=A_NowUTC
today+= 3, h
FormatTime, today_ddd, %today%, ddd
if(today_ddd = "Вс") {
Gui, ListView, lvtest
IniRead, valueToChange, %hotkey_ini%, reportsWeek, Вс
Iniwrite, % valueToChange+1, %hotkey_ini%, reportsWeek, Вс
IniRead, valueToSet, %hotkey_ini%, reportsWeek, Вс
LV_Modify(1 , , valueToSet)
}
if(today_ddd = "Пн") {
Gui, ListView, lvtest
IniRead, valueToChange, %hotkey_ini%, reportsWeek, Пн
Iniwrite, % valueToChange+1, %hotkey_ini%, reportsWeek, Пн
IniRead, valueToSet, %hotkey_ini%, reportsWeek, Пн
LV_Modify(1 , , , valueToSet)
}
if(today_ddd = "Вт") {
Gui, ListView, lvtest
IniRead, valueToChange, %hotkey_ini%, reportsWeek, Вт
Iniwrite, % valueToChange+1, %hotkey_ini%, reportsWeek, Вт
IniRead, valueToSet, %hotkey_ini%, reportsWeek, Вт
LV_Modify(1 , , , , valueToSet)
}
if(today_ddd = "Ср") {
Gui, ListView, lvtest
IniRead, valueToChange, %hotkey_ini%, reportsWeek, Ср
Iniwrite, % valueToChange+1, %hotkey_ini%, reportsWeek, Ср
IniRead, valueToSet, %hotkey_ini%, reportsWeek, Ср
LV_Modify(1 , , , , , valueToSet)
}
if(today_ddd = "Чт") {
Gui, ListView, lvtest
IniRead, valueToChange, %hotkey_ini%, reportsWeek, Чт
Iniwrite, % valueToChange+1, %hotkey_ini%, reportsWeek, Чт
IniRead, valueToSet, %hotkey_ini%, reportsWeek, Чт
LV_Modify(1 , , , , , , valueToSet)
}
if(today_ddd = "Пт") {
Gui, ListView, lvtest
IniRead, valueToChange, %hotkey_ini%, reportsWeek, Пт
Iniwrite, % valueToChange+1, %hotkey_ini%, reportsWeek, Пт
IniRead, valueToSet, %hotkey_ini%, reportsWeek, Пт
LV_Modify(1 , , , , , , , valueToSet)
}
if(today_ddd = "Сб") {
Gui, ListView, lvtest
IniRead, valueToChange, %hotkey_ini%, reportsWeek, Сб
Iniwrite, % valueToChange+1, %hotkey_ini%, reportsWeek, Сб
IniRead, valueToSet, %hotkey_ini%, reportsWeek, Сб
LV_Modify(1 , , , , , , , , valueToSet)
}
return

reportRemove:
today:=A_NowUTC
today+= 3, h
FormatTime, today_ddd, %today%, ddd
if(today_ddd = "Вс") {
Gui, ListView, lvtest
IniRead, valueToChange, %hotkey_ini%, reportsWeek, Вс
Iniwrite, % valueToChange-1, %hotkey_ini%, reportsWeek, Вс
IniRead, valueToSet, %hotkey_ini%, reportsWeek, Вс
LV_Modify(1 , , valueToSet)
}
if(today_ddd = "Пн") {
Gui, ListView, lvtest
IniRead, valueToChange, %hotkey_ini%, reportsWeek, Пн
Iniwrite, % valueToChange-1, %hotkey_ini%, reportsWeek, Пн
IniRead, valueToSet, %hotkey_ini%, reportsWeek, Пн
LV_Modify(1 , , , valueToSet)
}
if(today_ddd = "Вт") {
Gui, ListView, lvtest
IniRead, valueToChange, %hotkey_ini%, reportsWeek, Вт
Iniwrite, % valueToChange-1, %hotkey_ini%, reportsWeek, Вт
IniRead, valueToSet, %hotkey_ini%, reportsWeek, Вт
LV_Modify(1 , , , , valueToSet)
}
if(today_ddd = "Ср") {
Gui, ListView, lvtest
IniRead, valueToChange, %hotkey_ini%, reportsWeek, Ср
Iniwrite, % valueToChange-1, %hotkey_ini%, reportsWeek, Ср
IniRead, valueToSet, %hotkey_ini%, reportsWeek, Ср
LV_Modify(1 , , , , , valueToSet)
}
if(today_ddd = "Чт") {
Gui, ListView, lvtest
IniRead, valueToChange, %hotkey_ini%, reportsWeek, Чт
Iniwrite, % valueToChange-1, %hotkey_ini%, reportsWeek, Чт
IniRead, valueToSet, %hotkey_ini%, reportsWeek, Чт
LV_Modify(1 , , , , , , valueToSet)
}
if(today_ddd = "Пт") {
Gui, ListView, lvtest
IniRead, valueToChange, %hotkey_ini%, reportsWeek, Пт
Iniwrite, % valueToChange-1, %hotkey_ini%, reportsWeek, Пт
IniRead, valueToSet, %hotkey_ini%, reportsWeek, Пт
LV_Modify(1 , , , , , , , valueToSet)
}
if(today_ddd = "Сб") {
Gui, ListView, lvtest
IniRead, valueToChange, %hotkey_ini%, reportsWeek, Сб
Iniwrite, % valueToChange-1, %hotkey_ini%, reportsWeek, Сб
IniRead, valueToSet, %hotkey_ini%, reportsWeek, Сб
LV_Modify(1 , , , , , , , , valueToSet)
}
return
















reportsWorker:
;Начало подсчета истории и обнуление

today:=A_NowUTC
today+= 3, h

startDay:=A_NowUTC
startDay+= 3, h

endDay:=A_NowUTC
endDay+= 3, h

startDay += -7, Days
endDay += -1, Days
FormatTime, today_ddd, %today%, ddd
if(today_ddd = "Вс") {
IniRead, vs, %hotkey_ini%, reportsWeek, Вс
IniRead, pn, %hotkey_ini%, reportsWeek, Пн
IniRead, vt, %hotkey_ini%, reportsWeek, Вт
IniRead, sr, %hotkey_ini%, reportsWeek, Ср
IniRead, ct, %hotkey_ini%, reportsWeek, Чт
IniRead, pt, %hotkey_ini%, reportsWeek, Пт
IniRead, sb, %hotkey_ini%, reportsWeek, Сб
if ((pn !=0) || (vt !=0) || (sr !=0) || (ct!=0) || (pt!=0) || (sb!=0)){
FormatTime, sDate, %startDay%, dd-MM-yy
FormatTime, eDate, %endDay%, dd-MM-yy
IniRead, oldHistory, %hotkey_ini%, reportsWeek, history

if(oldHistory = 0){
    allReports:= % vs+pn+vt+sr+ct+pt+sb
    Iniwrite, %sDate% - %eDate% ``nВск: %vs% Пн: %pn% Вт: %vt% Ср: %sr% Чт: %ct% Пт: %pt% Сб: %sb%``nВсего: %allReports% , %hotkey_ini%, reportsWeek, history
    IniRead, History, %hotkey_ini%, reportsWeek, history
    StringReplace, History, History, ``n , `n, ReplaceAll
    LV_Modify(1 , , 0,0,0,0,0,0,0)
    GuiControl,, HistoryList, %History%
} else {
    allReports:= % vs+pn+vt+sr+ct+pt+sb
    IniRead, oldHistory, %hotkey_ini%, reportsWeek, history
    Iniwrite, %oldHistory%``n``n%sDate% - %eDate% ``nВск: %vs% Пн: %pn% Вт: %vt% Ср: %sr% Чт: %ct% Пт: %pt% Сб: %sb%``nВсего: %allReports% , %hotkey_ini%, reportsWeek, history
    IniRead, History, %hotkey_ini%, reportsWeek, history
    StringReplace, History, History, ``n , `n, ReplaceAll
    LV_Modify(1 , , 0,0,0,0,0,0,0)
    GuiControl,, HistoryList, %History%
}
Iniwrite, 0, %hotkey_ini%, reportsWeek, Вс
Iniwrite, 0, %hotkey_ini%, reportsWeek, Пн
Iniwrite, 0, %hotkey_ini%, reportsWeek, Вт
Iniwrite, 0, %hotkey_ini%, reportsWeek, Ср
Iniwrite, 0, %hotkey_ini%, reportsWeek, Чт
Iniwrite, 0, %hotkey_ini%, reportsWeek, Пт
Iniwrite, 0, %hotkey_ini%, reportsWeek, Сб
}
}
;Обновление GUI
IniRead, todayReports, %hotkey_ini%, reportsWeek, %today_ddd%
IniRead, vs, %hotkey_ini%, reportsWeek, Вс
IniRead, pn, %hotkey_ini%, reportsWeek, Пн
IniRead, vt, %hotkey_ini%, reportsWeek, Вт
IniRead, sr, %hotkey_ini%, reportsWeek, Ср
IniRead, ct, %hotkey_ini%, reportsWeek, Чт
IniRead, pt, %hotkey_ini%, reportsWeek, Пт
IniRead, sb, %hotkey_ini%, reportsWeek, Сб
allReports:= % vs+pn+vt+sr+ct+pt+sb
GuiControl, reportsGUI:, ReportsText, Репортов: %todayReports%`nЗа неделю: %allReports%

return



ovrShowHide:
toggle := !toggle
if (toggle){
    if(ovBinder=1){
    IniRead, bindsX, %hotkey_ini%, GuiPosition, bindsX
    IniRead, bindsY, %hotkey_ini%, GuiPosition, bindsY

    if(!bindsX){
        Gui, bindsGUI:Show, AutoSize NoActivate, reports
    } else if(!bindsY){
        Gui, bindsGUI:Show, AutoSize NoActivate, reports
    } else if(bindsX != 0){
        if(bindsY != 0){
        Gui, bindsGUI:Show, AutoSize NoActivate x%bindsX% y%bindsY%, reports
        } else {
        Gui, bindsGUI:Show, AutoSize NoActivate, reports
        }
    } else {
        Gui, bindsGUI:Show, AutoSize NoActivate, reports
    }


	WinSet, TransColor, %CustomColor%, reports
	}
    if(ovReports=1){
    IniRead, repsX, %hotkey_ini%, GuiPosition, reportsX
    IniRead, repsY, %hotkey_ini%, GuiPosition, reportsY


    if(!repsX){
    Gui, reportsGUI:Show, AutoSize NoActivate, reportsGUI
    } else if(!repsY){
    Gui, reportsGUI:Show, AutoSize NoActivate, reportsGUI
    } else if(repsX != 0){
     if(repsY !=0){
       Gui, reportsGUI:Show, AutoSize NoActivate x%repsX% y%repsY%, reportsGUI
     } else {
       Gui, reportsGUI:Show, AutoSize NoActivate, reportsGUI
     }
   } else {
   Gui, reportsGUI:Show, AutoSize NoActivate, reportsGUI
   }




    WinSet, TransColor, %CustomColor%, reportsGUI
    }
}else{
    if(ovBinder=1){
	Gui, bindsGUI:Hide
	}
    if(ovReports=1){
    Gui, reportsGUI:Hide
    }
}
return


ovrDrag:
toggle := !toggle
if (!toggle){
      if(ovBinder=1){
       if(ovReports=1){
           WinSet, AlwaysOnTop, off, reportsGUI
           WinActivate, reports
           ControlClick, , reports
       }
      }
    WinSet, Transparent, 200, reports
    WinSet, Enable, , reports
    WinSet, Transparent, 200, reportsGUI
    WinSet, Enable, , reportsGUI
  if(ovBinder=1){
   if(ovReports=1){
       WinSet, AlwaysOnTop, on, reportsGUI
   }
  }
} else {
   if(ovBinder=1){
    if(ovReports=1){
        WinSet, AlwaysOnTop, off, reportsGUI
        WinActivate, reports
        ControlClick, , reports
    }
   }
   WinSet, TransColor, 000000, reports
   WinSet, TransColor, 000000, reportsGUI
   WinGetPos, Xbinds, Ybinds, , , reports
   WinGetPos, Xreports, Yreports, , , reportsGUI


   IniWrite, %Xbinds%, %hotkey_ini%, GuiPosition, bindsX
   IniWrite, %Ybinds%, %hotkey_ini%, GuiPosition, bindsY
   IniWrite, %Xreports%, %hotkey_ini%, GuiPosition, reportsX
   IniWrite, %Yreports%, %hotkey_ini%, GuiPosition, reportsY

   WinSet, Disable, , reportsGUI
   WinSet, Disable, , reports
  if(ovBinder=1){
   if(ovReports=1){
       WinSet, AlwaysOnTop, on, reportsGUI
   }
  }
}
return

;Блок назначения хоткеев/админкоманд
MyKey1:
BlockInput, On
par:=clipboard
clipboard=%DEditR1%
Sendinput {LControl down}
sleep 50
Sendinput {V down}
sleep 200
Sendinput {LControl UP}
sleep 50
Sendinput {V UP}
Sleep 20
if (space1 = 1) {
Sendinput {space}
}
sleep 10
if(Checkstat1 = 1)
{
Sendinput {enter down}
sleep 50
Sendinput {enter UP}
}
clipboard:=par
BlockInput, Off
return
MyKey2:
BlockInput, On
par:=clipboard
clipboard=%DEditR2%
Sendinput {LControl down}
sleep 50
Sendinput {V down}
sleep 200
Sendinput {LControl UP}
sleep 50
Sendinput {V UP}
Sleep 20
if (space2 = 1) {
Sendinput {space}
}
sleep 10
if(Checkstat2 = 1)
{
Sendinput {enter down}
sleep 50
Sendinput {enter UP}
}
clipboard:=par
BlockInput, Off
return
MyKey3:
BlockInput, On
par:=clipboard
clipboard=%DEditR3%
Sendinput {LControl down}
sleep 50
Sendinput {V down}
sleep 200
Sendinput {LControl UP}
sleep 50
Sendinput {V UP}
Sleep 20
if (space3 = 1) {
Sendinput {space}
}
sleep 10
if(Checkstat3 = 1)
{
Sendinput {enter down}
sleep 50
Sendinput {enter UP}
}
clipboard:=par
BlockInput, Off
return
MyKey4:
BlockInput, On
par:=clipboard
clipboard=%DEditR4%
Sendinput {LControl down}
sleep 50
Sendinput {V down}
sleep 200
Sendinput {LControl UP}
sleep 50
Sendinput {V UP}
Sleep 20
if (space4 = 1) {
Sendinput {space}
}
sleep 10
if(Checkstat4 = 1)
{
Sendinput {enter down}
sleep 50
Sendinput {enter UP}
}
clipboard:=par
BlockInput, Off
return
MyKey5:
BlockInput, On
par:=clipboard
clipboard=%DEditR5%
Sendinput {LControl down}
sleep 50
Sendinput {V down}
sleep 200
Sendinput {LControl UP}
sleep 50
Sendinput {V UP}
Sleep 20
if (space5 = 1) {
Sendinput {space}
}
sleep 10
if(Checkstat5 = 1)
{
Sendinput {enter down}
sleep 50
Sendinput {enter UP}
}
clipboard:=par
BlockInput, Off
return
MyKey6:
BlockInput, On
par:=clipboard
clipboard=%DEditR6%
Sendinput {LControl down}
sleep 50
Sendinput {V down}
sleep 200
Sendinput {LControl UP}
sleep 50
Sendinput {V UP}
Sleep 20
if (space6 = 1) {
Sendinput {space}
}
sleep 10
if(Checkstat6 = 1)
{
Sendinput {enter down}
sleep 50
Sendinput {enter UP}
}
clipboard:=par
BlockInput, Off
return
MyKey7:
BlockInput, On
par:=clipboard
clipboard=%DEditR7%
Sendinput {LControl down}
sleep 50
Sendinput {V down}
sleep 200
Sendinput {LControl UP}
sleep 50
Sendinput {V UP}
Sleep 20
if (space7 = 1) {
Sendinput {space}
}
sleep 10
if(Checkstat7 = 1)
{
Sendinput {enter down}
sleep 50
Sendinput {enter UP}
}
clipboard:=par
BlockInput, Off
return
MyKey8:
BlockInput, On
par:=clipboard
clipboard=%DEditR8%
Sendinput {LControl down}
sleep 50
Sendinput {V down}
sleep 200
Sendinput {LControl UP}
sleep 50
Sendinput {V UP}
Sleep 20
if (space8 = 1) {
Sendinput {space}
}
sleep 10
if(Checkstat8 = 1)
{
Sendinput {enter down}
sleep 50
Sendinput {enter UP}
}
clipboard:=par
BlockInput, Off
return
MyKey9:
BlockInput, On
par:=clipboard
clipboard=%DEditR9%
Sendinput {LControl down}
sleep 50
Sendinput {V down}
sleep 200
Sendinput {LControl UP}
sleep 50
Sendinput {V UP}
Sleep 20
if (space9 = 1) {
Sendinput {space}
}
sleep 10
if(Checkstat9 = 1)
{
Sendinput {enter down}
sleep 50
Sendinput {enter UP}
}
clipboard:=par
BlockInput, Off
return
MyKey10:
BlockInput, On
par:=clipboard
clipboard=%DEditR10%
Sendinput {LControl down}
sleep 50
Sendinput {V down}
sleep 200
Sendinput {LControl UP}
sleep 50
Sendinput {V UP}
Sleep 20
if (space10 = 1) {
Sendinput {space}
}
sleep 10
if(Checkstat10 = 1)
{
Sendinput {enter down}
sleep 50
Sendinput {enter UP}
}
clipboard:=par
BlockInput, Off
return
MyKey11:
BlockInput, On
par:=clipboard
clipboard=%DEditR11%
Sendinput {LControl down}
sleep 50
Sendinput {V down}
sleep 200
Sendinput {LControl UP}
sleep 50
Sendinput {V UP}
Sleep 20
if (space11 = 1) {
Sendinput {space}
}
sleep 10
if(Checkstat11 = 1)
{
Sendinput {enter down}
sleep 50
Sendinput {enter UP}
}
clipboard:=par
BlockInput, Off
return
MyKey12:
BlockInput, On
par:=clipboard
clipboard=%DEditR12%
Sendinput {LControl down}
sleep 50
Sendinput {V down}
sleep 200
Sendinput {LControl UP}
sleep 50
Sendinput {V UP}
Sleep 20
if (space12 = 1) {
Sendinput {space}
}
sleep 10
if(Checkstat12 = 1)
{
Sendinput {enter down}
sleep 50
Sendinput {enter UP}
}
clipboard:=par
BlockInput, Off
return
MyKey13:
BlockInput, On
par:=clipboard
clipboard=%DEditR13%
Sendinput {LControl down}
sleep 50
Sendinput {V down}
sleep 200
Sendinput {LControl UP}
sleep 50
Sendinput {V UP}
Sleep 20
if (space13 = 1) {
Sendinput {space}
}
sleep 10
if(Checkstat13 = 1)
{
Sendinput {enter down}
sleep 50
Sendinput {enter UP}
}
clipboard:=par
BlockInput, Off
return
MyKey14:
BlockInput, On
par:=clipboard
clipboard=%DEditR14%
Sendinput {LControl down}
sleep 50
Sendinput {V down}
sleep 200
Sendinput {LControl UP}
sleep 50
Sendinput {V UP}
Sleep 20
if (space14 = 1) {
Sendinput {space}
}
sleep 10
if(Checkstat14 = 1)
{
Sendinput {enter down}
sleep 50
Sendinput {enter UP}
}
clipboard:=par
BlockInput, Off
return
MyKey15:
BlockInput, On
par:=clipboard
clipboard=%DEditR15%
Sendinput {LControl down}
sleep 50
Sendinput {V down}
sleep 200
Sendinput {LControl UP}
sleep 50
Sendinput {V UP}
Sleep 20
if (space15 = 1) {
Sendinput {space}
}
sleep 10
if(Checkstat15 = 1)
{
Sendinput {enter down}
sleep 50
Sendinput {enter UP}
}
clipboard:=par
BlockInput, Off
return
MyKey16:
BlockInput, On
par:=clipboard
clipboard=%DEditR16%
Sendinput {LControl down}
sleep 50
Sendinput {V down}
sleep 200
Sendinput {LControl UP}
sleep 50
Sendinput {V UP}
Sleep 20
if (space16 = 1) {
Sendinput {space}
}
sleep 10
if(Checkstat16 = 1)
{
Sendinput {enter down}
sleep 50
Sendinput {enter UP}
}
clipboard:=par
BlockInput, Off
return
MyKey17:
BlockInput, On
par:=clipboard
clipboard=%DEditR17%
Sendinput {LControl down}
sleep 50
Sendinput {V down}
sleep 200
Sendinput {LControl UP}
sleep 50
Sendinput {V UP}
Sleep 20
if (space17 = 1) {
Sendinput {space}
}
sleep 10
if(Checkstat17 = 1)
{
Sendinput {enter down}
sleep 50
Sendinput {enter UP}
}
clipboard:=par
BlockInput, Off
return
MyKey18:
BlockInput, On
par:=clipboard
clipboard=%DEditR18%
Sendinput {LControl down}
sleep 50
Sendinput {V down}
sleep 200
Sendinput {LControl UP}
sleep 50
Sendinput {V UP}
Sleep 20
if (space18 = 1) {
Sendinput {space}
}
sleep 10
if(Checkstat18 = 1)
{
Sendinput {enter down}
sleep 50
Sendinput {enter UP}
}
clipboard:=par
BlockInput, Off
return
MyKey19:
BlockInput, On
par:=clipboard
clipboard=%DEditR19%
Sendinput {LControl down}
sleep 50
Sendinput {V down}
sleep 200
Sendinput {LControl UP}
sleep 50
Sendinput {V UP}
Sleep 20
if (space19 = 1) {
Sendinput {space}
}
sleep 10
if(Checkstat19 = 1)
{
Sendinput {enter down}
sleep 50
Sendinput {enter UP}
}
clipboard:=par
BlockInput, Off
return
MyKey20:
BlockInput, On
par:=clipboard
clipboard=%DEditR20%
Sendinput {LControl down}
sleep 50
Sendinput {V down}
sleep 200
Sendinput {LControl UP}
sleep 50
Sendinput {V UP}
Sleep 20
if (space20 = 1) {
Sendinput {space}
}
sleep 10
if(Checkstat20 = 1)
{
Sendinput {enter down}
sleep 50
Sendinput {enter UP}
}
clipboard:=par
BlockInput, Off
return
MyKey21:
BlockInput, On
par:=clipboard
clipboard=%DEditR21%
Sendinput {LControl down}
sleep 50
Sendinput {V down}
sleep 200
Sendinput {LControl UP}
sleep 50
Sendinput {V UP}
Sleep 20
if (space21 = 1) {
Sendinput {space}
}
sleep 10
if(Checkstat21 = 1)
{
Sendinput {enter down}
sleep 50
Sendinput {enter UP}
}
clipboard:=par
BlockInput, Off
return
MyKey22:
BlockInput, On
par:=clipboard
clipboard=%DEditR22%
Sendinput {LControl down}
sleep 50
Sendinput {V down}
sleep 200
Sendinput {LControl UP}
sleep 50
Sendinput {V UP}
Sleep 20
if (space22 = 1) {
Sendinput {space}
}
sleep 10
if(Checkstat22 = 1)
{
Sendinput {enter down}
sleep 50
Sendinput {enter UP}
}
clipboard:=par
BlockInput, Off
return
MyKey23:
BlockInput, On
par:=clipboard
clipboard=%DEditR23%
Sendinput {LControl down}
sleep 50
Sendinput {V down}
sleep 200
Sendinput {LControl UP}
sleep 50
Sendinput {V UP}
Sleep 20
if (space23 = 1) {
Sendinput {space}
}
sleep 10
if(Checkstat23 = 1)
{
Sendinput {enter down}
sleep 50
Sendinput {enter UP}
}
clipboard:=par
BlockInput, Off
return
MyKey24:
BlockInput, On
par:=clipboard
clipboard=%DEditR24%
Sendinput {LControl down}
sleep 50
Sendinput {V down}
sleep 200
Sendinput {LControl UP}
sleep 50
Sendinput {V UP}
Sleep 20
if (space24 = 1) {
Sendinput {space}
}
sleep 10
if(Checkstat24 = 1)
{
Sendinput {enter down}
sleep 50
Sendinput {enter UP}
}
clipboard:=par
BlockInput, Off
return
MyKey25:
BlockInput, On
par:=clipboard
clipboard=%DEditR25%
Sendinput {LControl down}
sleep 50
Sendinput {V down}
sleep 200
Sendinput {LControl UP}
sleep 50
Sendinput {V UP}
Sleep 20
if (space25 = 1) {
Sendinput {space}
}
sleep 10
if(Checkstat25 = 1)
{
Sendinput {enter down}
sleep 50
Sendinput {enter UP}
}
clipboard:=par
BlockInput, Off
return
MyKey26:
BlockInput, On
par:=clipboard
clipboard=%DEditR26%
Sendinput {LControl down}
sleep 50
Sendinput {V down}
sleep 200
Sendinput {LControl UP}
sleep 50
Sendinput {V UP}
Sleep 20
if (space26 = 1) {
Sendinput {space}
}
sleep 10
if(Checkstat26 = 1)
{
Sendinput {enter down}
sleep 50
Sendinput {enter UP}
}
clipboard:=par
BlockInput, Off
return
MyKey27:
BlockInput, On
par:=clipboard
clipboard=%DEditR27%
Sendinput {LControl down}
sleep 50
Sendinput {V down}
sleep 200
Sendinput {LControl UP}
sleep 50
Sendinput {V UP}
Sleep 20
if (space27 = 1) {
Sendinput {space}
}
sleep 10
if(Checkstat27 = 1)
{
Sendinput {enter down}
sleep 50
Sendinput {enter UP}
}
clipboard:=par
BlockInput, Off
return
MyKey28:
BlockInput, On
par:=clipboard
clipboard=%DEditR28%
Sendinput {LControl down}
sleep 50
Sendinput {V down}
sleep 200
Sendinput {LControl UP}
sleep 50
Sendinput {V UP}
Sleep 20
if (space28 = 1) {
Sendinput {space}
}
sleep 10
if(Checkstat28 = 1)
{
Sendinput {enter down}
sleep 50
Sendinput {enter UP}
}
clipboard:=par
BlockInput, Off
return
MyKey29:
BlockInput, On
par:=clipboard
clipboard=%DEditR29%
Sendinput {LControl down}
sleep 50
Sendinput {V down}
sleep 200
Sendinput {LControl UP}
sleep 50
Sendinput {V UP}
Sleep 20
if (space29 = 1) {
Sendinput {space}
}
sleep 10
if(Checkstat29 = 1)
{
Sendinput {enter down}
sleep 50
Sendinput {enter UP}
}
clipboard:=par
BlockInput, Off
return
MyKey30:
BlockInput, On
par:=clipboard
clipboard=%DEditR30%
Sendinput {LControl down}
sleep 50
Sendinput {V down}
sleep 200
Sendinput {LControl UP}
sleep 50
Sendinput {V UP}
Sleep 20
if (space30 = 1) {
Sendinput {space}
}
sleep 10
if(Checkstat30 = 1)
{
Sendinput {enter down}
sleep 50
Sendinput {enter UP}
}
clipboard:=par
BlockInput, Off
return
MyKey31:
BlockInput, On
par:=clipboard
clipboard=%DEditR31%
Sendinput {LControl down}
sleep 50
Sendinput {V down}
sleep 200
Sendinput {LControl UP}
sleep 50
Sendinput {V UP}
Sleep 20
if (space31 = 1) {
Sendinput {space}
}
sleep 10
if(Checkstat31 = 1)
{
Sendinput {enter down}
sleep 50
Sendinput {enter UP}
}
clipboard:=par
BlockInput, Off
return
MyKey32:
BlockInput, On
par:=clipboard
clipboard=%DEditR32%
Sendinput {LControl down}
sleep 50
Sendinput {V down}
sleep 200
Sendinput {LControl UP}
sleep 50
Sendinput {V UP}
Sleep 20
if (space32 = 1) {
Sendinput {space}
}
sleep 10
if(Checkstat32 = 1)
{
Sendinput {enter down}
sleep 50
Sendinput {enter UP}
}
clipboard:=par
BlockInput, Off
return

;;Команда для кнопки "Сохранить"
save:
Gui, Submit, NoHide,
i=1
loop 32
{
Checkspace:=Checkspace%i%
EditKey:=EditKey%i%
DEditR:=DEditR%i%
Check:=Check%i%
Iniwrite, %Checkspace%, %hotkey_ini%, checkboxes, spacebox%i%
IniWrite, %EditKey%, %hotkey_ini%, HotKey, Key%i%
IniWrite, %DEditR%, %hotkey_ini%, Text, DEditR%i%
Iniwrite, %Check%, %hotkey_ini%, checkboxes, checkbox%i%
i:=i+1
}

Iniwrite, %HotKeyVisibleOverlay%, %hotkey_ini%, HotKey, OverlayShow
Iniwrite, %HotKeyDragOverlay%, %hotkey_ini%, HotKey, OverlayDrag
Iniwrite, %HotKeyAddReport%, %hotkey_ini%, HotKey, ReportsAdd
Iniwrite, %HotKeyRemoveReport%, %hotkey_ini%, HotKey, ReportsRemove
Iniwrite, %OverlayVisibleBinder%, %hotkey_ini%, checkboxes, OverlayBinder
Iniwrite, %OverlayVisibleReports%, %hotkey_ini%, checkboxes, OverlayReports
Iniwrite, %OverlayVisibleDiscord%, %hotkey_ini%, checkboxes, OverlayDiscord

sleep 500
Reload
return

;Команда для кнопки Сброс
del:
MsgBox , 4, Сброс настроек, Вы уверены, что хотите произвести сброс?
IfMsgBox Yes
{
FileDelete, %hotkey_ini%
reload
}
return

;Команда для нажатия на кнопку перезагрузки
reboot:
Progress, b w800, GTA5RP Admin AHK v%vers%, Перезагрузка, Reloading
Progress, 100
Sleep, 650
Progress, Off
Reload
return

;;Команда кнопки Выход
exit:
ExitApp
return

;;Команда кнопки перезагрузки в трее
relog:
Reload
return

;;Команда для отрисовки GUI при открытие в трее
show_my_gui:
Gui, Show, x100 y100 w800 h600, GTA5RP Admin AHK v%vers%
return



;;Назначение хоткеев
h=1
loop 32
{
varKey:=varKey%h%
HotKey, %varKey%, MyKey%h%, On, UseErrorLevel
h:=h+1
}
return