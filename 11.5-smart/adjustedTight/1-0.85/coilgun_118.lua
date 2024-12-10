-- Скрипт для программы FEMM 4.2 
--------------------------------------------------------------------------------
---- Версия 117, 29 марта 2010 -- 
--------------------------------------------------------------------------------
-- Чтение начальных данных из текстового файла
--------------------------------------------------------------------------------

setcompatibilitymode(1)          -- Совместимость с версией 4.2

Vers = 116

File_name=prompt ("Введите имя файла даных, без расширения .txt") 

handle = openfile(File_name .. ".txt","r")
pustaja_stroka = read(handle, "*l") -- просто пропускаем строки 4 шт
pustaja_stroka = read(handle, "*l")
pustaja_stroka = read(handle, "*l")
pustaja_stroka = read(handle, "*l")

C = read(handle, "*n", "*l") 	-- Емкость конденсатора, микроФарад		
U = read(handle, "*n", "*l")	-- Напряжение на конденсаторе, Вольт 
Rsw = read(handle, "*n", "*l")	-- Сопротивление ключа, Ом 
Dpr = read(handle, "*n", "*l")	-- Диаметр обмоточного провода катушки, милиметр
TruDpr = Dpr

Lkat = read(handle, "*n", "*l")	-- Длина катушки (не задавать меньше диаметра обмот. провода катушки), милиметр		
-- CoilsAmount = read(handle, "*n", "*l") 		
Dkat = read(handle, "*n", "*l") 	
CoilsAmount = Dkat	
Lmag = read(handle, "*n", "*l")	-- Толщина щёчек внешнего магнитопровода, по форме повторяет катушку, если ноль то его нет, милиметр
LmagY= read(handle, "*n", "*l")	-- Толщина стенки внешнего магнитопровода, если 0 то равно щёчкам.
Kark = read(handle, "*n", "*l")	-- Толщина каркаса катушки

Kmot = read(handle, "*n", "*l")	-- Плотность намотки (0,7-0,95) или количество витков

Lpuli  = read(handle, "*n", "*l")	-- Длина пули, милиметр		
Dpuli = read(handle, "*n", "*l")	-- Диаметр пули, милиметр
Lotv = read(handle, "*n", "*l")		-- Глубина отверстия в пуле, милиметр 
Dotv = read(handle, "*n", "*l")		-- Диаметр отверстия в пуле, милиметр (0 - если нет отверстия)

Nagr = read(handle, "*n", "*l")		-- Масса дополнительной нагрузки или оперения, грамм

Lsdv = read(handle, "*n", "*l")		-- Расстояние, на которое в начальный момент вдвинута пуля в катушку или находится до катушки с минусом, милиметр

Dstvola = read(handle, "*n", "*l")	-- Внешний диаметр ствола (не задавать меньше диаметра пули), милиметр
Vel0 = read(handle, "*n", "*l")		-- Начальная скорость пули, м/с (Вместо 0 лучше какое-то небольшое значение, иначе долго на месте стоит)
delta_t = read(handle, "*n", "*l")	-- Приращение времени, мкС 
-- Dkat = ((CoilsAmount*2*Dpr)+Dstvola) 	-- Внешний диаметр катушки, милиметр


mode = read(handle, "*n", "*l")	-- mode 
Vykls = read(handle, "*n", "*l")	-- mode 
Rdsc = read(handle, "*n", "*l")	-- mode 
Vykl = Vykls - Lsdv

closefile(handle)
--------------------------------------------------------------------------------

kRC = 140      -- Постоянная константа RC для распространённых электрколитических нденсаторов, Ом*мкФ
Rcc = (kRC/C)  -- Внутреннее сопротивление конденсатора
Rv = Rsw+Rcc     -- Сопротивление ключа + внутреннее сопротивление конденсатора, Ом

Vol = 3                -- Кратность свободного пространства вокруг модели (рекомендуется значение от 3 до 5)
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

mi_addmaterial("Cu",1,1,"","","",58,"","","",3,"","",1,Dpr)	-- добавляем материал медный провод диаметром Dpr проводимостью 58

mi_addcircprop("katushka",0,0,1)				-- добавляем катушку 

Name_mat="Iron"

mi_addmaterial(Name_mat,"","","","","",0)        -- добавляем таблицу свойств материала "мягкая сталь"
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
-- Располагаем объекты
--------------------------------------------------------------------------------


--Создаем пространство в Vol раз большее чем катушка
mi_addnode(0,(Lkat+Lmag)*-Vol) 				-- ставим точку
mi_addnode(0,(Lkat+Lmag)*Vol)				-- ставим точку
mi_addsegment(0,(Lkat+Lmag)*-Vol,0,(Lkat+Lmag)*Vol)		-- рисуем линию
mi_addarc(0,(Lkat+Lmag)*-5,0,(Lkat+Lmag)*Vol,180,max_segm)	-- рисуем дугу

mi_addblocklabel((Lkat+Lmag)*0.7*Vol,0)				-- добавляем блок	
mi_clearselected()						-- отменяем все 
mi_selectlabel((Lkat+Lmag)*0.7*Vol,0)				-- выделяем метку блока
mi_setblockprop("Air", 1, "", "", "",0) 			-- устанавливаем свойства блока с имнем Air и номером блока 0

mi_zoomnatural()	-- устанавливаем зум так что бы было видно на весь экран

-------------------------------------------------------------------------- Создаем пулю
if Dstvola < Dpuli then Dstvola = Dpuli+0.1 end -- защита от неумех 

if Lotv>(Lpuli-0.5) then Lotv = Lpuli - 0.5 end
if Lotv<0 then Lotv = 0 end
if Dotv>(Dpuli-0.5) then Dotv = Dpuli - 0.5 end
if Dotv<0 then Dotv = 0 end

-- если длина пули равна диаметру значит шар
if Lpuli==Dpuli then 

	mi_addnode(0,Lkat/2-Lsdv)
	mi_addnode(0,Lkat/2+Lpuli-Lsdv)

	mi_clearselected()
	mi_selectnode (0,Lkat/2-Lsdv)
	mi_selectnode (0,Lkat/2+Lpuli-Lsdv)
	mi_setnodeprop("",1)
	mi_addarc(0,Lkat/2-Lsdv,0,Lkat/2+Lpuli-Lsdv,180,5)


else	-- иначе просто цилиндр

	mi_addnode(0,Lkat/2-Lsdv)
	mi_addnode(Dpuli/2,Lkat/2-Lsdv)
	mi_addnode(Dpuli/2,Lkat/2+Lpuli-Lsdv)
	


        -- точки для отверстия в пуле
        if Dotv>0 then 
	 mi_addnode(0,Lkat/2-Lsdv+Lpuli-Lotv) -- точка внутри на средней линии
	 mi_addnode(Dotv/2,Lkat/2-Lsdv+Lpuli-Lotv) -- точка внутри пули
	 mi_addnode(Dotv/2,Lkat/2+Lpuli-Lsdv) -- точка на донышке пули
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

	mi_addsegment(Dpuli/2,Lkat/2-Lsdv,Dpuli/2,Lkat/2+Lpuli-Lsdv) -- внешняя линия вверх

 if Dotv>0 then mi_addsegment(Dpuli/2,Lkat/2+Lpuli-Lsdv,Dotv/2,Lkat/2+Lpuli-Lsdv) -- задний торец
 else 	mi_addsegment(Dpuli/2,Lkat/2+Lpuli-Lsdv,0,Lkat/2+Lpuli-Lsdv) end -- задний торец
 if Dotv>0 then  mi_addsegment(Dotv/2,Lkat/2+Lpuli-Lsdv,Dotv/2,Lkat/2-Lsdv+Lpuli-Lotv) -- стенка отверстия
        mi_addsegment(Dotv/2,Lkat/2-Lsdv+Lpuli-Lotv,0,Lkat/2-Lsdv+Lpuli-Lotv) -- дно отверстия
        mi_addsegment(0,Lkat/2-Lsdv+Lpuli-Lotv,0,Lkat/2-Lsdv) -- осевая линия вниз
 else	mi_addsegment(0,Lkat/2+Lpuli-Lsdv,0,Lkat/2-Lsdv) end -- осевая линия вниз
	mi_addsegment(0,Lkat/2-Lsdv,Dpuli/2,Lkat/2-Lsdv) -- передний торец 
end

mi_addblocklabel(Dpuli/4,Lkat/2+Lpuli/2-Lotv/2-Lsdv)
mi_clearselected()
mi_selectlabel(Dpuli/4,Lkat/2+Lpuli/2-Lotv/2-Lsdv)
mi_setblockprop(Name_mat, 1, Proj_meshsize, "", "",1)			-- номер блока 1


------------------------------------------------------------------------- Создаем катушку

if (Kark <= 0) then Kark = 0.5 end


mi_addnode(Dstvola/2,Lkat/2)			-- основание
mi_addnode(Dstvola/2,-Lkat/2)			-- основание
mi_addnode(Dkat/2,Lkat/2)				-- внешняя начальная часть
mi_addnode(Dkat/2,-Lkat/2)				-- внешняя конечная часть

mi_addnode(Kark+Dstvola/2,-Kark+Lkat/2)			-- основание
mi_addnode(Kark+Dstvola/2,Kark-Lkat/2)			-- основание
mi_addnode(-Kark+Dkat/2,-Kark+Lkat/2)				-- внешняя начальная часть
mi_addnode(-Kark+Dkat/2,Kark-Lkat/2)				-- внешняя конечная часть

mi_addsegment(Dstvola/2,-Lkat/2,Dstvola/2,Lkat/2)
mi_addsegment(Dstvola/2,Lkat/2,Dkat/2,Lkat/2)
mi_addsegment(Dkat/2,Lkat/2,Dkat/2,-Lkat/2)
mi_addsegment(Dkat/2,-Lkat/2,Dstvola/2,-Lkat/2)

mi_addsegment(Kark+Dstvola/2,Kark-Lkat/2,Kark+Dstvola/2,-Kark+Lkat/2)
mi_addsegment(Kark+Dstvola/2,-Kark+Lkat/2,-Kark+Dkat/2,-Kark+Lkat/2)
mi_addsegment(-Kark+Dkat/2,-Kark+Lkat/2,-Kark+Dkat/2,Kark-Lkat/2)
mi_addsegment(-Kark+Dkat/2,Kark-Lkat/2,Kark+Dstvola/2,Kark-Lkat/2)

mi_clearselected()
mi_selectnode(Kark+Dstvola/2,-Kark+Lkat/2)			-- основание
mi_selectnode(Kark+Dstvola/2,Kark-Lkat/2)		-- основание
mi_selectnode(-Kark+Dkat/2,-Kark+Lkat/2)				
mi_selectnode(-Kark+Dkat/2,Kark-Lkat/2)				
mi_setnodeprop("",2)


mi_addblocklabel(Dstvola/2+(Dkat/2-Dstvola/2)/2,0)
mi_clearselected()
mi_selectlabel(Dstvola/2+(Dkat/2-Dstvola/2)/2,0)
mi_setblockprop("Cu", 0, Coil_meshsize, "katushka", "",2) -- номер блока 2


mi_addblocklabel(Kark/2+Dstvola/2,-Kark+Lkat/4)		-- добавляем блок	
mi_clearselected()					-- отменяем все 
mi_selectlabel(Kark/2+Dstvola/2,-Kark+Lkat/4)		-- выделяем метку блока
mi_setblockprop("Air", 1, Coil_meshsize, "", "",4) 	-- устанавливаем свойства блока с имнем Air и номером блока 4



-------------------------------------------------------------------------- Создаем внешний магнитопровод
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
	mi_setblockprop(Name_mat, 1, "", "", "",3)		-- номер блока 3

end

mi_clearselected()


--------------------------------------------------------------------------------
-- система СИ - метр, Фарад
--------------------------------------------------------------------------------
C = C/1000000
Tiz = sqrt(Dpr)*0.07
Dpriz = Dpr+Tiz -- Диаметр провода в изоляции
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

-- Анализируем и запускаем постпроцессор
	
mi_analyze(1)				-- анализируем (скрывая окно анализа "1") 0 - будет видно окно и будет работать медленее
mi_loadsolution()			-- запускаем саму программу пост процессора

mo_groupselectblock(2)
Skat = mo_blockintegral(5) 		-- Площадь сечения катушки, Метр^2 
Vkat = mo_blockintegral(10)		-- Объем катушки, Метр^3
mo_clearblock()
mo_groupselectblock(1)
Vpuli = mo_blockintegral(10)		-- Объем пули, Метр^3	
mo_clearblock()			


Mpuli=ro*Vpuli + Nagr			-- Масса пули плюс оперение, кг

if ( Kmot < 1 ) then
 N=Kmot*Skat/(Dpriz*Dpriz)		-- Количество витков в катушке уточнённое
else N=Kmot end                         -- или явно задано 

DLprovoda=N * 2 * pi * (Dkat + Dstvola)/4   -- Длина обмоточного провода уточнённая, м

Rkat=sigma*DLprovoda/(pi*(Dpr/2)^2)	-- Сопротивление всего обмоточного провода катушки, Ом
R=Rv+Rkat				-- Полное сопротивление системы

--Устанавливаем число витков, а силу тока 100 А для оценки индуктивности

mi_clearselected()
mi_selectlabel(Dstvola*1000/2+(Dkat/2-Dstvola/2)*1000/2,0) 
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
I0=0.01         -- достаточно малое значение тока  I0=0.01
t=0		-- общее время
Vel=Vel0
Vmax=Vel
Uc = U
I=I0		-- начальное значение тока
Force = 0
FA=0
Fii = 0
Fix = 0
KC=1		-- счетчик циклов, для вывода в файл
T_I={}		-- создаем массив (таблицу как её называют в Lua)
T_F={}		
T_Vel={}	
T_x={}		
T_t={}
T_U={}

repeat  	------------------------------------------------------------ начинаем цикл
	
	t = t+dt
	--- Рассчитываем dFi/dI при I и силу
            mi_modifycircprop("katushka",1,I)	-- Устанавливает ток 
            mi_analyze(1)			-- анализируем (скрывая окно анализа "1") 0 - будет видно окно и будет работать медленее	
            mo_reload()				-- перезапускаем программу пост процессора
            mo_groupselectblock(1)

	Force = mo_blockintegral(19)		-- Сила действующая на пулю, Ньютон	
	Force=Force*-1				-- ставим "-" из за координат (направление силы в сторону уменьшения координаты)
	FA=FA+Force*dt		
	current_re,current_im,volts_re,volts_im,flux_re,flux_im=mo_getcircuitproperties("katushka") -- получаем данные с катушки
	Fi0=flux_re			            -- магнитный поток
        mi_modifycircprop("katushka",1,I*1.001)	-- Устанавливает ток, увельченный на 1.001
        mi_analyze(1)				-- анализируем (скрывая окно анализа "1") 0 - будет видно окно и будет работать медленее	
        mo_reload()				-- перезапускаем программу пост процессора			
	current_re,current_im,volts_re,volts_im,flux_re,flux_im=mo_getcircuitproperties("katushka") -- получаем данные с катушки

	Fi1=flux_re			            -- магнитный поток при I=I+0.001*I, dI=0.001*I 
	Fii=(Fi1-Fi0)/(0.001*I)                              -- Рассчитываем dFi/dI

	apuli = Force / Mpuli			-- Ускорение пули, Метр/секунда^2 
--	dx = Vel*dt+apuli*dt*dt/2		-- Приращение координаты, метр
        dx = Vel*dt                             -- Приращение координаты, метр (исправленое)
	x = x+dx				-- Новая позиция пули
	Vel = Vel+apuli*dt			-- Скорость после приращения, метр/секунда
	if Vmax<Vel then Vmax=Vel end
	mi_selectgroup(1)			-- Выделяем пулю
	mi_movetranslate(0,-dx*1000)		-- Перемещаем её на dx


	mi_modifycircprop("katushka",1,I)	-- Устанавливает ток 
        mi_analyze(1)				-- анализируем (скрывая окно анализа "1") 0 - будет видно окно и будет работать медленее	
        mo_reload()				-- перезапускаем программу пост процессора
        mo_groupselectblock(1)



        current_re,current_im,volts_re,volts_im,flux_re,flux_im=mo_getcircuitproperties("katushka") -- получаем данные с катушки
	Fi0=flux_re			        -- магнитный поток
        mi_modifycircprop("katushka",1,I*1.001)	-- Устанавливает ток, увельченный на 1.001
        mi_analyze(1)				-- анализируем (скрывая окно анализа "1") 0 - будет видно окно и будет работать медленее	
        mo_reload()				-- перезапускаем программу пост процессора			
	current_re,current_im,volts_re,volts_im,flux_re,flux_im=mo_getcircuitproperties("katushka") -- получаем данные с катушки

	Fi1=flux_re			            -- магнитный поток при I=I+0.001*I, dI=0.001*I 
	Fif=(Fi1-Fi0)/(0.001*I)                              -- Рассчитываем dFi/dI

	--- Рассчитываем dL
           
	dL=Fif-Fii

	------- Расчитываем ток и напряжение на конденсаторе

	if Uc<=0 then I=I+dt*(Uc-I*(R+Rdsc)-I*dL/dt)/Fii				
	else I=I+dt*(Uc-I*R-I*dL/dt)/Fii end

	Uc = Uc-dt*I/C

	if Uc< 0 then  Uc=0 end   --если стоит паралельный диод

	if x > Vykl/1000 then -- выключаем ток 
		Uc=0
	end

        -- if (mode >0) and (Vel<Vmax) then I=0 end
	
	if x > (Lpuli+Lkat-Lsdv) and Force >-1  then I=0 end -- Пуля вылетела за пределы катушки и сила очень маленькая
			
	if x < 0 then I=0 end -- Пуля вылетела назад	

	T_I[KC]=I		-- записываем данные в массив

	T_F[KC]=Force		

	T_Vel[KC]=Vel		

	T_x[KC]=x*1000		

	T_t[KC]=t*1000000

	T_U[KC]=Uc

	KC=KC+1

until (I <= 0) or (Vel < 0 )  -- повторяем расчет, пока не будет тока 

FA=FA/(dt*KC)

Epuli = (Mpuli*Vel^2)/2 
Epuli0 = (Mpuli*Vel0^2)/2
EC0= (C*U^2)/2
EC = (C*Uc^2)/2
dEpuli = Epuli-Epuli0
dEC = EC0-EC

KPD = dEpuli*100/dEC

showconsole()		-- показываем окно вывода промежуточных данных
clearconsole()
print ("-----------------------------------")						
print ("Полученные данные записаны в файл: " .. File_name .. " V: " .. Vel .. " Vmax: " .. Vmax .. " KPD: " .. KPD ..  ".txt")
-- print ("Расчёт закончен в " .. date())


----------------------------------------------------------------------------------------------------
-- Записываем всё в файл
----------------------------------------------------------------------------------------------------
handle = openfile(C*1000000 .. "-" .. TruDpr .. "-" .. CoilsAmount .. "-" .. Lkat*1000  .. "-" .. Lsdv*1000 .. "-".. Vykls .. "-".. Rdsc .. " V-" .. Vel .. " KPD-" .. KPD .. " Vm-" .. Vmax .. "E-" .. dEpuli ..  ".txt", "a")-- создаем файл а - будем дописывать в конец файла w - записать стерев всё что было перед тем

write (handle,"--------------------------------------------------------------------------------\n")
write (handle,"Начало расчёта " .. Start_date,"\n")
write (handle,"Варсия скрипта " .. Vers,"\n")
write (handle,"Ёмкость конденсатора, микроФарад = " .. C*1000000,"\n")
write (handle,"Начальное напряжение, Вольт = " .. U,"\n")
write (handle,"Общее сопротивление, Ом = "..R,"\n")
write (handle,"Внешнее сопротивление, Ом = " .. Rv,"\n")
write (handle,"Сопротивление обмотки, Ом = "..Rkat,"\n")
write (handle,"Количество витков = "..N,"\n")
write (handle,"  ДИАМЕТР ПРОВОДА, мм = " .. Dpr*1000,"\n")
write (handle,"Общая длина провода, м = "..DLprovoda,"\n")
write (handle,"Длина катушки, мм = " .. Lkat*1000,"\n")
write (handle,"Внешний диаметр катушки, мм = " .. Dkat*1000,"\n")
write (handle,"Индуктивность катушки в стартовой позиции, микроГенри = "..L*1000000,"\n")
write (handle,"Толщина щёчек внешнего магнитопровода, мм = " .. Lmag*1000,"\n")
write (handle,"Толщина корпуса внешнего магнитопровода, мм = " .. LmagY*1000,"\n")
write (handle,"Внутренний диаметр катушки, мм = " .. Dstvola*1000,"\n")
write (handle,"Масса пули без оперения, г = "..(Mpuli-Nagr)*1000,"\n")
write (handle,"Длина пули, мм = " .. Lpuli*1000,"\n")		
write (handle,"Диаметр пули, мм = " .. Dpuli*1000,"\n")
write (handle,"Глубина отверстия в пуле, мм = " .. Lotv*1000,"\n")		
write (handle,"Диаметр отверстия, мм = " .. Dotv*1000,"\n")
write (handle,"Масса оперения, г = " .. Nagr*1000,"\n")
write (handle,"Масса пули вместе с оперением, г = "..Mpuli*1000,"\n")
write (handle,"Стартовая позиция пули внутри катушки, мм = " .. Lsdv*1000,"\n")
write (handle,"Общее время, микросекунд = " .. t*1000000,"\n")
write (handle,"Интервал расчёта,  микросекунд =" .. delta_t,"\n")
write (handle,"----- ЭНЕРГИЯ ---------------------------------------------\n")
write (handle,"  Энергия пули начальная, Дж = " .. Epuli0,"\n")
write (handle,"  Энергия пули  конечная, Дж = " .. Epuli,"\n")
write (handle,"  Приращение энергии пули, Дж = " .. dEpuli,"\n")
write (handle,"  Энергия конденсатора начальная, Дж = " .. EC0,"\n")
write (handle,"  Энергия конденсатора  конечная, Дж = " .. EC,"\n")
write (handle,"  Расход энергии конденсатора, Дж = " .. dEC,"\n")
write (handle,"  КПД, % = " .. KPD,"\n")
write (handle,"------ СКОРОСТЬ -------------------------------------------\n")
write (handle,"Начальная скорость пули, м/с = " .. Vel0,"\n")
write (handle,"Конечная скорость пули, м/с = " .. Vel,"\n")
write (handle,"Максимальая скорость пули, (в катушк), м/с = " .. Vmax,"\n")
write (handle,"Средняя сила, Н = " .. FA,"\n")
write (handle,"Конец расчёта " .. date(),"\n")
write (handle,"------------------------------- Data of simulation -------------------------------\n")
write (handle,"Сила тока (А)		Напряжение (В)            Сила (Н)	          Скорость (м/с)	 	Позиция x (мм) 	Время (мкс) \n")

for Scet=1,KC-1 do
	write (handle,T_I[Scet],"\t",T_U[Scet],"\t",T_F[Scet],"\t",T_Vel[Scet],"\t",T_x[Scet],"\t",T_t[Scet],"\t","\n")
end
write (handle,"-- Data for export to Excel sheet --\n")
write (handle,"Сила тока (А)\n")
for Scet=1,KC-1 do
	data1,data2=gsub(T_I[Scet], "%.", ",")
	write (handle,data1,"\n")
end
write (handle,"Напряжение (В)\n")
for Scet=1,KC-1 do
	data1,data2=gsub(T_U[Scet], "%.", ",")
	write (handle,data1,"\n")
end
write (handle,"Сила (Н)\n")
for Scet=1,KC-1 do
	data1,data2=gsub(T_F[Scet], "%.", ",")
	write (handle,data1,"\n")
end
write (handle,"Скорость (м/с)\n")
for Scet=1,KC-1 do
	data1,data2=gsub(T_Vel[Scet], "%.", ",")
	write (handle,data1,"\n")
end
write (handle,"Позиция x (мм)\n")
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

