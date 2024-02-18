# FB_PL3D-KC
FreeBasic motor 3D solo por "software" basado en PL3D-KC

Es un motor gráfico muy simple, pensado para la simplicidad usando solo métodos "software", sin "hardware" dedicado que no sea la propia CPU.

Ademas, no emplea valores flotantes, solo enteros, para darle velocidad. El resultado es una apariencia muy de los 80's-90's con "pixel" gordos y deformados.





Para poder compilar he anulado estas lineas en FW\WVID.C :
linea 186 -> SetProcessDPIAware();
linea 213 -> AdjustWindowRectExForDpi(&r, style, 0, 0, GetDpiForWindow(FWi_wnd));
por que GCC no tiene esas llamadas. Al parecer solo son para MSVC, pero veo que no afecta y funciona igualmente sin ellas...



Ademas,parapoer usar el motor 3D en FreeBasic, he añadiro estas lineas:

en el fichero PL.C, linea 31 aprox, tras las variables 

	int PL_fov          = 9;
 
	int PL_raster_mode  = PL_FLAT;
 
	int PL_cull_mode    = PL_CULL_BACK;

 

Añadimos estas (son para que en FreeBasic podamos asignar las anteriores variables como subrutinas, por que el 

sistema del FB para acceder a variables en DLL (extern import ...) no parece funcionar

	// jepalza, necesarias para asignar las variables "extern" que FreeBasic no puede acceder
 
	void PL_Set_Fov( int valor) { PL_fov=valor; }
 
	void PL_Set_Raster_Mode( int valor) { PL_raster_mode=valor; }
 
	void PL_Set_Cull_Mode( int valor) { PL_cull_mode=valor; }
 
	void PL_Set_Cur_Tex(struct PL_TEX *tex) { PL_cur_tex=tex; }

 
	
Tenemos tambien que hacer lo mismo en PL.H:

linea 88 aprox., donde estan las varaibles "extern"

	extern int PL_fov; /* min valid value = 8 */
 
	extern struct PL_TEX *PL_cur_tex;
 
	extern int PL_raster_mode; /* PL_FLAT or PL_TEXTURED */
 
	extern int PL_cull_mode;

 

Añadimos estas:

	// jepalza, una manera de controlar las variables internas
 
	extern void PL_Set_Fov( int valor);
 
	extern void PL_Set_Raster_Mode( int valor);
 
	extern void PL_Set_Cull_Mode( int valor);
 
	extern void PL_Set_Cur_Tex(struct PL_TEX *tex); //jepalza, para asignar la variable TEX externamente desde FB


 
