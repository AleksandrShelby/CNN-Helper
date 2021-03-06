script_name('CNN Helper')  
script_author('Shelby') 
script_description('������ �������� ��������� ���/�����/��� � ����������� ���') 

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

local update_url = "https://raw.githubusercontent.com/AleksandrShelby/CNN-Helper/main/update.ini" -- ��� ���� ���� ������
local update_path = getWorkingDirectory() .. "/update.ini" -- � ��� ���� ������

local script_url = "" -- ��� ���� ������
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
	sampAddChatMessage(tag.."{FFFFFF}�����������,{0066ff} "..nick.."["..id.."]{FFFFFF}!", main_color)
	sampAddChatMessage(tag.."{FFFFFF}��� ���� ����� ��������� ������, ������� ������� {0066ff}/cnn", main_color)
	
		downloadUrlToFile(update_url, update_path, function(id, status)
       if status == dlstatus.STATUS_ENDDOWNLOADDATA then
          updateIni = inicfg.load(nil, update_path)
           if tonumber(updateIni.info.vers) > script_vers then
              sampAddChatMessage("tag..�������� ����� ����������! ������: " .. updateIni.info.vers_text, -1)
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
                   sampAddChatMessage(tag.."������ ������� �������!", -1)
                    thisScript():reload()
                end
            end)
            break
        end

	end
	imgui.Process = false
	
		
end	
function cmd_update(arg)
    sampAddChatMessage(tag.."{FFFFFF}� ��� ����������� ��������� ������ �������.", -1)
end

function cmd_cnn(arg)
	main_window_state.v = not main_window_state.v
	imgui.Process = main_window_state.v
 end
 function imgui.Hint(text, delay)
    if imgui.IsItemHovered() then
        if go_hint == nil then go_hint = os.clock() + (delay and delay or 0.0) end
        local alpha = (os.clock() - go_hint) * 5 -- �������� ���������
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
	imgui.Begin(u8"�������� ���/�����/���", main_window_state)
	if imgui.CollapsingHeader(u8'�������� ������ �������������� ����������') then
 
	if imgui.Button(u8"������") then
			lua_thread.create(function()
				sampSendChat("� ��������� ��� ����������, �� ��� ������������!")
				wait(2000)
				sampSendChat("/n ������ ������ � /do")
				wait(2000)
				sampSendChat("�� ��� �.. ������?")
			end)
		end
		imgui.SameLine()
		if imgui.Button(u8"�����") then
				sampSendChat("�����!")
		end
		imgui.SameLine()
		if imgui.Button(u8"�������") then
				sampSendChat("�������!")
		end
		imgui.Separator()
		imgui.SetCursorPos(imgui.ImVec2(3,76))
			if imgui.Button(u8"������ ��� � ��(�+�) 2��") then
				sampSendChat("�������������� ����������: ������ ��� � �� �+� �� 2�� ")
		end
		imgui.SameLine()
		imgui.VerticalSeparator()
		imgui.SetCursorPos(imgui.ImVec2(178,76))
		if imgui.Button(u8"�����##1") then
				sampSendChat("���������� �����: ������ ��� � ������� � �������� � �.���-������. ����: 2.000.000$")
		end
		imgui.SameLine()
		imgui.VerticalSeparator()
		imgui.SetCursorPos(imgui.ImVec2(3,102))
			if imgui.Button(u8"����� ��� � �������") then
				sampSendChat("�������������� ����������: ����� ��� � �������")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,102))
		if imgui.Button(u8"�����##2") then
				sampSendChat("���������� �����: ����� ��� � ������� � ����� ����� �����. ������: ���������")
		end
		if imgui.Button(u8"����� ��� � �����") then
				sampSendChat("�������������� ����������: ����� ��� � �������")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,128))
		if imgui.Button(u8"3.�����") then
				sampSendChat("���������� �����: ����� ��� � ������� ������. ������: ���������")
		end
		--imgui.Separator()
		if imgui.Button(u8"������ ������ �� 5��") then
				sampSendChat("�������������� ����������: ����� ��� � �����")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,154))
		if imgui.Button(u8"4.�����") then
				sampSendChat("���������� �����: ������ �/� ����� ������. ����: 5.000.000$")
		end
		if imgui.Button(u8"����� ������ ��") then
				sampSendChat("�������������� ����������: ����� ����� � ��")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,180))
		if imgui.Button(u8"5.�����") then
				sampSendChat("���������� �����: ����� �/� ����� ������ � ������� ����-�����. ������: ���������")
		end
		--imgui.Separator()
		if imgui.Button(u8"������ 123 ����") then
				sampSendChat("�������������� ����������: ������ 123 ����")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,206))
		if imgui.Button(u8"6.�����") then
				sampSendChat("���������� �����: ������ ������ � ������ 123. ����: ����������")
		end
		if imgui.Button(u8"����� ���� ������") then
				sampSendChat("�������������� ����������: ����� ���� ������")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,232))
		if imgui.Button(u8"7.�����") then
				sampSendChat("���������� �����: ����� ������ ������ �����. ������: ���������")
		end
		--imgui.Separator()
			if imgui.Button(u8"������ �� �� 8��") then
				sampSendChat("�������������� ����������: ������ �� �� 8��")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,258))
		if imgui.Button(u8"8.�����") then
				sampSendChat("���������� �����: ������ ����� ����-�����. ����: 8.000.000$")
		end
		if imgui.Button(u8"����� ������") then
				sampSendChat("�������������� ����������: ����� ������")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,284))
		if imgui.Button(u8"9.�����") then
				sampSendChat("���������� �����: ����� �������� ������. ������: ���������")
		end
		--imgui.Separator()
			if imgui.Button(u8"������ ��� ����") then
				sampSendChat("�������������� ����������: ������ ��������� ����")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,310))
		if imgui.Button(u8"10.�����") then
				sampSendChat("���������� �����: �����/�� ����������� �������/������� �����. ����������� ���������")
		end
		if imgui.Button(u8"����� ��� ����") then
				sampSendChat("�������������� ����������: ����� ��������� ���� �� �����")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,336))
		if imgui.Button(u8"11.�����") then
				sampSendChat("���������� �����: ����� �/� ���� �� �����. ������: ���������")
		end
		if imgui.Button(u8"������ �����") then
				sampSendChat("�������������� ����������: ������ �����")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,362))
		if imgui.Button(u8"12.�����") then
				sampSendChat("���������� �����: ������ �/� ��������� �������. ����: ����������")

		end
		--imgui.Separator()
		if imgui.Button(u8"������ �/� ������") then
				sampSendChat("�������������� ����������: ������ ��������� ������")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,388))
		if imgui.Button(u8"13.�����") then
				sampSendChat("���������� �����: ������ �/� ��� ���� ������. ����: ����������")
	
		end
		if imgui.Button(u8"������ �����") then
				sampSendChat("�������������� ����������: ������ ����� 1212123")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,414))
		if imgui.Button(u8"14.�����") then
				sampSendChat("���������� �����: ������ ���-����� ������� ��-��-���. ����: ����������")
		end
		if imgui.Button(u8"������ �����. �����") then
				sampSendChat("�������������� ����������: ������ ����������� �����")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,440))
		if imgui.Button(u8"15.�����") then
				sampSendChat("���������� �����: ������ ������������ ������ �����. ����: ����������")
		end
		if imgui.Button(u8"����� �������") then
				sampSendChat("�������������� ����������: ����� �������")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,466))
		if imgui.Button(u8"16.�����") then
				sampSendChat("���������� �����: ����� ��� �� ��������. ������: ���������")
		end
		if imgui.Button(u8"������ �������") then
				sampSendChat("�������������� ����������: ������ ������� ������� ������� �10")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,492))
		if imgui.Button(u8"17.�����") then
				sampSendChat("���������� �����: ������ �/� ������� ������� �10. ����: ����������")
		end
		if imgui.Button(u8"����� �/� ������") then
				sampSendChat("�������������� ����������: ����� ������ �� 8�")
		end
		imgui.SetCursorPos(imgui.ImVec2(178,518))
		if imgui.Button(u8"18.�����") then
				sampSendChat("���������� �����: ����� �/� ��������� ����. ����: 8.000$")
		end
		imgui.SetCursorPos(imgui.ImVec2(242,76))
		if imgui.Button(u8"������ �������") then
				sampSendChat("�������������� ����������: ������ ��������� �������")
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
		if imgui.Button(u8"19.�����") then
				sampSendChat("���������� �����: ������ ��������� ������. ����: ����������")
		end
		imgui.SetCursorPos(imgui.ImVec2(242,102))
		if imgui.Button(u8"����� � �����") then
				sampSendChat("�������������� ����������: ����� � ����� ����� ��� � �����")
		end
			imgui.SetCursorPos(imgui.ImVec2(382,102))
		if imgui.Button(u8"20.�����") then
				sampSendChat("���������� �����: ����� ����� ���� ������� �������������. ��� � �����")
		end
		imgui.SetCursorPos(imgui.ImVec2(242,128))
		if imgui.Button(u8"����� �/� ����") then
				sampSendChat("�������������� ����������: ����� ����� ��������")
		end
			imgui.SetCursorPos(imgui.ImVec2(382,128))
		if imgui.Button(u8"21.�����") then
				sampSendChat("���������� �����: ����� �/� ����� ��������. ������: ���������")
		end
		imgui.SetCursorPos(imgui.ImVec2(242,154))
		if imgui.Button(u8"������ �/� ���") then
				sampSendChat("�������������� ����������: ������ ��������� ���")
		end
			imgui.SetCursorPos(imgui.ImVec2(382,154))
		if imgui.Button(u8"22.�����") then
				sampSendChat("���������� �����: ������ �/� ����� ���. ����: ����������")
		end
		imgui.SetCursorPos(imgui.ImVec2(242,180))
		if imgui.Button(u8"����� �/� �������") then
				sampSendChat("�������������� ����������: ����� ������� �������")
		end
			imgui.SetCursorPos(imgui.ImVec2(382,180))
		if imgui.Button(u8"23.�����") then
				sampSendChat("���������� �����: ����� �/� ����� �������. ������: ���������")
		end
		imgui.SetCursorPos(imgui.ImVec2(242,206))
		if imgui.Button(u8"������ �/� ���") then
				sampSendChat("�������������� ����������: ������ �������� ���-600")
		end
			imgui.SetCursorPos(imgui.ImVec2(382,206))
		if imgui.Button(u8"24.�����") then
				sampSendChat("���������� �����: ������ �/� ����� ���-600. ����: ����������")
		end
		imgui.SetCursorPos(imgui.ImVec2(242,232))
		if imgui.Button(u8"������ ��� �� 1��") then
				sampSendChat("�������������� ����������: ������ ��� �� 1��")
		end
			imgui.SetCursorPos(imgui.ImVec2(382,232))
		if imgui.Button(u8"25.�����") then
				sampSendChat("���������� �����: �����/�� ������� �������������� ����!")
		end
		imgui.SetCursorPos(imgui.ImVec2(242,258))
		if imgui.Button(u8"��� ������") then
				sampSendChat("�������������� ����������: ��� ������ �� ����� ��������� �����")
		end
			imgui.SetCursorPos(imgui.ImVec2(382,258))
		if imgui.Button(u8"26.�����") then
				sampSendChat("���������� �����: �����/�� ����������� ������ ��������!")
		end
		imgui.SetCursorPos(imgui.ImVec2(242,284))
		if imgui.Button(u8"������ �/� ������") then
				sampSendChat("�������������� ����������: ������ ������ ���������� � ��")
		end
			imgui.SetCursorPos(imgui.ImVec2(382,284))
		if imgui.Button(u8"27.�����") then
				sampSendChat("���������� �����: ������ �/� ���������� � �.���-��������. ����: ����������")
		end
		imgui.SetCursorPos(imgui.ImVec2(242,310))
		if imgui.Button(u8"����� �/� ���� 123") then
				sampSendChat("�������������� ����������: ����� ������ ���� #123")
		end
			imgui.SetCursorPos(imgui.ImVec2(382,310))
		if imgui.Button(u8"28.�����") then
				sampSendChat("���������� �����: �����/�������� �������������� �������. �� ��������� ����!")
		end
		imgui.SetCursorPos(imgui.ImVec2(242,336))
		if imgui.Button(u8"������ ����") then
				sampSendChat("�������������� ����������: ������ ������ ������� ������!")
		end
			imgui.SetCursorPos(imgui.ImVec2(382,336))
		if imgui.Button(u8"29.�����") then
				sampSendChat("���������� �����: ������ �/� ����. ����: ����������")
		end
			imgui.SetCursorPos(imgui.ImVec2(242,362))
		if imgui.Button(u8"����� ��������") then
				sampSendChat("�������������� ����������: ������� ������ ����� �� ������ ������� � �������� 1��")
		end
			imgui.SetCursorPos(imgui.ImVec2(382,362))
		if imgui.Button(u8"30.�����") then
				sampSendChat("���������� �����: ������� �/� ����� ������ �� �/� ����� �������. �������: 1.000.000$")
		end
			imgui.SetCursorPos(imgui.ImVec2(242,388))
		if imgui.Button(u8"����� ���������") then
				sampSendChat("�������������� ����������: ������� ������ ���������� � �� �� ������ ���� � ���� � ��")
		end
			imgui.SetCursorPos(imgui.ImVec2(382,388))
		if imgui.Button(u8"31.�����") then
				sampSendChat("���������� �����: �����/��������� ������������� ����� ���������!")
		end
			imgui.SetCursorPos(imgui.ImVec2(242,414))
		if imgui.Button(u8"����� ������") then
				sampSendChat("�������������� ����������: ������� ��� ������ +3 �� ���� +5")
		end
			imgui.SetCursorPos(imgui.ImVec2(382,414))
		if imgui.Button(u8"32.�����") then
				sampSendChat("���������� �����: ������� �/� ������ � ����������� +3 �� ���� � ����������� +5. �������: ����������")
		end
			imgui.SetCursorPos(imgui.ImVec2(242,440))
		if imgui.Button(u8"����� ��� ��") then
				sampSendChat("�������������� ����������: ����� ��� ��")
		end
			imgui.SetCursorPos(imgui.ImVec2(382,440))
		if imgui.Button(u8"33.�����") then
				sampSendChat("���������� �����: �������� ������������� � ���������� �.���-��������")
		end
			imgui.SetCursorPos(imgui.ImVec2(242,466))
		if imgui.Button(u8"����� � ���") then
				sampSendChat("�������������� ����������: ����� � ���")
		end
			imgui.SetCursorPos(imgui.ImVec2(382,466))
		if imgui.Button(u8"34.�����") then
				sampSendChat("���������� �����: �����/� ��� ������������� ������� �� ��������!")
		end
			imgui.SetCursorPos(imgui.ImVec2(242,492))
		if imgui.Button(u8"����� � �����") then
				sampSendChat("�������������� ����������: ����� � �����")
		end
			imgui.SetCursorPos(imgui.ImVec2(382,492))
		if imgui.Button(u8"35.�����") then
				sampSendChat("���������� �����: �������� ����� � �� �����. ��� �� ������")
		end
	end
	if imgui.Button(u8"��������") then
				sampAddChatMessage(u8"��������", -1)
		end
end