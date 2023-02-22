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

local localeTexts = {
	widgetName = {en="FLOWMETER", fr="DEBITMETRE", de="FLOWMETER", es="es"},
	tankCapacity = {en="Tank capacity", fr="Capacité réservoir", de="Tank Inhalt", es="es"},
	pulsesName = {en="Pulses/L", fr="Impulsions/L", de= "Pulses/L", es="es"},
	}
	
local function localize(key)
	return localeTexts[key][locale] or localTexts[key]["en"] or key
end

local tankCapacity
local newValueTank
local pulses
local newValuePulse

local function name(widget)
  return localize("widgetName")
end

local function create(widget)
	local sensorTank = system.getSource({category=CATEGORY_TELEMETRY, appId=0x5201})
	tankCapacity = sensorTank:value()
	newValueTank = sensorTank:value()
	
	local sensorPulse = {}
	local sensorPulse = system.getSource({category=CATEGORY_TELEMETRY, appId=0x5200})
	pulses = sensorPulse:value()
	newValuePulse = sensorPulse:value()

  	-- Fuel Tank capacity
	local line = form.addLine(localize("tankCapacity"))
	local tankField = form.addNumberField(line, nil, 0 , 9999,
		function() return tankCapacity end,
		function(value) tankCapacity=value
		end)
	tankField:default(2000)
	tankField:step(50)
	tankField:suffix(" ml")
	
	-- Pulses Config
	local line = form.addLine(localize("pulsesName"))
	local pulsesField = form.addNumberField(line, nil, 0 , 9999,
		function() return pulses end,
		function(value) pulses=value
		end)
	pulsesField:default(2500)
	pulsesField:step(1)

	return {}
end

local function wakeup(widget)
	if newValueTank ~= tankCapacity then
		local sensorTank={}
		sensorTank = sport.getSensor({appId = 0x5201})
		sensorTank:pushFrame({physId=0x1B, primId=0x31, appId=0x5201, value=tankCapacity})
		newValueTank = tankCapacity
	end
	
	if newValuePulse ~= pulses then
		local sensorPulses={}
		sensorPulses = sport.getSensor({appId = 0x5200})
		sensorPulses:pushFrame({physId=0x1B, primId=0x31, appId=0x5200, value=pulses})
		newValuePulse = pulses
	end

end

local icon = lcd.loadMask("./flowmeter.png")

local function init()
	system.registerSystemTool({name=name, icon=icon, create=create, wakeup=wakeup})
end

return {init=init}
