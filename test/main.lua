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


-- Save the state of the game to the datastore
function save_state()
	print("Saving state...")
	local state = {}
    -- state["user_notes"] = user_notes

	playdate.datastore.write(state)
	print("State saved!")
end


save_state()
a = pd.file.listFiles()
for key, char in pairs(a) do
    print(char)
end


function pd.update()
    gfx.sprite.update()
    pd.timer.updateTimers()
end