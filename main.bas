/'***************************************************************************'/
/'
 * PiSHi LE (Lite edition) - Fundamentals of the King´s Crook graphics engine.
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

#Include "windows.bi"
#Include "fbgfx.bi"

#include "pl.bi"
#include "fw.bi"

/'  main.c
 *
 * Basic demo showing how to define a 3D scene, generate geometry,
 * import geometry, implement first person camera controls, and transform
 * the geometry.
 *
 * Controls:
 *      Arrow keys - looking
 *      W/A/S/D keys - movement
 *      T/G keys - move up and down
 *      C - cycle through culling modes
 *      1 - flat rendering
 *      2 - textured rendering
 *      3 - toggle between two FOVs
 *      SPACE - start/stop dynamic transformation
 *
 '/


Function EXT_calloc(n As ulong , esz As ULong) As Long ptr
    return Callocate(n, esz) 
End Function


Sub EXT_free(p As Long Ptr)
    Delete(p) 
End Sub


Sub EXT_error(err_id As Integer ,  modname As ZString Ptr ,  msgs As ZString Ptr)

    Print "vx error :"; err_id; modname; msgs
    sys_kill() 

    Sleep
    End
End Sub



#define VW 896
#define VH 504

/' cube size '/
#define CUSZ 128

/' grid size '/
#define GRSZ 1

/' movement speed '/
#define MOVSPD 4

Dim Shared As PL_OBJ Ptr floortile
Dim Shared As PL_OBJ Ptr texcube
Dim Shared As PL_OBJ Ptr imported

Dim Shared As Integer camrx = 0, camry = 0 
Dim Shared As Integer x = 0, y = 200, z = 90 
Dim Shared As Integer rot = 1 
Dim Shared As Integer sinvar = 0
Dim Shared As PL_TEX checktex
Dim Shared As Integer checker(PL_REQ_TEX_DIM * PL_REQ_TEX_DIM) 
Dim Shared As UInteger fpsclock= 0 


Sub maketex()

    Dim As uinteger i, j, c 

    for i = 0 To PL_REQ_TEX_DIM-1         
        for j = 0 To PL_REQ_TEX_DIM-1         
            if (i < &h10) OrElse (j < &h10) OrElse (i > ((PL_REQ_TEX_DIM - 1) - &h10)) OrElse (j > ((PL_REQ_TEX_DIM - 1) - &h10)) Then 
                /' border color '/
                c = &h3f4f5f 
            Else
                /' checkered pattern '/
                if ((i And &h10) Xor (j And &h10))<>0 Then 
                    c = &h3f4f5f 
                Else
                    c = &hd4ccba 
                EndIf 
            EndIf
  
            if (i = j) OrElse (Abs(i - j) < 3) Then 
                /' thick red line along diagonal '/
                checker(i + j * PL_REQ_TEX_DIM) = &h902215 
            Else
                checker(i + j * PL_REQ_TEX_DIM) = c 
            EndIf
        Next
    Next
    
    checktex.datas = @checker(0) 
End Sub


Sub init(model As String)

    maketex() 

	' cube
    PL_texture(@checktex) 
    texcube = PL_gen_box(CUSZ, CUSZ, CUSZ, PL_ALL, 255, 255, 255) 
    
   ' tile floor
    PL_texture(NULL) 
    floortile = PL_gen_box(CUSZ, CUSZ, CUSZ, PL_TOP, 77, 101, 94) 

    import_dmdl(model, @imported) 

    PL_fov = 9
    PL_Set_Fov(PL_fov) 
            
    PL_Set_Cur_Tex(NULL)
    
    PL_Set_Cull_Mode(PL_CULL_BACK)
    PL_Set_Raster_Mode(PL_TEXTURED)    

    fpsclock = clk_sample() 
End Sub


Sub update()

    if (pkb_key_pressed(FW_KEY_ESCAPE))  Then sys_shutdown() 
    
    if (pkb_key_held(FW_KEY_ARROW_RIGHT))Then camry += 1 
    if (pkb_key_held(FW_KEY_ARROW_LEFT)) Then camry -= 1 
    if (pkb_key_held(FW_KEY_ARROW_UP))   Then camrx -= 1 
    if (pkb_key_held(FW_KEY_ARROW_DOWN)) Then camrx += 1 

    if (pkb_key_held(Asc("w"))) Then 
        x += (MOVSPD * PL_sin(camry And PL_TRIGMSK)) Shr PL_P 
        y -= (MOVSPD * PL_sin(camrx And PL_TRIGMSK)) Shr PL_P 
        z += (MOVSPD * PL_cos(camry And PL_TRIGMSK)) Shr PL_P 
    EndIf
  
    if (pkb_key_held(Asc("s"))) Then 
        x -= (MOVSPD * PL_sin(camry And PL_TRIGMSK)) Shr PL_P 
        y += (MOVSPD * PL_sin(camrx And PL_TRIGMSK)) Shr PL_P 
        z -= (MOVSPD * PL_cos(camry And PL_TRIGMSK)) Shr PL_P 
    EndIf
  
    if (pkb_key_held(Asc("a"))) Then 
        x -= (MOVSPD * PL_cos(camry And PL_TRIGMSK)) Shr PL_P 
        z += (MOVSPD * PL_sin(camry And PL_TRIGMSK)) Shr PL_P 
    EndIf
  
    if (pkb_key_held(Asc("d"))) Then 
        x += (MOVSPD * PL_cos(camry And PL_TRIGMSK)) Shr PL_P 
        z -= (MOVSPD * PL_sin(camry And PL_TRIGMSK)) Shr PL_P 
    EndIf

  
    if (pkb_key_held(Asc("t"))) Then y += MOVSPD 
    if (pkb_key_held(Asc("g"))) Then y -= MOVSPD 
    
    if (pkb_key_pressed(Asc("c"))) Then 
        Static As Integer cmod = PL_CULL_BACK 
        if (cmod = PL_CULL_BACK) Then   
            cmod = PL_CULL_NONE 
        ElseIf (cmod = PL_CULL_FRONT) Then
            cmod = PL_CULL_BACK 
        Else
            cmod = PL_CULL_FRONT 
        EndIf
  
        PL_Set_Cull_Mode(cmod)
    EndIf
  
    if (pkb_key_held(Asc("1"))) Then 
        PL_Set_Raster_Mode(PL_FLAT) 
    EndIf
  
    if (pkb_key_held(Asc("2"))) Then 
        PL_Set_Raster_Mode(PL_TEXTURED) 
    EndIf
  
    if (pkb_key_pressed(Asc("3"))) Then 
        if (PL_fov = 8) Then 
        		PL_fov = 9
            PL_Set_Fov(PL_fov) 
        Else
            PL_fov = 8
            PL_Set_Fov(PL_fov) 
        EndIf
  
        Print "fov: "; PL_fov
    EndIf
  
    if (pkb_key_pressed(Asc(" "))) Then 
        rot = IIf(rot=0,1,0)
    EndIf
  
    sinvar+=1  
End Sub


Sub display()

    Dim As Integer i = 0, j = 0 
    Dim As Integer p1 = PL_P_ONE 
    Dim As Integer mo 

    /' clear viewport to black '/
    PL_clear_vp(0, 0, 0) 
    PL_polygon_count = 0 

    /' define camera orientation '/
    PL_set_camera(x, y, z, camrx, camry) 

    /' draw imported model '/
     PL_mst_push() 
     if (rot) Then 
         mo = (PL_sin(sinvar And PL_TRIGMSK) * 256) Shr PL_P 
         PL_mst_translate(mo, 400, 500) 
     Else
         PL_mst_translate(0, 400, 500) 
     EndIf
     PL_render_object(imported) 
     PL_mst_pop() 
    

    /' draw tile grid '/
    for i = -GRSZ To GRSZ -1      
        for j = -GRSZ To GRSZ -1        
            PL_mst_push() 
            PL_mst_translate(0 + i * CUSZ, 0, 600 + j * CUSZ) 
            PL_render_object(floortile) 
            PL_mst_pop() 
        Next
    Next

    /' draw textured cube '/
     PL_mst_push() 
     PL_mst_translate(-100, 100, 500) 
     If (rot) Then 
         PL_mst_rotatex(sinvar Shr 2) 
         PL_mst_rotatey(sinvar Shr 1) 
         PL_mst_scale(p1 * ((sinvar And &hff) + 128) Shr 8, p1, p1) 
     EndIf
     PL_render_object(texcube) 
     PL_mst_pop() 


    if (clk_sample() > fpsclock) Then 
        fpsclock = clk_sample() + 1000 
        Print "FPS: ";sys_getfps() 
    EndIf
  
    /' update window and sync '/
    vid_blit() 
    vid_sync() 
End Sub





   ' --------------------------------- M A I N ----------------------------------------

	' acepta el envio de modelos DMDL desde "command"
	Dim As String model=Command
	If model="" Then model="pots" ' por defecto, POTS
	If InStr(model,".") Then model=Left(model,InStr(model,".")-1)
	

    sys_init() 
    sys_updatefunc(Cast(Long,@update)) 
    sys_displayfunc(Cast(Long,@display))

    clk_mode(FW_CLK_MODE_HIRES) 
    pkb_reset() 
    sys_sethz(70) 
    sys_capfps(0) 

    if (vid_open(StrPtr("PL"), VW, VH, 1, FW_VFLAG_VIDFAST) <> FW_VERR_OK) Then 
        Print "unable to create window"
        Sleep
    EndIf
  
    /' give the video memory to PL '/
    PL_init(vid_getinfo()->video, VW, VH) 

    init(model) 
    sys_start() 

    sys_shutdown() 


