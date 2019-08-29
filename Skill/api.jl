#
# API function goes here, to be called by the
# skill-actions:
#

function scheduleOnDevice(device, startDate, endDate)

    planDate = Dates.Date(max(startDate, Dates.today()))
    triggerON = Snips.tryParseJSONfile("$TRIGGER_DIR/$(Snips.getConfig("$device:$INI_TRIGGER_ON"))",
                            quiet = true)
    updateTrigger!(triggerON)
    topic = Snips.getConfig("$device:$INI_TOPIC")

    # step days:
    #
    if Snips.isConfigValid("$device:$INI_EVERY_DAY", regex = r"^[0-9]+$")
        daystep = tryparse(Int, Snips.getConfig("$device:$INI_EVERY_DAY"))
        if daystep == nothing
            daystep = 1
        end
    else
        daystep = 1
    end

    Snips.printLog("Planning schedules for device $device from $startDate to $endDate")
    actions = []
    while planDate <= endDate

        for i in 1:length(Snips.getConfig("$device:$INI_TIME_ON"))-1

            onDateTime = readFuzzyTime("$device:$INI_TIME_ON", planDate, i)
            if (onDateTime > Dates.now())
                push!(actions, Snips.schedulerMakeAction(
                                        onDateTime, topic, triggerON))
                Snips.printLog("    ON  at $onDateTime")
            end
        end
        planDate += Dates.Day(daystep)
    end

    if length(actions) > 1
        Snips.schedulerAddActions(actions)
        sleep(2)  # wait to prevent to fast sequence of triggers
    end
end



function scheduleOnOffDevice(device, startDate, endDate)

    planDate = Dates.Date(max(startDate, Dates.today()))
    triggerON = Snips.tryParseJSONfile("$TRIGGER_DIR/$(Snips.getConfig("$device:$INI_TRIGGER_ON"))",
                            quiet = true)
    triggerOFF = Snips.tryParseJSONfile("$TRIGGER_DIR/$(Snips.getConfig("$device:$INI_TRIGGER_OFF"))",
                            quiet = true)
    updateTrigger!(triggerON)
    updateTrigger!(triggerOFF)
    topic = Snips.getConfig("$device:$INI_TOPIC")

    # step days:
    #
    if Snips.isConfigValid("$device:$INI_EVERY_DAY", regex = r"^[0-9]+$")
        daystep = tryparse(Int, Snips.getConfig("$device:$INI_EVERY_DAY"))
        if daystep == nothing
            daystep = 1
        end
    else
        daystep = 1
    end

    Snips.printLog("Planning schedules for device $device from $startDate to $endDate")
    actions = []
    while planDate <= endDate

        for i in 1:length(Snips.getConfig("$device:$INI_TIME_ON"))-1

            onDateTime = readFuzzyTime("$device:$INI_TIME_ON", planDate, i)

            if onDateTime > Dates.now()
                push!(actions, Snips.schedulerMakeAction(
                                        onDateTime, topic, triggerON))
                Snips.printLog("    ON  at $onDateTime")
            end
        end
        for i in 1:length(Snips.getConfig("$device:$INI_TIME_OFF"))-1

            offDateTime = readFuzzyTime("$device:$INI_TIME_OFF", planDate, i)

            push!(actions, Snips.schedulerMakeAction(
                                    offDateTime, topic, triggerOFF))
            Snips.printLog("    OFF at $offDateTime")
        end
        planDate += Dates.Day(daystep)
    end

    if length(actions) > 1
        Snips.schedulerAddActions(actions)
        sleep(2)  # wait to prevent to fast sequence of triggers
    end
end



function scheduleRandomDevice(device, startDate, endDate)

    planDate = Dates.Date(max(startDate, Dates.today()))
    triggerON = Snips.tryParseJSONfile("$TRIGGER_DIR/$(Snips.getConfig("$device:$INI_TRIGGER_ON"))",
                            quiet = true)
    triggerOFF = Snips.tryParseJSONfile("$TRIGGER_DIR/$(Snips.getConfig("$device:$INI_TRIGGER_OFF"))",
                            quiet = true)
    updateTrigger!(triggerON)
    updateTrigger!(triggerOFF)
    topic = Snips.getConfig("$device:$INI_TOPIC")

    # step days:
    #
    if Snips.isConfigValid("$device:$INI_EVERY_DAY", regex = r"^[0-9]+$")
        daystep = tryparse(Int, Snips.getConfig("$device:$INI_EVERY_DAY"))
        if daystep == nothing
            daystep = 1
        end
    else
        daystep = 1
    end

    Snips.printLog("Planning schedules for device $device from $startDate to $endDate")
    actions = []
    while planDate <= endDate
        onDateTime = readFuzzyTime("$device:$INI_TIME_ON", planDate)
        offDateTime = readFuzzyTime("$device:$INI_TIME_OFF", planDate)

        nextOn = onDateTime
        nextOff = readFuzzyTime("$device:$INI_DURATION_ON", nextOn)

        while nextOn < offDateTime
            if (nextOn > Dates.now()) && (nextOn < nextOff)
                push!(actions, Snips.schedulerMakeAction(
                                        nextOn, topic, triggerON))
                Snips.printLog("    ON  at $nextOn")

                push!(actions, Snips.schedulerMakeAction(
                                        nextOff, topic, triggerOFF))
                Snips.printLog("    OFF at $nextOff")
            end
            nextOn = readFuzzyTime("$device:$INI_DURATION_OFF", nextOff)
            nextOff = readFuzzyTime("$device:$INI_DURATION_ON", nextOn)
        end
        planDate += Dates.Day(daystep)
    end

    if length(actions) > 1
        Snips.schedulerAddActions(actions)
        sleep(2)  # wait to prevent to fast sequence of triggers
    end
end



"""
Read a time from duble as first +- second
If returnDateTime == true, an absolute DateTime is returned
if false,  only HH:MM is returned.
"""
function readFuzzyTime(param, planDate, i)

    times = Snips.getConfig(param)
    onTime = Dates.Time(times[i])     # time
    onFuzzy = Dates.Time(times[end])    # fuzzy

    planDateTime = Dates.DateTime(planDate)
    onTimeMins = Dates.value(Dates.Minute(onTime)) +
                 Dates.value(Dates.Hour(onTime)) * 60
    onTimeMins = Dates.Minute(onTimeMins)
    # onTimeDate = Dates.DateTime(planDate + onTime)

    fuzzyMins = Dates.value(Dates.Minute(onFuzzy)) +
                Dates.value(Dates.Hour(onFuzzy)) * 60
    ΔMins = Dates.Minute(rand(-fuzzyMins:fuzzyMins))
    onTimeDate = planDateTime + ΔMins + onTimeMins

    return onTimeDate
end




function readDatesFromSlots(payload)

    startDate = nothing
    endDate = nothing

    # date format delivered from Snips:
    #
    dateFormat = Dates.DateFormat("yyyy-mm-dd HH:MM:SS +00:00")
    times = Snips.extractSlotValue(payload, SLOT_DATE, multiple = true)
    Snips.printDebug("dates: $times")

    # fix timezone in slot:
    #
    for (i,s) in enumerate(times)
        times[i] = replace(s, r" \+\d\d:\d\d$"=>"")
    end
    Snips.printDebug("dates: $times")

    if length(times) == 0
        Snips.printLog("No dates in slot!")

    elseif length(times) == 2
        startDate = Dates.DateTime(times[1], dateFormat)
        endDate = Dates.DateTime(times[2], dateFormat)

        Snips.printDebug("Dates: $startDate, $endDate")

    elseif length(times) == 1
        startDate = Dates.now()
        endDate = Dates.DateTime(times[1], dateFormat)

    else # length(times) > 2
         Snips.printLog("More then 2 dates in slot!")
    end

    # correct, if wrong sequence:
    #
    if startDate == nothing || endDate == nothing
        Snips.printLog("ERROR: No dates in slot!")
        startDate, endDate = nothing, nothing
    else
        startDate = Dates.Date(startDate)
        endDate = Dates.Date(endDate)

        if startDate > endDate
            startDate, endDate = endDate, startDate
        end
    end


    return startDate, endDate
end


function updateTrigger!(trigger)

    trigger[:time] = "$(Dates.now())"
    trigger[:origin] = "ADoSnipsAutomation"
end



function deleteAllfromAutomation()
    Snips.schedulerDeleteOrigin("ADoSnipsAutomation")
end
