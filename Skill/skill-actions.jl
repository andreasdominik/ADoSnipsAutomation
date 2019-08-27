#
# actions called by the main callback()
# provide one function for each intent, defined in the Snips Console.
#
# ... and link the function with the intent name as shown in config.jl
#
# The functions will be called by the main callback function with
# 2 arguments:
# * MQTT-Topic as String
# * MQTT-Payload (The JSON part) as a nested dictionary, with all keys
#   as Symbols (Julia-style)
#
"""
    automateAction(topic, payload)

Schedule triggers for device automation.
"""
function automateAction(topic, payload)

    # log:
    Snips.printLog("action automateAction() started.")

    # get times for start and end:
    #
    (startDate, endDate) = readDatesFromSlots(payload)
    if startDate == nothing
        Snips.publishEndSession(:error_no_dates)
        return false
    end
    if !Snips.isInConfig(INI_DEVICES)
        Snips.printLog("ERROR: no devices found in config.ini!")
        Snips.publishEndSession(:error_no_devices)
        return false
    end

    # work on all devices
    #
    for device in Snips.getConfig(INI_DEVICES)
        if !checkDeviceConfig(device)
            Snips.publishEndSession(:error_device_config)
            return false
        end

        if Snips.getConfig("$device:$INI_MODE") == "on"
            scheduleOnDevice(device, startDate, endDate)
        end
    end


end





    #
    # myName = Snips.getConfig(INI_MY_NAME)
    # if myName == nothing
    #     Snips.publishEndSession(:noname)
    #     return false
    # end
    #
    # # get the word to repeat from slot:
    # #
    # word = Snips.extractSlotValue(payload, SLOT_WORD)
    # if word == nothing
    #     Snips.publishEndSession(:dunno)
    #     return true
    # end
    #
    # # say who you are:
    # #
    # Snips.publishSay(:bravo)
    Snips.publishEndSession("ende")
    return false
end



#
#
# check ini params:
#
#

function checkDeviceConfig(device)

    if !Snips.isConfigValid("$device:$INI_MODE", regex = r"(on|once|random)")
        Snips.printLog("ERROR: no mode for device $device found in config.ini!")
        return false
    end
    if !Snips.isConfigValid("$device:$INI_NAME")
        Snips.printLog("ERROR: no name for device $device found in config.ini!")
        return false
    end
    if !Snips.isConfigValid("$device:$INI_TOPIC", r"^qnd/trigger/")
        Snips.printLog("ERROR: no topic for device $device found in config.ini!")
        return false
    end
    if !Snips.isConfigValid("$device:$INI_TRIGGR", r"\.trigger") ||
       !isfile("$TRIGGER_DIR/$(Snips.getConfig("$device:$INI_TRIGGR"))")
        Snips.printLog("ERROR: no trigger file for device $device found in config.ini!")
        return false
    end

    if Snips.getConfig("$device:$INI_MODE") == "on"
        if !checkDubleTime("$device:$INI_TIME")
            Snips.printLog("ERROR: no time for device $device found in config.ini!")
            return false
        end

    elseif Snips.getConfig("$device:$INI_MODE") == "once"
        if !checkTripleTime("$device:$INI_TIME")
            Snips.printLog("ERROR: no time for device $device found in config.ini!")
            return false
        end

    elseif Snips.getConfig("$device:$INI_MODE") == "random"
        if !checkTripleTime("$device:$INI_TIME") ||
           !checkDubleTime("$device:$INI_ON") ||
           !checkDubleTime("$device:$INI_OFF")
            Snips.printLog("ERROR: no time for device $device found in config.ini!")
            return false
        end
    else
        Snips.printLog("ERROR: undefined mode for device $device found in config.ini!")
        return false
    end

    return true
end









function checkTripleTime(param)

    return Snips.isInConfig(param) &&
           Snips.getConfig(param) isa AbstactArray &&
           length(Snips.getConfig(param)) == 3 &&
           occursin(r"^\d\d:\d\d$", Snips.getConfig(param)[1]) &&
           occursin(r"^\d\d:\d\d$", Snips.getConfig(param)[2]) &&
           occursin(r"^\d\d:\d\d$", Snips.getConfig(param)[3])))
end

function checkDubleTime(param)

    return Snips.isInConfig(param) &&
           Snips.getConfig(param) isa AbstactArray &&
           length(Snips.getConfig(param)) == 3 &&
           occursin(r"^\d\d:\d\d$", Snips.getConfig(param)[1]) &&
           occursin(r"^\d\d:\d\d$", Snips.getConfig(param)[2])
end
