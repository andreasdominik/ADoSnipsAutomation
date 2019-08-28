#
# API function goes here, to be called by the
# skill-actions:
#

function scheduleOnDevice(device, startDate, endDate)

    planDate = Dates.Date(max(startDate, Dates.today()))
    triggerON = Snips.tryParseJSONfile("$TRIGGER_DIR/$(Snips.getConfig("$device:$INI_TRIGGER_ON"))")
    topic = Snips.getConfig("$device:$INI_TOPIC")

    # step days:
    #
    Snips.printLog("Planning schedules for device $device from $startDate to $endDate")
    actions = []
    while planDate <= endDate
        onDateTime = readFuzzyTime("$device:$INI_TIME_ON", planDate)

        if !(onDateTime < Dates.now())
            push!(actions, Snips.schedulerMakeAction(
                                    onDateTime, topic, triggerON))
            Snips.printLog("    ON at $onDateTime")
        end
        planDate += Dates.Day(1)
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
function readFuzzyTime(param, planDate; returnDateTime = true)

    times = Snips.getConfig(param)
    onTime = Dates.Time(times[1])     # time
    onFuzzy = Dates.Time(times[2])    # fuzzy

    onTimeDate = Dates.DateTime(planDate + onTime)

    fuzzyMins = Dates.value(Dates.Minute(onFuzzy)) +
                Dates.value(Dates.Hour(onFuzzy)) * 60
    ΔMins = Dates.Minute(rand(-fuzzyMins:fuzzyMins))
    onTimeDate += ΔMins
    if returnDateTime
        return onTimeDate
    else
        return Dates.Time(onTimeDate)
    end
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
