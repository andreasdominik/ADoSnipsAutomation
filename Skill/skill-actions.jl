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
    if (startDate == nothing) || (endDate == nothing)
        Snips.publishEndSession(:error_no_dates)
        return true
    end

    profile = Snips.extractSlotValue(payload, SLOT_PROFILE)
    if profile == nothing
        Snips.publishEndSession(:error_no_profile)
        return true
    end
    Snips.setConfigPrefix(profile)

    # read config again to refresh configuration:
    #
    Snips.readConfig("$APP_DIR")

    if !Snips.isInConfig(INI_DEVICES)
        Snips.printLog("ERROR: no devices found in config.ini!")
        Snips.publishEndSession(:error_no_devices)
        return false
    end

    Snips.publishSay("""$(Snips.langText(:i_start_from)) $(Snips.readableDate(startDate))
                        $(Snips.langText(:until)) $(Snips.readableDate(endDate))""")

    # work on all devices
    #
    for device in Snips.getConfig(INI_DEVICES, multiple=true)

        deviceName = Snips.getConfig("$device:$INI_NAME")
        # if !Snips.askYesOrNo(
        #    "$(Snips.langText(:ask_device_1)) $deviceName $(Snips.langText(:ask_device_2))")
        #
        #    Snips.publishSay("""$deviceName $(Snips.langText(:skipped))""")

       # else
            if !checkDeviceConfig(device)
                Snips.publishEndSession(:error_device_config)
                return false
            end

            if Snips.getConfig("$device:$INI_MODE") == "only_on"
                scheduleOnDevice(device, startDate, endDate)
            end

            if Snips.getConfig("$device:$INI_MODE") == "on_off"
                scheduleOnOffDevice(device, startDate, endDate)
            end

            if Snips.getConfig("$device:$INI_MODE") == "random_series"
                scheduleRandomDevice(device, startDate, endDate)
            end
        # end
    end

    Snips.publishEndSession(:is_on)
    return false
end


function endAction(topc, payload)

    if Snips.askYesOrNo(:ask_end)
        Snips.publishEndSession(:all_deleted)
        deleteAllfromAutomation()
    else
        Snips.publishEndSession(:continue)

    end
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
    if !Snips.isConfigValid("$device:$INI_TOPIC", regex = r"^qnd/trigger/")
        Snips.printLog("ERROR: no topic for device $device found in config.ini!")
        return false
    end
    if !Snips.isConfigValid("$device:$INI_TRIGGER_ON", regex = r"ON\.trigger") ||
       !isfile("$TRIGGER_DIR/$(Snips.getConfig("$device:$INI_TRIGGER_ON"))") ||
       !Snips.isConfigValid("$device:$INI_TRIGGER_OFF", regex = r"OFF\.trigger") ||
       !isfile("$TRIGGER_DIR/$(Snips.getConfig("$device:$INI_TRIGGER_OFF"))")
        Snips.printLog("ERROR: trigger file for device $device missing!")
        return false
    end
    param = "$device:$INI_TRIGGER_ON"
    json = Snips.tryParseJSONfile("$TRIGGER_DIR/$(Snips.getConfig(param))")
    Snips.printDebug("Check trigger: $json")


    if Snips.getConfig("$device:$INI_MODE") == "only_on"
        if !checkDubleTime("$device:$INI_TIME_ON")
            Snips.printLog("ERROR: no time for device $device found in config.ini!")
            return false
        end

    elseif Snips.getConfig("$device:$INI_MODE") == "on_off"
        if !checkDubleTime("$device:$INI_TIME_ON") ||
           !checkDubleTime("$device:$INI_TIME_OFF")
            Snips.printLog("ERROR: no time for device $device found in config.ini!")
            return false
        end

    elseif Snips.getConfig("$device:$INI_MODE") == "random_series"
        if !checkDubleTime("$device:$INI_TIME_ON") ||
           !checkDubleTime("$device:$INI_TIME_OFF") ||
           !checkDubleTime("$device:$INI_DURATION_ON") ||
           !checkDubleTime("$device:$INI_DURATION_OFF")
            Snips.printLog("ERROR: no time for device $device found in config.ini!")
            return false
        end
    else
        Snips.printLog("ERROR: undefined mode for device $device found in config.ini!")
        return false
    end

    return true
end








#
# function checkTripleTime(param)
#
#     return Snips.isInConfig(param) &&
#            Snips.getConfig(param) isa AbstractArray &&
#            length(Snips.getConfig(param)) == 3 &&
#            occursin(r"^\d\d:\d\d$", Snips.getConfig(param)[1]) &&
#            occursin(r"^\d\d:\d\d$", Snips.getConfig(param)[2]) &&
#            occursin(r"^\d\d:\d\d$", Snips.getConfig(param)[3])
# end

function checkDubleTime(param)

    return Snips.isInConfig(param) &&
           Snips.getConfig(param) isa AbstractArray &&
           length(Snips.getConfig(param)) >= 2 &&
           occursin(r"^\d\d:\d\d$", Snips.getConfig(param)[1]) &&
           occursin(r"^\d\d:\d\d$", Snips.getConfig(param)[2])
end
