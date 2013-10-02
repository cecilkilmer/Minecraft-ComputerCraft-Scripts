-- Crafts items to keep a set quantity within the system
-- Author: CecilKilmer
-- Version: 0.01
-- Date: 2013/10/01

columnPos = vector.new(1, 1, 1)

function printItemLine(termRow, itemName, itemQty, itemCraft)
	term.setCursorPos(columnPos.x, termRow)
	print(itemName)

	itemQty = CecilKilmerAPI.roundNumber(itemQty, 5, 0)
	term.setCursorPos(columnPos.y - string.len(itemQty), termRow)
	print(itemQty)

	itemCraft = CecilKilmerAPI.roundNumber(itemCraft, 5, 0)
	term.setCursorPos(columnPos.z - string.len(itemCraft), termRow)
	print(itemCraft)
end

-------------------------------------------------------
-- Begin main program
-------------------------------------------------------

-- Load our required APIs
print("Attempting to load required APIs")
if os.loadAPI("CecilKilmerAPI") == false then
	print("CecilKilmerAPI not found, downloading now")
	if shell.run("pastebin", "get", "BWQ8J5hT", "CecilKilmerAPI") == false then
		print("Missing API.  Please download using this command:")
		print("pastebin get BWQ8J5hT CecilKilmerAPI")
		return
	else
		if os.loadAPI("CecilKilmerAPI") == false then
			print("Missing API.  Please download using this command:")
			print("pastebin get BWQ8J5hT CecilKilmerAPI")
			return
		end
	end
end

-- Check for our required data files
itemsToSupplyFile = "AESupplyItems.txt"

if fs.exists(itemsToSupplyFile) == false then
	print("No items were selected to be supplied.  Please run AESelectItems.")
	print("pastebin get AESelectItems")
	return
end

meBridge = CecilKilmerAPI.getMEBridge()
monitor = CecilKilmerAPI.getMonitor()

-- Make sure we have a ME Bridge attached to us
if meBridge == nil then
	print("No ME Bridge found.  ME Bridge is required to operate.")
	return
end

-- If we have a monitor, then redirect to that
if monitor ~= nil then
	term.redirect(monitor)
end

-- Figure out our column positions (2 and 3 are right justified + 1)
screenWidth, screenHeight = term.getSize()
columnPos.z = screenWidth + 1
columnPos.y = columnPos.z - 6 -- 5 wide column for average + 1 space

-- Create our header divider line
headerStr = string.rep("-", columnPos.y - 7) .. " ----- -----"

itemsToSupply = CecilKilmerAPI.getItemsToSupply(itemsToSupplyFile)

-- When running at startup, we may hit a condition where we load before
-- the AE system loads, so poll for when that becomes available
local loopCounter = 0
local connected = false
while (loopCounter < 60) and (connected == false) do
	loopCounter = loopCounter + 1
	local bridgeChecker = meBridge.listItems()

	if bridgeChecker ~= nil then
		connected = true
	end
	os.sleep(1)
end

if connected == false then
	print("Unable to establish connection to AE system, quitting.")
	return
end

-- Main loop
while (true) do
	term.clear()
	term.setCursorPos(1, 1)
	print("Item")
	term.setCursorPos(columnPos.y - 5, 1)
	print("Qty")
	term.setCursorPos(columnPos.z - 5, 1)
	print("Craft")
	term.setCursorPos(1, 2)
	print(headerStr)
	
	local items = meBridge.listItems()
	itemRow = 3
	
	for itemUUID, itemName in pairs(itemsToMonitor) do
		printItemLine(itemRow, itemName, items[itemUUID], prodPerHour[itemUUID])
		itemRow = itemRow + 1
	end
	os.sleep(1)
end
