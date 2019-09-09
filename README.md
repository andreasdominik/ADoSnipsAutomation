# ADoSnipsAutomation

This is a skill for the SnipsHermesQnD framework for Snips.ai
written in Julia.

The full documentation is just work-in-progress!
Current version can be visited here:

[Framework Documentation](https://andreasdominik.github.io/ADoSnipsQnD/dev)

## Skill

The skill makes it possible to schedule actions for swiching devices at
specific times. Devices are addressed using qnd-system-triggers
(part of the QnD framework).

## `config.ini`

The configuration includes profiles and devices (see example `config.ini`).
The profile defines arbitrary but unique device names:
```
summer:controlled_devices=irrigation,small_lanay
```

Configuration for each device name must include:

```
summer:irrigation:name=my irrigation
summer:irrigation:mode=only_on
summer:irrigation:time_on=19:00,00:30
summer:irrigation:days=2
summer:irrigation:topic=qnd/trigger/andreasdominik:ADoSnipsIrrigation
summer:irrigation:trigger_on=irrigation.ON.trigger
summer:irrigation:trigger_off=irrigation.OFF.trigger

# roller at door to lanay:
#
summer:small_lanay:name=roller shutter at the lanay door
summer:small_lanay:mode=random_series
summer:small_lanay:time_on=10:00,00:30
summer:small_lanay:time_off=22:00,00:30
summer:small_lanay:duration_on=00:35,00:10
summer:small_lanay:duration_off=00:35,00:10
summer:small_lanay:days=1
summer:small_lanay:topic=qnd/trigger/andreasdominik:ADoSnipsRollerShutter
summer:small_lanay:trigger_on=rollerSmallLanay.CLOSE.trigger
summer:small_lanay:trigger_off=rollerSmallLanay.OPEN.trigger
```

All times are lists of `HH:MM` with a minimum of 2 elements, because the last
time is always used as fuzzy parameter; i.e.
`time_on=19:00,20:00,00:15` will switch a device on between 18:45h and 19:15h
and again between 19:45h and 20:15h.

**name:** description used in the voice feedback

**mode:** one of
- `only_on`: only a liste of times for switching-on is given
- `on_off`: two separate lists for `on` and `off` must be provided
- `random_series`: `on` and `off` define the range of time in which
   the device is switched on and off randomly, contolled by
   the duration settings.

**duration_on, duration_off:** only valid for mode `random_series`. The device
  is switched on for duration_on plusminus fuzzy and then kept off
  for duration_off plusminus fuzzy until time_off is reached.

**days:** if given the scheduler will trigger the device only every n days.
  If not defined, `days=1` is assumed.

**topic:** topic for the QnD system trigger to be published via the
  MQTT broker

**trigger_on, trigger_off:** file with the trigger as JSON string to be published
  in order to switch a device.

The profiles must correspond with the values of the slot `Profile` in the
intent `AutomateDE`. To use additional profiles, these must be added to
the list of values of the slot.



# Julia

This skill is (like the entire SnipsHermesQnD framework) written in the
modern programming language Julia (because Julia is faster
then Python and coding is much much easier and much more straight forward).
However "Pythonians" often need some time to get familiar with Julia.

If you are ready for the step forward, start here: https://julialang.org/
