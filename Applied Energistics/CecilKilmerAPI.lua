-- API for various common functionality for CecilKilmer's scripts
-- Author: CecilKilmer
-- Version: 1.0
-- Date: 2013/09/28

-- Functions for getting peripherals
function getPeripheral(peripheralName)
	local perObj = nil
	local perSide = nil
	if peripheral.getType("left") == peripheralName then
		perSide = "left"
	elseif peripheral.getType("right") == peripheralName then
		perSide = "right"
	elseif peripheral.getType("top") == peripheralName then
		perSide = "top"
	elseif peripheral.getType("bottom") == peripheralName then
		perSide = "bottom"
	elseif peripheral.getType("front") == peripheralName then
		perSide = "front"
	elseif peripheral.getType("back") == peripheralName then
		perSide = "back"
	end

	if perSide ~= nil then
		perObj = peripheral.wrap(perSide)
	end
	
	return perObj
end

function getMEBridge()
	return getPeripheral("meBridge")
end

function getMonitor()
	return getPeripheral("monitor")
end

-- Functions for working with item monitoring files for Applied Energistics programs
function getItemsToMonitor(fileName)
	local fileHandle = fs.open(fileName, "r")
	local tableData = {}
	for line in fileHandle.readLine do
		for uuidString, itemName in string.gmatch(line, "(%d-) = (.+)" ) do
			local uuid = tonumber(uuidString)
			tableData[uuid] = itemName
		end
	end
	fileHandle.close()
	return tableData
end
