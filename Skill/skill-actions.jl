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
