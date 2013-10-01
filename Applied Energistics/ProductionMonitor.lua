-- Displays player monitored items and production quantities
-- Author: CecilKilmer
-- Version: 1.0
-- Date: 2013/09/28

snapshotInterval = 1 * 60 -- update snapshot every 1 minute
snapshotCount = 60 * 60 / snapshotInterval -- 1 hours worth of snapshots
prodPerHourDecimals = 1 -- Number of values after the decimal
columnPos = vector.new(1, 1, 1)

snapshotTable = {}
prodPerHour = {}

-- Functions
function saveItemSnapshot(meBridge, itemsToMonitor)
	local data = { timestamp = os.clock(), items = {} }
	local items = meBridge.listItems()
	for itemUUID, itemName in pairs(itemsToMonitor) do
		data.items[itemUUID] = items[itemUUID]
	end
	return data
end

function updateItemSnapshots(meBridge, itemsToMonitor)
	if snapshotTable[#snapshotTable].timestamp < (os.clock() - snapshotInterval) then
		-- If our table is full, remove the oldest snapshot
		if #snapshotTable >= snapshotCount then
			table.remove(snapshotTable, 1)
		end
		
		-- Create the new snapshot and save it
		table.insert(snapshotTable, saveItemSnapshot(meBridge, itemsToMonitor))
		
		calcProdPerHour(itemsToMonitor)
	end
end

function calcProdPerHour(itemsToMonitor)
	for itemUUID, itemName in pairs(itemsToMonitor) do
		if #snapshotTable == 1 then
			prodPerHour[itemUUID] = 0
		else
			-- Calculate items per second
			prodPerHour[itemUUID] = (snapshotTable[#snapshotTable].items[itemUUID] - snapshotTable[1].items[itemUUID]) / (snapshotTable[#snapshotTable].timestamp - snapshotTable[1].timestamp)
			
			-- Update to per hour
			prodPerHour[itemUUID] = prodPerHour[itemUUID] * 3600
			
			-- Round our value
			prodPerHour[itemUUID] = math.floor((prodPerHour[itemUUID] * 10 ^ prodPerHourDecimals) + 0.5) / (10 ^ prodPerHourDecimals)
		end
	end
end

function printItemLine(termRow, itemName, itemQty, itemAvg)
	term.setCursorPos(columnPos.x, termRow)
	print(itemName)
	term.setCursorPos(columnPos.y - string.len(itemQty), termRow)
	print(itemQty)
	term.setCursorPos(columnPos.z - string.len(itemAvg), termRow)
	print(itemAvg)
end

-------------------------------------------------------
-- Begin main program
-------------------------------------------------------

-- Load our required APIs
if os.loadAPI("CecilKilmerAPI") == false then
	print("Missing API.  Please download using this command:")
	print("pastebin get BWQ8J5hT CecilKilmerAPI")
	return
end

-- Check for our required data files
itemsToMonitorFile = "ProductionMonitor.txt"

if fs.exists(itemsToMonitorFile) == false then
	print("No items were selected to be monitored.  Please run AESelectItems.")
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
headerStr = string.rep("-", columnPos.y - 6) .. " ----- -----"

itemsToMonitor = CecilKilmerAPI.getItemsToMonitor(itemsToMonitorFile)

-- Create our baseline snapshot
table.insert(snapshotTable, saveItemSnapshot(meBridge, itemsToMonitor))
calcProdPerHour(itemsToMonitor)

while (true) do
	term.clear()
	term.setCursorPos(1, 1)
	print("Item")
	term.setCursorPos(cursorPos.y - 5, 1)
	print("Qty")
	term.setCursorPos(cursorPos.z - 5, 1)
	print("Avg")
	term.setCursorPos(1, 2)
	print(headerStr)
	
	updateItemSnapshots(meBridge, itemsToMonitor)
	
	local items = meBridge.listItems()
	itemRow = 3
	
	for itemUUID, itemName in pairs(itemsToMonitor) do
		printItemLine(itemRow, itemName, items[itemUUID], prodPerHour[itemUUID])
		itemRow = itemRow + 1
	end
	os.sleep(1)
end
