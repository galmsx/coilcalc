-- ��� lua ������ ��� FEMM 4.0
--------------------------------------------------------------------------------
---- ������  �� 23 ��� 2006 �. 
--------------------------------------------------------------------------------
-- ������ �� ����� ��������� ���������
--------------------------------------------------------------------------------
File_name=prompt ("������� ��� ����� � ������� �����, ��� ���������� .txt") 

handle = openfile(File_name .. ".txt","r")
pustaja_stroka = read(handle, "*l") -- ������ ���������� ������ 4 ��
pustaja_stroka = read(handle, "*l")
pustaja_stroka = read(handle, "*l")
pustaja_stroka = read(handle, "*l")


Vel0 = read(handle, "*n", "*l")		-- ��������� �������� ����, �/� (������ 0 ����� �����-�� ��������� ��������, ����� ����� �� ����� �����)
delta_t = read(handle, "*n", "*l")	-- ���������� �������, ��� 
Dstvola = read(handle, "*n", "*l")	-- ������� ������� ������ (�� �������� ������ �������� ����), ��������

Nom_mat_puli = read(handle, "*n", "*l")	-- �������� �� �������� ������� ���� ��. �������
Lpuli  = read(handle, "*n", "*l")	-- ����� ����, ��������		
Dpuli = read(handle, "*n", "*l")	-- ������� ����, ��������
Lsdv = read(handle, "*n", "*l")		-- ����������, �� ������� � ��������� ������ �������� ���� � ������� ��� ��������� �� ������� � �������, ��������

Lmag = read(handle, "*n", "*l")	-- ������� �������� ��������������, �� ����� ��������� �������, ���� ���� �� ��� ���, ��������
Nom_mat_magnitoprovoda = read(handle, "*n", "*l")	-- �������� �� �������� ������ ������������� ������� ��. �������

Konfig_kat = read(handle, "*n", "*l")	-- 0 - ������� �������� �������, 1 - �������������� ������� ������ �����, 2 - ������������� ������ �������, ����� ��������� ��� ���
Diod = read(handle, "*n", "*l")	-- 0 - ��� ������������ ������� �����, 1 - � ������

C={}
U={}
Dpr={}
Tiz={}
Lkat={}
Dkat={}
Lvkl={}
Lmezdu_kat={}
L_vsego=0
i=1
repeat

	C[i] = read(handle, "*n", "*l") 	-- ������� ������������, ����������		
	U[i] = read(handle, "*n", "*l")		-- ���������� �� ������������, ����� 

	Dpr[i] = read(handle, "*n", "*l")	-- ������� ����������� ������� �������, ��������
	Tiz[i] = read(handle, "*n", "*l")	-- ��������� ������� �������� ������� (������� �������� � �������� � �������� ������), ��
	Lkat[i] = read(handle, "*n", "*l")	-- ����� ������� (�� �������� ������ �������� �����. ������� �������), ��������				
	Dkat[i] = read(handle, "*n", "*l")	-- ������� ������� �������, ��������
	
	Lmezdu_kat[i]= read(handle, "*n", "*l")	-- ��, ���������� ����� ��������� ������� 
	Lvkl[i] = read(handle, "*n", "*l")	-- ��, �� ����� ���������� �� ���������� ��������� ���� ���������� �������� 
	
	if C[i]>0 then
		L_vsego=L_vsego+Lkat[i]+Lmezdu_kat[i]
	end
	i=i+1
	
until C[i-1]==0  
N_kat =i-2

closefile(handle)
--------------------------------------------------------------------------------

Vol = 3                 -- ��������� ���������� ������������ ������ ������ (������������� �������� �� 3 �� 5)
Coil_meshsize = 0.5    -- ������ ����� �������, ��
Proj_meshsize = 0.35    -- ������ ����� ����, ��
max_segm      = 5     -- ������������ ������ �������� ������������, ����

t = 0			-- ��������� ������ �������, �������
sigma = 0.0000000175	-- �������� ������������� ����, �� * ����
ro = 7800		-- ��������� ������, ��/����^3
pi = 3.1415926535  
--------------------------------------------------------------------------------
-- ��������
--------------------------------------------------------------------------------
Start_date= date()


create(0)							-- ������� �������� ��� ��������� �����

mi_probdef(0,"millimeters","axi",1E-8,30)			-- ������� ������

mi_saveas("temp.fem")						-- ��������� ���� ��� ������ ������

mi_addmaterial("Air",1,1)					-- ��������� �������� ������


i=1
repeat
	mi_addmaterial("Cu" .. i,1,1,"","","",58,"","","",4,"","",1,Dpr[i])	-- ��������� �������� ������ ������ ��������� Dpr ������������� 58
	mi_addcircprop("katushka" .. i,0,0,1)				-- ��������� ������� 
	i=i+1
until N_kat<i  



dofile ("func.lua")	-- ����������� ������� ��� ����������� ������� � ���					
vvod_materiala (Nom_mat_magnitoprovoda,"M")	-- ������ �������� �������������� ������� ��� ��� � � ����� ���������
Material_magnitoprovoda="M" .. Nom_mat_magnitoprovoda

vvod_materiala (Nom_mat_puli,"P")		---- ������ �������� ���� ������� ��� ��� � � ����� ���������
Material_puli="P" .. Nom_mat_puli	

--------------------------------------------------------------------------------
-- ����������� �������
--------------------------------------------------------------------------------

--������� ������������ � Vol ��� ������� ��� �������
mi_addnode(0,L_vsego*-Vol) 				-- ������ �����
mi_addnode(0,L_vsego*(Vol-1))				-- ������ �����
mi_addsegment(0,L_vsego*-Vol,0,L_vsego*(Vol-1))		-- ������ �����
mi_addarc(0,L_vsego*-Vol,0,L_vsego*(Vol-1),180,max_segm)	-- ������ ����

mi_addblocklabel(L_vsego*0.7*Vol,0)				-- ��������� ����	
mi_clearselected()						-- �������� ��� 
mi_selectlabel(L_vsego*0.7*Vol,0)				-- �������� ����� �����
mi_setblockprop("Air", 1, "", "", "",0) 			-- ������������� �������� ����� � ����� Air � ������� ����� 0

mi_zoomnatural()	-- ������������� ��� ��� ��� �� ���� ����� �� ���� �����

-------------------------------------------------------------------------- ������� ����

-- ���� ����� ���� ����� �������� ������ ���
if Lpuli==Dpuli then 

	mi_addnode(0,-Lsdv)
	mi_addnode(0,Lpuli-Lsdv)

	mi_clearselected()
	mi_selectnode (0,-Lsdv)
	mi_selectnode (0,Lpuli-Lsdv)
	mi_setnodeprop("",N_kat+2)
	mi_addarc(0,-Lsdv,0,Lpuli-Lsdv,180,5)


else	-- ����� ������ �������

	mi_addnode(0,-Lsdv)
	mi_addnode(Dpuli/2,-Lsdv)
	mi_addnode(Dpuli/2,Lpuli-Lsdv)
	mi_addnode(0,Lpuli-Lsdv)

	mi_clearselected()
	mi_selectnode(0,-Lsdv)
	mi_selectnode(Dpuli/2,-Lsdv)
	mi_selectnode(Dpuli/2,Lpuli-Lsdv)
	mi_selectnode(0,Lpuli-Lsdv)
	mi_setnodeprop("",N_kat+2)

	mi_addsegment(Dpuli/2,-Lsdv,Dpuli/2,Lpuli-Lsdv)
	mi_addsegment(Dpuli/2,Lpuli-Lsdv,0,Lpuli-Lsdv)
	mi_addsegment(0,Lpuli-Lsdv,0,-Lsdv)
	mi_addsegment(0,-Lsdv,Dpuli/2,-Lsdv)

end
mi_addblocklabel(Dpuli/4,Lpuli/2-Lsdv)
mi_clearselected()
mi_selectlabel(Dpuli/4,Lpuli/2-Lsdv)
mi_setblockprop(Material_puli, 0, Proj_meshsize, "", "",N_kat+2)			-- ����� ����� N_kat+2

------------------------------------------------------------------------- ������� �������


i=1
Lkatpol=0
repeat
	

	mi_addnode(Dstvola/2,-Lkatpol)				-- ���������
	mi_addnode(Dstvola/2,-Lkatpol-Lkat[i])			-- ���������
	mi_addnode(Dkat[i]/2,-Lkatpol)				-- ������� ��������� �����
	mi_addnode(Dkat[i]/2,-Lkatpol-Lkat[i])			-- ������� �������� �����


	mi_addsegment(Dstvola/2,-Lkatpol,Dstvola/2,-Lkatpol-Lkat[i])
	mi_addsegment(Dstvola/2,-Lkatpol-Lkat[i],Dkat[i]/2,-Lkatpol-Lkat[i])
	mi_addsegment(Dkat[i]/2,-Lkatpol-Lkat[i],Dkat[i]/2,-Lkatpol)
	mi_addsegment(Dkat[i]/2,-Lkatpol,Dstvola/2,-Lkatpol)


	mi_clearselected()
	mi_selectnode(Dstvola/2,-Lkatpol)			
	mi_selectnode(Dstvola/2,-Lkatpol-Lkat[i])		
	mi_selectnode(Dkat[i]/2,-Lkatpol)				
	mi_selectnode(Dkat[i]/2,-Lkatpol-Lkat[i])				
	mi_setnodeprop("",i)


	mi_addblocklabel(Dstvola/2+(Dkat[i]/2-Dstvola/2)/2,-Lkatpol-Lkat[i]/2)
	mi_clearselected()
	mi_selectlabel(Dstvola/2+(Dkat[i]/2-Dstvola/2)/2,-Lkatpol-Lkat[i]/2)
	mi_setblockprop("Cu" .. i, 0, Coil_meshsize, "katushka" .. i, "",i) -- ����� ����� i
	
	Lkatpol=Lkatpol+Lkat[i]+Lmezdu_kat[i]
	i=i+1
until N_kat<i 

mi_clearselected()


-------------------------------------------------------------------------- ������� ������� �������������
if (Lmag > 0) and (Nom_mat_magnitoprovoda > 0) then 
	

	------------------------------------------------------------------
	-- ������� �������� ������� � ���������������
	if Konfig_kat==0 then 
	i=1
	Lkatpol=0
	repeat
	

		mi_addnode(Dstvola/2,-Lkatpol+Lmag)				-- ���������
		mi_addnode(Dstvola/2,-Lkatpol-Lkat[i]-Lmag)			-- ���������
		mi_addnode(Dkat[i]/2+Lmag,-Lkatpol+Lmag)				-- ������� ��������� �����
		mi_addnode(Dkat[i]/2+Lmag,-Lkatpol-Lkat[i]-Lmag)			-- ������� �������� �����


		mi_addsegment(Dstvola/2,-Lkatpol+Lmag,Dstvola/2,-Lkatpol-Lkat[i]-Lmag)
		mi_addsegment(Dstvola/2,-Lkatpol-Lkat[i]-Lmag,Dkat[i]/2+Lmag,-Lkatpol-Lkat[i]-Lmag)
		mi_addsegment(Dkat[i]/2+Lmag,-Lkatpol-Lkat[i]-Lmag,Dkat[i]/2+Lmag,-Lkatpol+Lmag)
		mi_addsegment(Dkat[i]/2+Lmag,-Lkatpol+Lmag,Dstvola/2,-Lkatpol+Lmag)


		mi_clearselected()
		mi_selectnode(Dstvola/2,-Lkatpol+Lmag)			
		mi_selectnode(Dstvola/2,-Lkatpol-Lkat[i]-Lmag)		
		mi_selectnode(Dkat[i]/2+Lmag,-Lkatpol+Lmag)				
		mi_selectnode(Dkat[i]/2+Lmag,-Lkatpol-Lkat[i]-Lmag)				
		mi_setnodeprop("",N_kat+1)


		mi_addblocklabel(Dkat[i]/2+Lmag/2,-Lkatpol-Lkat[i]/2)
		mi_clearselected()
		mi_selectlabel(Dkat[i]/2+Lmag/2,-Lkatpol-Lkat[i]/2)
		mi_setblockprop(Material_magnitoprovoda, 1, "", "", "",N_kat+1) -- ����� ����� N_kat+1
	
		Lkatpol=Lkatpol+Lkat[i]+Lmezdu_kat[i]
		i=i+1
	until N_kat<i 
	mi_clearselected()
	end
	

	------------------------------------------------------------------
	-- ������ �������������
	if Konfig_kat==1 then 
	i=1
	Lkatpol=0
	repeat
	

		mi_addnode(Dstvola/2,-Lkatpol+Lmag)				-- ���������
		mi_addnode(Dstvola/2,-Lkatpol-Lkat[i]-Lmag)			-- ���������
		mi_addnode(Dkat[i]/2+Lmag,-Lkatpol+Lmag)				-- ������� ��������� �����
		mi_addnode(Dkat[i]/2+Lmag,-Lkatpol-Lkat[i]-Lmag)			-- ������� �������� �����
		mi_addnode(Dkat[i]/2,-Lkatpol+Lmag)				-- ������� �������� �����
		mi_addnode(Dkat[i]/2,-Lkatpol-Lkat[i]-Lmag)			-- ������� �������� �����

		mi_addsegment(Dstvola/2,-Lkatpol+Lmag,Dstvola/2,-Lkatpol-Lkat[i]-Lmag)
		mi_addsegment(Dstvola/2,-Lkatpol-Lkat[i]-Lmag,Dkat[i]/2,-Lkatpol-Lkat[i]-Lmag)
		mi_addsegment(Dkat[i]/2+Lmag,-Lkatpol-Lkat[i]-Lmag,Dkat[i]/2+Lmag,-Lkatpol+Lmag)
		mi_addsegment(Dkat[i]/2,-Lkatpol+Lmag,Dstvola/2,-Lkatpol+Lmag)

		if i==1 then
			mi_addsegment(Dkat[i]/2+Lmag,-Lkatpol+Lmag,Dstvola/2,-Lkatpol+Lmag)
		end
		if i==N_kat then
			mi_addsegment(Dstvola/2,-Lkatpol-Lkat[i]-Lmag,Dkat[i]/2+Lmag,-Lkatpol-Lkat[i]-Lmag)
		end
		


		mi_clearselected()
		mi_selectnode(Dstvola/2,-Lkatpol+Lmag)			
		mi_selectnode(Dstvola/2,-Lkatpol-Lkat[i]-Lmag)		
		mi_selectnode(Dkat[i]/2+Lmag,-Lkatpol+Lmag)				
		mi_selectnode(Dkat[i]/2+Lmag,-Lkatpol-Lkat[i]-Lmag)
		mi_selectnode(Dkat[i]/2,-Lkatpol+Lmag)
		mi_selectnode(Dkat[i]/2,-Lkatpol-Lkat[i]-Lmag)	
		mi_setnodeprop("",N_kat+1)

		if i>=2 then
			
			mi_addsegment(Dkat[i]/2+Lmag,-Lkatpol+Lmag,Dkat[i-1]/2+Lmag,-Lkatpol-Lmag+Lmezdu_kat[i-1])
			mi_addsegment(Dkat[i]/2,-Lkatpol+Lmag,Dkat[i-1]/2,-Lkatpol-Lmag+Lmezdu_kat[i-1])

		end

		Lkatpol=Lkatpol+Lkat[i]+Lmezdu_kat[i]
		i=i+1
	until N_kat<i 

	mi_addblocklabel(Dstvola/2+(Dkat[1]/2-Dstvola/2)/2,Lmag/2)
	mi_clearselected()
	mi_selectlabel(Dstvola/2+(Dkat[1]/2-Dstvola/2)/2,Lmag/2)
	mi_setblockprop(Material_magnitoprovoda, 1, "", "", "",N_kat+1) -- ����� ����� N_kat+1
	mi_clearselected()

	end


	------------------------------------------------------------------
	-- ������ �������������, �� ����� ��������� ��� ���

	if Konfig_kat==2 then 
	i=2
	Lkatpol=Lkat[1]+Lmezdu_kat[1]

	mi_addnode(Dkat[1]/2+Lmag,Lmag)	-- ������� ��������� �����
	mi_addnode(Dkat[1]/2+Lmag,-Lkat[1])-- ������� �������� �����


	mi_addsegment(Dkat[1]/2+Lmag,Lmag,Dkat[1]/2+Lmag,-Lkat[1])
	mi_addsegment(Dkat[2]/2,-Lkatpol,Dkat[1]/2,-Lkatpol+Lmezdu_kat[1])
	
	repeat
	
		mi_addnode(Dkat[i]/2+Lmag,-Lkatpol)	-- ������� ��������� �����
		mi_addnode(Dkat[i]/2+Lmag,-Lkatpol-Lkat[i])-- ������� �������� �����


		mi_addsegment(Dkat[i]/2+Lmag,-Lkatpol,Dkat[i]/2+Lmag,-Lkatpol-Lkat[i])
		mi_addsegment(Dkat[i]/2,-Lkatpol,Dkat[i-1]/2,-Lkatpol+Lmezdu_kat[i])
		mi_addsegment(Dkat[i]/2+Lmag,-Lkatpol,Dkat[i-1]/2+Lmag,-Lkatpol+Lmezdu_kat[i])

		mi_clearselected()
		mi_selectnode(Dkat[i]/2+Lmag,-Lkatpol)			
		mi_selectnode(Dkat[i]/2+Lmag,-Lkatpol-Lkat[i])		
		mi_setnodeprop("",N_kat+1)

		Lkatpol=Lkatpol+Lkat[i]+Lmezdu_kat[i]
		i=i+1
	until N_kat<i

	mi_addnode(Dstvola/2,Lmag)				-- ���������
	mi_addsegment(Dkat[1]/2+Lmag,Lmag,Dstvola/2,Lmag)
	mi_addsegment(Dstvola/2,0,Dstvola/2,Lmag)

	mi_addnode(Dstvola/2,-Lkatpol-Lmag+Lmezdu_kat[i-1])
	mi_addnode(Dkat[i-1]/2+Lmag,-Lkatpol-Lmag+Lmezdu_kat[i-1])
	mi_addsegment(Dstvola/2,-Lkatpol-Lmag+Lmezdu_kat[i-1],Dkat[i-1]/2+Lmag,-Lkatpol-Lmag+Lmezdu_kat[i-1])

	mi_addsegment(Dstvola/2,-Lkatpol+Lmezdu_kat[i-1],Dstvola/2,-Lkatpol-Lmag+Lmezdu_kat[i-1])
	mi_addsegment(Dkat[i-1]/2+Lmag,-Lkatpol-Lmag+Lmezdu_kat[i-1],Dkat[i-1]/2+Lmag,-Lkatpol+Lmezdu_kat[i-1])


	mi_addblocklabel(Dstvola/2+(Dkat[1]/2-Dstvola/2)/2,Lmag/2)
	mi_clearselected()
	mi_selectlabel(Dstvola/2+(Dkat[1]/2-Dstvola/2)/2,Lmag/2)
	mi_setblockprop(Material_magnitoprovoda, 1, "", "", "",N_kat+1) -- ����� ����� N_kat+1
	mi_clearselected()

	end
end

mi_clearselected()

------------------------------------------------------------------------------------------------------------------------
-- ����������� � ��������� �������������
	
mi_analyze(1)				-- ����������� (������� ���� ������� "1") 0 - ����� ����� ���� � ����� �������� ��������
mi_loadsolution()			-- ��������� ���� ��������� ���� ����������

mo_zoom(0,-L_vsego*1.2,Lpuli,Dkat[1]*1.5)

mo_clearblock()
mo_groupselectblock(N_kat+2)
Vpuli = mo_blockintegral(10)		-- ����� ����, ����^3	
mo_clearblock()	
Mpuli=ro*Vpuli				-- ����� ����, ��


N={}
DLprovoda={}
Rkat={}
R={}
Rv={}

i=1
Lkatpol=0
repeat

	mo_groupselectblock(i)
	Skat = mo_blockintegral(5) 				-- ������� ������� �������, ����^2 
	mo_clearblock()
	N[i]=Skat*0.94/((Dpr[i]+Tiz[i])*(Dpr[i]+Tiz[i])/1000000)-- ���������� ������ � ������� 
	DLprovoda[i]=N[i] * 2 * pi * (Dkat[i] + Dstvola)/4000   -- ����� ����������� ������� ���������, �

	Rkat[i]=sigma*DLprovoda[i]/(pi*(Dpr[i]/2000)^2)		-- ������������� ����� ����������� ������� �������, ��
	
	kRC = 140      		-- ���������� ��������� RC ��� ��������������� ������������������ �����������, ��*���
	Rcc = (kRC/C[i])  	-- ���������� ������������� ������������
	Rv[i] = 0.35+Rcc     	-- ������������� ���������� �������� + ������������� ��������� + ���������� ������������� ������������, ��

	R[i]=Rv[i]+Rkat[i]						-- ������ ������������� �������

	mi_clearselected()
	mi_selectlabel(Dstvola/2+(Dkat[i]/2-Dstvola/2)/2,-Lkatpol-Lkat[i]/2) 
	mi_setblockprop("Cu" .. i, 0, Coil_meshsize, "katushka" .. i, "",i,N[i]) -- --������������� ����� ������
	mi_clearselected()
	Lkatpol=Lkatpol+Lkat[i]+Lmezdu_kat[i]

	i=i+1
until N_kat<i


--------------------------------------------------------------------------------
-- ������ ���������
--------------------------------------------------------------------------------

dt = delta_t/1000000 -- ������� ���������� ������� � ������� 
x=0		-- ��������� ������� ����
t=0		-- ����� �����
Vel=Vel0
Vmax=Vel
Force = 0
Fii = 0
Fix = 0

I={}
Uc={}
Force={}
i=1
repeat
	I[i]=0 	-- ��������� �������� ����
	Uc[i] = U[i] 	-- �������� �������� ����������	
	Force[i]=0
	mi_modifycircprop("katushka" .. i,1,0)	-- ������������� ��� 
	i=i+1
until N_kat<i

KC=1		-- ������� ������, ��� ������ � ����
T_I={}
T_I[KC]=";"
T_F ={}		
T_Vel={}	
T_x={}		
T_t={}



repeat  	------------------------------------------------------------ �������� ����
	
	t = t+dt
	for i = 1,N_kat,1  do				-- ����������� ����� ����� � �������� ��� ��� ��� ��� � ������ ����� ����
		if x>=Lvkl[i]/1000 then 

			------------------------------------------ ������������ dFi/dI ��� I � ����
					
			if I[i]==0 then I[i]=0.000000001  end  		-- ���� � ������ ��� �� ���� ���������� ����� �������� ����			
            		mi_modifycircprop("katushka" .. i,1,I[i])	-- ������������� ��� 
            		mi_analyze(1)					-- ����������� (������� ���� ������� "1") 0 - ����� ����� ���� � ����� �������� ��������	
            		mo_reload()					-- ������������� ��������� ���� ����������
            		
			--- ������������ dFi/dx ��� x

			current_re,current_im,volts_re,volts_im,flux_re,flux_im=mo_getcircuitproperties("katushka" .. i) -- �������� ������ � �������
			Fi0=flux_re 		-- ��������� �����
				            	
        		
			mi_modifycircprop("katushka" .. i,1,I[i]*1.001)	-- ������������� ���, ����������� �� 1.001
        		mi_analyze(1)					-- ����������� (������� ���� ������� "1") 0 - ����� ����� ���� � ����� �������� ��������	
        		mo_reload()					-- ������������� ��������� ���� ����������			
			current_re,current_im,volts_re,volts_im,flux_re,flux_im=mo_getcircuitproperties("katushka" .. i) -- �������� ������ � �������
           		Fi1=flux_re 			            -- ��������� ����� ��� I=I+0.001*I, dI=0.001*I 
			
			Fii=(Fi1-Fi0)/(0.001*I[i])                              -- ������������ dFi/dI

			Force = mo_groupselectblock(N_kat+2)		-- ���� ��� ������ �������
			Force = mo_blockintegral(19)
			
			Fix= Force/I[i]
			------- ����������� ��� � ���������� �� ������������

			I[i]=I[i]+dt*(Uc[i]-I[i]*R[i]-Fix*Vel)/Fii	--			

			Uc[i] = Uc[i]-dt*I[i]*1000000/C[i]
			
			mi_modifycircprop("katushka" .. i,1,0)

			if Uc[i]<= 0  and Diod == 1 then 
				Uc[i]=0 
				I[i]= 0
			end
		end

		T_I[KC+i*10000]=I[i] -- ���������� ������ � ������
		
	end

---------------------------------------------------------------------------
			i2=1
			repeat

				mi_modifycircprop("katushka" .. i2,1,I[i2])	-- ������������� ��� ��� ���� �������
				i2=i2+1
			until N_kat<i2


			mi_analyze(1)					-- ����������� (������� ���� ������� "1") 0 - ����� ����� ���� � ����� �������� ��������	
            		mo_reload()
			mo_groupselectblock(N_kat+2)
			Force = mo_blockintegral(19)			-- ���� ����������� �� ����, ������

			Force=Force*-1					-- ������ "-" �� �� ��������� (����������� ���� � ������� ���������� ����������)
			apuli = Force / Mpuli				-- ��������� ����, ����/�������^2 
			dx = Vel*dt+apuli*dt*dt/2			-- ���������� ����������, ����
			x = x+dx					-- ����� ������� ����
			Vel = Vel+apuli*dt				-- �������� ����� ����������, ����/�������
			
			if Vmax<Vel then Vmax=Vel end
			
			mi_selectgroup(N_kat+2)				-- �������� ����
			mi_movetranslate(0,-dx*1000)			-- ���������� � �� dx
			mi_clearselected()
			if Vel < 0 then 
				break
			end -- ���� �������� �����
			

			i2=1
			repeat

				mi_modifycircprop("katushka" .. i2,1,0)	-- ������� ��� 
				i2=i2+1
			until N_kat<i2

			T_F[KC]=Force		

			T_Vel[KC]=Vel		

			T_x[KC]=x*1000		

			T_t[KC]=t*1000000	

			KC=KC+1
			
----------------------------------------------------------------------------
until x > L_vsego/1000 -- ��������� ������ 

Epuli = (Mpuli*Vel^2)/2 - (Mpuli*Vel0^2)/2

i=1
EC=0
repeat
	EC= EC+(C[i]/1000000*U[i]^2)/2
	i=i+1
until N_kat<i 

KPD = Epuli*100/EC

showconsole()							-- ���������� ���� ������ ������������� ������
clearconsole()
print ("-----------------------------------")						
print ("������ ��������� " .. Start_date)
i=1
repeat
print ("----------------------------------------------------")
print ("������� �= " .. i)
print ("������� ������������, ����������= " .. C[i])
print ("���������� �� ������������, ����� = " .. U[i])
print ("������������� �����, �� = "..R[i])
print ("������� �������������, �� = " .. Rv[i])
print ("������������� �������, O� = "..Rkat[i])
print ("���������� ������ � ������� = "..N[i])
print ("������� ����������� ������� �������, �������� = " .. Dpr[i])
print ("����� ������� � �������, ���� = "..DLprovoda[i])
print ("����� �������, �������� = " .. Lkat[i])
print ("������� ������� �������, �������� = " .. Dkat[i])
print ("���������� ����� ��������� �������, ��������  = " ..  Lmezdu_kat[i])
print ("�� ����� ���������� �� ���������� ��������� ���� ���������� �������� , ��������  = " ..  Lvkl[i])
print ("��������� ������� �������� ������� (������� �������� � �������� � �������� ������, ��������  = " ..  Tiz[i])		
print ("----------------------------------------------------")
	i=i+1
until N_kat<i  
print ("������� �������� ��������������, �������� = " .. Lmag)
print ("�������� �������� �������������� ������� = � " .. Nom_mat_magnitoprovoda .. " " .. vyvod_name_materiala(Nom_mat_magnitoprovoda))
print ("������� ������� ������, �������� = " .. Dstvola)	
print ("����� ����, ����� = "..Mpuli*1000)
print ("����� ����, �������� = " .. Lpuli)		
print ("������� ����, �������� = " .. Dpuli)
print ("����������, �� ������� � ��������� ������ �������� ���� � �������, �������� = " .. Lsdv)	
print ("�������� �� ������� ������� ���� = � " .. Nom_mat_puli .. " " .. vyvod_name_materiala(Nom_mat_puli))
print ("����� �������� (��������)= " .. t*1000000)
print ("���������� �������,  ��������=" .. delta_t)
print ("������� ���� �� = " .. Epuli)
print ("������� ������������ �� = " .. EC)
print ("��� �����(%)= " .. KPD )
print ("��������� �������� ����, �/� = " .. Vel0)
print ("�������� ���� �� ������ �� �������, �/�= " .. Vel )
print ("������������ ��������, ������� ���� ����������, �/� = " .. Vmax )
print ("��� ������ � ������������� �������� � ����: " .. File_name .. " V = " .. Vel .. ".txt")
print ("��������� ��������� " .. date())


----------------------------------------------------------------------------------------------------
-- ���������� �� � ����
----------------------------------------------------------------------------------------------------
handle = openfile(File_name .. " V = " .. Vel .. ".txt", "a")-- ������� ���� � - ����� ���������� � ����� ����� w - �������� ������ �� ��� ���� ����� ���

write (handle,"--------------------------------------------------------------------------------\n")
write (handle,"������ ��������� " .. Start_date,"\n")
i=1
repeat
write (handle,"----------------------------------------------------","\n")
write (handle,"������� �= " .. i,"\n")
write (handle,"������� ������������, ����������= " .. C[i],"\n")
write (handle,"���������� �� ������������, ����� = " .. U[i],"\n")
write (handle,"������������� �����, �� = "..R[i],"\n")
write (handle,"������� �������������, �� = " .. Rv[i],"\n")
write (handle,"������������� �������, O� = "..Rkat[i],"\n")
write (handle,"���������� ������ � ������� = "..N[i],"\n")
write (handle,"������� ����������� ������� �������, �������� = " .. Dpr[i],"\n")
write (handle,"����� ������� � �������, ���� = "..DLprovoda[i],"\n")
write (handle,"����� �������, �������� = " .. Lkat[i],"\n")
write (handle,"������� ������� �������, �������� = " .. Dkat[i],"\n")
write (handle,"���������� ����� ��������� �������, ��������  = " ..  Lmezdu_kat[i],"\n")
write (handle,"�� ����� ���������� �� ���������� ��������� ���� ���������� �������� , ��������  = " ..  Lvkl[i],"\n")
write (handle,"��������� ������� �������� ������� (������� �������� � �������� � �������� ������, ��������  = " ..  Tiz[i],"\n")
write (handle,"----------------------------------------------------","\n")
	i=i+1
until N_kat<i  
write (handle,"----------------------------------------------------","\n\n\n")
write (handle,"������� �������� ��������������, �������� = " .. Lmag,"\n")
write (handle,"�������� �������� �������������� ������� = � " .. Nom_mat_magnitoprovoda .. " " .. vyvod_name_materiala(Nom_mat_magnitoprovoda),"\n")
write (handle,"������� ������� ������, �������� = " .. Dstvola,"\n")
write (handle,"����� ����, ����� = "..Mpuli*1000,"\n")
write (handle,"����� ����, �������� = " .. Lpuli,"\n")		
write (handle,"������� ����, �������� = " .. Dpuli,"\n")
write (handle,"����������, �� ������� � ��������� ������ �������� ���� � �������, �������� = " .. Lsdv,"\n")
write (handle,"�������� �� ������� ������� ���� = � " .. Nom_mat_puli .. " " .. vyvod_name_materiala(Nom_mat_puli),"\n")
write (handle,"����� �������� (��������)= " .. t*1000000,"\n")
write (handle,"���������� �������,  ��������=" .. delta_t,"\n")
write (handle,"������� ���� �� = " .. Epuli,"\n")
write (handle,"������� ������������ �� = " .. EC,"\n")
write (handle,"��� �����(%)= " .. KPD,"\n")
write (handle,"��������� �������� ����, �/� = " .. Vel0,"\n")
write (handle,"�������� ���� �� ������ �� �������, �/�= " .. Vel,"\n")
write (handle,"������������ ��������, ������� ���� ����������, �/� = " .. Vmax,"\n")
write (handle,"��������� ��������� " .. date(),"\n\n\n")
write (handle,"-------------------------------������������� ������---------------------------------\n")
i=1
repeat
	write (handle,"���� ����(�) ��� " .. i .. " ")
	i=i+1
until N_kat<i
write (handle,"���� �. �� ���� (�)     �������� (�/�)       ���������� �(��)     ����� (���)           \n")

for Scet=1,KC-1 do
	i=1
	repeat
		my_str=strsub(tostring(T_I[Scet+i*10000]), 1, 15)
		len_str= strlen (my_str)
		if len_str<21 then my_str=my_str .. strrep (" ", 21-len_str) end
		write (handle,my_str)
	i=i+1
	until N_kat<i


		my_str=strsub(tostring(T_F[Scet]), 1, 15)
		len_str= strlen (my_str)
		if len_str<21 then my_str=my_str .. strrep (" ", 21-len_str) end
		write (handle,my_str)


		my_str=strsub(tostring(T_Vel[Scet]), 1, 15)
		len_str= strlen (my_str)
		if len_str<21 then my_str=my_str .. strrep (" ", 21-len_str) end
		write (handle,my_str)


		my_str=strsub(tostring(T_x[Scet]), 1, 15)
		len_str= strlen (my_str)
		if len_str<21 then my_str=my_str .. strrep (" ", 21-len_str) end
		write (handle,my_str)


		my_str=strsub(tostring(T_t[Scet]), 1, 15)
		len_str= strlen (my_str)
		if len_str<21 then my_str=my_str .. strrep (" ", 21-len_str) end
		write (handle,my_str)


	write (handle,"\n")
end

closefile(handle)

-- ������� ������������� �����
remove ("temp.fem")
remove ("temp.ans")

