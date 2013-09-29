-- Displays player monitored items and production quantities
-- Author: CecilKilmer
-- Version: 1.0
-- Date: 2013/09/28

-- Functions
function saveItemSnapshot(meBridge, itemsToMonitor)
	local data = { timestamp = os.clock(), items = {} }
	local items = meBridge.listItems()
	for itemUUID, itemName in pairs(itemsToMonitor) do
		data.items[itemUUID] = items[itemUUID]
	end
	return data
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

itemsToMonitor = CecilKilmerAPI.getItemsToMonitor(itemsToMonitorFile)


while (true) do
	term.clear()
	term.setCursorPos(1, 1)

	local items = meBridge.listItems()

	for itemUUID, itemName in pairs(itemsToMonitor) do
		print(itemName .. " - " .. items[itemUUID]);
	end
	os.sleep(1)
end
