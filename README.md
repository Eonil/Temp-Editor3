

Editor3
=======
This is 3rd re-architected version of Editor.



See `NOTE.md` for details.
Documentation for each features are located in the closest directory
of each features. Please look for there.

Entry point is `main.swift` file. You can start from there.





What You Need To Know Before Getting Started
--------------------------------------------
Largely, this app is built with two tiers.

- UI
- State

Basically, "UI" drives everything. Changes between UI components are
notified by single closure property `onEvent`, and always single-cast.

UI components are fundamentally segregated. Which means no component
should depend on another component's state. A super-component can control
subcomponents, but not in opposite direction.

"State" is used if a UI component have to share some state with another
components. State changes from a state component to UI component are 
always broadcasted by global notification. (no local or signle-cast)

State is independent from UI, and can be out-synced sometimes. UI will
try its best to keep synced state, but fundamentally it's asynchronous.





Event Handling Advise
---------------------
"Event" is a notification from aliens. "Aliens" means you don't know what 
it is, and have no control on them. So you have assume EVERY events are
coming in no order regardless of whatever it is and however it defined.
Because every system can have bugs, errors, and unexpected situations and
you have no control on such things for aliens.

* Note: State-machines are not events. You can define some assumptions on
        state machines if you can control them completely. If you cannot
        control them, then that's not a state-machine TO YOU, so you have
        to treat them as bunch of orderless events.








