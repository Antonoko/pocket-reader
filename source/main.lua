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
local screenWidth <const> = playdate.display.getWidth()
local screenHeight <const> = playdate.display.getHeight()

-- local IMG_ABOUT <const> = gfx.image.new("img/about")
-- playdate.setMenuImage(IMG_ABOUT)

local FONT_READER = {
    SHS_20 = {
        name = "SourceHanSansCN-M-20px",
        font = gfx.font.new('font/SourceHanSansCN-M-20px'),
        lineheight = 1.6,
    },
    LXGW_24 = {
        name = "LXGWWenKaiGBScreen-24px",
        font = gfx.font.new('font/LXGWWenKaiGBScreen-24px'),
        lineheight = 1.4,
    }, 
}
local FONT = {
    source_san_20 = {
        name = "SourceHanSansCN-M-20px",
        font = gfx.font.new('font/SourceHanSansCN-M-20px'),
        lineheight = 1.6,
    },
    Asheville_Sans_14_Light = {
        name = "Asheville-Sans-14-Light",
        font = gfx.font.new('font/Asheville-Sans-14-Light')
    },
    Asheville_Sans_14_Bold = {
        name = "Asheville-Sans-14-Bold",
        font = gfx.font.new('font/Asheville-Sans-14-Bold')
    },
    Nontendo_Light = {
        name = "Nontendo-Light",
        font = gfx.font.new('font/Nontendo-Light')
    },
    font_full_circle_halved = {
        name = "font-full-circle-halved",
        font = gfx.font.new('font/font-full-circle-halved')
    }
}
local SFX = {
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
local indicator_img = {
    list_A = gfx.image.new("img/indicator_A.png"),
    main_screen_bg = gfx.image.new("img/main_screen_background.png"),
}
local STAGE = {}
local stage_manager = "file_list"
local reader_menu = playdate.getSystemMenu()
local reader_side_mode = false
local dark_mode = false

local prt_tbl = {}
local arrow_btn_skip_cnt_sensitivity = 100
local current_select_file_index = 1

local reader_page_index_tbl = {}
local reader_page_index = 1
local char_offset_cache = 0
local reader_tbl_cache = {}
local reader_padding = {
    width = 8,
    height = 8
}
local page_index_cache = {}
local reader_font_selection = "SHS_20"
local draw_reader_init = false

local reader_sprite = gfx.sprite.new()
reader_sprite:setCenter(0,0)
reader_sprite:moveTo(screenWidth, 0)
reader_sprite:add()

----------------utils

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
    reader_font_selection = get_or_default(state, "reader_font_selection", "string", "SHS_20")
    reader_side_mode = get_or_default(state, "reader_side_mode", "boolean", false)
    dark_mode = get_or_default(state, "dark_mode", "boolean", false)

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
    local modeMenuItem, error = reader_menu:addCheckmarkMenuItem("side mode", function(value)
        reader_side_mode = value
        draw_reader_init = false
        save_state()
    end)
    local modeMenuItem, error = reader_menu:addCheckmarkMenuItem("dark", function(value)
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
    local file_content = {
        text= {
            "添","加"
        }
    }
    json.encodeToFile("快速上手指南.PRT", file_content)
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
    local index_x = (screen_width-width)/2 + (reader_page_index/#reader_page_index_tbl)*width
    gfx.drawTextAligned(reader_page_index, index_x, y, kTextAlignment.center)
    if index_x > (screen_width/2) then
        gfx.drawTextAligned(get_time_now_as_string(), (screen_width-width)/2, y, kTextAlignment.left)
    else
        gfx.drawTextAligned(get_time_now_as_string(), width+(screen_width-width)/2, y, kTextAlignment.right)
    end
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

        gfx.setFont(FONT["source_san_20"].font)
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
        gfx.setFont(FONT["Asheville_Sans_14_Light"].font)
        gfx.drawTextAligned("pocket reader", x+14, y+8, kTextAlignment.left)
        indicator_img.main_screen_bg:draw(0, y)
    end

    function draw_file_list_gridview:drawCell(section, row, column, selected, x, y, width, height)
        gfx.setFont(FONT["source_san_20"].font)
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


function draw_reader(container_width, container_height, rotation)
    function _update_reader()
        local image = gfx.image.new(container_width, container_height)
        local tbl_to_render = {}
        local start_index = reader_page_index_tbl[reader_page_index]
        local end_index
        if start_index == #reader_page_index_tbl then
            end_index = #reader_tbl_cache.text
        else
            end_index = reader_page_index_tbl[reader_page_index +1]
        end
        for i=start_index, end_index do
            table.insert(tbl_to_render, reader_tbl_cache.text[i])
         end
        gfx.pushContext(image)
            char_offset_cache = draw_text_area(tbl_to_render, FONT_READER[reader_font_selection].lineheight, 0, FONT_READER[reader_font_selection].font, playdate.graphics.kDrawModeCopy, reader_padding.width, reader_padding.height, container_width-reader_padding.width, container_height-reader_padding.height)
            draw_page_indicator(container_width, container_width-reader_padding.width*4, container_height-14)
        gfx.popContext()
        reader_sprite:setImage(image:rotatedImage(rotation))

        page_index_cache[prt_tbl[current_select_file_index]] = reader_page_index
        print("page", reader_page_index, "/", #reader_page_index_tbl)
    end

    if not draw_reader_init then
        reader_tbl_cache = json.decodeFile(prt_tbl[current_select_file_index])
        reader_page_index_tbl = calc_text_tbl(reader_tbl_cache.text, FONT_READER[reader_font_selection].lineheight, 0, FONT_READER[reader_font_selection].font, container_width-reader_padding.width*2, container_height-reader_padding.height*2)
        print("load:", prt_tbl[current_select_file_index])

        if tableContainsKey(page_index_cache, prt_tbl[current_select_file_index]) then
            reader_page_index = page_index_cache[prt_tbl[current_select_file_index]]
        else
            reader_page_index = 1
        end

        _update_reader()
        draw_reader_init = true
    end

    ---control
    if pd.buttonIsPressed(pd.kButtonDown) or pd.buttonIsPressed(pd.kButtonRight) then
        arrow_btn_skip_cnt_sensitivity += 1
        if arrow_btn_skip_cnt_sensitivity > 10 then
            arrow_btn_skip_cnt_sensitivity = 0
            if reader_page_index < #reader_page_index_tbl then
                reader_page_index += 1
                _update_reader()
            end
        end
    elseif pd.buttonIsPressed(pd.kButtonUp) or pd.buttonIsPressed(pd.kButtonLeft) then
        arrow_btn_skip_cnt_sensitivity += 1
        if arrow_btn_skip_cnt_sensitivity > 10 then
            arrow_btn_skip_cnt_sensitivity = 0
            if reader_page_index > 1 then
                reader_page_index -= 1
                _update_reader()
            end
        end
    end
    if pd.buttonJustReleased(pd.kButtonDown) or pd.buttonJustReleased(pd.kButtonUp) or pd.buttonJustReleased(pd.kButtonLeft) or pd.buttonJustReleased(pd.kButtonRight) then
        arrow_btn_skip_cnt_sensitivity = 100
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
    if reader_side_mode then
        draw_reader(screenHeight, screenWidth, 90)
    else
        draw_reader(screenWidth, screenHeight, 0)
    end
    draw_file_list_animation("out")
    draw_reader_animation("in")

    if pd.buttonJustPressed(pd.kButtonB) then
        SFX.click.sound:play()
        draw_file_list_animation_init = false
        draw_reader_animation_init = false
        draw_reader_init = false
        stage_manager = "file_list"
        save_state()
    end
end

STAGE["reader_quick_preview"] = function()

end


-----------------

function init()
    load_state()
    save_state()
    note_sidebar_option()
    setInverted(dark_mode)
end


function pd.update()
    gfx.sprite.update()
    pd.timer.updateTimers()

    STAGE[stage_manager]()
end

init()






