import 'CoreLibs/graphics'
import "CoreLibs/ui"
import "CoreLibs/timer"
import "CoreLibs/crank"
import "CoreLibs/sprites"
import "CoreLibs/animation"
import "CoreLibs/animator"
import "CoreLibs/easing"

local pd <const> = playdate
local gfx <const> = playdate.graphics
local screenWidth <const> = playdate.display.getWidth() + 1
local screenHeight <const> = playdate.display.getHeight() + 1

local IMG_ABOUT <const> = gfx.image.new("img/about")
playdate.setMenuImage(IMG_ABOUT)

local FRAMERATE_CONFIG <const> = {
    normal = 30,
    low = 10,
}
local FONT_READER <const> = {
    Sans_20 = {
        name = "SourceHanSansCN-M-20px",
        font = gfx.font.new('font/SourceHanSansCN-M-20px'),
        lineheight = 1.6,
    },
    Serif_24 = {
        name = "SourceHanSerifCN-SemiBold-24px",
        font = gfx.font.new('font/SourceHanSerifCN-SemiBold-24px'),
        lineheight = 1.6,
    },
    LXGW_24 = {
        name = "LXGWWenKaiGBScreen-24px",
        font = gfx.font.new('font/LXGWWenKaiGBScreen-24px'),
        lineheight = 1.3,
    },
    pixel_12 = {
        name = "fusion-pixel-font-12px-proportional-zh_hans",
        font = gfx.font.new('font/fusion-pixel-font-12px-proportional-zh_hans'),
        lineheight = 1.4,
    }, 
}
local FONT <const> = {
    Nontendo_Light = {
        name = "Nontendo-Light",
        font = gfx.font.new('font/Nontendo-Light')
    },
    font_full_circle_halved = {
        name = "font-full-circle-halved",
        font = gfx.font.new('font/font-full-circle-halved')
    },
    font_full_circle = {
        name = "font-full-circle",
        font = gfx.font.new('font/font-full-circle')
    },
    Asheville_Rounded_24_px = {
        name = "Asheville-Rounded-24-px",
        font = gfx.font.new('font/Asheville-Rounded-24-px')
    }
}
local SFX <const> = {
    selection = {
        sound = pd.sound.fileplayer.new("sound/selection")
    },
    selection_reverse = {
        sound = pd.sound.fileplayer.new("sound/selection-reverse")
    },
    denial = {
        sound = pd.sound.fileplayer.new("sound/denial")
    },
    key = {
        sound = pd.sound.fileplayer.new("sound/key")
    },
    slide_in = {
        sound = pd.sound.fileplayer.new("sound/slide_in")
    },
    slide_out = {
        sound = pd.sound.fileplayer.new("sound/slide_out")
    },
    click = {
        sound = pd.sound.fileplayer.new("sound/click")
    }
}
local SFX_paper <const> = {
    pd.sound.fileplayer.new("sound/paper1"),
    pd.sound.fileplayer.new("sound/paper2"),
    pd.sound.fileplayer.new("sound/paper3"),
    pd.sound.fileplayer.new("sound/paper4"),
    pd.sound.fileplayer.new("sound/paper5"),
    pd.sound.fileplayer.new("sound/paper6"),
    pd.sound.fileplayer.new("sound/paper7"),
    pd.sound.fileplayer.new("sound/paper8"),
    pd.sound.fileplayer.new("sound/paper9"),
    pd.sound.fileplayer.new("sound/paper10"),
    pd.sound.fileplayer.new("sound/paper11"),
    pd.sound.fileplayer.new("sound/paper12"),
    pd.sound.fileplayer.new("sound/paper13"),
    pd.sound.fileplayer.new("sound/paper14"),
}
local trun_on_paper_sfx = true
local default_books = {
    "快速上手指南.PRT",
    "围城 第一章 - 钱钟书.PRT",
    "一只特立独行的猪 - 王小波.PRT",
}
local indicator_img <const> = {
    list_A = gfx.image.new("img/indicator_A"),
    glance_mask = gfx.image.new("img/glance-mask"),
    glance_mask_side = gfx.image.new("img/glance-mask-side"),
    glance_hint_A = gfx.image.new("img/glance_hint_A"),
    glance_hint_B = gfx.image.new("img/glance_hint_B"),
}
local main_screen_header <const> = {
    gfx.image.new("img/bg1"),
    gfx.image.new("img/bg2"),
    gfx.image.new("img/bg3"),
    gfx.image.new("img/bg4"),
    gfx.image.new("img/bg5"),
    gfx.image.new("img/bg6"),
    gfx.image.new("img/bg7"),
    gfx.image.new("img/bg8"),
    gfx.image.new("img/bg9"),
    gfx.image.new("img/bg10"),
    gfx.image.new("img/bg11"),
    gfx.image.new("img/bg12"),
    gfx.image.new("img/bg13"),
    gfx.image.new("img/bg14"),
    gfx.image.new("img/bg15"),
    gfx.image.new("img/bg16"),
    gfx.image.new("img/bg17"),
    gfx.image.new("img/bg18"),
    gfx.image.new("img/bg19"),
    gfx.image.new("img/bg20"),
    gfx.image.new("img/bg21"),
    gfx.image.new("img/bg22"),
    gfx.image.new("img/bg23"),
    gfx.image.new("img/bg24"),
    gfx.image.new("img/bg25"),
}
local main_screen_header_index = math.random(#main_screen_header)
local STAGE = {}
local stage_manager = "file_list"
local is_first_install = true

local reader_menu = playdate.getSystemMenu()
local reader_side_mode = false
local dark_mode = false

local prt_tbl = {}
local arrow_btn_skip_cnt_sensitivity = 100
local current_select_file_index = 1

local reader_page_index_tbl = {}
local reader_page_index = 1
local glance_page_index = 1
local glance_page_index_lazy = 1
local force_update_reader_render = false
local reader_tbl_cache = {}
local reader_padding = {
    width = 8,
    height = 8
}
local page_index_cache = {}
local reader_font_selection = "Sans_20"
local draw_reader_init = false
local reader_sprite = gfx.sprite.new()

local is_auto_page_turn_on = false
local is_start_new_timer_cycle = true
local auto_page_turn_sec = 10
local auto_page_turn_sec_lazy = 0
local page_turn_setting_ui = gfx.sprite.new(gfx.image.new("img/frame_auto_page_turn"))
local page_turn_setting_ui_num = gfx.sprite.new()
local page_turn_setting_ui_num_offset_coord = {
    x = 0,
    y = 30,
}
reader_sprite:setCenter(0,0)
reader_sprite:moveTo(screenWidth, 0)
reader_sprite:add()
page_turn_setting_ui:moveTo(screenWidth/2, screenHeight*1.6)
page_turn_setting_ui:setZIndex(300)
page_turn_setting_ui:add()
page_turn_setting_ui_num:moveTo(screenWidth/2+page_turn_setting_ui_num_offset_coord.x, screenHeight*1.6+page_turn_setting_ui_num_offset_coord.y)
page_turn_setting_ui_num:setZIndex(310)
page_turn_setting_ui_num:add()
local auto_page_turn_indicator = gfx.sprite.new(gfx.image.new(4,screenHeight,playdate.graphics.kColorBlack))
auto_page_turn_indicator:setCenter(1,1)
auto_page_turn_indicator:setZIndex(290)
auto_page_turn_indicator:moveTo(screenWidth, 0)
local auto_page_turn_indicator_side = gfx.sprite.new(gfx.image.new(screenWidth,4,playdate.graphics.kColorBlack))
auto_page_turn_indicator_side:setCenter(0,1)
auto_page_turn_indicator_side:setZIndex(290)
auto_page_turn_indicator_side:moveTo(screenWidth, screenHeight)

----------------utils

function mapValue(old_value, old_min, old_max, new_min, new_max)
    return ((old_value - old_min) * (new_max - new_min) / (old_max - old_min) + new_min)
end


function get_time_now_as_string()
    local minute = playdate.getTime().minute
    if minute <10 then
        minute = "0"..minute
    end
    local second = playdate.getTime().second
    if second <10 then
        second = "0"..second
    end

    return playdate.getTime().hour..":"..minute
end

function tableContainsKey(tbl, x)
    for j, v in pairs(tbl) do
        if j == x then
            return true
        end
    end
    return false
end

-- Get a value from a table if it exists or return a default value
local get_or_default = function (table, key, expectedType, default)
	local value = table[key]
	if value == nil then
		return default
	else
		if type(value) ~= expectedType then
			print("Warning: value for key " .. key .. " is type " .. type(value) .. " but expected type " .. expectedType)
			return default
		end
		return value
	end
end

-- Save the state of the game to the datastore
function save_state()
	print("Saving state...")
	local state = {}
    state["page_index_cache"] = page_index_cache
    state["reader_font_selection"] = reader_font_selection
    state["reader_side_mode"] = reader_side_mode
    state["dark_mode"] = dark_mode
    state["is_first_install"] = is_first_install
    state["trun_on_paper_sfx"] = trun_on_paper_sfx
    state["auto_page_turn_sec"] = auto_page_turn_sec

	playdate.datastore.write(state)
	print("State saved!")
end


-- Load the state of the game from the datastore
function load_state()
	print("Loading state...")
	local state = playdate.datastore.read()
	if state == nil then
		print("No state found, using defaults")
        state = {}
	else
		print("State found!")
	end

    page_index_cache = get_or_default(state, "page_index_cache", "table", {})
    reader_font_selection = get_or_default(state, "reader_font_selection", "string", "Sans_20")
    reader_side_mode = get_or_default(state, "reader_side_mode", "boolean", false)
    dark_mode = get_or_default(state, "dark_mode", "boolean", false)
    is_first_install = get_or_default(state, "is_first_install", "boolean", true)
    trun_on_paper_sfx = get_or_default(state, "trun_on_paper_sfx", "boolean", true)
    auto_page_turn_sec = get_or_default(state, "auto_page_turn_sec", "number", 10)

end

function note_sidebar_option()
    local font_option = {}
    for k, v in pairs(FONT_READER) do
        table.insert(font_option, k)
    end
    local modeMenuItem, error = reader_menu:addOptionsMenuItem("font", font_option, reader_font_selection, function(value)
        reader_font_selection = value
        draw_reader_init = false
        save_state()
    end)
    local modeMenuItem, error = reader_menu:addCheckmarkMenuItem("side mode", reader_side_mode, function(value)
        reader_side_mode = value
        draw_reader_init = false
        is_start_new_timer_cycle = true
        save_state()
    end)
    local modeMenuItem, error = reader_menu:addCheckmarkMenuItem("dark", dark_mode, function(value)
        dark_mode = value
        setInverted(dark_mode)
        save_state()
    end)
end

function setInverted(inverted)
	playdate.display.setInverted(inverted)
end

function getPRTfiletable()
    local tbl = pd.file.listFiles()
    local prts = {}

    for i, v in pairs(tbl) do
        if type(v) == 'string' and v:sub(-4) == '.PRT' then
            table.insert(prts, v)
        end
    end

    prt_tbl = prts
end

function add_init_file()
    local json_cache = json.decodeFile("default_book/快速上手指南.PRT")
    json.encodeToFile("快速上手指南.PRT", json_cache)
end

function add_default_books()
    local json_cache
    for k, v in pairs(default_books) do
        json_cache = json.decodeFile("default_book/"..v)
        json.encodeToFile(v, json_cache)
    end
end

function is_auto_page_turn_on_switcher()
    if is_auto_page_turn_on then
        is_auto_page_turn_on = false
        auto_page_turn_indicator:remove()
        auto_page_turn_indicator:moveTo(screenWidth, 0)
        auto_page_turn_indicator_side:remove()
        auto_page_turn_indicator_side:moveTo(screenWidth, screenHeight)
        -- playdate.display.setRefreshRate(FRAMERATE_CONFIG.normal)
    else
        auto_page_turn_indicator:add()
        auto_page_turn_indicator_side:add()
        is_auto_page_turn_on = true
        is_start_new_timer_cycle = true
        -- playdate.display.setRefreshRate(FRAMERATE_CONFIG.low)
    end
end

function draw_text_area(text_tbl, lineheight_factor, char_kerning, font, draw_mode, start_x, start_y, width, height)
    -- example:
    -- draw_text_area({"你","好"}, 1.6, 0, gfx.font.new('font/SourceHanSansCN-M-20px'), playdate.graphics.kDrawModeCopy, 0, 0, 300, 200)
    --
    -- return:
    -- char_offset: how many chars has been drawn

    function _findNextSpaceIndex(tbl, index)
        if index >= #tbl then
            return -1
        end
        for i = index + 1, #tbl do
            if tbl[i] == " " then
                if i > 12 then  --max line break char length
                    return -1
                else
                    return i
                end
            end
        end
        return -1
    end

    local char_offset = 1
    local current_x = start_x
    local current_y = start_y
    gfx.setFont(font)
    gfx.setImageDrawMode(draw_mode)
    local max_zh_char_size = gfx.getTextSize("啊") + char_kerning
    local lineheight = max_zh_char_size * lineheight_factor

    function _linebreak_offset()
        current_x = start_x
        current_y += lineheight
    end

    for key, char in pairs(text_tbl) do
        if current_y > height - lineheight then
            break
        end

        if char == "\n" then
            _linebreak_offset()
        else
            if char == " " then  --word break
                local next_space_index = _findNextSpaceIndex(text_tbl, key)
                local word_width = 0
                if next_space_index > 1 and next_space_index > key then
                    for i = key+1, next_space_index do
                        word_width += gfx.getTextSize(text_tbl[i]) + char_kerning
                    end
                    if current_x + word_width > width - max_zh_char_size then
                        _linebreak_offset()
                    end
                end
            end
            
            gfx.drawTextAligned(char, current_x, current_y, kTextAlignment.left)
            current_x += gfx.getTextSize(char) + char_kerning
        end
        
        if current_x > width - max_zh_char_size then
            _linebreak_offset()
        end

        char_offset += 1
    end

    return char_offset
end


function calc_text_tbl(text_tbl, lineheight_factor, char_kerning, font, width, height)

    function _findNextSpaceIndex(tbl, index)
        if index >= #tbl then
            return -1
        end
        for i = index + 1, #tbl do
            if tbl[i] == " " then
                if i > 12 then  --max line break char length
                    return -1
                else
                    return i
                end
            end
        end
        return -1
    end

    local per_page_start_char_index_tbl = {1}
    local char_offset = 1
    local current_x = 0
    local current_y = 0
    gfx.setFont(font)
    local max_zh_char_size = gfx.getTextSize("啊") + char_kerning
    local lineheight = max_zh_char_size * lineheight_factor

    function _linebreak_offset()
        current_x = 0
        current_y += lineheight
    end

    for key, char in pairs(text_tbl) do
        if current_y > height - lineheight then
            current_y = 0
            table.insert(per_page_start_char_index_tbl, char_offset)
        end

        if char == "\n" then
            _linebreak_offset()
        else
            if char == " " then  --word break
                local next_space_index = _findNextSpaceIndex(text_tbl, key)
                local word_width = 0
                if next_space_index > 1 and next_space_index > key then
                    for i = key+1, next_space_index do
                        word_width += gfx.getTextSize(text_tbl[i]) + char_kerning
                    end
                    if current_x + word_width > width - max_zh_char_size then
                        _linebreak_offset()
                    end
                end
            end
            
            current_x += gfx.getTextSize(char) + char_kerning
        end
        
        if current_x > width - max_zh_char_size then
            _linebreak_offset()
        end

        char_offset += 1
    end

    return per_page_start_char_index_tbl
end

-----------------


function draw_page_indicator(screen_width, width, y)
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
    gfx.setFont(FONT["font_full_circle_halved"].font)
    local auto_page_indicator_string = ""
    if is_auto_page_turn_on then
        auto_page_indicator_string = "AUTO "..auto_page_turn_sec
    end
    -- local index_x = (screen_width-width)/2 + (reader_page_index/#reader_page_index_tbl)*width
    local index_x = mapValue(reader_page_index/#reader_page_index_tbl, 0, 1, (screen_width-width)/2, screen_width-(screen_width-width)/2)
    if index_x > (screen_width/2) then
        gfx.drawTextAligned(reader_page_index, index_x, y, kTextAlignment.right)
        gfx.drawTextAligned(get_time_now_as_string().."  "..auto_page_indicator_string, (screen_width-width)/2, y+1, kTextAlignment.left)
    else
        gfx.drawTextAligned(reader_page_index, index_x, y, kTextAlignment.left)
        gfx.drawTextAligned(auto_page_indicator_string.."  "..get_time_now_as_string(), width+(screen_width-width)/2, y+1, kTextAlignment.right)
    end
end

function draw_page_indicator_glance(screen_width, width, y)
    -- local index_x = (screen_width-width)/2 + (reader_page_index/#reader_page_index_tbl)*width
    local index_x = mapValue(reader_page_index/#reader_page_index_tbl, 0, 1, (screen_width-width)/2, screen_width-(screen_width-width)/2)

    gfx.setImageDrawMode(gfx.kDrawModeCopy)
    indicator_img.glance_hint_B:draw(index_x-14, y+3)

    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.setFont(FONT["font_full_circle_halved"].font)
    gfx.drawTextAligned(reader_page_index, index_x, y, kTextAlignment.left)

    local index_x2 = mapValue(glance_page_index/#reader_page_index_tbl, 0, 1, (screen_width-width)/2, screen_width-(screen_width-width)/2-70)
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
    indicator_img.glance_hint_A:draw(index_x2-60, y-3)

    gfx.setFont(FONT["font_full_circle"].font)
    gfx.drawTextAligned(glance_page_index, index_x2+14, y, kTextAlignment.left)

end


local draw_file_list_init = false
local draw_file_list_size, draw_file_list_gridview, draw_file_list_gridviewSprite
function draw_file_list()
    if not draw_file_list_init then
        getPRTfiletable()
        if #prt_tbl == 0 then
            add_init_file()
            getPRTfiletable()
        end

        gfx.setFont(FONT_READER["Sans_20"].font)
        draw_file_list_size = gfx.getTextSize("我")
        draw_file_list_gridview = pd.ui.gridview.new(0, draw_file_list_size*1.5+2)
        draw_file_list_gridview:setNumberOfRows((#prt_tbl))
        draw_file_list_gridview:setCellPadding(0,0,4,0)
        draw_file_list_gridview:setSectionHeaderHeight(42)

        draw_file_list_gridviewSprite = gfx.sprite.new()
        draw_file_list_gridviewSprite:setCenter(0,0)
        draw_file_list_gridviewSprite:moveTo(screenWidth, 0)
        draw_file_list_gridviewSprite:setZIndex(100)
        draw_file_list_gridviewSprite:add()

        draw_file_list_init = true
    end

    function draw_file_list_gridview:drawSectionHeader(section, x, y, width, height)
        main_screen_header[main_screen_header_index]:draw(0, y)
    end

    function draw_file_list_gridview:drawCell(section, row, column, selected, x, y, width, height)
        gfx.setFont(FONT_READER["Sans_20"].font)
        if selected then
            gfx.fillRect(x, y, width, height)
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
            gfx.drawTextAligned(prt_tbl[row]:sub(1,-5), x+10, y+5, 350, draw_file_list_size*1.5*2)
            gfx.setImageDrawMode(gfx.kDrawModeCopy)
            indicator_img.list_A:draw(screenWidth-50, y)
        else
            gfx.setImageDrawMode(gfx.kDrawModeCopy)
            gfx.drawTextAligned(prt_tbl[row]:sub(1,-5), x+10, y+5, 350, draw_file_list_size*1.5*2)
        end
        
    end

    function _scroll_select_file_gridview(direction)
        if direction == "next" then
            draw_file_list_gridview:selectNextRow(true)
        elseif direction == "previous" then
            draw_file_list_gridview:selectPreviousRow(true)
        end
        SFX.selection.sound:play()
    end

    local crankTicks = pd.getCrankTicks(10)
    if crankTicks == 1 then
        _scroll_select_file_gridview("next")
    elseif crankTicks == -1 then
        _scroll_select_file_gridview("previous")
    end

    if pd.buttonIsPressed(pd.kButtonDown) then
        arrow_btn_skip_cnt_sensitivity += 1
        if arrow_btn_skip_cnt_sensitivity > 4 then
            arrow_btn_skip_cnt_sensitivity = 0
            _scroll_select_file_gridview("next")
        end
    elseif pd.buttonIsPressed(pd.kButtonUp) then
        arrow_btn_skip_cnt_sensitivity += 1
        if arrow_btn_skip_cnt_sensitivity > 4 then
            arrow_btn_skip_cnt_sensitivity = 0
            _scroll_select_file_gridview("previous")
        end
    end
    if pd.buttonJustReleased(pd.kButtonDown) or pd.buttonJustReleased(pd.kButtonUp) then
        arrow_btn_skip_cnt_sensitivity = 100
    end

    _, current_select_file_index, _ = draw_file_list_gridview:getSelection()
    
    ----------------------draw
    if draw_file_list_gridview.needsDisplay then
        local pos = {
            x=screenWidth,
            y=screenHeight,
        }
        local gridviewImage = gfx.image.new(pos.x,pos.y)
        gfx.pushContext(gridviewImage)
            draw_file_list_gridview:drawInRect(0, 0, pos.x, pos.y)
        gfx.popContext()
        draw_file_list_gridviewSprite:setImage(gridviewImage)
    end


end


local draw_file_list_animation_init = false
local draw_file_list_animator
function draw_file_list_animation(type)
    if not draw_file_list_animation_init then
        if type == "out" then
            draw_file_list_animator = gfx.animator.new(200, 0, -screenWidth, playdate.easingFunctions.outQuart)
        elseif type == "in" then
            draw_file_list_animator = gfx.animator.new(200, -screenWidth, 0, playdate.easingFunctions.outQuart)
        end
        draw_file_list_animation_init = true
    else
        if not draw_file_list_animator:ended() then
            draw_file_list_gridviewSprite:moveTo(draw_file_list_animator:currentValue(),0)
        end
    end
end


local draw_reader_animation_init = false
local draw_reader_animator
function draw_reader_animation(type)
    if not draw_reader_animation_init then
        if type == "out" then
            draw_reader_animator = gfx.animator.new(200, 0, screenWidth, playdate.easingFunctions.outQuart)
        elseif type == "in" then
            draw_reader_animator = gfx.animator.new(200, screenWidth, 0, playdate.easingFunctions.outQuart)
        end
        draw_reader_animation_init = true
    else
        if not draw_reader_animator:ended() then
            reader_sprite:moveTo(draw_reader_animator:currentValue(),0)
        end
    end
end


function draw_reader(container_width, container_height, rotation, is_glance_mode)
    function _update_reader()
        local page_index
        if is_glance_mode then
            page_index = glance_page_index
        else
            page_index = reader_page_index
        end

        local image = gfx.image.new(container_width, container_height)
        local tbl_to_render = {}
        if page_index > #reader_page_index_tbl then
            page_index = #reader_page_index_tbl - 1
            reader_page_index = #reader_page_index_tbl - 1  --not close env
        end
        local start_index = reader_page_index_tbl[page_index]
        local end_index = start_index+1
        if page_index == #reader_page_index_tbl then
            end_index = #reader_tbl_cache.text
        else
            end_index = reader_page_index_tbl[page_index +1]
        end
        -- print("start_index", start_index, "end_index", end_index)
        for i=start_index, end_index do
            table.insert(tbl_to_render, reader_tbl_cache.text[i])
        end
        gfx.pushContext(image)
            draw_text_area(tbl_to_render, FONT_READER[reader_font_selection].lineheight, 0, FONT_READER[reader_font_selection].font, playdate.graphics.kDrawModeCopy, reader_padding.width, reader_padding.height, container_width-reader_padding.width, container_height)
            
            if is_glance_mode then
                if rotation == 90 then
                    indicator_img.glance_mask_side:draw(0, 1)
                elseif rotation == 0 then
                    indicator_img.glance_mask:draw(0, 0)
                end
                draw_page_indicator_glance(container_width, container_width-reader_padding.width*4, container_height-14)
            else
                if trun_on_paper_sfx then
                    SFX_paper[math.random(#SFX_paper)]:play()
                end
                draw_page_indicator(container_width, container_width-reader_padding.width*4, container_height-14)
            end
        gfx.popContext()
        reader_sprite:setImage(image:rotatedImage(rotation))

        page_index_cache[prt_tbl[current_select_file_index]] = page_index
        force_update_reader_render = false
        -- print("page", page_index, "/", #reader_page_index_tbl)
    end

    if not draw_reader_init then
        reader_tbl_cache = json.decodeFile(prt_tbl[current_select_file_index])
        reader_page_index_tbl = calc_text_tbl(reader_tbl_cache.text, FONT_READER[reader_font_selection].lineheight, 0, FONT_READER[reader_font_selection].font, container_width-reader_padding.width*2, container_height-reader_padding.height*1)
        print("load:", prt_tbl[current_select_file_index])

        --load last time page
        if tableContainsKey(page_index_cache, prt_tbl[current_select_file_index]) then
            reader_page_index = page_index_cache[prt_tbl[current_select_file_index]]
        else
            reader_page_index = 1
        end

        _update_reader()
        draw_reader_init = true
    end

    ---control
    if is_glance_mode then
        --glance
        if glance_page_index_lazy ~= glance_page_index then
            SFX.key.sound:play()
            _update_reader()
            glance_page_index_lazy = glance_page_index
        end
    else
        --reader
        if pd.buttonIsPressed(pd.kButtonDown) or pd.buttonIsPressed(pd.kButtonRight) then
            arrow_btn_skip_cnt_sensitivity += 1
            if arrow_btn_skip_cnt_sensitivity > 10 then
                arrow_btn_skip_cnt_sensitivity = 0
                if reader_page_index < #reader_page_index_tbl then
                    reader_page_index += 1
                    is_start_new_timer_cycle = true
                    _update_reader()
                end
            end
        elseif pd.buttonIsPressed(pd.kButtonUp) or pd.buttonIsPressed(pd.kButtonLeft) then
            arrow_btn_skip_cnt_sensitivity += 1
            if arrow_btn_skip_cnt_sensitivity > 10 then
                arrow_btn_skip_cnt_sensitivity = 0
                if reader_page_index > 1 then
                    reader_page_index -= 1
                    is_start_new_timer_cycle = true
                    _update_reader()
                end
            end
        end
        if pd.buttonJustReleased(pd.kButtonDown) or pd.buttonJustReleased(pd.kButtonUp) or pd.buttonJustReleased(pd.kButtonLeft) or pd.buttonJustReleased(pd.kButtonRight) then
            arrow_btn_skip_cnt_sensitivity = 100
        end
    end

    if force_update_reader_render then
        _update_reader()
    end

end


local draw_auto_page_turn_ui_animation_init = false
local draw_auto_page_turn_ui_animator = gfx.animator.new(0, screenHeight*1.6, screenHeight*1.6)
local draw_auto_page_turn_ui_y = screenHeight*1.6
function draw_auto_page_turn_ui_animation(type)
    if draw_auto_page_turn_ui_animation_init then
        if type == "in" then
            draw_auto_page_turn_ui_animator = gfx.animator.new(200, draw_auto_page_turn_ui_y, screenHeight/2, playdate.easingFunctions.outQuart, 300)
        elseif type == "out" then
            draw_auto_page_turn_ui_animator = gfx.animator.new(200, draw_auto_page_turn_ui_y, screenHeight*1.6, playdate.easingFunctions.outQuart, 300)
        end
        draw_auto_page_turn_ui_animation_init = false
    else
        if not draw_auto_page_turn_ui_animator:ended() then
            draw_auto_page_turn_ui_y = draw_auto_page_turn_ui_animator:currentValue()
            page_turn_setting_ui_num:moveTo(screenWidth/2+page_turn_setting_ui_num_offset_coord.x, draw_auto_page_turn_ui_y+page_turn_setting_ui_num_offset_coord.y)
            page_turn_setting_ui:moveTo(screenWidth/2, draw_auto_page_turn_ui_y)
        end
    end
end

function draw_auto_page_turn_ui()
    function _update_sec()
        local image = gfx.image.new(80,30)
        gfx.pushContext(image)
            gfx.setImageDrawMode(gfx.kDrawModeCopy)
            gfx.setFont(FONT_READER["Sans_20"].font)
            gfx.drawTextAligned(auto_page_turn_sec.." 秒", 40, 10, kTextAlignment.center)
        gfx.popContext()
        page_turn_setting_ui_num:setImage(image)
    end

    local crankTicks = pd.getCrankTicks(10)
    if crankTicks == 1 then
        if auto_page_turn_sec < 180 then
            auto_page_turn_sec += 1
        end
    elseif crankTicks == -1 then
        if auto_page_turn_sec > 1 then
            auto_page_turn_sec -= 1
        end
    end
    if pd.buttonIsPressed(pd.kButtonLeft) then
        arrow_btn_skip_cnt_sensitivity += 1
        if arrow_btn_skip_cnt_sensitivity > 6 then
            arrow_btn_skip_cnt_sensitivity = 0
            if auto_page_turn_sec > 1 then
                auto_page_turn_sec -= 1
            end
        end
    elseif pd.buttonIsPressed(pd.kButtonRight) then
        arrow_btn_skip_cnt_sensitivity += 1
        if arrow_btn_skip_cnt_sensitivity > 6 then
            arrow_btn_skip_cnt_sensitivity = 0
            if auto_page_turn_sec < 180 then  --playdate autolock timer limitation
                auto_page_turn_sec += 1
            end
        end
    end
    if pd.buttonJustReleased(pd.kButtonLeft) or pd.buttonJustReleased(pd.kButtonRight) then
        arrow_btn_skip_cnt_sensitivity = 100
    end

    if auto_page_turn_sec_lazy ~= auto_page_turn_sec then
        _update_sec()
        auto_page_turn_sec_lazy = auto_page_turn_sec
    end

    if reader_side_mode then
        page_turn_setting_ui_num:setRotation(90)
        page_turn_setting_ui:setImage(gfx.image.new("img/frame_auto_page_turn_side"))
        page_turn_setting_ui_num_offset_coord = {
            x = -28,
            y = 0,
        }
    else
        page_turn_setting_ui_num:setRotation(0)
        page_turn_setting_ui:setImage(gfx.image.new("img/frame_auto_page_turn"))
        page_turn_setting_ui_num_offset_coord = {
            x = 0,
            y = 30,
        }
    end

end

local auto_page_turn_timer, auto_page_turn_animator
function auto_page_turn_manager(state)
    -- FIXME add side mode width support
    if not is_auto_page_turn_on then
        return
    end

    function _auto_page_turn_manager_to_next_page()
        if not is_auto_page_turn_on then
            return
        end
        if reader_page_index < #reader_page_index_tbl then
            reader_page_index += 1
            _update_reader()
        else
            is_auto_page_turn_on = false
            auto_page_turn_indicator:remove()
            auto_page_turn_indicator_side:remove()
        end
        auto_page_turn_timer:remove()
        is_start_new_timer_cycle = true
    end

    if is_start_new_timer_cycle then
        for k, v in pairs(playdate.timer.allTimers()) do
            -- print("removing timer",v)
            v:remove()
        end

        auto_page_turn_timer = playdate.timer.new(auto_page_turn_sec*1000, function()
            _auto_page_turn_manager_to_next_page()
        end
        )
        if reader_side_mode then
            auto_page_turn_animator = gfx.animator.new(auto_page_turn_sec*1000, screenWidth, 0, playdate.easingFunctions.linear)
        else
            auto_page_turn_animator = gfx.animator.new(auto_page_turn_sec*1000, 0, screenHeight, playdate.easingFunctions.linear)
        end
        is_start_new_timer_cycle = false
    end

    if not auto_page_turn_animator:ended() then
        if reader_side_mode then
            auto_page_turn_indicator_side:add()
            auto_page_turn_indicator:remove()
            auto_page_turn_indicator_side:moveTo(auto_page_turn_animator:currentValue(), screenHeight)
        else
            auto_page_turn_indicator_side:remove()
            auto_page_turn_indicator:add()
            auto_page_turn_indicator:moveTo(screenWidth, auto_page_turn_animator:currentValue())
        end
    end
end

-----------------

STAGE["file_list"] = function()
    draw_file_list()
    draw_file_list_animation("in")
    draw_reader_animation("out")

    if pd.buttonJustPressed(pd.kButtonA) then
        SFX.click.sound:play()
        draw_file_list_animation_init = false
        draw_reader_animation_init = false
        draw_reader_init = false
        stage_manager = "reader"
    end
end

STAGE["reader"] = function()
    auto_page_turn_manager()
    if reader_side_mode then
        draw_reader(screenHeight, screenWidth, 90, false)
    else
        draw_reader(screenWidth, screenHeight, 0, false)
    end
    draw_file_list_animation("out")
    draw_reader_animation("in")

    if pd.buttonJustPressed(pd.kButtonB) then
        SFX.click.sound:play()
        -- playdate.display.setRefreshRate(FRAMERATE_CONFIG.normal)
        draw_file_list_animation_init = false
        draw_reader_animation_init = false
        draw_reader_init = false
        is_auto_page_turn_on = false
        main_screen_header_index = math.random(#main_screen_header)
        stage_manager = "file_list"
        save_state()
    end

    local crankTicks = pd.getCrankTicks(10)
    if crankTicks ~= 0 then
        glance_page_index = reader_page_index
        stage_manager = "reader_glance"
    end

    if pd.buttonJustPressed(pd.kButtonA) then
        draw_auto_page_turn_ui_animation_init = true
        draw_auto_page_turn_ui_animation("in")
        stage_manager = "set_auto_page_turn"
    end
end

STAGE["reader_glance"] = function()
    if reader_side_mode then
        draw_reader(screenHeight, screenWidth, 90, true)
    else
        draw_reader(screenWidth, screenHeight, 0, true)
    end

    local crankTicks = pd.getCrankTicks(10)
    if crankTicks == 1 then
        if glance_page_index < #reader_page_index_tbl then
            glance_page_index += 1
        end
    elseif crankTicks == -1 then
        if glance_page_index > 1 then
            glance_page_index -= 1
        end
    end

    if pd.buttonIsPressed(pd.kButtonRight) then
        arrow_btn_skip_cnt_sensitivity += 1
        if arrow_btn_skip_cnt_sensitivity > 4 then
            arrow_btn_skip_cnt_sensitivity = 0
            if glance_page_index < #reader_page_index_tbl-10 then
                glance_page_index += 10
            else
                glance_page_index = #reader_page_index_tbl
            end
        end
    elseif pd.buttonIsPressed(pd.kButtonLeft) then
        arrow_btn_skip_cnt_sensitivity += 1
        if arrow_btn_skip_cnt_sensitivity > 4 then
            arrow_btn_skip_cnt_sensitivity = 0
            if glance_page_index > 10 then
                glance_page_index -= 10
            else
                glance_page_index = 1
            end
        end
    elseif pd.buttonJustPressed(pd.kButtonUp) then
        glance_page_index = 1
    elseif pd.buttonJustPressed(pd.kButtonDown) then
        glance_page_index = #reader_page_index_tbl
    end
    if pd.buttonJustReleased(pd.kButtonRight) or pd.buttonJustReleased(pd.kButtonLeft) then
        arrow_btn_skip_cnt_sensitivity = 100
    end

    if pd.buttonJustPressed(pd.kButtonB) or playdate.isCrankDocked() then
        SFX.slide_out.sound:play()
        force_update_reader_render = true
        stage_manager = "reader"
        save_state()
    elseif pd.buttonJustPressed(pd.kButtonA) then
        reader_page_index = glance_page_index
        SFX.slide_in.sound:play()
        force_update_reader_render = true
        stage_manager = "reader"
        save_state()
    end
end


STAGE["set_auto_page_turn"] = function()
    draw_auto_page_turn_ui()

    if pd.buttonJustReleased(pd.kButtonA) then
        draw_auto_page_turn_ui_animation_init = true
        draw_auto_page_turn_ui_animation("out")
        is_auto_page_turn_on_switcher()
        is_start_new_timer_cycle = true
        draw_reader_init = false
        stage_manager = "reader"
    end
end

-----------------

function init()
    load_state()
    if is_first_install then
        save_state()
        add_default_books()

        is_first_install = false
        save_state()
    end

    note_sidebar_option()
    setInverted(dark_mode)
end


function pd.update()
    gfx.sprite.update()
    pd.timer.updateTimers()

    draw_auto_page_turn_ui_animation()
    STAGE[stage_manager]()

end

function pd.gameWillTerminate()
    save_state()
end

init()






