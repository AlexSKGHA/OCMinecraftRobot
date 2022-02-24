-- invman lib | version alpha 0.1.1

local component = require "component"
local robot = require "robot"
local ic = component.inventory_controller
local o = require "os"

local invman = {
	maxSize = robot.inventorySize(),
	inventory = {}
}

function invman.get_slots(self, item, force_unveil)
	
	if type(item) == "number" then
		item = self.inventory[item]["label"]
	end

	slots = {}

	for i = 1, self.maxSize do
		if force_unveil then
			if self.inventory[i]["label"] == "undefined" then
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
	empty_slots = self:get_slots(nil, false)
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
	
	self:init_toolbelt()
end

function invman.update(self)
	
	for i = 1, self.maxSize do
		count = robot.count(i)
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

function invman.equip(self, item)

	assert(not self.toolbelt["label"], "Slot is occupied")

	slot_number = self:get_slots(item)[1]
	robot.select(slot_number)
	ic.equip()
	self.toolbelt = ic.getStackInInternalSlot()
	robot.select(1)
end

function invman.unequip(self)
	
	assert (self.toolbelt["label"], "Nothing to unequip")

	empty_slots = self:get_slots(nil, false)
	if #empty_slots == 0 then
		error("No at least one empty slot for a tool to unequip")
	end

	robot.select(empty_slots[1])
	ic.equip()
	self.toolbelt = {}
	robot.select(1)
end

function invman.place(self, item, force_unveil)
	item_slot = self:get_slots(item, force_unveil)[1]

	robot.select(item_slot)
	is_success = robot.place()
	if is_success then
		stack_size = self.inventory[item_slot]["size"]
		if stack_size == 1 then
			self.inventory[item_slot] = {}
		else
			self.inventory[item_slot]["size"] = stack_size - 1
		end
	else
		error("Item has not placed")
	end
	robot.select(1)
end

return invman
