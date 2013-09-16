-- Mob Farm turtle
-- Kills mobs in front, picks up drops, puts into chest below it
-- Author: CecilKilmer
-- Version 1.0
-- Date 2013/09/15

-- Next inventory slot, but 0 based
nextSlot = 0

-- Functions
function emptyNextSlot()
	turtle.dropDown()
	nextSlot = nextSlot + 1
	nextSlot = nextSlot % 16
	turtle.select(nextSlot + 1)
end

function mainLoop()
	turtle.attack()
	turtle.suck()
	emptyNextSlot()
	os.sleep(.1)
end

turtle.select(1)

term.clear()
term.setCursorPos(1,1)
print(os.getComputerLabel() .. " - Commencing mob farming")

while true do
	mainLoop()
end