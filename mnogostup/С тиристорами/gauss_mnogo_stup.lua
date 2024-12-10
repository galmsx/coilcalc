-- Это lua скрипт для FEMM 4.0
--------------------------------------------------------------------------------
---- Версия  от 23 мая 2006 г. 
--------------------------------------------------------------------------------
-- Читаем из файла начальные параметры
--------------------------------------------------------------------------------
File_name=prompt ("Введите имя файла с данными гауса, без расширения .txt") 

handle = openfile(File_name .. ".txt","r")
pustaja_stroka = read(handle, "*l") -- просто пропускаем строки 4 шт
pustaja_stroka = read(handle, "*l")
pustaja_stroka = read(handle, "*l")
pustaja_stroka = read(handle, "*l")


Vel0 = read(handle, "*n", "*l")		-- Начальная скорость пули, м/с (Вместо 0 лучше какое-то небольшое значение, иначе долго на месте стоит)
delta_t = read(handle, "*n", "*l")	-- Приращение времени, мкС 
Dstvola = read(handle, "*n", "*l")	-- Внешний диаметр ствола (не задавать меньше диаметра пули), милиметр

Nom_mat_puli = read(handle, "*n", "*l")	-- материал из которого сделана пуля см. таблицу
Lpuli  = read(handle, "*n", "*l")	-- Длина пули, милиметр		
Dpuli = read(handle, "*n", "*l")	-- Диаметр пули, милиметр
Lsdv = read(handle, "*n", "*l")		-- Расстояние, на которое в начальный момент вдвинута пуля в катушку или находится до катушки с минусом, милиметр

Lmag = read(handle, "*n", "*l")	-- Толщина внешнего магнитопровода, по форме повторяет катушку, если ноль то его нет, милиметр
Nom_mat_magnitoprovoda = read(handle, "*n", "*l")	-- материал из которого сделан магнитопровод катушки см. таблицу

Konfig_kat = read(handle, "*n", "*l")	-- 0 - катушки отдельно стоящие, 1 - магнитопроводы катушек единое целое, 2 - магнитопровод только внешний, между катушками его нет
Diod = read(handle, "*n", "*l")	-- 0 - без паралельного катушке диода, 1 - с диодом

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

	C[i] = read(handle, "*n", "*l") 	-- Емкость конденсатора, микроФарад		
	U[i] = read(handle, "*n", "*l")		-- Напряжение на конденсаторе, Вольт 

	Dpr[i] = read(handle, "*n", "*l")	-- Диаметр обмоточного провода катушки, милиметр
	Tiz[i] = read(handle, "*n", "*l")	-- Удвоенная толщина изоляции провода (разница диаметра в изоляции и диаметра голого), мм
	Lkat[i] = read(handle, "*n", "*l")	-- Длина катушки (не задавать меньше диаметра обмот. провода катушки), милиметр				
	Dkat[i] = read(handle, "*n", "*l")	-- Внешний диаметр катушки, милиметр
	
	Lmezdu_kat[i]= read(handle, "*n", "*l")	-- мм, расстояние между обмотками катушек 
	Lvkl[i] = read(handle, "*n", "*l")	-- мм, на каком расстоянии от начального положения пули включается тиристор 
	
	if C[i]>0 then
		L_vsego=L_vsego+Lkat[i]+Lmezdu_kat[i]
	end
	i=i+1
	
until C[i-1]==0  
N_kat =i-2

closefile(handle)
--------------------------------------------------------------------------------

Vol = 3                 -- Кратность свободного пространства вокруг модели (рекомендуется значение от 3 до 5)
Coil_meshsize = 0.5    -- Размер сетки катушки, мм
Proj_meshsize = 0.35    -- Размер сетки пули, мм
max_segm      = 5     -- Максимальный размер сегмента пространства, град

t = 0			-- Начальный момент времени, секунды
sigma = 0.0000000175	-- Удельное сопротивление меди, Ом * Метр
ro = 7800		-- Плотность железа, Кг/Метр^3
pi = 3.1415926535  
--------------------------------------------------------------------------------
-- Начинаем
--------------------------------------------------------------------------------
Start_date= date()


create(0)							-- создаем документ для магнитных задач

mi_probdef(0,"millimeters","axi",1E-8,30)			-- создаем задачу

mi_saveas("temp.fem")						-- сохраняем файл под другим именем

mi_addmaterial("Air",1,1)					-- добавляем материал воздух


i=1
repeat
	mi_addmaterial("Cu" .. i,1,1,"","","",58,"","","",4,"","",1,Dpr[i])	-- добавляем материал медный провод диаметром Dpr проводимостью 58
	mi_addcircprop("katushka" .. i,0,0,1)				-- добавляем катушку 
	i=i+1
until N_kat<i  



dofile ("func.lua")	-- компилируем функции для дальнейшего доступа к ним					
vvod_materiala (Nom_mat_magnitoprovoda,"M")	-- вводим материал магнитопровода назовем его как М и номер материала
Material_magnitoprovoda="M" .. Nom_mat_magnitoprovoda

vvod_materiala (Nom_mat_puli,"P")		---- вводим материал пули назовем его как Р и номер материала
Material_puli="P" .. Nom_mat_puli	

--------------------------------------------------------------------------------
-- Располагаем объекты
--------------------------------------------------------------------------------

--Создаем пространство в Vol раз большее чем катушка
mi_addnode(0,L_vsego*-Vol) 				-- ставим точку
mi_addnode(0,L_vsego*(Vol-1))				-- ставим точку
mi_addsegment(0,L_vsego*-Vol,0,L_vsego*(Vol-1))		-- рисуем линию
mi_addarc(0,L_vsego*-Vol,0,L_vsego*(Vol-1),180,max_segm)	-- рисуем дугу

mi_addblocklabel(L_vsego*0.7*Vol,0)				-- добавляем блок	
mi_clearselected()						-- отменяем все 
mi_selectlabel(L_vsego*0.7*Vol,0)				-- выделяем метку блока
mi_setblockprop("Air", 1, "", "", "",0) 			-- устанавливаем свойства блока с имнем Air и номером блока 0

mi_zoomnatural()	-- устанавливаем зум так что бы было видно на весь экран

-------------------------------------------------------------------------- Создаем пулю

-- если длина пули равна диаметру значит шар
if Lpuli==Dpuli then 

	mi_addnode(0,-Lsdv)
	mi_addnode(0,Lpuli-Lsdv)

	mi_clearselected()
	mi_selectnode (0,-Lsdv)
	mi_selectnode (0,Lpuli-Lsdv)
	mi_setnodeprop("",N_kat+2)
	mi_addarc(0,-Lsdv,0,Lpuli-Lsdv,180,5)


else	-- иначе просто цилиндр

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
mi_setblockprop(Material_puli, 0, Proj_meshsize, "", "",N_kat+2)			-- номер блока N_kat+2

------------------------------------------------------------------------- Создаем катушки


i=1
Lkatpol=0
repeat
	

	mi_addnode(Dstvola/2,-Lkatpol)				-- основание
	mi_addnode(Dstvola/2,-Lkatpol-Lkat[i])			-- основание
	mi_addnode(Dkat[i]/2,-Lkatpol)				-- внешняя начальная часть
	mi_addnode(Dkat[i]/2,-Lkatpol-Lkat[i])			-- внешняя конечная часть


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
	mi_setblockprop("Cu" .. i, 0, Coil_meshsize, "katushka" .. i, "",i) -- номер блока i
	
	Lkatpol=Lkatpol+Lkat[i]+Lmezdu_kat[i]
	i=i+1
until N_kat<i 

mi_clearselected()


-------------------------------------------------------------------------- Создаем внешний магнитопровод
if (Lmag > 0) and (Nom_mat_magnitoprovoda > 0) then 
	

	------------------------------------------------------------------
	-- катушки отдельно стоящие с магнитопроводом
	if Konfig_kat==0 then 
	i=1
	Lkatpol=0
	repeat
	

		mi_addnode(Dstvola/2,-Lkatpol+Lmag)				-- основание
		mi_addnode(Dstvola/2,-Lkatpol-Lkat[i]-Lmag)			-- основание
		mi_addnode(Dkat[i]/2+Lmag,-Lkatpol+Lmag)				-- внешняя начальная часть
		mi_addnode(Dkat[i]/2+Lmag,-Lkatpol-Lkat[i]-Lmag)			-- внешняя конечная часть


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
		mi_setblockprop(Material_magnitoprovoda, 1, "", "", "",N_kat+1) -- номер блока N_kat+1
	
		Lkatpol=Lkatpol+Lkat[i]+Lmezdu_kat[i]
		i=i+1
	until N_kat<i 
	mi_clearselected()
	end
	

	------------------------------------------------------------------
	-- единый магнитопровод
	if Konfig_kat==1 then 
	i=1
	Lkatpol=0
	repeat
	

		mi_addnode(Dstvola/2,-Lkatpol+Lmag)				-- основание
		mi_addnode(Dstvola/2,-Lkatpol-Lkat[i]-Lmag)			-- основание
		mi_addnode(Dkat[i]/2+Lmag,-Lkatpol+Lmag)				-- внешняя начальная часть
		mi_addnode(Dkat[i]/2+Lmag,-Lkatpol-Lkat[i]-Lmag)			-- внешняя конечная часть
		mi_addnode(Dkat[i]/2,-Lkatpol+Lmag)				-- внешняя конечная часть
		mi_addnode(Dkat[i]/2,-Lkatpol-Lkat[i]-Lmag)			-- внешняя конечная часть

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
	mi_setblockprop(Material_magnitoprovoda, 1, "", "", "",N_kat+1) -- номер блока N_kat+1
	mi_clearselected()

	end


	------------------------------------------------------------------
	-- единый магнитопровод, но между катушками его нет

	if Konfig_kat==2 then 
	i=2
	Lkatpol=Lkat[1]+Lmezdu_kat[1]

	mi_addnode(Dkat[1]/2+Lmag,Lmag)	-- внешняя начальная часть
	mi_addnode(Dkat[1]/2+Lmag,-Lkat[1])-- внешняя конечная часть


	mi_addsegment(Dkat[1]/2+Lmag,Lmag,Dkat[1]/2+Lmag,-Lkat[1])
	mi_addsegment(Dkat[2]/2,-Lkatpol,Dkat[1]/2,-Lkatpol+Lmezdu_kat[1])
	
	repeat
	
		mi_addnode(Dkat[i]/2+Lmag,-Lkatpol)	-- внешняя начальная часть
		mi_addnode(Dkat[i]/2+Lmag,-Lkatpol-Lkat[i])-- внешняя конечная часть


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

	mi_addnode(Dstvola/2,Lmag)				-- основание
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
	mi_setblockprop(Material_magnitoprovoda, 1, "", "", "",N_kat+1) -- номер блока N_kat+1
	mi_clearselected()

	end
end

mi_clearselected()

------------------------------------------------------------------------------------------------------------------------
-- Анализируем и запускаем постпроцессор
	
mi_analyze(1)				-- анализируем (скрывая окно анализа "1") 0 - будет видно окно и будет работать медленее
mi_loadsolution()			-- запускаем саму программу пост процессора

mo_zoom(0,-L_vsego*1.2,Lpuli,Dkat[1]*1.5)

mo_clearblock()
mo_groupselectblock(N_kat+2)
Vpuli = mo_blockintegral(10)		-- Объем пули, Метр^3	
mo_clearblock()	
Mpuli=ro*Vpuli				-- Масса пули, кг


N={}
DLprovoda={}
Rkat={}
R={}
Rv={}

i=1
Lkatpol=0
repeat

	mo_groupselectblock(i)
	Skat = mo_blockintegral(5) 				-- Площадь сечения катушки, Метр^2 
	mo_clearblock()
	N[i]=Skat*0.94/((Dpr[i]+Tiz[i])*(Dpr[i]+Tiz[i])/1000000)-- Количество витков в катушке 
	DLprovoda[i]=N[i] * 2 * pi * (Dkat[i] + Dstvola)/4000   -- Длина обмоточного провода уточнённая, м

	Rkat[i]=sigma*DLprovoda[i]/(pi*(Dpr[i]/2000)^2)		-- Сопротивление всего обмоточного провода катушки, Ом
	
	kRC = 140      		-- Постоянная константа RC для распространённых электрколитических нденсаторов, Ом*мкФ
	Rcc = (kRC/C[i])  	-- Внутреннее сопротивление конденсатора
	Rv[i] = 0.35+Rcc     	-- Сопротивление подводящих проводов + сопротивление тиристора + внутреннее сопротивление конденсатора, Ом

	R[i]=Rv[i]+Rkat[i]						-- Полное сопротивление системы

	mi_clearselected()
	mi_selectlabel(Dstvola/2+(Dkat[i]/2-Dstvola/2)/2,-Lkatpol-Lkat[i]/2) 
	mi_setblockprop("Cu" .. i, 0, Coil_meshsize, "katushka" .. i, "",i,N[i]) -- --Устанавливаем число витков
	mi_clearselected()
	Lkatpol=Lkatpol+Lkat[i]+Lmezdu_kat[i]

	i=i+1
until N_kat<i


--------------------------------------------------------------------------------
-- НАчало симуляции
--------------------------------------------------------------------------------

dt = delta_t/1000000 -- перевод приращения времени в секунды 
x=0		-- начальная позиция пули
t=0		-- общее время
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
	I[i]=0 	-- начальное значение тока
	Uc[i] = U[i] 	-- нчальное значение напряжения	
	Force[i]=0
	mi_modifycircprop("katushka" .. i,1,0)	-- Устанавливает ток 
	i=i+1
until N_kat<i

KC=1		-- счетчик циклов, для вывода в файл
T_I={}
T_I[KC]=";"
T_F ={}		
T_Vel={}	
T_x={}		
T_t={}



repeat  	------------------------------------------------------------ начинаем цикл
	
	t = t+dt
	for i = 1,N_kat,1  do				-- расчитываем какой будет в катушках при том что ток в других равен нулю
		if x>=Lvkl[i]/1000 then 

			------------------------------------------ Рассчитываем dFi/dI при I и силу
					
			if I[i]==0 then I[i]=0.000000001  end  		-- если в первый раз то даем достаточно малое значение тока			
            		mi_modifycircprop("katushka" .. i,1,I[i])	-- Устанавливает ток 
            		mi_analyze(1)					-- анализируем (скрывая окно анализа "1") 0 - будет видно окно и будет работать медленее	
            		mo_reload()					-- перезапускаем программу пост процессора
            		
			--- Рассчитываем dFi/dx при x

			current_re,current_im,volts_re,volts_im,flux_re,flux_im=mo_getcircuitproperties("katushka" .. i) -- получаем данные с катушки
			Fi0=flux_re 		-- магнитный поток
				            	
        		
			mi_modifycircprop("katushka" .. i,1,I[i]*1.001)	-- Устанавливает ток, увельченный на 1.001
        		mi_analyze(1)					-- анализируем (скрывая окно анализа "1") 0 - будет видно окно и будет работать медленее	
        		mo_reload()					-- перезапускаем программу пост процессора			
			current_re,current_im,volts_re,volts_im,flux_re,flux_im=mo_getcircuitproperties("katushka" .. i) -- получаем данные с катушки
           		Fi1=flux_re 			            -- магнитный поток при I=I+0.001*I, dI=0.001*I 
			
			Fii=(Fi1-Fi0)/(0.001*I[i])                              -- Рассчитываем dFi/dI

			Force = mo_groupselectblock(N_kat+2)		-- сила для каждой катушки
			Force = mo_blockintegral(19)
			
			Fix= Force/I[i]
			------- Расчитываем ток и напряжение на конденсаторе

			I[i]=I[i]+dt*(Uc[i]-I[i]*R[i]-Fix*Vel)/Fii	--			

			Uc[i] = Uc[i]-dt*I[i]*1000000/C[i]
			
			mi_modifycircprop("katushka" .. i,1,0)

			if Uc[i]<= 0  and Diod == 1 then 
				Uc[i]=0 
				I[i]= 0
			end
		end

		T_I[KC+i*10000]=I[i] -- записываем данные в массив
		
	end

---------------------------------------------------------------------------
			i2=1
			repeat

				mi_modifycircprop("katushka" .. i2,1,I[i2])	-- Устанавливает ток для всех катушек
				i2=i2+1
			until N_kat<i2


			mi_analyze(1)					-- анализируем (скрывая окно анализа "1") 0 - будет видно окно и будет работать медленее	
            		mo_reload()
			mo_groupselectblock(N_kat+2)
			Force = mo_blockintegral(19)			-- Сила действующая на пулю, Ньютон

			Force=Force*-1					-- ставим "-" из за координат (направление силы в сторону уменьшения координаты)
			apuli = Force / Mpuli				-- Ускорение пули, Метр/секунда^2 
			dx = Vel*dt+apuli*dt*dt/2			-- Приращение координаты, метр
			x = x+dx					-- Новая позиция пули
			Vel = Vel+apuli*dt				-- Скорость после приращения, метр/секунда
			
			if Vmax<Vel then Vmax=Vel end
			
			mi_selectgroup(N_kat+2)				-- Выделяем пулю
			mi_movetranslate(0,-dx*1000)			-- Перемещаем её на dx
			mi_clearselected()
			if Vel < 0 then 
				break
			end -- Пуля вылетела назад
			

			i2=1
			repeat

				mi_modifycircprop("katushka" .. i2,1,0)	-- Убираем ток 
				i2=i2+1
			until N_kat<i2

			T_F[KC]=Force		

			T_Vel[KC]=Vel		

			T_x[KC]=x*1000		

			T_t[KC]=t*1000000	

			KC=KC+1
			
----------------------------------------------------------------------------
until x > L_vsego/1000 -- повторяем расчет 

Epuli = (Mpuli*Vel^2)/2 - (Mpuli*Vel0^2)/2

i=1
EC=0
repeat
	EC= EC+(C[i]/1000000*U[i]^2)/2
	i=i+1
until N_kat<i 

KPD = Epuli*100/EC

showconsole()							-- показываем окно вывода промежуточных данных
clearconsole()
print ("-----------------------------------")						
print ("Начало симуляции " .. Start_date)
i=1
repeat
print ("----------------------------------------------------")
print ("Катушка №= " .. i)
print ("Емкость конденсатора, микроФарад= " .. C[i])
print ("Напряжение на конденсаторе, Вольт = " .. U[i])
print ("Сопротивление общее, Ом = "..R[i])
print ("Внешнее сопротивление, Ом = " .. Rv[i])
print ("Сопротивление катушки, Oм = "..Rkat[i])
print ("Количество витков в катушке = "..N[i])
print ("Диаметр обмоточного провода катушки, милиметр = " .. Dpr[i])
print ("Длина провода в катушке, метр = "..DLprovoda[i])
print ("Длина катушки, милиметр = " .. Lkat[i])
print ("Внешний диаметр катушки, милиметр = " .. Dkat[i])
print ("расстояние между обмотками катушек, милиметр  = " ..  Lmezdu_kat[i])
print ("на каком расстоянии от начального положения пули включается тиристор , милиметр  = " ..  Lvkl[i])
print ("Удвоенная толщина изоляции провода (разница диаметра в изоляции и диаметра голого, милиметр  = " ..  Tiz[i])		
print ("----------------------------------------------------")
	i=i+1
until N_kat<i  
print ("Толщина внешнего магнитопровода, милиметр = " .. Lmag)
print ("Материал внешнего магнитопровода катушки = № " .. Nom_mat_magnitoprovoda .. " " .. vyvod_name_materiala(Nom_mat_magnitoprovoda))
print ("Внешний диаметр ствола, милиметр = " .. Dstvola)	
print ("Масса пули, грамм = "..Mpuli*1000)
print ("Длина пули, милиметр = " .. Lpuli)		
print ("Диаметр пули, милиметр = " .. Dpuli)
print ("Расстояние, на которое в начальный момент вдвинута пуля в катушку, милиметр = " .. Lsdv)	
print ("Материал из которго сделана пуля = № " .. Nom_mat_puli .. " " .. vyvod_name_materiala(Nom_mat_puli))
print ("Время процесса (микросек)= " .. t*1000000)
print ("Приращение времени,  микросек=" .. delta_t)
print ("Энергия пули Дж = " .. Epuli)
print ("Энергия конденсатора Дж = " .. EC)
print ("КПД гауса(%)= " .. KPD )
print ("Начальная скорость пули, м/с = " .. Vel0)
print ("Скорость пули на выходе из катушки, м/с= " .. Vel )
print ("Максимальная скорость, которая была достигнута, м/с = " .. Vmax )
print ("Все данные и промежуточные занесены в файл: " .. File_name .. " V = " .. Vel .. ".txt")
print ("Окончания симуляции " .. date())


----------------------------------------------------------------------------------------------------
-- Записываем всё в файл
----------------------------------------------------------------------------------------------------
handle = openfile(File_name .. " V = " .. Vel .. ".txt", "a")-- создаем файл а - будем дописывать в конец файла w - записать стерев всё что было перед тем

write (handle,"--------------------------------------------------------------------------------\n")
write (handle,"Начало симуляции " .. Start_date,"\n")
i=1
repeat
write (handle,"----------------------------------------------------","\n")
write (handle,"Катушка №= " .. i,"\n")
write (handle,"Емкость конденсатора, микроФарад= " .. C[i],"\n")
write (handle,"Напряжение на конденсаторе, Вольт = " .. U[i],"\n")
write (handle,"Сопротивление общее, Ом = "..R[i],"\n")
write (handle,"Внешнее сопротивление, Ом = " .. Rv[i],"\n")
write (handle,"Сопротивление катушки, Oм = "..Rkat[i],"\n")
write (handle,"Количество витков в катушке = "..N[i],"\n")
write (handle,"Диаметр обмоточного провода катушки, милиметр = " .. Dpr[i],"\n")
write (handle,"Длина провода в катушке, метр = "..DLprovoda[i],"\n")
write (handle,"Длина катушки, милиметр = " .. Lkat[i],"\n")
write (handle,"Внешний диаметр катушки, милиметр = " .. Dkat[i],"\n")
write (handle,"расстояние между обмотками катушек, милиметр  = " ..  Lmezdu_kat[i],"\n")
write (handle,"на каком расстоянии от начального положения пули включается тиристор , милиметр  = " ..  Lvkl[i],"\n")
write (handle,"Удвоенная толщина изоляции провода (разница диаметра в изоляции и диаметра голого, милиметр  = " ..  Tiz[i],"\n")
write (handle,"----------------------------------------------------","\n")
	i=i+1
until N_kat<i  
write (handle,"----------------------------------------------------","\n\n\n")
write (handle,"Толщина внешнего магнитопровода, милиметр = " .. Lmag,"\n")
write (handle,"Материал внешнего магнитопровода катушки = № " .. Nom_mat_magnitoprovoda .. " " .. vyvod_name_materiala(Nom_mat_magnitoprovoda),"\n")
write (handle,"Внешний диаметр ствола, милиметр = " .. Dstvola,"\n")
write (handle,"Масса пули, грамм = "..Mpuli*1000,"\n")
write (handle,"Длина пули, милиметр = " .. Lpuli,"\n")		
write (handle,"Диаметр пули, милиметр = " .. Dpuli,"\n")
write (handle,"Расстояние, на которое в начальный момент вдвинута пуля в катушку, милиметр = " .. Lsdv,"\n")
write (handle,"Материал из которго сделана пуля = № " .. Nom_mat_puli .. " " .. vyvod_name_materiala(Nom_mat_puli),"\n")
write (handle,"Время процесса (микросек)= " .. t*1000000,"\n")
write (handle,"Приращение времени,  микросек=" .. delta_t,"\n")
write (handle,"Энергия пули Дж = " .. Epuli,"\n")
write (handle,"Энергия конденсатора Дж = " .. EC,"\n")
write (handle,"КПД гауса(%)= " .. KPD,"\n")
write (handle,"Начальная скорость пули, м/с = " .. Vel0,"\n")
write (handle,"Скорость пули на выходе из катушки, м/с= " .. Vel,"\n")
write (handle,"Максимальная скорость, которая была достигнута, м/с = " .. Vmax,"\n")
write (handle,"Окончания симуляции " .. date(),"\n\n\n")
write (handle,"-------------------------------Промежуточные данные---------------------------------\n")
i=1
repeat
	write (handle,"Сила тока(А) кат№ " .. i .. " ")
	i=i+1
until N_kat<i
write (handle,"Сила д. на пулю (Н)     Скорость (м/с)       Координата х(мм)     Время (мкС)           \n")

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

-- Удаляем промежуточные файлы
remove ("temp.fem")
remove ("temp.ans")

