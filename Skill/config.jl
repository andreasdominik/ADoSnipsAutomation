
# language settings:
# 1) set LANG to "en", "de", "fr", etc.
# 2) link the Dict with messages to the version with
#    desired language as defined in languages.jl:
#

lang = Snips.getConfig(:language)
const LANG = (lang != nothing) ? lang : "de"

# DO NOT CHANGE THE FOLLOWING 3 LINES UNLESS YOU KNOW
# WHAT YOU ARE DOING!
# set CONTINUE_WO_HOTWORD to true to be able to chain
# commands without need of a hotword in between:
#
const CONTINUE_WO_HOTWORD = false
const DEVELOPER_NAME = "andreasdominik"
Snips.setDeveloperName(DEVELOPER_NAME)
Snips.setModule(@__MODULE__)

# Slots:
# Name of slots to be extracted from intents:
#
const SLOT_DATE = "StartEndDate"

# name of entry in config.ini:
#
const INI_DEVICES = "controlled_devices"    # list of devices
const INI_NAME = "name"                     # postfix: device name with article
const INI_TIME = "time"                     # postfix: start-, end-, fuzzy-time
const INI_MODE = "mode"                     # postfix: one of on, once, random
                                            #    on: only on
                                            #    once: fuzzy on and off
                                            #    random: multiple fuzzy on and off
const INI_ON_TIME = "on_duration"           # postfix: time and fuzzy of on-times
const INI_OFF = "off_duration"              # postfix: time and fuzzy of off-times

#
# link between actions and intents:
# intent is linked to action{Funktion}
# the action is only matched, if
#   * intentname matches and
#   * if the siteId matches, if site is  defined in config.ini
#     (such as: "switch TV in room abc").
#
# Language-dependent settings:
#
if LANG == "de"
    Snips.registerIntentAction("AutomateDE", automateAction)
else
    Snips.registerIntentAction("AutomateDE", automateAction)
end
