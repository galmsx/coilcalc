-- Это lua скрипт для FEMM 4.0
--------------------------------------------------------------------------------
---- Версия 2.4.04 от 22 января 2006 г. 
--------------------------------------------------------------------------------
-- Читаем из файла начальные параметры
--------------------------------------------------------------------------------
File_name=prompt ("Введите имя файла с данными гауса, без расширения .txt") 

handle = openfile(File_name .. ".txt","r")
pustaja_stroka = read(handle, "*l") -- просто пропускаем строки 4 шт
pustaja_stroka = read(handle, "*l")
pustaja_stroka = read(handle, "*l")
pustaja_stroka = read(handle, "*l")

C = read(handle, "*n", "*l") 	-- Емкость конденсатора, микроФарад		
U = read(handle, "*n", "*l")	-- Напряжение на конденсаторе, Вольт 


Nom_mat_puli = read(handle, "*n", "*l")	-- материал из которого сделана пуля см. таблицу
Lpuli  = read(handle, "*n", "*l")	-- Длина пули, милиметр		
Dpuli = read(handle, "*n", "*l")	-- Диаметр пули, милиметр
Lsdv = read(handle, "*n", "*l")		-- Расстояние, на которое в начальный момент вдвинута пуля в катушку или находится до катушки с минусом, милиметр

-- Dstvola = read(handle, "*n", "*l")	-- Внешний диаметр ствола (не задавать меньше диаметра пули), милиметр
Vel0 = read(handle, "*n", "*l")		-- Начальная скорость пули, м/с (Вместо 0 лучше какое-то небольшое значение, иначе долго на месте стоит)
delta_t = read(handle, "*n", "*l")	-- Приращение времени, мкС 

Nom_mat_magnitoprovoda = read(handle, "*n", "*l")	-- материал из которого сделан магнитопровод катушки см. таблицу
Dpr = read(handle, "*n", "*l")	-- Диаметр обмоточного провода катушки, милиметр
Tiz = read(handle, "*n", "*l")	-- Удвоенная толщина изоляции провода (разница диаметра в изоляции и диаметра голого), мм


Rkat={}
Zkat={}
i=0
repeat
	Rkat[i] = read(handle, "*n", "*l")	-- координата r, милиметр
	Zkat[i] = read(handle, "*n", "*l")	-- координата z, милиметр
--	print (Rkat[i],Zkat[i])
	
	i=i+1
until (Rkat[i-1]==0) and (Zkat[i-1]==0) 
N_per =i-2

Rmag={}
Zmag={}
i=0
repeat
	Rmag[i] = read(handle, "*n", "*l")	-- координата r магнитопровода, милиметр
	Zmag[i] = read(handle, "*n", "*l")	-- координата z магнитопровода, милиметр
	i=i+1
until (Rmag[i-1]==0) and (Zmag[i-1]==0) 
N_per_m =i-2


closefile(handle)
--------------------------------------------------------------------------------

kRC = 140      -- Постоянная константа RC для распространённых электрколитических нденсаторов, Ом*мкФ
Rcc = (kRC/C)  -- Внутреннее сопротивление конденсатора
Rv = 0.35+Rcc     -- Сопротивление подводящих проводов + сопротивление тиристора + внутреннее сопротивление конденсатора, Ом

Vol =30                 -- Кратность свободного пространства вокруг модели (рекомендуется значение от 3 до 5)
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

mi_addmaterial("Cu",1,1,"","","",58,"","","",4,"","",1,Dpr)	-- добавляем материал медный провод диаметром Dpr проводимостью 58

mi_addcircprop("katushka",0,0,1)				-- добавляем катушку 

dofile ("func.lua")	-- компилируем функции для дальнейшего доступа к ним					
vvod_materiala (Nom_mat_magnitoprovoda,"M")	-- вводим материал магнитопровода назовем его как М и номер материала
Material_magnitoprovoda="M" .. Nom_mat_magnitoprovoda

vvod_materiala (Nom_mat_puli,"P")		---- вводим материал пули назовем его как Р и номер материала
Material_puli="P" .. Nom_mat_puli	

--------------------------------------------------------------------------------
-- Располагаем объекты
--------------------------------------------------------------------------------

--Создаем пространство в Vol раз большее чем катушка
mi_addnode(0,(Zkat[N_per])*(-Vol+1)) 				-- ставим точку
mi_addnode(0,(Zkat[N_per])*Vol)				-- ставим точку
mi_addsegment(0,(Zkat[N_per])*Vol,0,(Zkat[N_per])*(-Vol+1))		-- рисуем линию
mi_addarc(0,(Zkat[N_per])*Vol,0,(Zkat[N_per])*(-Vol+1),180,max_segm)	-- рисуем дугу

mi_addblocklabel((Zkat[N_per])*0.7*-Vol,0)				-- добавляем блок	
mi_clearselected()						-- отменяем все 
mi_selectlabel((Zkat[N_per])*0.7*-Vol,0)				-- выделяем метку блока
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
	mi_setnodeprop("",1)
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
	mi_setnodeprop("",1)

	mi_addsegment(Dpuli/2,-Lsdv,Dpuli/2,Lpuli-Lsdv)
	mi_addsegment(Dpuli/2,Lpuli-Lsdv,0,Lpuli-Lsdv)
	mi_addsegment(0,Lpuli-Lsdv,0,-Lsdv)
	mi_addsegment(0,-Lsdv,Dpuli/2,-Lsdv)

end
mi_addblocklabel(Dpuli/4,Lpuli/2-Lsdv)
mi_clearselected()
mi_selectlabel(Dpuli/4,Lpuli/2-Lsdv)
mi_setblockprop(Material_puli, 0, Proj_meshsize, "", "",1)			-- номер блока 1

------------------------------------------------------------------------- Создаем катушку

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
mi_setblockprop("Cu", 0, Coil_meshsize, "katushka", "",2) -- номер блока 2


-------------------------------------------------------------------------- Создаем внешний магнитопровод
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
mi_setblockprop(Material_magnitoprovoda, 0, Proj_meshsize, "", "",3)		-- номер блока 3

end

mi_clearselected()

--------------------------------------------------------------------------------
-- система СИ - метр, Фарад
--------------------------------------------------------------------------------
C = C/1000000
Dpriz = Dpr+Tiz -- Диаметр провода в изоляции
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

-- Анализируем и запускаем постпроцессор
	
mi_analyze(1)				-- анализируем (скрывая окно анализа "1") 0 - будет видно окно и будет работать медленее
mi_loadsolution()			-- запускаем саму программу пост процессора


mo_groupselectblock(1)
Vpuli = mo_blockintegral(10)		-- Объем пули, Метр^3	
mo_clearblock()	
Mpuli=ro*Vpuli				-- Масса пули, кг



mo_groupselectblock(2)
Skat = mo_blockintegral(5) 		-- Площадь сечения катушки, Метр^2 
Vkat = mo_blockintegral(10) 		-- Объем катушки, Метр^3 			


N=Skat*0.94/(Dpriz*Dpriz)		-- Количество витков в катушке уточнённое
DLprovoda=N*Vkat/Skat   -- Длина обмоточного провода уточнённая, м

Rkatushki=sigma*DLprovoda/(pi*(Dpr/2)^2)	-- Сопротивление всего обмоточного провода катушки, Ом
R=Rv+Rkatushki				-- Полное сопротивление системы


--Устанавливаем число витков, а силу тока 100 А для оценки индуктивности

mi_clearselected()
mi_selectlabel(Rkat[0]+0.001,Zkat[0]-0.001) 
mi_setblockprop("Cu", 0, Coil_meshsize, "katushka", "",2,N) -- последнее значение - число витков
mi_clearselected()
mi_modifycircprop("katushka",1,100)


-- Анализируем и запускаем постпроцессор

mi_analyze(1)				-- анализируем (скрывая окно анализа "1") 	
mo_reload()				-- перезапускаем программу пост процессора			
current_re,current_im,volts_re,volts_im,flux_re,flux_im=mo_getcircuitproperties("katushka") -- получаем данные с катушки


L=flux_re/current_re			-- Оценочная индуктивность, Генри


--------------------------------------------------------------------------------
-- НАчало симуляции
--------------------------------------------------------------------------------

dt = delta_t/1000000 -- перевод приращения времени в секунды 
x=0		-- начальная позиция пули
I0=0.00000001   -- достаточно малое значение тока
t=0		-- общее время
Vel=Vel0
Vmax=Vel
Uc = U
I=I0		-- начальное значение тока
Force = 0
Fii = 0
Fix = 0
KC=1		-- счетчик циклов, для вывода в файл
T_I={}		-- создаем массив (таблицу как её называют в Lua)
T_F={}		
T_Vel={}	
T_x={}		
T_t={}
Pricina="Vel < 0"
repeat  	------------------------------------------------------------ начинаем цикл
	
	t = t+dt
	--- Рассчитываем dFi/dI при I и силу
            mi_modifycircprop("katushka",1,I)	-- Устанавливает ток 
            mi_analyze(1)			-- анализируем (скрывая окно анализа "1") 0 - будет видно окно и будет работать медленее	
            mo_reload()				-- перезапускаем программу пост процессора
            mo_groupselectblock(1)

	Force = mo_blockintegral(19)		-- Сила действующая на пулю, Ньютон	
	Force=Force*-1				-- ставим "-" из за координат (направление силы в сторону уменьшения координаты)
			
	current_re,current_im,volts_re,volts_im,flux_re,flux_im=mo_getcircuitproperties("katushka") -- получаем данные с катушки
	Fi0=flux_re			            -- магнитный поток
        mi_modifycircprop("katushka",1,I*1.001)	-- Устанавливает ток, увельченный на 1.001
        mi_analyze(1)				-- анализируем (скрывая окно анализа "1") 0 - будет видно окно и будет работать медленее	
        mo_reload()				-- перезапускаем программу пост процессора			
	current_re,current_im,volts_re,volts_im,flux_re,flux_im=mo_getcircuitproperties("katushka") -- получаем данные с катушки

	Fi1=flux_re			            -- магнитный поток при I=I+0.001*I, dI=0.001*I 
	Fii=(Fi1-Fi0)/(0.001*I)                              -- Рассчитываем dFi/dI

	apuli = Force / Mpuli			-- Ускорение пули, Метр/секунда^2 
	dx = Vel*dt+apuli*dt*dt/2		-- Приращение координаты, метр
	x = x+dx				-- Новая позиция пули				
	Vel = Vel+apuli*dt			-- Скорость после приращения, метр/секунда
	if Vmax<Vel then Vmax=Vel end
	mi_selectgroup(1)			-- Выделяем пулю
	mi_movetranslate(0,-dx*1000)		-- Перемещаем её на dx

	--- Рассчитываем dFi/dx при x
           
	Fix= Force/I
	------- Расчитываем ток и напряжение на конденсаторе

	I=I+dt*(Uc-I*R-Fix*Vel)/Fii				

	Uc = Uc-dt*I/C

	if Uc< 0 then  
		Pricina="напряжение на конденсаторе = 0"
		break
	end   --если стоит паралельный диод
	
	if x > (Lpuli-Zkat[N_per]-Lsdv)/1000 and Force >-1  then 

		Pricina="Пуля вылетела за пределы катушки и сила очень маленькая"
		break
	end -- Пуля вылетела за пределы катушки и сила очень маленькая


	if x < 0 then 
		Pricina="Пуля вылетела назад"
		break
	end -- Пуля вылетела назад

	if KC==2 then
	--

	end		

	T_I[KC]=I		-- записываем данные в массив

	T_F[KC]=Force		

	T_Vel[KC]=Vel		

	T_x[KC]=x*1000		

	T_t[KC]=t*1000000	

	KC=KC+1

until Vel < 0  -- повторяем расчет

Epuli = (Mpuli*Vel^2)/2 - (Mpuli*Vel0^2)/2
EC= (C*U^2)/2
KPD = Epuli*100/EC

showconsole()							-- показываем окно вывода промежуточных данных
clearconsole()
print ("-----------------------------------")						
print ("Начало симуляции " .. Start_date)
print ("Причина остановки расчетов: " .. Pricina)
print ("Емкость конденсатора, микроФарад= " .. C*1000000)
print ("Напряжение на конденсаторе, Вольт = " .. U)
print ("Сопротивление общее, Ом = " .. R)
print ("Внешнее сопротивление, Ом = " .. Rv)
print ("Сопротивление катушки, Oм = " .. Rkatushki)
print ("Количество витков в катушке = " .. N)
print ("Диаметр обмоточного провода катушки, милиметр = " .. Dpr*1000)
print ("Длина провода в катушке, метр = "..DLprovoda)
print ("Индуктивность катушки с пулей в начальном положении, микроГенри= " .. L*1000000)
print ("Материал внешнего магнитопровода катушки = № " .. Nom_mat_magnitoprovoda .. " " .. vyvod_name_materiala(Nom_mat_magnitoprovoda))
print ("Масса пули, грамм = " .. Mpuli*1000)
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
write (handle,"Начальные параметры " .. Start_date,"\n")
write (handle,"--------------------------------------------------------------------------------\n\n\n")
write (handle,C*1000000 .. "	микроФарад, ёмкость конденсатора\n")
write (handle,U .. "	вольт, напряжение на конденсаторе\n\n")
write (handle,Nom_mat_puli .. "	материал из которго сделана пуля - "  .. vyvod_name_materiala(Nom_mat_puli),"\n")
write (handle,Lpuli .. "	мм, длина пули\n")
write (handle,Dpuli .. "	мм, диаметр пули\n")
write (handle,Lsdv .. "	мм, расстояние, на которое в начальный момент вдвинута пуля в катушку\n\n")
write (handle,Vel0 .. "	м/с, начальная скорость пули\n\n")
write (handle,delta_t .. "	микросек, приращение времени\n\n")
write (handle,Nom_mat_magnitoprovoda .. "	материал из которого сделан магнитопровод катушки - "  .. vyvod_name_materiala(Nom_mat_magnitoprovoda),"\n")
write (handle,Dpr*1000 .. "	мм, диаметр обмоточного провода катушки\n")
write (handle,Tiz .. "	мм, удвоенная толщина изоляции провода\n\n")

i=0
repeat
	write (handle,Rkat[i] .. "	мм, координата r катушки\n")
	write (handle,Zkat[i] .. "	мм, координата z катушки\n\n")
	i=i+1
until i>N_per 

write (handle,"0 - стоп\n")
write (handle,"0 - стоп\n\n")
i=0
repeat
	write (handle,Rmag[i] .. "	мм, координата r магнитопровода	\n")
	write (handle,Zmag[i] .. "	мм, координата z магнитопровода	\n\n")
	i=i+1
until i>N_per_m 
write (handle,"0 - стоп\n")
write (handle,"0 - стоп\n\n\n")

write (handle,"--------------------------------------------------------------------------------\n")
write (handle,"Расчетные данные \n")
write (handle,"--------------------------------------------------------------------------------\n\n")

write (handle,"Причина остановки расчетов: " .. Pricina,"\n")
write (handle,"Сопротивление общее, Ом = "..R,"\n")
write (handle,"Внешнее сопротивление, Ом = " .. Rv,"\n")
write (handle,"Сопротивление катушки, Oм = "..Rkatushki,"\n")
write (handle,"Количество витков в катушке = "..N,"\n")
write (handle,"Длина провода в катушке, метр = "..DLprovoda,"\n")
write (handle,"Индуктивность катушки с пулей в начальном положении, микроГенри= "..L*1000000,"\n")
write (handle,"Масса пули, грамм = "..Mpuli*1000,"\n")
write (handle,"Время процесса (микросек)= " .. t*1000000,"\n")
write (handle,"Энергия пули Дж = " .. Epuli,"\n")
write (handle,"Энергия конденсатора Дж = " .. EC,"\n")
write (handle,"КПД гауса(%)= " .. KPD,"\n")
write (handle,"Скорость пули на выходе из катушки, м/с= " .. Vel,"\n")
write (handle,"Максимальная скорость, которая была достигнута, м/с = " .. Vmax,"\n")
--write (handle,"Окончания симуляции " .. date(),"\n")
write (handle,"\n\n\n")
write (handle,"-------------------------------Промежуточные данные---------------------------------\n")
write (handle,"Сила тока (А)		Сила д. на пулю (Н)	Скорость (м/с)		Координата х(мм) 	Время (мкС) \n")

for Scet=1,KC-1 do
	write (handle,T_I[Scet],"\t",T_F[Scet],"\t",T_Vel[Scet],"\t",T_x[Scet],"\t",T_t[Scet],"\t","\n")
end
write (handle,"-- Промежуточные данные для графиков --\n")
write (handle,"Сила тока (А)\n")
for Scet=1,KC-1 do
	data1,data2=gsub(T_I[Scet], "%.", ",")
	write (handle,data1,"\n")
end
write (handle,"Сила д. на пулю (Н)\n")
for Scet=1,KC-1 do
	data1,data2=gsub(T_F[Scet], "%.", ",")
	write (handle,data1,"\n")
end
write (handle,"Скорость (м/с)\n")
for Scet=1,KC-1 do
	data1,data2=gsub(T_Vel[Scet], "%.", ",")
	write (handle,data1,"\n")
end
write (handle,"Координата х(мм)\n")
for Scet=1,KC-1 do
	data1,data2=gsub(T_x[Scet], "%.", ",")
	write (handle,data1,"\n")
end
write (handle,"Время (мкс)\n")
for Scet=1,KC-1 do
	data1,data2=gsub(T_t[Scet], "%.", ",")
	write (handle,data1,"\n")
end
closefile(handle)

-- Удаляем промежуточные файлы
remove ("temp.fem")
remove ("temp.ans")