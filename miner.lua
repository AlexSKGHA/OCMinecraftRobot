--Alpha 0.2.2

-- component = require "component"
-- robot = require "robot"
-- ic = component.inventory_controller
-- inventorySize = robot.inventorySize()
-- os = require "os"
-- sides = require "sides"
-- computer = require "computer"

-- InventoryController = {
-- 	contents = {}
-- }

-- local listOfItemsToDropOff = {
--   "Cobblestone",
--   "Dirt",
--   "Gravel",
--   "Stone",
--   "Diorite",
--   "Andesite",
--   "Flint",
--   "Granite"
-- }

-- function InventoryController.select(...)
-- 	local arg = {...}
-- 	for _, f in ipairs(arg) do
-- 		f()
-- 	end
-- 	robot.select(1)
-- 	return
-- end

-- function InventoryController.preInit(self)
	
-- 	robot.select(1)
-- 	for i=1, inventorySize do
-- 		self.contents[i] = {}
-- 	end
-- 	self.contents["count"] = 0
-- 	self.contents["equippedItem"] = {}
-- 	return
-- end

-- function InventoryController.init(self)
	
-- 	contents = self.contents
-- 	for i=1, inventorySize do
-- 		stack = ic.getStackInInternalSlot(i)
-- 		if stack ~= nil then
-- 			name1 = stack["label"]
-- 			size = stack["size"]
-- 			contents[i][1] = name1
-- 			contents[i][2] = size
-- 			contents.count = contents.count + size
-- 		else
-- 			contents[i] = {"Empty", 0}
-- 		end
-- 	end
-- 	return
-- end

-- function InventoryController.update(self)

-- 	contents = self.contents
-- 	currentItemCounts = {}
-- 	lastItemCounts = {}
-- 	currentCount = 0
-- 	lastCount = contents.count
-- 	for i=1, inventorySize do
-- 		c = robot.count(i)
-- 		table.insert(currentItemCounts, c)
-- 		currentCount = currentCount + c
-- 	end
-- 	difference = currentCount - lastCount

-- 	if lastCount ~= currentCount then
-- 		for i=1, inventorySize do
-- 			table.insert(lastItemCounts, contents[i][2])
-- 		end
-- 		knownItemsCountDifference = 0
-- 		unknownItemsCountDifference = 0
-- 		for i=1, inventorySize do
-- 			if contents[i][1] == "Empty" then
-- 				if currentItemCounts[i] ~= 0 then
-- 					unknownItemsCountDifference = unknownItemsCountDifference + currentItemCounts[i]
-- 					contents[i] = {"Unknown", currentItemCounts[i]}
-- 				end
-- 			elseif contents[i][1] == "Unknown" then
-- 				unknownItemsCountDifference = unknownItemsCountDifference + (currentItemCounts[i] - lastItemCounts[i])
-- 				if currentItemCounts[i] == 0 then
-- 					contents[i] = {"Empty", 0}
-- 				else
-- 					contents[i] = {"Unknown", currentItemCounts[i]}
-- 				end
-- 			else
-- 				knownItemsCountDifference = knownItemsCountDifference + (currentItemCounts[i] - lastItemCounts[i])
-- 				if currentItemCounts[i] == 0 then
-- 					contents[i] = {"Empty", 0}
-- 				else
-- 					contents[i] = {contents[i][1], currentItemCounts[i]}
-- 				end
-- 			end
-- 			if difference - (knownItemsCountDifference + unknownItemsCountDifference) == 0 then
-- 				--print("Proccesing stopped at: " .. i)
-- 				break
-- 			end
-- 		end
-- 		equation = currentCount - (lastCount + knownItemsCountDifference + unknownItemsCountDifference)
-- 		contents.count = currentCount
-- 		if equation ~= 0 then 
-- 			print("Equation is not true")
-- 			print(currentCount, lastCount, knownItemsCountDifference, unknownItemsCountDifference)
-- 			os.sleep(10000)
-- 			self:init()
-- 		end
-- 	end
-- end

-- function InventoryController.getInventoryFullness(self)
-- 	self:update()
-- 	numOfEmptySlots = self:search("Empty")
-- 	return #numOfEmptySlots
-- end

-- function InventoryController.getItem(self, slot)

-- 	self:update()
-- 	contents = self.contents
-- 	if contents[slot][1] == "Unknown" then
-- 		stack = ic.getStackInInternalSlot(slot)
-- 		contents[slot][1] = stack.label
-- 	end
-- 	return self.contents[slot][1]
-- end

-- function InventoryController.search(self, name, fullSearch)

-- 	self:update()
-- 	contents = self.contents
-- 	slots = {}
-- 	for i=1, inventorySize do
-- 		if ((fullSearch and self:getItem(i)) or contents[i][1]) == name then
-- 			table.insert(slots, i)
-- 		end
-- 	end
-- 	return slots
-- end

-- function InventoryController.initToolBelt(self)

-- 	emptySlot = self:search("Empty", false)[1]

-- 	if emptySlot == nil then
-- 		emptySlot = inventorySize
-- 	end

-- 	if emptySlot ~= nil then
-- 		robot.select(emptySlot)
-- 		ic.equip()
-- 		stack = ic.getStackInInternalSlot(emptySlot)
-- 		if stack == nil then
-- 			self.contents.equippedItem = {"Empty", 0}
-- 		else
-- 			self.contents.equippedItem[1] = stack.label
-- 			self.contents.equippedItem[2] = stack.size
-- 		end
-- 		ic.equip()
-- 		robot.select(1)
-- 	else
-- 		return false
-- 	end
-- 	return true
-- end

-- function InventoryController.count(self, slot)

-- 	self:update()
-- 	return self.contents[slot][2]
-- end

-- function InventoryController.equip(self, slot)

-- 	self:initToolBelt()
-- 	contents = self.contents
-- 	if contents.equippedItem[1] == "Empty" then
-- 		name = self:getItem(slot)
-- 		if name ~= "Empty" then
-- 			size = self:count(slot)
-- 			robot.select(slot)
-- 			ic.equip()
-- 			robot.select(1)
-- 			contents.equippedItem = {name, size}
-- 			contents.count = contents.count - 1
-- 			contents[slot] = {"Empty", 0}
-- 		else
-- 			return false
-- 		end
-- 	else
-- 		return false
-- 	end
-- 	return true
-- end

-- function InventoryController.unequip(self)

-- 	self:initToolBelt()
-- 	contents = self.contents

-- 	if contents.equippedItem[1] ~= "Empty" then
-- 		emptySlot = self:search("Empty", false)[1]
-- 		robot.select(emptySlot)
-- 		ic.equip()
-- 		robot.select(1)
-- 		contents[emptySlot] = {contents.equippedItem[1], contents.equippedItem[2]}
-- 		contents.count = contents.count + 1
-- 		contents.equippedItem = {"Empty", 0}
-- 	else
-- 		return false
-- 	end
-- end

-- function clearInventory()
-- 	InventoryController:update()
-- 	for _, filter in ipairs(listOfItemsToDropOff) do
-- 		for i=1, inventorySize do
-- 			if InventoryController:getItem(i) == filter then
-- 				robot.select(i)
-- 				robot.dropDown()
-- 			end
-- 		end
-- 	end
-- end

-- function charge()

-- 	depth = 0

-- 	while robot.detectDown() ~= true do
-- 		robot.down();
-- 		depth = depth + 1
-- 	end

-- 	if depth ~= 0 then
-- 		robot.up();
-- 		depth = depth - 1
-- 	else
-- 		robot.swingDown()
-- 	end

-- 	InventoryController.select(function()
-- 		im = InventoryController
-- 		im:unequip()
-- 		robot.select(im:search("MFSU", false)[1])
-- 		robot.placeDown()
-- 		robot.select(im:search("Advanced Diamond Drill", false)[1])
-- 		robot.dropDown()
-- 		os.sleep(5)
-- 		robot.suckDown()
-- 		im:equip(im:search("Electric Wrench", false)[1])
-- 		robot.useDown(sides.forward, false)
-- 		im:unequip()
-- 		im:equip(im:search("Advanced Diamond Drill", false)[1])
-- 	end)
-- 	for i=1, depth do
-- 		robot.up()
-- 	end
-- 	return true
-- end

-- previousEnergy = computer.maxEnergy()
-- maxEnergy = computer.maxEnergy()

-- function energyCheck()
-- 	currentEnergy = computer.energy()
-- 	percent = (currentEnergy / maxEnergy) * 100
-- 	if percent < 90 then
-- 		if component.generator.count() < 2 then
-- 			print("Loaded")
-- 			InventoryController.select(intakeCoal)
-- 		end
-- 	end
-- end

-- function intakeCoal()
-- 	amount = 1
-- 	coalSlots = InventoryController:search("Coal")
-- 	for _, v in ipairs(coalSlots) do
-- 		num = InventoryController:count(v)
-- 		if num > 1 then
-- 			if num < amount then
-- 				c.generator.insert(num - 1)
-- 				amount = amount - (num - 1)
-- 			else
-- 				robot.select(v)
-- 				component.generator.insert(amount)
-- 				return true
-- 			end
-- 		end
-- 	end
-- 	return false
-- end

-- local b = 0
-- local prep = false

-- function perform()
-- 	while robot.durability() > 0.1 do
--     if b <= 15 then
--     	freeSpace = InventoryController:getInventoryFullness()
--     	if freeSpace < 2 then
--     		InventoryController.select(clearInventory())
--     	end
--     	energyCheck()
--     	robot.swing()
--     	robot.forward()
--     	b = b + 1
--     else
--       if prep == false then
--         robot.back()
--         if hasTurnedRight == true then
--           robot.turnLeft()
--           hasTurnedRight = false
--         else
--           robot.turnRight()
--           hasTurnedRight = true
--         end
--         robot.forward()
--         b = 13
--         prep = true
--       else
--         b = 3
--         robot.back()
--         if hasTurnedRight == true then
--           robot.turnRight()
--         else 
--           robot.turnLeft()
--         end
--         robot.forward()
--         prep = false
--       end 
--     end  
--   end
--   return
-- end

-- function run()
-- 	InventoryController:preInit()
--   	InventoryController:init()
--   	InventoryController:initToolBelt()
--   	n = InventoryController:search("Advanced Diamond Drill", false)[1]
-- 	InventoryController:equip(n)
-- 	while true do
-- 		perform()
-- 		charge()
-- 	end
-- 	return
-- end

-- run()

-- Alpha 0.3.0

local im = require "invman"
local robot = require "robot"
local component = require "component"

im:init()

local listOfItemsToDropOff = {
  "Cobblestone",
  "Dirt",
  "Gravel",
  "Stone",
  "Diorite",
  "Andesite",
  "Flint",
  "Granite"
}

function clear_proccess()
	print("clearing process began")

	for _, filter in ipairs(listOfItemsToDropOff) do
		slots = im:get_slots(filter, true)
		for _, slot in pairs(slots) do
			robot.select(slot)
			robot.dropDown()
		end
	end
end

function clear_inventory()
	im:update()
	clear_proccess()
	im:update()
end

local b = 0
local prep = false

print(robot.durability(), "durability")


function perform()
	while true do
    	if b <= 15 then
    		im:update()
    		freeSpace = #im:get_slots(nil)
    		print(freeSpace)
    		if freeSpace < 2 then
    			clear_inventory()
    		end
    		--energyCheck()
    		robot.swing()
    		robot.forward()
    		b = b + 1
    	else
      		if prep == false then
        		robot.back()
        		if hasTurnedRight == true then
          			robot.turnLeft()
          			hasTurnedRight = false
        		else
          			robot.turnRight()
          			hasTurnedRight = true
        		end
        		robot.forward()
        		b = 13
        		prep = true
      		else
        		b = 3
        		robot.back()
        		if hasTurnedRight == true then
          			robot.turnRight()
        		else 
          			robot.turnLeft()
        		end
        		robot.forward()
        		prep = false
      		end 
    	end  
  	end
end

function run()
	while true do
		perform()
	end
	return
end

run()

clear_inventory()
