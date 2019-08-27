#
# API function goes here, to be called by the
# skill-actions:
#

function scheduleOnDevice(device, startDate, endDate)

    planDate = startDate
    if planDate < Dates.now()
        planDate = Dates.now()
    end

    # step days:
    #
    actions = []
    while planDate <= endDate
        onTime = readFuzzyTime("$device:$INI_TIME")
        if !(planDate == startDate && onTime < Dates.now())
            push!(actions, Snips.schedulerMakeAction(onTime, ))




        planDate += Dates.Day(1)
    end

"""
Read a time from duble as first +- second
"""
function readFuzzyTime(param)

    times = Snips.getConfig(param)
    onTime = Dates.Time(times[1])
    onFuzzy = Dates.Time(times[2])

    fuzzyMins = Dates.value(Dates.Minute(onFuzzy))
    onTime += Dates.Minute(rand(-fuzzyMins:fuzzyMins))
    return onTime
end




function readDatesFromSlots(payload)

    startDate = nothing
    endDate = nothing

    # date format delivered from Snips:
    #
    dateFormat = Dates.DateFormat("yyyy-mm-dd HH:MM:SS +00:00")
    times = extractSlotValue(payload, SLOT_DATE)

    if length(times) == 0
        Snips.printLog("No dates in slot!")

    elseif length(times) == 2
        startDate = Dates.DateTime(times[1], dateFormat)
        endDate = Dates.DateTime(times[2], dateFormat)

        Snips.printDebug("Dates: $startDate, $endDate")

    elseif length(times) = 1
        startDate = Dates.now()
        endDate = Dates.DateTime(times[1], dateFormat)

    else # length(times) > 2
         Snips.printLog("More then 2 dates in slot!")
    end

    # correct, if wrong sequence:
    #
    if startDate == nothing || endDate == nothing
        Snips.printLog("ERROR: Not dates in slot!")
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
