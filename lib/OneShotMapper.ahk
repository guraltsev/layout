#Requires AutoHotkey v2.0
/*
================================================================================
 OneShotMapper.ahk
================================================================================

PURPOSE
-------
OneShotMapper implements a reusable "trigger, then capture the next key" input
mechanism. It is used for mathematical input and accent composition.

Examples in this application:

    Trigger           Mapping          Result
    ----------------  ---------------  --------------------------
    Backtick          LaTeX map        A key becomes a LaTeX command
    Backtick          Unicode map      A key becomes a Unicode symbol
    Right Alt + '     Acute map        A key becomes an accented character
    Right Alt + `     Grave map        A key becomes an accented character
    Right Alt + P     Diaeresis map    A key becomes an accented character

The actual keys and output values are defined by the application configuration
and Registries.ahk. This class knows nothing about LaTeX, Unicode, or accents.

Its responsibility is the common input-capture lifecycle: activation, capture,
mapping lookup, output, cancellation, and cleanup.


ARCHITECTURE
------------

    layout.ahk
        |
        |  Creates ConfigLoader and loads configuration
        v
    Registries.ahk
        |
        |  Constructs OneShotMapper instances
        |
        +-----------------------------+
        |                             |
        v                             v
    LaTeX mapper                 Unicode mapper
    trigger: SC029               trigger: SC029
    mapping: latexMap            mapping: unicodeMap
        |                             |
        +-------------+---------------+
                      |
                      | Enable()/Disable()
                      v
                  ModeManager
                      |
                      | Selects exactly one input mode
                      |
                      v
                  OneShotMapper
                      |
                      +--> Registers trigger hotkey
                      |
                      +--> Captures subsequent input
                      |
                      +--> Looks up captured text in Map
                      |
                      +--> Sends mapped output or fallback text


SEPARATION OF RESPONSIBILITIES
------------------------------

OneShotMapper owns:
    - The trigger hotkey registration associated with this mapper.
    - The mapping object and output function.
    - The active InputHook, when one exists.
    - Cancellation of an active capture.
    - Protection against callbacks from an obsolete activation.
    - Cleanup after success, timeout, cancellation, or an exception.

OneShotMapper does NOT own:
    - The application-wide layout or input-mode state.
    - Loading or saving configuration.
    - Choosing which input mode should be active.
    - Constructing the character maps.
    - Drawing or updating the tray menu.
    - Choosing the meaning of a particular trigger or mapped character.

Those responsibilities belong to AppState, ConfigLoader, Registries,
ModeManager, TrayUI, and layout.ahk.


NORMAL CAPTURE LIFECYCLE
-----------------------

    1. Enable()
       The mapper registers its trigger hotkey and becomes active.

    2. OnTrigger()
       When the trigger is pressed, the handler records the current activation
       generation and assigns an identifier to this particular capture.

    3. Start capture
       The trigger is temporarily disabled to prevent recursive activation.
       The handler creates and starts an InputHook, then releases Critical
       execution protection before waiting for user input.

    4. Wait
       InputHook.Wait() allows the capture to finish. Other script actions,
       including a change of input mode from the tray, must remain possible.

    5. Validate
       Once the capture ends, the handler checks whether this mapper is still
       enabled, whether its activation generation is unchanged, whether the
       capture still owns the active-capture slot, and whether the hook was
       stopped.

    6. Send output
       A valid capture is looked up in the mapping. If there is no mapping,
       the captured text is passed to the configured output function unchanged.

    7. Cleanup
       The active-capture reference is cleared only if it still belongs to
       this capture. The trigger is re-enabled only if this activation still
       owns it.


CANCELLATION LIFECYCLE
---------------------

A capture may be waiting for input when the user changes modes or layouts.

For example:

    LaTeX mode enabled
        |
        v
    User presses backtick
        |
        v
    LaTeX InputHook waits for the next character
        |
        v
    User changes mode to Unicode or Off
        |
        +--> ModeManager calls the old mapper's Disable()
        |
        +--> Disable() marks the mapper inactive
        |
        +--> The activation generation changes
        |
        +--> The active-capture reference is invalidated
        |
        +--> InputHook.Stop() cancels the capture
        |
        v
    The old InputHook.Wait() returns
        |
        v
    The old handler sees that its capture is invalid
        |
        +--> No mapped output is sent
        |
        +--> No stale active-capture reference is cleared
        |
        +--> The old trigger is not re-enabled
        |
        v
    The newly selected mode retains control of its trigger


WHY THE GENERATION COUNTER IS NECESSARY
---------------------------------------

Checking only this.enabled is insufficient.

Consider:

    1. A capture begins in generation 3.
    2. Disable() sets enabled := false and advances the generation to 4.
    3. Enable() sets enabled := true and advances the generation to 5.
    4. The old capture callback resumes.

At step 4, enabled is true again. A test of enabled alone would mistakenly allow
the old callback to send output or re-enable its hotkey.

The generation check rejects the old callback because it belongs to generation
3, not generation 5.

Each capture also receives a unique identifier. This prevents the cleanup code
from clearing the reference to a newer capture that started after cancellation.


WHY BOTH LaTeX AND Unicode NEED THIS PROTECTION
-----------------------------------------------

The LaTeX and Unicode mappers both use SC029 as their trigger.

ModeManager is responsible for disabling the previous mapper before enabling
the next one. OneShotMapper must respect this ownership arrangement.

An obsolete LaTeX capture must not re-enable SC029 after Unicode mode has
taken over. Likewise, an older capture must not overwrite the active-capture
state of a newly started capture.

The generation and capture-identifier checks enforce these requirements within
each mapper instance, assuming mode changes go through the application's
normal ModeManager workflow.


STATE MODEL
-----------

enabled
    Whether this mapper is intended to be active.

_generation
    Activation version. Incremented when enabling or disabling the mapper.
    A capture may produce output only while its saved generation is current.

_captureSerial
    Monotonically increasing identifier source for capture sessions.

_activeCaptureId
    Identifier of the capture currently owned by this mapper, or 0 if none.

_activeGeneration
    Generation associated with the active capture, or 0 if none.

_activeHook
    InputHook object for the currently owned capture, or an empty string if
    there is no active capture.

_handler
    Bound callback passed to AutoHotkey when registering the trigger hotkey.


INVARIANTS
----------

1. A disabled mapper must not produce output from a canceled capture.

2. An old generation must never become valid merely because the mapper was
   enabled again.

3. Cleanup from a capture may modify the shared capture state only if that
   capture still owns the active-capture identifier.

4. A capture may re-enable its trigger only if its mapper remains enabled and
   its generation is still current.

5. Waiting for user input must not occur while the handler is Critical. Other
   script actions must be able to disable the mapper and cancel its capture.

6. Cleanup must run even when the output function throws an exception.

7. The class preserves the existing mapping and fallback policy. It does not
   independently choose the desired active layout or input mode.


THREADING AND INTERRUPTIBILITY
------------------------------

AutoHotkey can run a hotkey or menu callback while another handler is waiting
for input. That behavior is essential to this design.

Critical is used only around short state transitions:

    - Activating or deactivating a mapper.
    - Publishing a new capture and starting its hook.
    - Validating a completed capture and sending its result.
    - Releasing capture state and restoring the trigger.

Critical is explicitly turned off before InputHook.Wait().

The completed-capture validity check and output operation are kept together
so an ordinary mode-switch callback cannot invalidate the capture between
validation and sending its result.


PUBLIC INTERFACE
----------------

    mapper := OneShotMapper(
        triggerHotkey,
        mapping,
        sendFn,
        captureLen,
        timeoutMs
    )

    mapper.Enable()
        Activates the trigger hotkey.

    mapper.Disable()
        Deactivates the trigger and cancels an outstanding capture.

Parameters:
    triggerHotkey
        AutoHotkey hotkey string, e.g. "SC029" or ">!SC028".

    mapping
        Map of captured text to replacement output.

    sendFn
        Function that sends the output. Defaults to SendText.

    captureLen
        Number of characters to collect. Defaults to 1.

    timeoutMs
        Maximum capture time in milliseconds. 0 means no timeout.


COMPATIBILITY
-------------

This implementation retains the existing constructor, Enable(), Disable(),
map lookup, send function, configurable capture length, and timeout behavior.

An empty capture produces no output. A stopped capture is canceled even if
InputHook.Input already contains text. A completed capture with text retains
the existing mapped-output / unmapped-text fallback policy.

This module does not change the intended layout mappings or input-mode policy.
================================================================================
*/


class OneShotMapper {

    ; -------------------------------------------------------------------------
    ; Construction
    ; -------------------------------------------------------------------------

    __New(triggerHotkey, mapping, sendFn := unset,
        captureLen := 1, timeoutMs := 0) {

        this.trigger := triggerHotkey
        this.map := mapping
        this.sendFn := IsSet(sendFn) ? sendFn : SendText
        this.captureLen := captureLen
        this.timeoutMs := timeoutMs

        ; Desired activation state.
        this.enabled := false

        ; Incremented on every enable/disable transition. Invalidates callbacks
        ; created by an earlier activation, including rapid reactivation.
        this._generation := 0

        ; Distinguishes individual captures, even within one mapper instance.
        this._captureSerial := 0

        ; Shared state describing the currently owned capture.
        this._activeCaptureId := 0
        this._activeGeneration := 0
        this._activeHook := ""

        ; One stable callback object is registered for the trigger hotkey.
        this._handler := ObjBindMethod(this, "OnTrigger")
    }


    ; -------------------------------------------------------------------------
    ; Enable
    ; -------------------------------------------------------------------------

    Enable() {
        ; Keep the activation transition atomic with respect to other ordinary
        ; AutoHotkey threads.
        Critical

        if this.enabled {
            Critical "Off"
            return
        }

        ; A newly enabled mapper belongs to a new activation generation.
        this._generation += 1
        this.enabled := true

        try {
            Hotkey(this.trigger, this._handler, "On")
        } catch as err {
            ; Do not report an active mapper if registration failed.
            this.enabled := false
            this._generation += 1

            Critical "Off"
            throw err
        }

        Critical "Off"
    }


    ; -------------------------------------------------------------------------
    ; Disable and cancel
    ; -------------------------------------------------------------------------

    Disable() {
        Critical

        wasEnabled := this.enabled

        ; Invalidate the current activation before stopping the hook. When the
        ; waiting callback resumes, it will already be marked obsolete.
        this.enabled := false
        this._generation += 1

        ; Keep a local reference so the hook can be stopped after shared state
        ; is invalidated.
        ih := this._activeHook

        this._activeHook := ""
        this._activeGeneration := 0
        this._activeCaptureId := 0

        ; Do not switch off a shared trigger when this mapper is already
        ; disabled: another mapper may now own that same hotkey.
        if wasEnabled {
            try {
                Hotkey(this.trigger, "Off")
            } catch {
                ; Cleanup should continue even if hotkey removal fails.
            }
        }

        ; Stop() terminates an active InputHook and wakes a thread waiting for
        ; it. It is harmless if collection has already ended.
        if IsObject(ih) {
            try {
                ih.Stop()
            } catch {
                ; Continue cleanup if the hook has already stopped.
            }
        }

        Critical "Off"
    }


    ; -------------------------------------------------------------------------
    ; Trigger handler
    ; -------------------------------------------------------------------------

    OnTrigger(*) {
        ; The setup must not be interrupted between validating the mapper,
        ; disabling the trigger, and publishing the active InputHook.
        Critical

        if !this.enabled {
            Critical "Off"
            return
        }

        ; A mapper must not start a second capture while it already owns one.
        if (this._activeCaptureId != 0) {
            Critical "Off"
            return
        }

        ; Record the exact activation and capture that own this handler.
        generation := this._generation

        this._captureSerial += 1
        captureId := this._captureSerial

        hk := this.trigger
        ih := ""

        ; Set up the capture. If setup fails, undo the partial state and
        ; restore the trigger only if this activation still owns it.
        try {
            Hotkey(hk, "Off")

            ih := InputHook("L" this.captureLen)

            if (this.timeoutMs > 0)
                ih.Timeout := this.timeoutMs / 1000.0

            ; Publish the hook before Start(). Disable() can then locate and
            ; cancel the capture as soon as setup protection is released.
            this._activeHook := ih
            this._activeGeneration := generation
            this._activeCaptureId := captureId

            ih.Start()

        } catch as err {
            if IsObject(ih) {
                try {
                    ih.Stop()
                } catch {
                }
            }

            ; Clear only the state belonging to this failed setup attempt.
            if (this._activeCaptureId = captureId) {
                this._activeHook := ""
                this._activeGeneration := 0
                this._activeCaptureId := 0
            }

            ; A different activation or mapper may own the trigger now.
            if (this.enabled && this._generation = generation) {
                try {
                    Hotkey(hk, "On")
                } catch {
                }
            }

            Critical "Off"
            throw err
        }

        ; Waiting must be interruptible so a tray selection or another hotkey
        ; can disable the mapper and stop the current InputHook.
        Critical "Off"

        try {
            ; Wait() returns the reason that ended input collection.
            reason := ih.Wait()
            key := ih.Input

            ; Keep validation and output together. If a mode switch invalidated
            ; this capture first, its generation or identifier will differ.
            Critical

            isCurrentCapture :=
                this.enabled
                && this._generation = generation
                && this._activeGeneration = generation
                && this._activeCaptureId = captureId

            wasStopped := (reason = "Stopped")

            if (isCurrentCapture && !wasStopped && key != "") {
                ; Preserve the application's existing mapping behavior:
                ; mapped text becomes its replacement; otherwise the original
                ; captured text is passed to the configured send function.
                if this.map.Has(key)
                    out := this.map[key]
                else
                    out := key

                (this.sendFn)(out)
            }

        } finally {
            ; This block must run after normal completion and if the send
            ; function or other capture-processing code throws an exception.
            Critical

            ; Never clear state that belongs to a newer capture.
            if (this._activeCaptureId = captureId) {
                this._activeHook := ""
                this._activeGeneration := 0
                this._activeCaptureId := 0
            }

            ; Never re-enable a trigger on behalf of an obsolete activation.
            ; This is essential when LaTeX and Unicode share the same trigger.
            if (this.enabled && this._generation = generation) {
                try {
                    Hotkey(hk, "On")
                } catch {
                    ; Do not hide or overwrite the original send exception.
                }
            }

            Critical "Off"
        }
    }
}
