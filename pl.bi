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

#Inclib "pl"

/'  pl.h
 *
 * Main header file for the PL library.
 *
 '/


/' maximum possible horizontal or vertical resolution '/
#define PL_MAX_SCREENSIZE 2048

/'***************************************************************************'/
/'******************************** CLIPPING *********************************'/
/'***************************************************************************'/

#define PL_Z_NEAR_PLANE 16 /' where near z plane is '/

#define PL_Z_OUTC_IN_VIEW &h0 /' in front of z plane '/
#define PL_Z_OUTC_PART_NZ &h1 /' partially in front of z plane '/
#define PL_Z_OUTC_OUTSIDE &h2 /' completely behind z plane '/

Dim Shared As Integer PL_vp_min_x 
Dim Shared As Integer PL_vp_max_x 
Dim Shared As Integer PL_vp_min_y 
Dim Shared As Integer PL_vp_max_y 
Dim Shared As Integer PL_vp_cen_x 
Dim Shared As Integer PL_vp_cen_y 

/' define viewport
 *
 * update_center - updates what the engine considers to be the perspective
 *                 focal point of the image
 *
 '/
Declare Sub PL_set_viewport Cdecl Alias "PL_set_viewport"(ByVal minx As Integer ,ByVal  miny As Integer ,ByVal  maxx As Integer ,ByVal  maxy As Integer ,ByVal  update_center As Integer) 

/' clip lines and polygons to 2D viewport '/
Declare Function PL_clip_line_x Cdecl Alias "PL_clip_line_x"(ByVal  v0 As Integer Ptr Ptr,ByVal   v1 As Integer Ptr Ptr,ByVal  len As Integer ,ByVal  min As Integer ,ByVal  max As Integer) As Integer 
Declare Function PL_clip_line_y Cdecl Alias "PL_clip_line_y"(ByVal  v0 As Integer Ptr Ptr,ByVal   v1 As Integer Ptr Ptr,ByVal  len As Integer ,ByVal  min As Integer ,ByVal  max As Integer) As Integer 
Declare Function PL_clip_poly_x Cdecl Alias "PL_clip_poly_x"(ByVal  dst As Integer Ptr ,ByVal   src As Integer Ptr ,ByVal  len As Integer ,ByVal  num As Integer) As Integer 
Declare Function PL_clip_poly_y Cdecl Alias "PL_clip_poly_y"(ByVal  dst As Integer Ptr ,ByVal   src As Integer Ptr ,ByVal  len As Integer ,ByVal  num As Integer) As Integer 

/' test point to determine if it´s in front of near plane '/
Declare Function PL_point_frustum_test Cdecl Alias "PL_point_frustum_test"(ByVal  v As Integer Ptr) As Integer 
/' test z bounds to determine its position relative to near plane '/
Declare Function PL_frustum_test Cdecl Alias "PL_frustum_test"(ByVal minz As Integer ,ByVal  maxz As Integer) As Integer 
/' clip polygon to near plane '/
Declare Function PL_clip_poly_nz Cdecl Alias "PL_clip_poly_nz"(ByVal  dst As Integer Ptr ,ByVal   src As Integer Ptr ,ByVal  len As Integer ,ByVal  num As Integer) As Integer 

/'***************************************************************************'/
/'********************************* ENGINE **********************************'/
/'***************************************************************************'/

/' maximum number of vertices in object '/
#define PL_MAX_OBJ_V 4096

#define PL_FLAT     	1
#define PL_TEXTURED 	0

#define PL_CULL_NONE  0
#define PL_CULL_FRONT 1
#define PL_CULL_BACK  2

/' for storage size definition '/
#define PL_VDIM      5 /' X Y Z U V '/
#define PL_POLY_VLEN 3 /' Idx U V '/

' jepalza: llamadas propias incluidas por mi, para asignar valores internos al motor
Declare Sub PL_Set_Fov Cdecl Alias "PL_Set_Fov"(ByVal valor As integer) /' min valid value = 8 '/
Declare Sub PL_Set_Raster_Mode Cdecl Alias "PL_Set_Raster_Mode"(ByVal valor As integer) /' PL_FLAT or PL_TEXTURED '/
Declare Sub PL_Set_Cull_Mode Cdecl Alias "PL_Set_Cull_Mode"(ByVal valor As integer)

Dim Shared As Integer PL_fov = 9

/' only square textures with dimensions of PL_REQ_TEX_DIM '/
Type PL_TEX 
    As Integer Ptr Datas  /' 4 byte-per-pixel true color X8R8G8B8 color data '/
End Type 
' jepalza: llamada propias incluida por mi, para asignar valor PL_TEX al motor
Declare Sub PL_Set_Cur_Tex Cdecl Alias "PL_Set_Cur_Tex"(ByVal tex As PL_TEX Ptr)


Type PL_POLY 
    As PL_TEX Ptr tex 

    /' As a user defined polygon may only have 3 or 4 vertices.  '/

    /' [As index, U, V] array of indices into obj verts array '/
    As Integer verts((6 * PL_POLY_VLEN)-1) 
    As Integer colors 
    As Integer n_verts 
 End Type 

Type PL_OBJ 
    As PL_POLY Ptr polys  /' list of polygons in the object '/
    As Integer Ptr verts             /' array of [x, y, z, 0] values '/
    As Integer n_polys 
    As Integer n_verts 
End Type 

/' take an XYZ coord in world space and convert to screen space '/
Declare Function PL_xfproj_vert Cdecl Alias "PL_xfproj_vert"(ByVal in As Integer Ptr ,ByVal outs As Integer Ptr) As Integer 

Declare Sub PL_render_object Cdecl Alias "PL_render_object"(ByVal obj As PL_OBJ Ptr) 
Declare Sub PL_delete_object Cdecl Alias "PL_delete_object"(ByVal obj As PL_OBJ Ptr) 
Declare Sub PL_copy_object   Cdecl Alias "PL_copy_object"  (ByVal dst As PL_OBJ Ptr ,ByVal src As PL_OBJ Ptr) 

/'***************************************************************************'/
/'********************************** IMODE **********************************'/
/'***************************************************************************'/

#define PL_TRIANGLES &h00
#define PL_QUADS     &h01

Declare Sub PL_ibeg Cdecl Alias "PL_ibeg"( )  /' begin primitive '/
/' type is PL_TRIANGLES or PL_QUADS '/
Declare Sub PL_type Cdecl Alias "PL_type"(ByVal types As Integer) 

/' applies to the next polygon made. '/
Declare Sub PL_texture Cdecl Alias "PL_texture"(ByVal tex As PL_TEX Ptr) 

/' last color defined before the poly is finished is used as the poly´s color '/
Declare Sub PL_color Cdecl Alias "PL_color"(ByVal r As Integer ,ByVal  g As Integer ,ByVal  b As Integer) 
Declare Sub PL_texcoord Cdecl Alias "PL_texcoord"(ByVal u As Integer ,ByVal  v As Integer) 
Declare Sub PL_vertex Cdecl Alias "PL_vertex"(ByVal x As Integer ,ByVal  y As Integer ,ByVal  z As Integer) 

Declare Function PL_cur_vertex_count Cdecl Alias "PL_cur_vertex_count"( ) As Integer 
Declare Function PL_cur_polygon_count Cdecl Alias "PL_cur_polygon_count"( ) As Integer 

/' doesn´t delete the previous object once called '/
Declare Sub PL_iend Cdecl Alias "PL_iend"( )  /' end primitive '/

Declare Sub PL_iinit Cdecl Alias "PL_iinit"( )    /' initialize (ByVal only needed if not exporting) '/
Declare Sub PL_irender Cdecl Alias "PL_irender"( )  /' render (ByVal only needed if not exporting) '/

/' save current model that has been defined in immediate mode '/
Declare Sub PL_export Cdecl Alias "PL_export"(ByVal  dest As PL_OBJ Ptr) 

/' get pointer to object currently being defined in immediate mode '/
Declare Function PL_get_working_copy Cdecl Alias "PL_get_working_copy"( ) As PL_OBJ Ptr

/'***************************************************************************'/
/'******************************** GRAPHICS *********************************'/
/'***************************************************************************'/

/' textures must be square with a dimension of (1 << PL_REQ_TEX_LOG_DIM) '/
#define PL_REQ_TEX_LOG_DIM 7
#define PL_REQ_TEX_DIM (1 Shl PL_REQ_TEX_LOG_DIM)

#define PL_TP 12 /' texture interpolation precision '/

#define PL_MAX_POLY_VERTS 8 /' max verts in a polygon (post-clip) '/

#define PL_STREAM_FLAT 3 /' X Y Z '/
#define PL_STREAM_TEX  5 /' X Y Z U V '/

Dim Shared As Integer PL_polygon_count  /' number of polygons rendered '/

Dim Shared As Integer PL_hres    /' horizontal resolution '/
Dim Shared As Integer PL_vres    /' vertical resolution '/
Dim Shared As Integer PL_hres_h  /' half resolutions '/
Dim Shared As Integer PL_vres_h 

Dim Shared As Integer Ptr PL_video_buffer 
Dim Shared As Integer Ptr PL_depth_buffer 


/' Call this to initialize PL
 *
 * video - pointer to target image (4 byte-per-pixel true color X8R8G8B8)
 * hres - horizontal resolution of image
 * vres - vertical resolution of image
 *
 '/
Declare Sub PL_init Cdecl Alias "PL_init"(ByVal  video As Integer Ptr ,ByVal  hres As Integer ,ByVal  vres As Integer) 

/' clear viewport color and depth '/
Declare Sub PL_clear_vp Cdecl Alias "PL_clear_vp"(ByVal r As Integer ,ByVal  g As Integer ,ByVal  b As Integer) 
Declare Sub PL_clear_color_vp Cdecl Alias "PL_clear_color_vp"(ByVal r As Integer ,ByVal  g As Integer ,ByVal  b As Integer)  /' clear viewport color '/
Declare Sub PL_clear_depth_vp Cdecl Alias "PL_clear_depth_vp"()                 /' clear viewport depth '/

/' Solid color polygon fill.
 * Expecting input stream of 3 values [X,Y,Z] '/
Declare Sub PL_flat_poly Cdecl Alias "PL_flat_poly"(ByVal  stream As Integer Ptr ,ByVal  lens As Integer ,ByVal  rgbs As Integer) 

/' Affine (linear) texture mapped polygon fill.
 * Expecting input stream of 5 values [X,Y,Z,U,V] '/
Declare Sub PL_lintx_poly Cdecl Alias "PL_lintx_poly"(ByVal  stream As Integer Ptr ,ByVal  lens As Integer ,ByVal   texel As Integer Ptr) 

/'***************************************************************************'/
/'********************************** MATH ***********************************'/
/'***************************************************************************'/

/' maximum matrix stack depth '/
#define PL_MAX_MST_DEPTH 64

/' number of elements in PL_sin and PL_cos '/
#define PL_TRIGMAX 256
#define PL_TRIGMSK (PL_TRIGMAX - 1)

/' number of elements in a vector '/
#define PL_VLEN 4

/' precision for fixed point math '/
#define PL_P 15
#define PL_P_ONE (1 Shl PL_P)

/' identity matrix '/
#Define PL_IDT_MAT _
	{ _
	   PL_P_ONE, 0, 0, 0, _
	   0, PL_P_ONE, 0, 0, _
	   0, 0, PL_P_ONE, 0, _
	   0, 0, 0, PL_P_ONE  _
	}

#define PL_VEC2_ELEMS(x) x(0), x(1)
#define PL_VEC3_ELEMS(x) x(0), x(1), x(2)
#define PL_VEC4_ELEMS(x) x(0), x(1), x(2), x(3)



'-------------------------------------------------------------------------------
' NOTA Jepalza: FB no localiza las variables, por lo que las reconstruyo aqui
' Extern Import PL_sin Alias "PL_sin" As Integer Ptr
' Extern Import PL_cos Alias "PL_cos" As Integer Ptr

Dim Shared As Integer PL_sin(PL_TRIGMAX) = { _
    &h0000, &h0324, &h0647, &h096a, &h0c8b, &h0fab, &h12c8, &h15e2, &h18f8,  _
    &h1c0b, &h1f19, &h2223, &h2528, &h2826, &h2b1f, &h2e11, &h30fb, &h33de,  _
    &h36ba, &h398c, &h3c56, &h3f17, &h41ce, &h447a, &h471c, &h49b4, &h4c3f,  _
    &h4ebf, &h5133, &h539b, &h55f5, &h5842, &h5a82, &h5cb4, &h5ed7, &h60ec,  _
    &h62f2, &h64e8, &h66cf, &h68a6, &h6a6d, &h6c24, &h6dca, &h6f5f, &h70e2,  _
    &h7255, &h73b5, &h7504, &h7641, &h776c, &h7884, &h798a, &h7a7d, &h7b5d,  _
    &h7c29, &h7ce3, &h7d8a, &h7e1d, &h7e9d, &h7f09, &h7f62, &h7fa7, &h7fd8,  _
    &h7ff6, &h8000, &h7ff6, &h7fd8, &h7fa7, &h7f62, &h7f09, &h7e9d, &h7e1d,  _
    &h7d8a, &h7ce3, &h7c29, &h7b5d, &h7a7d, &h798a, &h7884, &h776c, &h7641,  _
    &h7504, &h73b5, &h7255, &h70e2, &h6f5f, &h6dca, &h6c24, &h6a6d, &h68a6,  _
    &h66cf, &h64e8, &h62f2, &h60ec, &h5ed7, &h5cb4, &h5a82, &h5842, &h55f5,  _
    &h539b, &h5133, &h4ebf, &h4c3f, &h49b4, &h471c, &h447a, &h41ce, &h3f17,  _
    &h3c56, &h398c, &h36ba, &h33de, &h30fb, &h2e11, &h2b1f, &h2826, &h2528,  _
    &h2223, &h1f19, &h1c0b, &h18f8, &h15e2, &h12c8, &h0fab, &h0c8b, &h096a,  _
    &h0647, &h0324}
    
	 Dim Shared as Integer PL_cos(PL_TRIGMAX) 

    Dim As Integer i
    ' sine is mirrored over X after PI 
    for i = 0 to (PL_TRIGMAX Shr 1)-1
        PL_sin((PL_TRIGMAX Shr 1) + i) = -PL_sin(i)
    Next
    ' construct cosine table by copying sine table 
    for i = 0 To ((PL_TRIGMAX Shr 1) + (PL_TRIGMAX Shr 2))-1
        PL_cos(i) = PL_sin(i + (PL_TRIGMAX shr 2))
    Next
    for i = 0 To (PL_TRIGMAX Shr 2)-1
        PL_cos(i + ((PL_TRIGMAX Shr 1) + (PL_TRIGMAX Shr 2))) = PL_sin(i)
    Next
' --------------------------------------------------------------------------------------------




/' vectors are assumed to be integer arrays of length PL_VLEN '/
/' matrices are assumed to be integer arrays of length 16 '/

Declare Function PL_winding_order Cdecl Alias "PL_winding_order"(ByVal  a As Integer Ptr ,ByVal   b As Integer Ptr ,ByVal   c As Integer Ptr) As Integer 
Declare Sub PL_vec_shorten Cdecl Alias "PL_vec_shorten"(ByVal  v As Integer Ptr)  /' shorten vector to fit in 15 bits '/
Declare Sub PL_psp_project Cdecl Alias "PL_psp_project"(ByVal  src As Integer Ptr ,ByVal   dst As Integer Ptr ,ByVal  len As Integer ,ByVal  num As Integer ,ByVal  fov As Integer) 

/' matrix stack (mst) '/
Declare Sub PL_mst_get Cdecl Alias "PL_mst_get"(ByVal  m As Integer Ptr)     /' get current top of mst '/
Declare Sub PL_mst_push Cdecl Alias "PL_mst_push"( )      /' push matrix onto mst '/
Declare Sub PL_mst_pop Cdecl Alias "PL_mst_pop"( )       /' pop matrix from mst '/
Declare Sub PL_mst_load_idt Cdecl Alias "PL_mst_load_idt"( )  /' load identity matrix '/
Declare Sub PL_mst_load Cdecl Alias "PL_mst_load"(ByVal  m As Integer Ptr)    /' load specified matrix to mst '/
Declare Sub PL_mst_mul Cdecl Alias "PL_mst_mul"(ByVal  m As Integer Ptr)     /' multiply given matrix to mst '/
Declare Sub PL_mst_scale Cdecl Alias "PL_mst_scale"(ByVal x As Integer ,ByVal  y As Integer ,ByVal  z As Integer) 
Declare Sub PL_mst_translate Cdecl Alias "PL_mst_translate"(ByVal x As Integer ,ByVal  y As Integer ,ByVal  z As Integer) 
Declare Sub PL_mst_rotatex Cdecl Alias "PL_mst_rotatex"(ByVal rx As Integer) 
Declare Sub PL_mst_rotatey Cdecl Alias "PL_mst_rotatey"(ByVal ry As Integer) 
Declare Sub PL_mst_rotatez Cdecl Alias "PL_mst_rotatez"(ByVal rz As Integer) 
Declare Sub PL_set_camera Cdecl Alias "PL_set_camera"(ByVal x As Integer ,ByVal  y As Integer ,ByVal  z As Integer ,ByVal  rx As Integer ,ByVal  ry As Integer) 

/' transform a stream of vertices by the current model+view '/
Declare Sub PL_mst_xf_modelview_vec Cdecl Alias "PL_mst_xf_modelview_vec"(ByVal  v As Integer Ptr ,ByVal   out As Integer Ptr ,ByVal  len As Integer) 

/' result is stored in ´a´ '/
Declare Sub PL_mat_mul Cdecl Alias "PL_mat_mul"(ByVal  a As Integer Ptr ,ByVal   b As Integer Ptr) 
Declare Sub PL_mat_cpy Cdecl Alias "PL_mat_cpy"(ByVal  dst As Integer Ptr ,ByVal   src As Integer Ptr) 

/'***************************************************************************'/
/'*********************************** GEN ***********************************'/
/'***************************************************************************'/

/' flags to specify the faces of the box to generate '/
' nota: originalmente estaban en OCTAL,los he convertido a HEXADECIMAL
#define PL_TOP    &h01 ' 001
#define PL_BOTTOM &h02 ' 002
#define PL_BACK   &h04 ' 004
#define PL_FRONT  &h08 ' 010
#define PL_LEFT   &h10 ' 020
#define PL_RIGHT  &h20 ' 040
#define PL_ALL    &h3F ' 077 ' este es el normal para un cubo texturado

/' generate immediate mode commands for a box '/
Declare Sub PL_gen_box_list Cdecl Alias "PL_gen_box_list"(ByVal x As Integer ,ByVal y As Integer ,ByVal z As Integer ,ByVal w As Integer ,ByVal h As Integer ,ByVal d As Integer ,ByVal side_flags As Integer) 

/' generate a box '/
Declare Function PL_gen_box Cdecl Alias "PL_gen_box"(ByVal w As Integer ,ByVal h As Integer ,ByVal d As Integer ,ByVal side_flags As Integer ,ByVal r As Integer ,ByVal g As Integer ,ByVal b As Integer) As PL_OBJ Ptr

/'***************************************************************************'/
/'******************************** IMPORTER *********************************'/
/'***************************************************************************'/
Declare Function import_dmdl Cdecl Alias "import_dmdl"(ByVal  names As ZString Ptr ,ByVal  o As PL_OBJ Ptr Ptr) As Integer  /' import DMDL object '/

/'***************************************************************************'/
/'****************************** USER DEFINED *******************************'/
/'***************************************************************************'/

#define PL_ERR_NO_MEM 0
#define PL_ERR_MISC   1
/' error function (PL expects program to halt after calling this) '/
Declare Sub EXT_error Cdecl Alias "EXT_error"(ByVal err_id As Integer ,ByVal  modname As ZString Ptr ,ByVal  msg As ZString Ptr) 

/' memory allocation function, ideally a calloc or something similar '/
Declare Function EXT_calloc Cdecl Alias "EXT_calloc"(ByVal a As ULong ,ByVal  b As ULong) As Long Ptr
/' memory freeing function '/
Declare Sub EXT_free Cdecl Alias "EXT_free"(ByVal a As Long Ptr) 
