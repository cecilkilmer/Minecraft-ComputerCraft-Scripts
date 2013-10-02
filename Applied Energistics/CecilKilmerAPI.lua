-- API for various common functionality for CecilKilmer's scripts
-- Author: CecilKilmer
-- Version: 0.03
-- Date: 2013/10/01

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

function getItemsToSupply(fileName)
	local fileHandle = fs.open(fileName, "r")
	local tableData = {}
	for line in fileHandle.readLine do
		for uuidString, itemQty, itemName in string.gmatch(line, "(%d-) = (%d-) = (.+)" ) do
			local uuid = tonumber(uuidString)
			tableData[uuid] = { name = itemName, qty = itemQty }
		end
	end
	fileHandle.close()
	return tableData
end

-- General functions

-- Rounding requires at least a maxLength of 4 (100k, etc)
function roundNumber(number, maxLength, decimalPlaces)
	-- Check if we're working with a decimal or not
	decimalIndex = string.find(number, ".")
	stringLength = string.len(number)

	if decimalIndex ~= nil then
		-- A decimal
		if (stringLength - decimalIndex) <= decimalPlaces then
			number = math.floor((number * 10 ^ decimalPlaces) + 0.5) / (10 ^ decimalPlaces)
			stringLength = string.len(number)
		end
	end

	if stringLength <= maxLength then
		return number
	else
		-- If we're a decimal number and we can't even fit in a single place, floor ourselves
		if decimalIndex ~= nil and (stringLength - decimalPlaces) >= maxLength then
			number = math.floor(number)
			stringLength = string.len(number)
			
			if stringLength <= maxLength then
				return number
			end
		else
			return string.sub(number, 1, maxLength)
		end
		
		units = 0
		while (number >= 1000) do
			number = math.floor(number / 1000)
			units = units + 1
		end
		
		if units == 1 then
			return number .. "k"
		elseif units == 2 then
			return number .. "M"
		elseif units == 3 then
			return number .. "B"
		elseif units == 4 then
			return number .. "T"
		end
	end
end
