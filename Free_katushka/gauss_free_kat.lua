-- ��� lua ������ ��� FEMM 4.0
--------------------------------------------------------------------------------
---- ������ 2.4.04 �� 22 ������ 2006 �. 
--------------------------------------------------------------------------------
-- ������ �� ����� ��������� ���������
--------------------------------------------------------------------------------
File_name=prompt ("������� ��� ����� � ������� �����, ��� ���������� .txt") 

handle = openfile(File_name .. ".txt","r")
pustaja_stroka = read(handle, "*l") -- ������ ���������� ������ 4 ��
pustaja_stroka = read(handle, "*l")
pustaja_stroka = read(handle, "*l")
pustaja_stroka = read(handle, "*l")

C = read(handle, "*n", "*l") 	-- ������� ������������, ����������		
U = read(handle, "*n", "*l")	-- ���������� �� ������������, ����� 


Nom_mat_puli = read(handle, "*n", "*l")	-- �������� �� �������� ������� ���� ��. �������
Lpuli  = read(handle, "*n", "*l")	-- ����� ����, ��������		
Dpuli = read(handle, "*n", "*l")	-- ������� ����, ��������
Lsdv = read(handle, "*n", "*l")		-- ����������, �� ������� � ��������� ������ �������� ���� � ������� ��� ��������� �� ������� � �������, ��������

-- Dstvola = read(handle, "*n", "*l")	-- ������� ������� ������ (�� �������� ������ �������� ����), ��������
Vel0 = read(handle, "*n", "*l")		-- ��������� �������� ����, �/� (������ 0 ����� �����-�� ��������� ��������, ����� ����� �� ����� �����)
delta_t = read(handle, "*n", "*l")	-- ���������� �������, ��� 

Nom_mat_magnitoprovoda = read(handle, "*n", "*l")	-- �������� �� �������� ������ ������������� ������� ��. �������
Dpr = read(handle, "*n", "*l")	-- ������� ����������� ������� �������, ��������
Tiz = read(handle, "*n", "*l")	-- ��������� ������� �������� ������� (������� �������� � �������� � �������� ������), ��


Rkat={}
Zkat={}
i=0
repeat
	Rkat[i] = read(handle, "*n", "*l")	-- ���������� r, ��������
	Zkat[i] = read(handle, "*n", "*l")	-- ���������� z, ��������
--	print (Rkat[i],Zkat[i])
	
	i=i+1
until (Rkat[i-1]==0) and (Zkat[i-1]==0) 
N_per =i-2

Rmag={}
Zmag={}
i=0
repeat
	Rmag[i] = read(handle, "*n", "*l")	-- ���������� r ��������������, ��������
	Zmag[i] = read(handle, "*n", "*l")	-- ���������� z ��������������, ��������
	i=i+1
until (Rmag[i-1]==0) and (Zmag[i-1]==0) 
N_per_m =i-2


closefile(handle)
--------------------------------------------------------------------------------

kRC = 140      -- ���������� ��������� RC ��� ��������������� ������������������ �����������, ��*���
Rcc = (kRC/C)  -- ���������� ������������� ������������
Rv = 0.35+Rcc     -- ������������� ���������� �������� + ������������� ��������� + ���������� ������������� ������������, ��

Vol =30                 -- ��������� ���������� ������������ ������ ������ (������������� �������� �� 3 �� 5)
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

mi_addmaterial("Cu",1,1,"","","",58,"","","",4,"","",1,Dpr)	-- ��������� �������� ������ ������ ��������� Dpr ������������� 58

mi_addcircprop("katushka",0,0,1)				-- ��������� ������� 

dofile ("func.lua")	-- ����������� ������� ��� ����������� ������� � ���					
vvod_materiala (Nom_mat_magnitoprovoda,"M")	-- ������ �������� �������������� ������� ��� ��� � � ����� ���������
Material_magnitoprovoda="M" .. Nom_mat_magnitoprovoda

vvod_materiala (Nom_mat_puli,"P")		---- ������ �������� ���� ������� ��� ��� � � ����� ���������
Material_puli="P" .. Nom_mat_puli	

--------------------------------------------------------------------------------
-- ����������� �������
--------------------------------------------------------------------------------

--������� ������������ � Vol ��� ������� ��� �������
mi_addnode(0,(Zkat[N_per])*(-Vol+1)) 				-- ������ �����
mi_addnode(0,(Zkat[N_per])*Vol)				-- ������ �����
mi_addsegment(0,(Zkat[N_per])*Vol,0,(Zkat[N_per])*(-Vol+1))		-- ������ �����
mi_addarc(0,(Zkat[N_per])*Vol,0,(Zkat[N_per])*(-Vol+1),180,max_segm)	-- ������ ����

mi_addblocklabel((Zkat[N_per])*0.7*-Vol,0)				-- ��������� ����	
mi_clearselected()						-- �������� ��� 
mi_selectlabel((Zkat[N_per])*0.7*-Vol,0)				-- �������� ����� �����
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
	mi_setnodeprop("",1)
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
	mi_setnodeprop("",1)

	mi_addsegment(Dpuli/2,-Lsdv,Dpuli/2,Lpuli-Lsdv)
	mi_addsegment(Dpuli/2,Lpuli-Lsdv,0,Lpuli-Lsdv)
	mi_addsegment(0,Lpuli-Lsdv,0,-Lsdv)
	mi_addsegment(0,-Lsdv,Dpuli/2,-Lsdv)

end
mi_addblocklabel(Dpuli/4,Lpuli/2-Lsdv)
mi_clearselected()
mi_selectlabel(Dpuli/4,Lpuli/2-Lsdv)
mi_setblockprop(Material_puli, 0, Proj_meshsize, "", "",1)			-- ����� ����� 1

------------------------------------------------------------------------- ������� �������

i=0
repeat
	mi_addnode(Rkat[i],Zkat[i])
	mi_clearselected()
	mi_selectnode(Rkat[i],Zkat[i])
	mi_setnodeprop("",2)
	i=i+1
until i>N_per 

i=0
repeat
	mi_addsegment(Rkat[i],Zkat[i],Rkat[i+1],Zkat[i+1])
	i=i+1
until i>=N_per
mi_addsegment(Rkat[0],Zkat[0],Rkat[N_per],Zkat[N_per])



mi_addblocklabel(Rkat[0]+0.001,Zkat[0]-0.001)
mi_clearselected()
mi_selectlabel(Rkat[0]+0.001,Zkat[0]-0.001)
mi_setblockprop("Cu", 0, Coil_meshsize, "katushka", "",2) -- ����� ����� 2


-------------------------------------------------------------------------- ������� ������� �������������
if (Nom_mat_magnitoprovoda > 0) and (N_per_m > 0) then 

	

i=0
repeat
	mi_addnode(Rmag[i],Zmag[i])
	mi_clearselected()
	mi_selectnode(Rmag[i],Zmag[i])
	mi_setnodeprop("",3)
	i=i+1
until i>N_per_m 

i=0
repeat
	mi_addsegment(Rmag[i],Zmag[i],Rmag[i+1],Zmag[i+1])
	i=i+1
until i>=N_per_m
--mi_addsegment(Rkat[0],Zkat[0],Rmag[0],Zmag[0])
--mi_addsegment(Rkat[N_per],Zkat[N_per],Rmag[N_per_m],Zmag[N_per_m])


mi_addblocklabel(Rmag[1]+0.001,Zmag[1]-0.001)
mi_clearselected()
mi_selectlabel(Rmag[1]+0.001,Zmag[1]-0.001)
mi_setblockprop(Material_magnitoprovoda, 0, Proj_meshsize, "", "",3)		-- ����� ����� 3

end

mi_clearselected()

--------------------------------------------------------------------------------
-- ������� �� - ����, �����
--------------------------------------------------------------------------------
C = C/1000000
Dpriz = Dpr+Tiz -- ������� ������� � ��������
Dpr = Dpr/1000
Dpriz = Dpriz/1000		
--Lpuli  = Lpuli/1000
--Dpuli = Dpuli/1000
--Lsdv = Lsdv/1000

--i=0
--repeat
	--Rkat[i]=Rkat[i]/1000
	--Zkat[i]=Zkat[i]/1000
	--i=i+1
--until i>N_per 

--i=0
--repeat
	--Rmag[i]=Rmag[i]/1000
	--Zmag[i]=Zmag[i]/1000
	--i=i+1
--until i>N_per_m 

--------------------------------------------------------------------------------

-- ����������� � ��������� �������������
	
mi_analyze(1)				-- ����������� (������� ���� ������� "1") 0 - ����� ����� ���� � ����� �������� ��������
mi_loadsolution()			-- ��������� ���� ��������� ���� ����������


mo_groupselectblock(1)
Vpuli = mo_blockintegral(10)		-- ����� ����, ����^3	
mo_clearblock()	
Mpuli=ro*Vpuli				-- ����� ����, ��



mo_groupselectblock(2)
Skat = mo_blockintegral(5) 		-- ������� ������� �������, ����^2 
Vkat = mo_blockintegral(10) 		-- ����� �������, ����^3 			


N=Skat*0.94/(Dpriz*Dpriz)		-- ���������� ������ � ������� ���������
DLprovoda=N*Vkat/Skat   -- ����� ����������� ������� ���������, �

Rkatushki=sigma*DLprovoda/(pi*(Dpr/2)^2)	-- ������������� ����� ����������� ������� �������, ��
R=Rv+Rkatushki				-- ������ ������������� �������


--������������� ����� ������, � ���� ���� 100 � ��� ������ �������������

mi_clearselected()
mi_selectlabel(Rkat[0]+0.001,Zkat[0]-0.001) 
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
I0=0.00000001   -- ���������� ����� �������� ����
t=0		-- ����� �����
Vel=Vel0
Vmax=Vel
Uc = U
I=I0		-- ��������� �������� ����
Force = 0
Fii = 0
Fix = 0
KC=1		-- ������� ������, ��� ������ � ����
T_I={}		-- ������� ������ (������� ��� � �������� � Lua)
T_F={}		
T_Vel={}	
T_x={}		
T_t={}
Pricina="Vel < 0"
repeat  	------------------------------------------------------------ �������� ����
	
	t = t+dt
	--- ������������ dFi/dI ��� I � ����
            mi_modifycircprop("katushka",1,I)	-- ������������� ��� 
            mi_analyze(1)			-- ����������� (������� ���� ������� "1") 0 - ����� ����� ���� � ����� �������� ��������	
            mo_reload()				-- ������������� ��������� ���� ����������
            mo_groupselectblock(1)

	Force = mo_blockintegral(19)		-- ���� ����������� �� ����, ������	
	Force=Force*-1				-- ������ "-" �� �� ��������� (����������� ���� � ������� ���������� ����������)
			
	current_re,current_im,volts_re,volts_im,flux_re,flux_im=mo_getcircuitproperties("katushka") -- �������� ������ � �������
	Fi0=flux_re			            -- ��������� �����
        mi_modifycircprop("katushka",1,I*1.001)	-- ������������� ���, ����������� �� 1.001
        mi_analyze(1)				-- ����������� (������� ���� ������� "1") 0 - ����� ����� ���� � ����� �������� ��������	
        mo_reload()				-- ������������� ��������� ���� ����������			
	current_re,current_im,volts_re,volts_im,flux_re,flux_im=mo_getcircuitproperties("katushka") -- �������� ������ � �������

	Fi1=flux_re			            -- ��������� ����� ��� I=I+0.001*I, dI=0.001*I 
	Fii=(Fi1-Fi0)/(0.001*I)                              -- ������������ dFi/dI

	apuli = Force / Mpuli			-- ��������� ����, ����/�������^2 
	dx = Vel*dt+apuli*dt*dt/2		-- ���������� ����������, ����
	x = x+dx				-- ����� ������� ����				
	Vel = Vel+apuli*dt			-- �������� ����� ����������, ����/�������
	if Vmax<Vel then Vmax=Vel end
	mi_selectgroup(1)			-- �������� ����
	mi_movetranslate(0,-dx*1000)		-- ���������� � �� dx

	--- ������������ dFi/dx ��� x
           
	Fix= Force/I
	------- ����������� ��� � ���������� �� ������������

	I=I+dt*(Uc-I*R-Fix*Vel)/Fii				

	Uc = Uc-dt*I/C

	if Uc< 0 then  
		Pricina="���������� �� ������������ = 0"
		break
	end   --���� ����� ����������� ����
	
	if x > (Lpuli-Zkat[N_per]-Lsdv)/1000 and Force >-1  then 

		Pricina="���� �������� �� ������� ������� � ���� ����� ���������"
		break
	end -- ���� �������� �� ������� ������� � ���� ����� ���������


	if x < 0 then 
		Pricina="���� �������� �����"
		break
	end -- ���� �������� �����

	if KC==2 then
	--

	end		

	T_I[KC]=I		-- ���������� ������ � ������

	T_F[KC]=Force		

	T_Vel[KC]=Vel		

	T_x[KC]=x*1000		

	T_t[KC]=t*1000000	

	KC=KC+1

until Vel < 0  -- ��������� ������

Epuli = (Mpuli*Vel^2)/2 - (Mpuli*Vel0^2)/2
EC= (C*U^2)/2
KPD = Epuli*100/EC

showconsole()							-- ���������� ���� ������ ������������� ������
clearconsole()
print ("-----------------------------------")						
print ("������ ��������� " .. Start_date)
print ("������� ��������� ��������: " .. Pricina)
print ("������� ������������, ����������= " .. C*1000000)
print ("���������� �� ������������, ����� = " .. U)
print ("������������� �����, �� = " .. R)
print ("������� �������������, �� = " .. Rv)
print ("������������� �������, O� = " .. Rkatushki)
print ("���������� ������ � ������� = " .. N)
print ("������� ����������� ������� �������, �������� = " .. Dpr*1000)
print ("����� ������� � �������, ���� = "..DLprovoda)
print ("������������� ������� � ����� � ��������� ���������, ����������= " .. L*1000000)
print ("�������� �������� �������������� ������� = � " .. Nom_mat_magnitoprovoda .. " " .. vyvod_name_materiala(Nom_mat_magnitoprovoda))
print ("����� ����, ����� = " .. Mpuli*1000)
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
write (handle,"��������� ��������� " .. Start_date,"\n")
write (handle,"--------------------------------------------------------------------------------\n\n\n")
write (handle,C*1000000 .. "	����������, ������� ������������\n")
write (handle,U .. "	�����, ���������� �� ������������\n\n")
write (handle,Nom_mat_puli .. "	�������� �� ������� ������� ���� - "  .. vyvod_name_materiala(Nom_mat_puli),"\n")
write (handle,Lpuli .. "	��, ����� ����\n")
write (handle,Dpuli .. "	��, ������� ����\n")
write (handle,Lsdv .. "	��, ����������, �� ������� � ��������� ������ �������� ���� � �������\n\n")
write (handle,Vel0 .. "	�/�, ��������� �������� ����\n\n")
write (handle,delta_t .. "	��������, ���������� �������\n\n")
write (handle,Nom_mat_magnitoprovoda .. "	�������� �� �������� ������ ������������� ������� - "  .. vyvod_name_materiala(Nom_mat_magnitoprovoda),"\n")
write (handle,Dpr*1000 .. "	��, ������� ����������� ������� �������\n")
write (handle,Tiz .. "	��, ��������� ������� �������� �������\n\n")

i=0
repeat
	write (handle,Rkat[i] .. "	��, ���������� r �������\n")
	write (handle,Zkat[i] .. "	��, ���������� z �������\n\n")
	i=i+1
until i>N_per 

write (handle,"0 - ����\n")
write (handle,"0 - ����\n\n")
i=0
repeat
	write (handle,Rmag[i] .. "	��, ���������� r ��������������	\n")
	write (handle,Zmag[i] .. "	��, ���������� z ��������������	\n\n")
	i=i+1
until i>N_per_m 
write (handle,"0 - ����\n")
write (handle,"0 - ����\n\n\n")

write (handle,"--------------------------------------------------------------------------------\n")
write (handle,"��������� ������ \n")
write (handle,"--------------------------------------------------------------------------------\n\n")

write (handle,"������� ��������� ��������: " .. Pricina,"\n")
write (handle,"������������� �����, �� = "..R,"\n")
write (handle,"������� �������������, �� = " .. Rv,"\n")
write (handle,"������������� �������, O� = "..Rkatushki,"\n")
write (handle,"���������� ������ � ������� = "..N,"\n")
write (handle,"����� ������� � �������, ���� = "..DLprovoda,"\n")
write (handle,"������������� ������� � ����� � ��������� ���������, ����������= "..L*1000000,"\n")
write (handle,"����� ����, ����� = "..Mpuli*1000,"\n")
write (handle,"����� �������� (��������)= " .. t*1000000,"\n")
write (handle,"������� ���� �� = " .. Epuli,"\n")
write (handle,"������� ������������ �� = " .. EC,"\n")
write (handle,"��� �����(%)= " .. KPD,"\n")
write (handle,"�������� ���� �� ������ �� �������, �/�= " .. Vel,"\n")
write (handle,"������������ ��������, ������� ���� ����������, �/� = " .. Vmax,"\n")
--write (handle,"��������� ��������� " .. date(),"\n")
write (handle,"\n\n\n")
write (handle,"-------------------------------������������� ������---------------------------------\n")
write (handle,"���� ���� (�)		���� �. �� ���� (�)	�������� (�/�)		���������� �(��) 	����� (���) \n")

for Scet=1,KC-1 do
	write (handle,T_I[Scet],"\t",T_F[Scet],"\t",T_Vel[Scet],"\t",T_x[Scet],"\t",T_t[Scet],"\t","\n")
end
write (handle,"-- ������������� ������ ��� �������� --\n")
write (handle,"���� ���� (�)\n")
for Scet=1,KC-1 do
	data1,data2=gsub(T_I[Scet], "%.", ",")
	write (handle,data1,"\n")
end
write (handle,"���� �. �� ���� (�)\n")
for Scet=1,KC-1 do
	data1,data2=gsub(T_F[Scet], "%.", ",")
	write (handle,data1,"\n")
end
write (handle,"�������� (�/�)\n")
for Scet=1,KC-1 do
	data1,data2=gsub(T_Vel[Scet], "%.", ",")
	write (handle,data1,"\n")
end
write (handle,"���������� �(��)\n")
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