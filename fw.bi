 /'***************************************************************************'/
/'
 * FW LE (Lite edition) - Fundamentals of the King´s Crook graphics engine.
 *
 *   by EMMIR 2018-2022
 *
 *   YouTube: https://www.youtube.com/c/LMP88
 *
 * This software is released into the public domain.
 '/
 '
 ' adaptacion a FreeBasic ( https://www.freebasic.net/ ) por :
 ' Joseba Epalza 2024 <jepalza> (gmail com)
 '
/'***************************************************************************'/


/'  fw.h
 *
 * Main file to include to use the FW framework.
 *
 * This lite edition of FW has the following capabilities:
 *   - simple program loop
 *   - polled keyboard input
 *   - ability to create software video context on Win32/macOS(XQuartz)/Linux
 *      > GDI under Windows
 *      > X11 (with optional MIT-SHM image extension) under macOS/Linux
 *   - low and high resolution clock sampling
 *
 '/

/'*********************************************************************'/
/' windows '/
#define FW_OS_TYPE_WINDOWS 1

/' define as 1 if you want to compile with MIT-SHM support '/
#ifndef FW_X11_HAS_SHM_EXT
#Define FW_X11_HAS_SHM_EXT 1
#endif

/'*********************************************************************'/
#ifndef NULL
#Define NULL (cast(any ptr,0))
#endif


#ifndef FW_DEFAULT_TITLE_SIZE
#Define FW_DEFAULT_TITLE_SIZE 16
#EndIf

/'*********************************************************************'/

Type VIDINFO 
    As Integer Ptr video   /' pointer to video memory '/
    As Integer width_    /' horizontal resolution '/
    As Integer height_   /' vertical resolution '/
    As Integer pitch    /' bytes per scanline '/
    As Integer bytespp  /' bytes per pixel '/
    As Integer flags    /' any flags used when creating video context '/
End Type 

/' system functions '/
Declare Sub sys_init Cdecl Alias "sys_init"( )     /' setup FW system (ByVal call this before anything) '/
Declare Sub sys_sethz Cdecl Alias "sys_sethz"(ByVal hz As Integer)  /' set loop rate '/

' llamadas a funciones por punteros: las funciones las creamos nosotros a nivel FreeBasic
Declare Sub sys_updatefunc Cdecl Alias "sys_updatefunc"(ByVal update As Long) /' update callback '/
Declare Sub sys_displayfunc Cdecl Alias "sys_displayfunc"(ByVal draws As Long) /' display callback '/
Declare Sub sys_keybfunc Cdecl Alias "sys_keybfunc"(ByVal key As Long) /' key down callback '/
Declare Sub sys_keybupfunc Cdecl Alias "sys_keybupfunc"(ByVal key As Long) /' key up callback '/
'
Declare Sub sys_start Cdecl Alias "sys_start"( )                            /' start main loop '/
Declare Sub sys_shutdown Cdecl Alias "sys_shutdown"()   /' waits for loop to finish '/
Declare Sub sys_kill Cdecl Alias "sys_kill"()       /' instantaneous shutdown '/
Declare Function sys_poll Cdecl Alias "sys_poll"() As Integer        /' poll the operating system for events '/
Declare Function sys_getfps Cdecl Alias "sys_getfps"() As Integer      /' get current fps of system '/
Declare Sub sys_capfps Cdecl Alias "sys_capfps"(ByVal cap As Integer)  /' limit fps to hz specified by sys_sethz '/
/'*********************************************************************'/

#define FW_VFLAG_NONE    000
#define FW_VFLAG_VIDFAST 002 /' request the fastest graphics context '/

#define FW_VERR_OK     0
#define FW_VERR_NOMEM  1
#define FW_VERR_WINDOW 2

/' video device functions '/

/' open video context with given title, resolution, and scale '/
Declare Function vid_open Cdecl Alias "vid_open"(ByVal  title As Byte Ptr ,ByVal  width_ As Integer ,ByVal  height_ As Integer ,ByVal  scale As Integer ,ByVal  flags As Integer) As Integer 
Declare Sub vid_blit Cdecl Alias "vid_blit"()         /' draw image onto window '/
Declare Sub vid_sync Cdecl Alias "vid_sync"()         /' sync (ByVal behavior is OS-dependent) '/
Declare Function vid_getinfo Cdecl Alias "vid_getinfo"() As VIDINFO Ptr  /' get current video info '/

/'*********************************************************************'/

Type As UInteger utime 

#define FW_CLK_MODE_LORES 0 /' low resolution clock (default) '/
#define FW_CLK_MODE_HIRES 1 /' high resolution clock '/

/' clock and timing functions '/
Declare Sub clk_mode Cdecl Alias "clk_mode"(ByVal mode As Integer)  /' set clock mode '/
Declare Function clk_sample Cdecl Alias "clk_sample"() As utime   /' sample the clock (ByVal milliseconds) '/

/'*********************************************************************'/

/' keyboard input functions '/
#define FW_KEY_ARROW_LEFT  &h25
#define FW_KEY_ARROW_UP    &h26
#define FW_KEY_ARROW_RIGHT &h27
#define FW_KEY_ARROW_DOWN  &h28
#define FW_KEY_PLUS        "+"
#define FW_KEY_MINUS       "-"
#define FW_KEY_EQUALS      "="
#define FW_KEY_ENTER       &h0d
#define FW_KEY_SPACE       &h20
#define FW_KEY_TAB         &h09
#define FW_KEY_ESCAPE      &h1b
#define FW_KEY_SHIFT       &h10
#define FW_KEY_CONTROL     &h11
#define FW_KEY_BACKSPACE   &h08

Declare Function kbd_vk2ascii Cdecl Alias "kbd_vk2ascii"(ByVal vk As Integer) As Integer           /' virtual keycode to ascii '/
Declare Sub kbd_ignorerepeat Cdecl Alias "kbd_ignorerepeat"(ByVal ignore As Integer)  /' ignore OS key repeat when held '/
/'*********************************************************************'/

/' polled keyboard implementation '/
Declare Sub pkb_reset Cdecl Alias "pkb_reset"()          /' reset all keys '/
Declare Sub pkb_keyboard Cdecl Alias "pkb_keyboard"(ByVal key As Integer)    /' key down callback for polled kb '/
Declare Sub pkb_keyboardup Cdecl Alias "pkb_keyboardup"(ByVal key As Integer)  /' key up callback for polled kb '/
Declare Function pkb_key_pressed Cdecl Alias "pkb_key_pressed"(ByVal key As Integer) As Integer  /' this tests if key was pressed '/
Declare Function pkb_key_held Cdecl Alias "pkb_key_held"(ByVal key As Integer) As Integer     /' this tests if key is being held '/
/'*********************************************************************'/

