script_name('CNN Helper')  
script_author('Shelby') 
script_description('Скрипт помогает принимать ПРО/Устав/ППЭ у сотрудников СМИ') 

require "lib.moonloader" 
local imgui = require 'imgui'
local dlstatus = require('moonloader').download_status
local inicfg = require 'inicfg'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8
update_state = false
local tag ='{0066ff}[CNN Helper]: '
local main_color = 0x0066ff
local main_color_text = "{0066ff}"
local white_color = "{FFFFFF}"
local main_window_state = imgui.ImBool(false)
local text_buffer = imgui.ImBuffer(256)
local keys = require "vkeys"

local script_vers = 1
local script_vers_text = "1.00"

local update_url = "https://raw.githubusercontent.com/AleksandrShelby/CNN-Helper/main/update.ini" -- тут тоже свою ссылку
local update_path = getWorkingDirectory() .. "/update.ini" -- и тут свою ссылку

local script_url = "" -- тут свою ссылку
local script_path = thisScript().path


function imgui.TextColoredRGB(text)
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4

    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end

    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImColor(r, g, b, a):GetVec4()
    end

    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else imgui.Text(u8(w)) end
        end
    end

    render_text(text)
end
function apply_custom_style()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    local ImVec2 = imgui.ImVec2
    style.WindowPadding                = ImVec2(4.0, 4.0)
    style.WindowRounding               = 7
    style.WindowTitleAlign             = ImVec2(0.5, 0.5)
    style.FramePadding                 = ImVec2(4.0, 3.0)
    style.ItemSpacing                  = ImVec2(8.0, 4.0)
    style.ItemInnerSpacing             = ImVec2(4.0, 4.0)
    style.ChildWindowRounding          = 7
    style.FrameRounding                = 7
    style.ScrollbarRounding            = 7
    style.GrabRounding                 = 7
    style.IndentSpacing                = 21.0
    style.ScrollbarSize                = 13.0
    style.GrabMinSize                  = 10.0
    style.ButtonTextAlign              = ImVec2(0.5, 0.5)
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 1.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.96)
    colors[clr.Border]                 = ImVec4(0.73, 0.36, 0.00, 0.00)
    colors[clr.FrameBg]                = ImVec4(0.49, 0.24, 0.00, 1.00)
    colors[clr.FrameBgHovered]         = ImVec4(0.65, 0.32, 0.00, 1.00)
    colors[clr.FrameBgActive]          = ImVec4(0.73, 0.36, 0.00, 1.00)
    colors[clr.TitleBg]                = ImVec4(0.15, 0.11, 0.09, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.73, 0.36, 0.00, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.15, 0.11, 0.09, 0.51)
    colors[clr.MenuBarBg]              = ImVec4(0.62, 0.31, 0.00, 1.00)
    colors[clr.CheckMark]              = ImVec4(1.00, 0.49, 0.00, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.84, 0.41, 0.00, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.98, 0.49, 0.00, 1.00)
    colors[clr.Button]                 = ImVec4(0.73, 0.36, 0.00, 0.40)
    colors[clr.ButtonHovered]          = ImVec4(0.73, 0.36, 0.00, 1.00)
    colors[clr.ButtonActive]           = ImVec4(1.00, 0.50, 0.00, 1.00)
    colors[clr.Header]                 = ImVec4(0.49, 0.24, 0.00, 1.00)
    colors[clr.HeaderHovered]          = ImVec4(0.70, 0.35, 0.01, 1.00)
    colors[clr.HeaderActive]           = ImVec4(1.00, 0.49, 0.00, 1.00)
    colors[clr.SeparatorHovered]       = ImVec4(0.49, 0.24, 0.00, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.49, 0.24, 0.00, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.48, 0.23, 0.00, 1.00)
    colors[clr.ResizeGripHovered]      = ImVec4(0.78, 0.38, 0.00, 1.00)
    colors[clr.ResizeGripActive]       = ImVec4(1.00, 0.49, 0.00, 1.00)
    colors[clr.PlotLines]              = ImVec4(0.83, 0.41, 0.00, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.99, 0.00, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.93, 0.46, 0.00, 1.00)
    colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.00, 0.00, 0.00, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.33, 0.33, 0.33, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.39, 0.39, 0.39, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.48, 0.48, 0.48, 1.00)
    colors[clr.CloseButton]            = colors[clr.FrameBg]
    colors[clr.CloseButtonHovered]     = colors[clr.FrameBgHovered]
    colors[clr.CloseButtonActive]      = colors[clr.FrameBgActive]
end
apply_custom_style()
function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end
	sampRegisterChatCommand("cnn", cmd_cnn)
	sampRegisterChatCommand("update", cmd_update)
	_, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
	nick = sampGetPlayerNickname(id)
	sampAddChatMessage(tag.."{FFFFFF}Приветствую,{0066ff} "..nick.."["..id.."]{FFFFFF}!", main_color)
	sampAddChatMessage(tag.."{FFFFFF}Для того чтобы запустить скрипт, введите команду {0066ff}/cnn", main_color)
	
		downloadUrlToFile(update_url, update_path, function(id, status)
       if status == dlstatus.STATUS_ENDDOWNLOADDATA then
          updateIni = inicfg.load(nil, update_path)
           if tonumber(updateIni.info.vers) > script_vers then
              sampAddChatMessage("tag..Доступно новое обновление! Версия: " .. updateIni.info.vers_text, -1)
               update_state = true
            end
           os.remove(update_path)
        end
    end)
    
	while true do
        wait(0)

  if update_state then
            downloadUrlToFile(script_url, script_path, function(id, status)
               if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                   sampAddChatMessage(tag.."Скрипт успешно обновлён!", -1)
                    thisScript():reload()
                end
            end)
            break
        end

	end
	imgui.Process = false
	
		
end	
function cmd_update(arg)
    sampAddChatMessage(tag.."{FFFFFF}У вас установлена последняя версия скрипта.", -1)
end

function cmd_cnn(arg)
	main_window_state.v = not main_window_state.v
	imgui.Process = main_window_state.v
 end
 function imgui.Hint(text, delay)
    if imgui.IsItemHovered() then
        if go_hint == nil then go_hint = os.clock() + (delay and delay or 0.0) end
        local alpha = (os.clock() - go_hint) * 5 -- Скорость появления
        if os.clock() >= go_hint then
            imgui.PushStyleVar(imgui.StyleVar.Alpha, (alpha <= 1.0 and alpha or 1.0))
                imgui.PushStyleColor(imgui.Col.PopupBg, imgui.GetStyle().Colors[imgui.Col.ButtonHovered])
                    imgui.BeginTooltip()
                    imgui.PushTextWrapPos(450)
                    imgui.TextUnformatted(text)
                    if not imgui.IsItemVisible() and imgui.GetStyle().Alpha == 1.0 then go_hint = nil end
                    imgui.PopTextWrapPos()
                    imgui.EndTooltip()
                imgui.PopStyleColor()
            imgui.PopStyleVar()
        end
    end
end
function imgui.VerticalSeparator()
    local p = imgui.GetCursorScreenPos()
    imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x, p.y + imgui.GetContentRegionMax().y), imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.Separator]))
end

function imgui.OnDrawFrame()
	if not main_window_state.v then
		imgui.Process = false
	end

    if main_window_state.v then
        local sw, sh = getScreenResolution()
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(475, 550), imgui.Cond.FirstUseEver)
	end
	imgui.Begin(u8"Проверка ПРО/Устав/ППЭ", main_window_state)
	if imgui.CollapsingHeader(u8'Проверка Правил Редактирования Объявлений') then
 
	if imgui.Button(u8"Начало") then
			lua_thread.create(function()
				sampSendChat("Я озвучиваю вам объявление, вы его редактируете!")
				wait(2000)
				sampSendChat("/n Ответы писать в /do")
				wait(2000)
				sampSendChat("Ну что ж.. Начнём?")
			end)
		end
		imgui.SameLine()
		if imgui.Button(u8"Верно") then
				sampSendChat("Верно!")
		end
		imgui.SameLine()
		if imgui.Button(u8"Неверно") then
				sampSendChat("Неверно!")
		end
		imgui.Separator()
		imgui.SetCursorPos(imgui.ImVec2(3,76))
			if imgui.Button(u8"Продам дом в СФ(Г+П) 2кк") then
				sampSendChat("Отредактируйте объявление: Продам дом в СФ г+п за 2кк ")
		end
		imgui.SameLine()
		imgui.VerticalSeparator()
		imgui.SetCursorPos(imgui.ImVec2(178,76))
		if imgui.Button(u8"Ответ##1") then
				sampSendChat("Правильный ответ: Продам дом с гаражом и подвалом в г.Сан-Фиерро. Цена: 2.000.000$")
		end
		imgui.SameLine()
		imgui.VerticalSeparator()
		imgui.SetCursorPos(imgui.ImVec2(3,102))
			if imgui.Button(u8"Куплю дом с гаражом") then
				sampSendChat("Отредактируйте объявление: Куплю дом с гаражом")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,102))
		if imgui.Button(u8"Ответ##2") then
				sampSendChat("Правильный ответ: Куплю дом с гаражом в любой точке штата. Бюджет: свободный")
		end
		if imgui.Button(u8"Куплю дом в гетто") then
				sampSendChat("Отредактируйте объявление: Куплю дом с гаражом")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,128))
		if imgui.Button(u8"3.Ответ") then
				sampSendChat("Правильный ответ: Куплю дом в опасном районе. Бюджет: свободный")
		end
		--imgui.Separator()
		if imgui.Button(u8"Продам Элегию за 5кк") then
				sampSendChat("Отредактируйте объявление: Куплю дом в гетто")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,154))
		if imgui.Button(u8"4.Ответ") then
				sampSendChat("Правильный ответ: Продам а/м марки Элегия. Цена: 5.000.000$")
		end
		if imgui.Button(u8"Куплю буллку ТТ") then
				sampSendChat("Отредактируйте объявление: Куплю булку с ТТ")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,180))
		if imgui.Button(u8"5.Ответ") then
				sampSendChat("Правильный ответ: Куплю а/м марки Буллет с пакетом Твин-Турбо. Бюджте: свободный")
		end
		--imgui.Separator()
		if imgui.Button(u8"Продам 123 скин") then
				sampSendChat("Отредактируйте объявление: Продам 123 скин")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,206))
		if imgui.Button(u8"6.Ответ") then
				sampSendChat("Правильный ответ: Продам одежду с биркой 123. Цена: договорная")
		end
		if imgui.Button(u8"Куплю скин Конора") then
				sampSendChat("Отредактируйте объявление: Куплю скин Конора")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,232))
		if imgui.Button(u8"7.Ответ") then
				sampSendChat("Правильный ответ: Куплю одежду пошива Конор. Бюджет: свободный")
		end
		--imgui.Separator()
			if imgui.Button(u8"Продам ТТ за 8кк") then
				sampSendChat("Отредактируйте объявление: Продам ТТ за 8кк")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,258))
		if imgui.Button(u8"8.Ответ") then
				sampSendChat("Правильный ответ: Продам пакет Твин-Турбо. Цена: 8.000.000$")
		end
		if imgui.Button(u8"Куплю Суприм") then
				sampSendChat("Отредактируйте объявление: Куплю Суприм")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,284))
		if imgui.Button(u8"9.Ответ") then
				sampSendChat("Правильный ответ: Куплю наклейку Суприм. Бюджет: свободный")
		end
		--imgui.Separator()
			if imgui.Button(u8"Продам акс нимб") then
				sampSendChat("Отредактируйте объявление: Продам аксессуар Нимб")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,310))
		if imgui.Button(u8"10.Ответ") then
				sampSendChat("Правильный ответ: Отказ/не рекламируем покупку/продажу Нимба. Запрещённый аксессуар")
		end
		if imgui.Button(u8"Куплю акс Бита") then
				sampSendChat("Отредактируйте объявление: Куплю аксессуар Бита на спину")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,336))
		if imgui.Button(u8"11.Ответ") then
				sampSendChat("Правильный ответ: Куплю а/с Бита на спину. Бюджет: свободный")
		end
		if imgui.Button(u8"Продам Дилдо") then
				sampSendChat("Отредактируйте объявление: Продам дилдо")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,362))
		if imgui.Button(u8"12.Ответ") then
				sampSendChat("Правильный ответ: Продам а/с резиновая игрушка. Цена: договорная")

		end
		--imgui.Separator()
		if imgui.Button(u8"Продам д/к мангал") then
				sampSendChat("Отредактируйте объявление: Продам декорацию мангал")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,388))
		if imgui.Button(u8"13.Ответ") then
				sampSendChat("Правильный ответ: Продам д/к для дома Мангал. Цена: договорная")
	
		end
		if imgui.Button(u8"Продам симку") then
				sampSendChat("Отредактируйте объявление: Продам симку 1212123")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,414))
		if imgui.Button(u8"14.Ответ") then
				sampSendChat("Правильный ответ: Продам сим-карту формата АБ-АБ-АБВ. Цена: договорная")
		end
		if imgui.Button(u8"Продам модиф. Химик") then
				sampSendChat("Отредактируйте объявление: Продам модификацию Химик")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,440))
		if imgui.Button(u8"15.Ответ") then
				sampSendChat("Правильный ответ: Продам карнавальный костюм Химик. Цена: договорная")
		end
		if imgui.Button(u8"Куплю трейлер") then
				sampSendChat("Отредактируйте объявление: Куплю трейлер")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,466))
		if imgui.Button(u8"16.Ответ") then
				sampSendChat("Правильный ответ: Куплю дом на колёсиках. Бюджет: свободный")
		end
		if imgui.Button(u8"Продам телефон") then
				sampSendChat("Отредактируйте объявление: Продам телефон Самсунг Гэлэкси С10")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,492))
		if imgui.Button(u8"17.Ответ") then
				sampSendChat("Правильный ответ: Продам м/т Самсунг Гэлэкси С10. Цена: договорная")
		end
		if imgui.Button(u8"Куплю р/с бронза") then
				sampSendChat("Отредактируйте объявление: Куплю бронзу за 8к")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,518))
		if imgui.Button(u8"18.Ответ") then
				sampSendChat("Правильный ответ: Куплю р/с бронзовая руда. Цена: 8.000$")
		end
		imgui.SetCursorPos(imgui.ImVec2(242,76))
		if imgui.Button(u8"Продам рулетки") then
				sampSendChat("Отредактируйте объявление: Продам бронзовые рулетки")
		end
		imgui.SameLine()
		imgui.Spacing()
		imgui.SameLine()
		imgui.Spacing()
		imgui.SameLine()
		imgui.Spacing()
		imgui.SameLine()
		imgui.VerticalSeparator()
		imgui.Spacing()
		imgui.SameLine()
		imgui.SetCursorPos(imgui.ImVec2(382,76))
		if imgui.Button(u8"19.Ответ") then
				sampSendChat("Правильный ответ: Продам бронзовые медали. Цена: договорная")
		end
		imgui.SetCursorPos(imgui.ImVec2(242,102))
		if imgui.Button(u8"Набор в семью") then
				sampSendChat("Отредактируйте объявление: Набор в семью Твикс ждём у маяка")
		end
			imgui.SetCursorPos(imgui.ImVec2(382,102))
		if imgui.Button(u8"20.Ответ") then
				sampSendChat("Правильный ответ: Семья Твикс ищет дальних родственников. Ждём у маяка")
		end
		imgui.SetCursorPos(imgui.ImVec2(242,128))
		if imgui.Button(u8"Куплю м/с Джет") then
				sampSendChat("Отредактируйте объявление: Куплю лодку Джетмакс")
		end
			imgui.SetCursorPos(imgui.ImVec2(382,128))
		if imgui.Button(u8"21.Ответ") then
				sampSendChat("Правильный ответ: Куплю м/с марки Джетмакс. Бюджет: свободный")
		end
		imgui.SetCursorPos(imgui.ImVec2(242,154))
		if imgui.Button(u8"Продам в/с БМХ") then
				sampSendChat("Отредактируйте объявление: Продам велосипед БМХ")
		end
			imgui.SetCursorPos(imgui.ImVec2(382,154))
		if imgui.Button(u8"22.Ответ") then
				sampSendChat("Правильный ответ: Продам в/с марки БМХ. Цена: договорная")
		end
		imgui.SetCursorPos(imgui.ImVec2(242,180))
		if imgui.Button(u8"Куплю в/т Маверик") then
				sampSendChat("Отредактируйте объявление: Куплю вертолёт Маверик")
		end
			imgui.SetCursorPos(imgui.ImVec2(382,180))
		if imgui.Button(u8"23.Ответ") then
				sampSendChat("Правильный ответ: Куплю в/т марки Маверик. Бюджет: свободный")
		end
		imgui.SetCursorPos(imgui.ImVec2(242,206))
		if imgui.Button(u8"Продам м/ц ПСЖ") then
				sampSendChat("Отредактируйте объявление: Продам мотоцикл ПСЖ-600")
		end
			imgui.SetCursorPos(imgui.ImVec2(382,206))
		if imgui.Button(u8"24.Ответ") then
				sampSendChat("Правильный ответ: Продам м/ц марки ПСЖ-600. Цена: договорная")
		end
		imgui.SetCursorPos(imgui.ImVec2(242,232))
		if imgui.Button(u8"Продам дом за 1кк") then
				sampSendChat("Отредактируйте объявление: Продам дом за 1кк")
		end
			imgui.SetCursorPos(imgui.ImVec2(382,232))
		if imgui.Button(u8"25.Ответ") then
				sampSendChat("Правильный ответ: Отказ/не указано местоположение дома!")
		end
		imgui.SetCursorPos(imgui.ImVec2(242,258))
		if imgui.Button(u8"Ищу собаку") then
				sampSendChat("Отредактируйте объявление: Ищу собаку по имени Александр Шелби")
		end
			imgui.SetCursorPos(imgui.ImVec2(382,258))
		if imgui.Button(u8"26.Ответ") then
				sampSendChat("Правильный ответ: Отказ/не рекламируем поиски животных!")
		end
		imgui.SetCursorPos(imgui.ImVec2(242,284))
		if imgui.Button(u8"Продам б/з закусь") then
				sampSendChat("Отредактируйте объявление: Продам бизнес закусочная в ЛВ")
		end
			imgui.SetCursorPos(imgui.ImVec2(382,284))
		if imgui.Button(u8"27.Ответ") then
				sampSendChat("Правильный ответ: Продам б/з Закусочная в г.Лас-Вентурас. Цена: договорная")
		end
		imgui.SetCursorPos(imgui.ImVec2(242,310))
		if imgui.Button(u8"Куплю б/з Ларёк 123") then
				sampSendChat("Отредактируйте объявление: Куплю бизнес Ларёк #123")
		end
			imgui.SetCursorPos(imgui.ImVec2(382,310))
		if imgui.Button(u8"28.Ответ") then
				sampSendChat("Правильный ответ: Отказ/уточните местоположение бизнеса. Не указываем айди!")
		end
		imgui.SetCursorPos(imgui.ImVec2(242,336))
		if imgui.Button(u8"Продам АММО") then
				sampSendChat("Отредактируйте объявление: Продам бизнес магазин оружия!")
		end
			imgui.SetCursorPos(imgui.ImVec2(382,336))
		if imgui.Button(u8"29.Ответ") then
				sampSendChat("Правильный ответ: Продам б/з АММО. Цена: договорная")
		end
			imgui.SetCursorPos(imgui.ImVec2(242,362))
		if imgui.Button(u8"Обмен машинами") then
				sampSendChat("Отредактируйте объявление: Обменяю машину Булка на машину Туризмо с доплатой 1кк")
		end
			imgui.SetCursorPos(imgui.ImVec2(382,362))
		if imgui.Button(u8"30.Ответ") then
				sampSendChat("Правильный ответ: Обменяю а/м марки Буллет на а/м марки Туризмо. Доплата: 1.000.000$")
		end
			imgui.SetCursorPos(imgui.ImVec2(242,388))
		if imgui.Button(u8"Обмен бизнесами") then
				sampSendChat("Отредактируйте объявление: Обменяю бизнес закусочная в ЛВ на бизнес Ларёк с едой в СФ")
		end
			imgui.SetCursorPos(imgui.ImVec2(382,388))
		if imgui.Button(u8"31.Ответ") then
				sampSendChat("Правильный ответ: Отказ/запрещено рекламировать обмен бизнесами!")
		end
			imgui.SetCursorPos(imgui.ImVec2(242,414))
		if imgui.Button(u8"Обмен аксами") then
				sampSendChat("Отредактируйте объявление: Обменяю акс лопату +3 на биту +5")
		end
			imgui.SetCursorPos(imgui.ImVec2(382,414))
		if imgui.Button(u8"32.Ответ") then
				sampSendChat("Правильный ответ: Обменяю а/с Лопату с гравировкой +3 на Биту с гравировкой +5. Доплата: договорная")
		end
			imgui.SetCursorPos(imgui.ImVec2(242,440))
		if imgui.Button(u8"Собес СМИ ЛВ") then
				sampSendChat("Отредактируйте объявление: Собес СМИ ЛВ")
		end
			imgui.SetCursorPos(imgui.ImVec2(382,440))
		if imgui.Button(u8"33.Ответ") then
				sampSendChat("Правильный ответ: Проходит собеседование в Радиоцентр г.Лас-Вентурас")
		end
			imgui.SetCursorPos(imgui.ImVec2(242,466))
		if imgui.Button(u8"Собес в ФБР") then
				sampSendChat("Отредактируйте объявление: Собес в ФБР")
		end
			imgui.SetCursorPos(imgui.ImVec2(382,466))
		if imgui.Button(u8"34.Ответ") then
				sampSendChat("Правильный ответ: Отказ/в ФБР собеседования никогда не проходят!")
		end
			imgui.SetCursorPos(imgui.ImVec2(242,492))
		if imgui.Button(u8"Набор в Ацтек") then
				sampSendChat("Отредактируйте объявление: Набор в Ацтек")
		end
			imgui.SetCursorPos(imgui.ImVec2(382,492))
		if imgui.Button(u8"35.Ответ") then
				sampSendChat("Правильный ответ: Проходит набор в БК Ацтек. Ждём на районе")
		end
	end
end