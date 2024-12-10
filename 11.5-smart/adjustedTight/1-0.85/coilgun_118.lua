-- ������ ��� ��������� FEMM 4.2 
--------------------------------------------------------------------------------
---- ������ 117, 29 ����� 2010 -- 
--------------------------------------------------------------------------------
-- ������ ��������� ������ �� ���������� �����
--------------------------------------------------------------------------------

setcompatibilitymode(1)          -- ������������� � ������� 4.2

Vers = 116

File_name=prompt ("������� ��� ����� �����, ��� ���������� .txt") 

handle = openfile(File_name .. ".txt","r")
pustaja_stroka = read(handle, "*l") -- ������ ���������� ������ 4 ��
pustaja_stroka = read(handle, "*l")
pustaja_stroka = read(handle, "*l")
pustaja_stroka = read(handle, "*l")

C = read(handle, "*n", "*l") 	-- ������� ������������, ����������		
U = read(handle, "*n", "*l")	-- ���������� �� ������������, ����� 
Rsw = read(handle, "*n", "*l")	-- ������������� �����, �� 
Dpr = read(handle, "*n", "*l")	-- ������� ����������� ������� �������, ��������
TruDpr = Dpr

Lkat = read(handle, "*n", "*l")	-- ����� ������� (�� �������� ������ �������� �����. ������� �������), ��������		
-- CoilsAmount = read(handle, "*n", "*l") 		
Dkat = read(handle, "*n", "*l") 	
CoilsAmount = Dkat	
Lmag = read(handle, "*n", "*l")	-- ������� ����� �������� ��������������, �� ����� ��������� �������, ���� ���� �� ��� ���, ��������
LmagY= read(handle, "*n", "*l")	-- ������� ������ �������� ��������������, ���� 0 �� ����� ������.
Kark = read(handle, "*n", "*l")	-- ������� ������� �������

Kmot = read(handle, "*n", "*l")	-- ��������� ������� (0,7-0,95) ��� ���������� ������

Lpuli  = read(handle, "*n", "*l")	-- ����� ����, ��������		
Dpuli = read(handle, "*n", "*l")	-- ������� ����, ��������
Lotv = read(handle, "*n", "*l")		-- ������� ��������� � ����, �������� 
Dotv = read(handle, "*n", "*l")		-- ������� ��������� � ����, �������� (0 - ���� ��� ���������)

Nagr = read(handle, "*n", "*l")		-- ����� �������������� �������� ��� ��������, �����

Lsdv = read(handle, "*n", "*l")		-- ����������, �� ������� � ��������� ������ �������� ���� � ������� ��� ��������� �� ������� � �������, ��������

Dstvola = read(handle, "*n", "*l")	-- ������� ������� ������ (�� �������� ������ �������� ����), ��������
Vel0 = read(handle, "*n", "*l")		-- ��������� �������� ����, �/� (������ 0 ����� �����-�� ��������� ��������, ����� ����� �� ����� �����)
delta_t = read(handle, "*n", "*l")	-- ���������� �������, ��� 
-- Dkat = ((CoilsAmount*2*Dpr)+Dstvola) 	-- ������� ������� �������, ��������


mode = read(handle, "*n", "*l")	-- mode 
Vykls = read(handle, "*n", "*l")	-- mode 
Rdsc = read(handle, "*n", "*l")	-- mode 
Vykl = Vykls - Lsdv

closefile(handle)
--------------------------------------------------------------------------------

kRC = 140      -- ���������� ��������� RC ��� ��������������� ������������������ �����������, ��*���
Rcc = (kRC/C)  -- ���������� ������������� ������������
Rv = Rsw+Rcc     -- ������������� ����� + ���������� ������������� ������������, ��

Vol = 3                -- ��������� ���������� ������������ ������ ������ (������������� �������� �� 3 �� 5)
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

mi_addmaterial("Cu",1,1,"","","",58,"","","",3,"","",1,Dpr)	-- ��������� �������� ������ ������ ��������� Dpr ������������� 58

mi_addcircprop("katushka",0,0,1)				-- ��������� ������� 

Name_mat="Iron"

mi_addmaterial(Name_mat,"","","","","",0)        -- ��������� ������� ������� ��������� "������ �����"
     mi_addbhpoint(Name_mat,0,0)
     mi_addbhpoint(Name_mat,0.0001,50)
     mi_addbhpoint(Name_mat,0.001,100)
     mi_addbhpoint(Name_mat,0.01,150)
     mi_addbhpoint(Name_mat,0.015,175)
     mi_addbhpoint(Name_mat,0.0253,200)
     mi_addbhpoint(Name_mat,0.15,300)
     mi_addbhpoint(Name_mat,0.5031,400)
     mi_addbhpoint(Name_mat,1.0059,500)
     mi_addbhpoint(Name_mat,1.3706,700)
     mi_addbhpoint(Name_mat,1.4588,900)
     mi_addbhpoint(Name_mat,1.51,1200)
     mi_addbhpoint(Name_mat,1.55,1600)
     mi_addbhpoint(Name_mat,1.58,2000)
     mi_addbhpoint(Name_mat,1.62,2700)
     mi_addbhpoint(Name_mat,1.77,10000)
     mi_addbhpoint(Name_mat,1.84,20000)
     mi_addbhpoint(Name_mat,1.93,42000)
     mi_addbhpoint(Name_mat,2.01,75000)
     mi_addbhpoint(Name_mat,2.10,123300)
     mi_addbhpoint(Name_mat,2.25,207000)
     mi_addbhpoint(Name_mat,2.439,350000)
     mi_addbhpoint(Name_mat,3.13,900000)
     mi_addbhpoint(Name_mat,7.65,4500000)
     mi_addbhpoint(Name_mat,13.3,9000000)
     mi_addbhpoint(Name_mat,22.09,16000000)

--------------------------------------------------------------------------------
-- ����������� �������
--------------------------------------------------------------------------------


--������� ������������ � Vol ��� ������� ��� �������
mi_addnode(0,(Lkat+Lmag)*-Vol) 				-- ������ �����
mi_addnode(0,(Lkat+Lmag)*Vol)				-- ������ �����
mi_addsegment(0,(Lkat+Lmag)*-Vol,0,(Lkat+Lmag)*Vol)		-- ������ �����
mi_addarc(0,(Lkat+Lmag)*-5,0,(Lkat+Lmag)*Vol,180,max_segm)	-- ������ ����

mi_addblocklabel((Lkat+Lmag)*0.7*Vol,0)				-- ��������� ����	
mi_clearselected()						-- �������� ��� 
mi_selectlabel((Lkat+Lmag)*0.7*Vol,0)				-- �������� ����� �����
mi_setblockprop("Air", 1, "", "", "",0) 			-- ������������� �������� ����� � ����� Air � ������� ����� 0

mi_zoomnatural()	-- ������������� ��� ��� ��� �� ���� ����� �� ���� �����

-------------------------------------------------------------------------- ������� ����
if Dstvola < Dpuli then Dstvola = Dpuli+0.1 end -- ������ �� ������ 

if Lotv>(Lpuli-0.5) then Lotv = Lpuli - 0.5 end
if Lotv<0 then Lotv = 0 end
if Dotv>(Dpuli-0.5) then Dotv = Dpuli - 0.5 end
if Dotv<0 then Dotv = 0 end

-- ���� ����� ���� ����� �������� ������ ���
if Lpuli==Dpuli then 

	mi_addnode(0,Lkat/2-Lsdv)
	mi_addnode(0,Lkat/2+Lpuli-Lsdv)

	mi_clearselected()
	mi_selectnode (0,Lkat/2-Lsdv)
	mi_selectnode (0,Lkat/2+Lpuli-Lsdv)
	mi_setnodeprop("",1)
	mi_addarc(0,Lkat/2-Lsdv,0,Lkat/2+Lpuli-Lsdv,180,5)


else	-- ����� ������ �������

	mi_addnode(0,Lkat/2-Lsdv)
	mi_addnode(Dpuli/2,Lkat/2-Lsdv)
	mi_addnode(Dpuli/2,Lkat/2+Lpuli-Lsdv)
	


        -- ����� ��� ��������� � ����
        if Dotv>0 then 
	 mi_addnode(0,Lkat/2-Lsdv+Lpuli-Lotv) -- ����� ������ �� ������� �����
	 mi_addnode(Dotv/2,Lkat/2-Lsdv+Lpuli-Lotv) -- ����� ������ ����
	 mi_addnode(Dotv/2,Lkat/2+Lpuli-Lsdv) -- ����� �� ������� ����
	else
	 mi_addnode(0,Lkat/2+Lpuli-Lsdv)
        end

	mi_clearselected()

	mi_selectnode(0,Lkat/2-Lsdv)
	mi_selectnode(Dpuli/2,Lkat/2-Lsdv) 
	mi_selectnode(Dpuli/2,Lkat/2+Lpuli-Lsdv)
	
 	
	if Dotv>0 then
	 mi_selectnode(0,Lkat/2-Lsdv+Lpuli-Lotv)
	 mi_selectnode(Dotv/2,Lkat/2-Lsdv+Lpuli-Lotv)
	 mi_selectnode(Dotv/2,Lkat/2+Lpuli-Lsdv)
	else
	 mi_selectnode(0,Lkat/2+Lpuli-Lsdv)
 	end
	
	mi_setnodeprop("",1)

	mi_addsegment(Dpuli/2,Lkat/2-Lsdv,Dpuli/2,Lkat/2+Lpuli-Lsdv) -- ������� ����� �����

 if Dotv>0 then mi_addsegment(Dpuli/2,Lkat/2+Lpuli-Lsdv,Dotv/2,Lkat/2+Lpuli-Lsdv) -- ������ �����
 else 	mi_addsegment(Dpuli/2,Lkat/2+Lpuli-Lsdv,0,Lkat/2+Lpuli-Lsdv) end -- ������ �����
 if Dotv>0 then  mi_addsegment(Dotv/2,Lkat/2+Lpuli-Lsdv,Dotv/2,Lkat/2-Lsdv+Lpuli-Lotv) -- ������ ���������
        mi_addsegment(Dotv/2,Lkat/2-Lsdv+Lpuli-Lotv,0,Lkat/2-Lsdv+Lpuli-Lotv) -- ��� ���������
        mi_addsegment(0,Lkat/2-Lsdv+Lpuli-Lotv,0,Lkat/2-Lsdv) -- ������ ����� ����
 else	mi_addsegment(0,Lkat/2+Lpuli-Lsdv,0,Lkat/2-Lsdv) end -- ������ ����� ����
	mi_addsegment(0,Lkat/2-Lsdv,Dpuli/2,Lkat/2-Lsdv) -- �������� ����� 
end

mi_addblocklabel(Dpuli/4,Lkat/2+Lpuli/2-Lotv/2-Lsdv)
mi_clearselected()
mi_selectlabel(Dpuli/4,Lkat/2+Lpuli/2-Lotv/2-Lsdv)
mi_setblockprop(Name_mat, 1, Proj_meshsize, "", "",1)			-- ����� ����� 1


------------------------------------------------------------------------- ������� �������

if (Kark <= 0) then Kark = 0.5 end


mi_addnode(Dstvola/2,Lkat/2)			-- ���������
mi_addnode(Dstvola/2,-Lkat/2)			-- ���������
mi_addnode(Dkat/2,Lkat/2)				-- ������� ��������� �����
mi_addnode(Dkat/2,-Lkat/2)				-- ������� �������� �����

mi_addnode(Kark+Dstvola/2,-Kark+Lkat/2)			-- ���������
mi_addnode(Kark+Dstvola/2,Kark-Lkat/2)			-- ���������
mi_addnode(-Kark+Dkat/2,-Kark+Lkat/2)				-- ������� ��������� �����
mi_addnode(-Kark+Dkat/2,Kark-Lkat/2)				-- ������� �������� �����

mi_addsegment(Dstvola/2,-Lkat/2,Dstvola/2,Lkat/2)
mi_addsegment(Dstvola/2,Lkat/2,Dkat/2,Lkat/2)
mi_addsegment(Dkat/2,Lkat/2,Dkat/2,-Lkat/2)
mi_addsegment(Dkat/2,-Lkat/2,Dstvola/2,-Lkat/2)

mi_addsegment(Kark+Dstvola/2,Kark-Lkat/2,Kark+Dstvola/2,-Kark+Lkat/2)
mi_addsegment(Kark+Dstvola/2,-Kark+Lkat/2,-Kark+Dkat/2,-Kark+Lkat/2)
mi_addsegment(-Kark+Dkat/2,-Kark+Lkat/2,-Kark+Dkat/2,Kark-Lkat/2)
mi_addsegment(-Kark+Dkat/2,Kark-Lkat/2,Kark+Dstvola/2,Kark-Lkat/2)

mi_clearselected()
mi_selectnode(Kark+Dstvola/2,-Kark+Lkat/2)			-- ���������
mi_selectnode(Kark+Dstvola/2,Kark-Lkat/2)		-- ���������
mi_selectnode(-Kark+Dkat/2,-Kark+Lkat/2)				
mi_selectnode(-Kark+Dkat/2,Kark-Lkat/2)				
mi_setnodeprop("",2)


mi_addblocklabel(Dstvola/2+(Dkat/2-Dstvola/2)/2,0)
mi_clearselected()
mi_selectlabel(Dstvola/2+(Dkat/2-Dstvola/2)/2,0)
mi_setblockprop("Cu", 0, Coil_meshsize, "katushka", "",2) -- ����� ����� 2


mi_addblocklabel(Kark/2+Dstvola/2,-Kark+Lkat/4)		-- ��������� ����	
mi_clearselected()					-- �������� ��� 
mi_selectlabel(Kark/2+Dstvola/2,-Kark+Lkat/4)		-- �������� ����� �����
mi_setblockprop("Air", 1, Coil_meshsize, "", "",4) 	-- ������������� �������� ����� � ����� Air � ������� ����� 4



-------------------------------------------------------------------------- ������� ������� �������������
if (Lmag > 0) then 

        if (LmagY <=0) then 
         LmagY = Lmag 
        end
	mi_addnode(Dstvola/2,Lkat/2+LmagY)
	mi_addnode(Dkat/2+Lmag,Lkat/2+LmagY)
	mi_addnode(Dkat/2+Lmag,-Lkat/2-LmagY)	
	mi_addnode(Dstvola/2,-Lkat/2-LmagY)
	
	mi_addsegment(Dstvola/2,Lkat/2,Dstvola/2,Lkat/2+LmagY)
	mi_addsegment(Dstvola/2,Lkat/2+LmagY,Dkat/2+Lmag,Lkat/2+LmagY)
	mi_addsegment(Dkat/2+Lmag,Lkat/2+LmagY,Dkat/2+Lmag,-Lkat/2-LmagY)

	mi_addsegment(Dkat/2+Lmag,-Lkat/2-LmagY,Dstvola/2,-Lkat/2-LmagY)
	mi_addsegment(Dstvola/2,-Lkat/2-LmagY,Dstvola/2,-Lkat/2)

	mi_addblocklabel(Dkat/2+Lmag/2,0)
	mi_clearselected()
	mi_selectlabel(Dkat/2+Lmag/2,0)
	mi_setblockprop(Name_mat, 1, "", "", "",3)		-- ����� ����� 3

end

mi_clearselected()


--------------------------------------------------------------------------------
-- ������� �� - ����, �����
--------------------------------------------------------------------------------
C = C/1000000
Tiz = sqrt(Dpr)*0.07
Dpriz = Dpr+Tiz -- ������� ������� � ��������
Dpr = Dpr/1000
Dpriz = Dpriz/1000		
Lpuli  = Lpuli/1000
Dpuli = Dpuli/1000
Lotv = Lotv/1000
Dotv = Dotv/1000
Dstvola = Dstvola/1000				
Lkat = Lkat/1000
Dkat = Dkat/1000
Lsdv = Lsdv/1000
Lmag = Lmag/1000
LmagY = LmagY/1000
Nagr = Nagr/1000
--------------------------------------------------------------------------------

-- ����������� � ��������� �������������
	
mi_analyze(1)				-- ����������� (������� ���� ������� "1") 0 - ����� ����� ���� � ����� �������� ��������
mi_loadsolution()			-- ��������� ���� ��������� ���� ����������

mo_groupselectblock(2)
Skat = mo_blockintegral(5) 		-- ������� ������� �������, ����^2 
Vkat = mo_blockintegral(10)		-- ����� �������, ����^3
mo_clearblock()
mo_groupselectblock(1)
Vpuli = mo_blockintegral(10)		-- ����� ����, ����^3	
mo_clearblock()			


Mpuli=ro*Vpuli + Nagr			-- ����� ���� ���� ��������, ��

if ( Kmot < 1 ) then
 N=Kmot*Skat/(Dpriz*Dpriz)		-- ���������� ������ � ������� ���������
else N=Kmot end                         -- ��� ���� ������ 

DLprovoda=N * 2 * pi * (Dkat + Dstvola)/4   -- ����� ����������� ������� ���������, �

Rkat=sigma*DLprovoda/(pi*(Dpr/2)^2)	-- ������������� ����� ����������� ������� �������, ��
R=Rv+Rkat				-- ������ ������������� �������

--������������� ����� ������, � ���� ���� 100 � ��� ������ �������������

mi_clearselected()
mi_selectlabel(Dstvola*1000/2+(Dkat/2-Dstvola/2)*1000/2,0) 
mi_setblockprop("Cu", 0, Coil_meshsize, "katushka", "",2,N) -- ��������� �������� - ����� ������
mi_clearselected()
mi_modifycircprop("katushka",1,100)


-- ����������� � ��������� �������������

mi_analyze(1)				-- ����������� (������� ���� ������� "1") 	
mo_reload()				-- ������������� ��������� ���� ����������			
current_re,current_im,volts_re,volts_im,flux_re,flux_im=mo_getcircuitproperties("katushka") -- �������� ������ � �������


L=flux_re/current_re			-- ��������� �������������, �����

--------------------------------------------------------------------------------
-- ������ ���������
--------------------------------------------------------------------------------

dt = delta_t/1000000 -- ������� ���������� ������� � ������� 
x=0		-- ��������� ������� ����
I0=0.01         -- ���������� ����� �������� ����  I0=0.01
t=0		-- ����� �����
Vel=Vel0
Vmax=Vel
Uc = U
I=I0		-- ��������� �������� ����
Force = 0
FA=0
Fii = 0
Fix = 0
KC=1		-- ������� ������, ��� ������ � ����
T_I={}		-- ������� ������ (������� ��� � �������� � Lua)
T_F={}		
T_Vel={}	
T_x={}		
T_t={}
T_U={}

repeat  	------------------------------------------------------------ �������� ����
	
	t = t+dt
	--- ������������ dFi/dI ��� I � ����
            mi_modifycircprop("katushka",1,I)	-- ������������� ��� 
            mi_analyze(1)			-- ����������� (������� ���� ������� "1") 0 - ����� ����� ���� � ����� �������� ��������	
            mo_reload()				-- ������������� ��������� ���� ����������
            mo_groupselectblock(1)

	Force = mo_blockintegral(19)		-- ���� ����������� �� ����, ������	
	Force=Force*-1				-- ������ "-" �� �� ��������� (����������� ���� � ������� ���������� ����������)
	FA=FA+Force*dt		
	current_re,current_im,volts_re,volts_im,flux_re,flux_im=mo_getcircuitproperties("katushka") -- �������� ������ � �������
	Fi0=flux_re			            -- ��������� �����
        mi_modifycircprop("katushka",1,I*1.001)	-- ������������� ���, ����������� �� 1.001
        mi_analyze(1)				-- ����������� (������� ���� ������� "1") 0 - ����� ����� ���� � ����� �������� ��������	
        mo_reload()				-- ������������� ��������� ���� ����������			
	current_re,current_im,volts_re,volts_im,flux_re,flux_im=mo_getcircuitproperties("katushka") -- �������� ������ � �������

	Fi1=flux_re			            -- ��������� ����� ��� I=I+0.001*I, dI=0.001*I 
	Fii=(Fi1-Fi0)/(0.001*I)                              -- ������������ dFi/dI

	apuli = Force / Mpuli			-- ��������� ����, ����/�������^2 
--	dx = Vel*dt+apuli*dt*dt/2		-- ���������� ����������, ����
        dx = Vel*dt                             -- ���������� ����������, ���� (�����������)
	x = x+dx				-- ����� ������� ����
	Vel = Vel+apuli*dt			-- �������� ����� ����������, ����/�������
	if Vmax<Vel then Vmax=Vel end
	mi_selectgroup(1)			-- �������� ����
	mi_movetranslate(0,-dx*1000)		-- ���������� � �� dx


	mi_modifycircprop("katushka",1,I)	-- ������������� ��� 
        mi_analyze(1)				-- ����������� (������� ���� ������� "1") 0 - ����� ����� ���� � ����� �������� ��������	
        mo_reload()				-- ������������� ��������� ���� ����������
        mo_groupselectblock(1)



        current_re,current_im,volts_re,volts_im,flux_re,flux_im=mo_getcircuitproperties("katushka") -- �������� ������ � �������
	Fi0=flux_re			        -- ��������� �����
        mi_modifycircprop("katushka",1,I*1.001)	-- ������������� ���, ����������� �� 1.001
        mi_analyze(1)				-- ����������� (������� ���� ������� "1") 0 - ����� ����� ���� � ����� �������� ��������	
        mo_reload()				-- ������������� ��������� ���� ����������			
	current_re,current_im,volts_re,volts_im,flux_re,flux_im=mo_getcircuitproperties("katushka") -- �������� ������ � �������

	Fi1=flux_re			            -- ��������� ����� ��� I=I+0.001*I, dI=0.001*I 
	Fif=(Fi1-Fi0)/(0.001*I)                              -- ������������ dFi/dI

	--- ������������ dL
           
	dL=Fif-Fii

	------- ����������� ��� � ���������� �� ������������

	if Uc<=0 then I=I+dt*(Uc-I*(R+Rdsc)-I*dL/dt)/Fii				
	else I=I+dt*(Uc-I*R-I*dL/dt)/Fii end

	Uc = Uc-dt*I/C

	if Uc< 0 then  Uc=0 end   --���� ����� ����������� ����

	if x > Vykl/1000 then -- ��������� ��� 
		Uc=0
	end

        -- if (mode >0) and (Vel<Vmax) then I=0 end
	
	if x > (Lpuli+Lkat-Lsdv) and Force >-1  then I=0 end -- ���� �������� �� ������� ������� � ���� ����� ���������
			
	if x < 0 then I=0 end -- ���� �������� �����	

	T_I[KC]=I		-- ���������� ������ � ������

	T_F[KC]=Force		

	T_Vel[KC]=Vel		

	T_x[KC]=x*1000		

	T_t[KC]=t*1000000

	T_U[KC]=Uc

	KC=KC+1

until (I <= 0) or (Vel < 0 )  -- ��������� ������, ���� �� ����� ���� 

FA=FA/(dt*KC)

Epuli = (Mpuli*Vel^2)/2 
Epuli0 = (Mpuli*Vel0^2)/2
EC0= (C*U^2)/2
EC = (C*Uc^2)/2
dEpuli = Epuli-Epuli0
dEC = EC0-EC

KPD = dEpuli*100/dEC

showconsole()		-- ���������� ���� ������ ������������� ������
clearconsole()
print ("-----------------------------------")						
print ("���������� ������ �������� � ����: " .. File_name .. " V: " .. Vel .. " Vmax: " .. Vmax .. " KPD: " .. KPD ..  ".txt")
-- print ("������ �������� � " .. date())


----------------------------------------------------------------------------------------------------
-- ���������� �� � ����
----------------------------------------------------------------------------------------------------
handle = openfile(C*1000000 .. "-" .. TruDpr .. "-" .. CoilsAmount .. "-" .. Lkat*1000  .. "-" .. Lsdv*1000 .. "-".. Vykls .. "-".. Rdsc .. " V-" .. Vel .. " KPD-" .. KPD .. " Vm-" .. Vmax .. "E-" .. dEpuli ..  ".txt", "a")-- ������� ���� � - ����� ���������� � ����� ����� w - �������� ������ �� ��� ���� ����� ���

write (handle,"--------------------------------------------------------------------------------\n")
write (handle,"������ ������� " .. Start_date,"\n")
write (handle,"������ ������� " .. Vers,"\n")
write (handle,"������� ������������, ���������� = " .. C*1000000,"\n")
write (handle,"��������� ����������, ����� = " .. U,"\n")
write (handle,"����� �������������, �� = "..R,"\n")
write (handle,"������� �������������, �� = " .. Rv,"\n")
write (handle,"������������� �������, �� = "..Rkat,"\n")
write (handle,"���������� ������ = "..N,"\n")
write (handle,"  ������� �������, �� = " .. Dpr*1000,"\n")
write (handle,"����� ����� �������, � = "..DLprovoda,"\n")
write (handle,"����� �������, �� = " .. Lkat*1000,"\n")
write (handle,"������� ������� �������, �� = " .. Dkat*1000,"\n")
write (handle,"������������� ������� � ��������� �������, ���������� = "..L*1000000,"\n")
write (handle,"������� ����� �������� ��������������, �� = " .. Lmag*1000,"\n")
write (handle,"������� ������� �������� ��������������, �� = " .. LmagY*1000,"\n")
write (handle,"���������� ������� �������, �� = " .. Dstvola*1000,"\n")
write (handle,"����� ���� ��� ��������, � = "..(Mpuli-Nagr)*1000,"\n")
write (handle,"����� ����, �� = " .. Lpuli*1000,"\n")		
write (handle,"������� ����, �� = " .. Dpuli*1000,"\n")
write (handle,"������� ��������� � ����, �� = " .. Lotv*1000,"\n")		
write (handle,"������� ���������, �� = " .. Dotv*1000,"\n")
write (handle,"����� ��������, � = " .. Nagr*1000,"\n")
write (handle,"����� ���� ������ � ���������, � = "..Mpuli*1000,"\n")
write (handle,"��������� ������� ���� ������ �������, �� = " .. Lsdv*1000,"\n")
write (handle,"����� �����, ����������� = " .. t*1000000,"\n")
write (handle,"�������� �������,  ����������� =" .. delta_t,"\n")
write (handle,"----- ������� ---------------------------------------------\n")
write (handle,"  ������� ���� ���������, �� = " .. Epuli0,"\n")
write (handle,"  ������� ����  ��������, �� = " .. Epuli,"\n")
write (handle,"  ���������� ������� ����, �� = " .. dEpuli,"\n")
write (handle,"  ������� ������������ ���������, �� = " .. EC0,"\n")
write (handle,"  ������� ������������  ��������, �� = " .. EC,"\n")
write (handle,"  ������ ������� ������������, �� = " .. dEC,"\n")
write (handle,"  ���, % = " .. KPD,"\n")
write (handle,"------ �������� -------------------------------------------\n")
write (handle,"��������� �������� ����, �/� = " .. Vel0,"\n")
write (handle,"�������� �������� ����, �/� = " .. Vel,"\n")
write (handle,"����������� �������� ����, (� ������), �/� = " .. Vmax,"\n")
write (handle,"������� ����, � = " .. FA,"\n")
write (handle,"����� ������� " .. date(),"\n")
write (handle,"------------------------------- Data of simulation -------------------------------\n")
write (handle,"���� ���� (�)		���������� (�)            ���� (�)	          �������� (�/�)	 	������� x (��) 	����� (���) \n")

for Scet=1,KC-1 do
	write (handle,T_I[Scet],"\t",T_U[Scet],"\t",T_F[Scet],"\t",T_Vel[Scet],"\t",T_x[Scet],"\t",T_t[Scet],"\t","\n")
end
write (handle,"-- Data for export to Excel sheet --\n")
write (handle,"���� ���� (�)\n")
for Scet=1,KC-1 do
	data1,data2=gsub(T_I[Scet], "%.", ",")
	write (handle,data1,"\n")
end
write (handle,"���������� (�)\n")
for Scet=1,KC-1 do
	data1,data2=gsub(T_U[Scet], "%.", ",")
	write (handle,data1,"\n")
end
write (handle,"���� (�)\n")
for Scet=1,KC-1 do
	data1,data2=gsub(T_F[Scet], "%.", ",")
	write (handle,data1,"\n")
end
write (handle,"�������� (�/�)\n")
for Scet=1,KC-1 do
	data1,data2=gsub(T_Vel[Scet], "%.", ",")
	write (handle,data1,"\n")
end
write (handle,"������� x (��)\n")
for Scet=1,KC-1 do
	data1,data2=gsub(T_x[Scet], "%.", ",")
	write (handle,data1,"\n")
end
write (handle,"����� (���)\n")
for Scet=1,KC-1 do
	data1,data2=gsub(T_t[Scet], "%.", ",")
	write (handle,data1,"\n")
end
closefile(handle)

-- ������� ������������� �����
remove ("temp.fem")
remove ("temp.ans")

