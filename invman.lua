local component = require "component"
local robot = require "robot"
local ic = component.inventory_controller
local o = require "os"

local invman = {

	maxSize = robot.inventorySize(),
	inventory = {}
}

function invman.init(self)
	for i = 1, self.maxSize do
		robot.select(i)
		stack = ic.getStackInInternalSlot()
		if stack then
			self.inventory[i] = stack
		else
			self.inventory[i] = {}
		end
	end
	return
end

function invman.update(self)
	
	for i = 1, self.maxSize do
		robot.select(i)
		count = robot.count()
		stack = self.inventory[i]

		if stack["label"] == nil then
			if count > 0 then
				self.inventory[i] = {
					size = count,
					label = "undefined"
				}
			end
		else
			difference = count - stack["size"]
			if difference + stack["size"] == 0 then
				self.inventory[i] = {}
			else
				stack["size"] = count
			end
		end
	end
end

function invman.get_slot(self, item, force_unveil)
	
	slots = {}

	for i = 1, self.maxSize do

		if self.inventory[i]["label"] == "undefined" then
			if force_unveil then
				robot.select(i)
				self.inventory[i] = ic.getStackInInternalSlot()
			end
		end

		if self.inventory[i]["label"] == item then
			table.insert(slots, i)
		end
	end
	robot.select(1)
	return slots
end

function invman.init_toolbelt(self)
	empty_slots = self:get_slot(nil, false)
	if #empty_slots == 0 then
		error("No empty slots availible to initiate toolbelt entry")
	end

	robot.select(empty_slots[1])
	ic.equip()
	stack = ic.getStackInInternalSlot()
	if stack then
		self.toolbelt = stack
	else
		self.toolbelt = {}
	end

	ic.equip()
	robot.select(1)
end

return invman
