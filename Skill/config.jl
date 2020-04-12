# DO NOT CHANGE THE FOLLOWING 3 LINES UNLESS YOU KNOW
# WHAT YOU ARE DOING!
# set CONTINUE_WO_HOTWORD to true to be able to chain
# commands without need of a hotword in between:
#
const CONTINUE_WO_HOTWORD = false
const DEVELOPER_NAME = "andreasdominik"
Snips.setDeveloperName(DEVELOPER_NAME)
Snips.setModule(@__MODULE__)

const TRIGGER_DIR ="$(Snips.getAppDir())/Triggers"

#
# language settings:
# Snips.LANG in QnD(Snips) is defined from susi.toml or set
# to "en" if no susi.toml found.
# This will override LANG by config.ini if a key "language"
# is defined locally:
#
if Snips.isConfigValid(:language)
    Snips.setLanguage(Snips.getConfig(:language))
end
# or LANG can be set manually here:
# Snips.setLanguage("fr")
#
# set a local const with LANG:
#
const LANG = Snips.getLanguage()
#
# END OF DO-NOT-CHANGE.


# Slots:
# Name of slots to be extracted from intents:
#
const SLOT_DATE = "StartEndDate"
const SLOT_START_DATE = "StartDate"
const SLOT_END_DATE = "EndDate"
const SLOT_PROFILE = "Profile"

# name of entry in config.ini:
#
const INI_DEVICES = "controlled_devices"    # list of devices
const INI_NAME = "name"                     # postfix: device name with article
const INI_MODE = "mode"                     # postfix: one of
const INI_EVERY_DAY = "days"

const INI_TIME_ON = "time_on"               # postfix: start-, fuzzy-time
const INI_TIME_OFF = "time_off"             # postfix: end-, fuzzy-time
                                            #    once_on, once_on_off, random_series
const INI_DURATION_ON= "duration_on"        # postfix: time and fuzzy of on-times
const INI_DURATION_OFF = "duration_off"     # postfix: time and fuzzy of off-times

const INI_TRIGGER_ON = "trigger_on"         # postfix: filename of trigger
const INI_TRIGGER_OFF = "trigger_off"       # postfix: filename of trigger
const INI_TOPIC = "topic"                   # postfix: topic of trigger

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
    Snips.registerIntentAction("AutomateEndDE", endAction)
else
    Snips.registerIntentAction("AutomateDE", automateAction)
    Snips.registerIntentAction("AutomateEndDE", endAction)
end
