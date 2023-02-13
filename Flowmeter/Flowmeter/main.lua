-- ##########################################################################################################
-- #                                                                                                        #
-- # Flowmeter SystemTools lua for ETHOS V1.1.0 or above  												    #									
-- # 																										#
-- #https://github.com/aviat40/Sensor-FrSky/tree/main/Flowmeter                                             #
-- #                                                                                                        #
-- # hobby-rc.freeboxos.fr (2023)                                                                           #
-- #                                                                                                        #
-- ##########################################################################################################

local locale = system.getLocale()

local function name(widget)
  return "FLOWMETER"
end

local localeTexts = {
	tankCapacity = {en="Tank capacity", fr="Capacité réservoir", de="Tank Inhalt", es="es"},
	}
	
local function localize(key)
	return localeTexts[key][locale] or localTexts[key]["en"] or key
end

local tankCapacity
local newValue

local function create(widget)
	
	local sensor = system.getSource({category=CATEGORY_TELEMETRY, appId=0x0D30})
	tankCapacity = sensor:value()
	newValue = sensor:value()
	local line = form.addLine("appId")
	local physIdField = form.addStaticText(line, nil, string.format('0x%04x',sensor:appId()))
	
  	-- Fuel Tank capacity
	local line = form.addLine(localize("tankCapacity"))
	local tankField = form.addNumberField(line, nil, 0 , 9999,
		function() return tankCapacity end,
		function(value) tankCapacity=value
		end)
	tankField:default(2000)
	tankField:step(50)
	tankField:suffix(" ml")
	return {}
end

local function wakeup(widget)
	if newValue ~= tankCapacity then
		local sensorTank={}
		sensorTank = sport.getSensor({appId = 0x0D30})
		sensorTank:pushFrame({physId=0x1B, primId=0x31, appId=0x0D30, value=tankCapacity})
		newValue = tankCapacity
	end
end

local icon = lcd.loadMask("./flowmeter.png")

local function init()
	system.registerSystemTool({name=name, icon=icon, create=create, wakeup=wakeup})
end

return {init=init}
