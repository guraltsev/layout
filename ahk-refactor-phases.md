# AHK Refactor Plan — Phase-by-Phase Instructions

This document turns the refactor plan into executable phases. Each phase is designed to be **small, testable, and reversible**, so you can stop after any phase with the scripts still usable.

**Scope / Inputs**
- Current scripts (as uploaded):  
  `layout.ahk`, `CharacterMaps.ahk`, `LaTeXMathInput.ahk`, `LaTeXMathInputMaps.ahk`, `UnicodeMathInput.ahk`, `UnicodeMathInputMaps.ahk`

**High-level goals**
1. Reduce extension friction by centralizing state and UI updates.
2. Eliminate duplicated “capture next key → map → send” logic (one reusable component).
3. Make layouts and input modes **data-driven** and **registry-based**.

---

## Phase 0 — Stabilize current behavior (bug fixes + semantics)

### Goal
Ensure the existing scripts behave correctly before structural changes.

### Tasks
1. **Fix the broken toggle assignment**
   - In `layout.ahk`, `UnicodeMathInput_Toggle()` currently has a newline splitting:
     ```ahk
     UnicodeMathInput := !
     UnicodeMathInput
     ```
   - Replace with:
     ```ahk
     UnicodeMathInput := !UnicodeMathInput
     ```

2. **Fix tray initial check for Unicode mode**
   - The `"UnicodeInput"` tray check is currently tied to `LaTeXMathInput`.  
     Make it depend on `UnicodeMathInput`.

3. **Fix hotkey binding for LaTeX mode**
   - Under `#HotIf LaTeXMathInput == True`, the hotkey currently binds to `UnicodeMath_HKF`.  
     Bind it to `LaTeXMath_HKF`.

4. **Decide the semantics for math modes**
   - Recommended: **one mode field** (`Off | LaTeX | Unicode`) instead of two independent toggles.
   - If you keep two toggles for now, define precedence rules and make them explicit.

### Acceptance tests
- Toggling Unicode mode actually toggles.
- Tray checks reflect the real booleans.
- In LaTeX mode, backtick triggers LaTeX map; in Unicode mode, backtick triggers Unicode map.
- Switching layout still works as before.

### Rollback plan
Revert only `layout.ahk` to the pre-Phase-0 commit.

---

## Phase 1 — Introduce a reusable OneShotMapper (remove duplication)

### Goal
Move all “capture next key and map it” features to one reusable component so new modes/maps require no custom hotkey function.

### New files
- `lib/OneShotMapper.ahk`
- (optional) `lib/Logger.ahk` (Phase 2 if you want)

### Tasks
1. Implement `OneShotMapper` with:
   - constructor arguments:
     - `triggerHotkey` (e.g. `"SC029"` or `">!SC029"`)
     - `mapping` (`Map`)
     - `sendFn` (callable; default `SendText`)
     - `captureLen` (default 1)
     - `timeoutMs` (optional)
     - `visibleNonText` (default true)
   - methods:
     - `Enable()`, `Disable()`
     - internal handler `OnTrigger()` that:
       1) disables the trigger hotkey using `A_ThisHotkey`
       2) runs InputHook (collects input)
       3) looks up mapped output
       4) sends output if found, else fall back (send captured input)
       5) re-enables trigger hotkey

2. Replace the following in `layout.ahk` (or in the new main file if you start moving):
   - `LaTeXMath_HKF` → use `OneShotMapper` instance with `LaTeXMathMap`
   - `UnicodeMath_HKF` → instance with `UnicodeMathMap`
   - `RAlt_Accent_HKF` → instances with the relevant accent maps

3. Ensure each mapper has its **own InputHook**, not a shared global `IH`.

### Acceptance tests
- Every previously supported one-shot mapping still works:
  - LaTeX: backtick + `a` → `\alpha` (example)
  - Unicode: backtick + `a` → `α` (example)
  - Accent compose: RAlt + `'` then `e` → `é` (example)
- Trigger hotkeys are not “stuck off” after a mapping.
- No interference between accent mode and math mode.

### Rollback plan
Revert only the mapper migration commit(s). Your original functions can remain in code until fully replaced.

---

## Phase 2 — Centralize State + UI rendering (single source of truth)

### Goal
Replace global variables + scattered tray updates with an `AppState` object and a single `ApplyState(state)` pipeline.

### New files
- `lib/AppState.ahk`
- `lib/TrayUI.ahk`
- `lib/Registries.ahk` (or keep registries in `main.ahk` initially)
- `lib/Config.ahk` (optional, for INI path management)

### Tasks
1. Create `AppState` with fields:
   - `layout` (string name, or index)
   - `mode` (`"off" | "latex" | "unicode"`, recommended)
   - `debug` (bool)
   - `configPath` (INI path)

2. Add `Load()` / `Save()` using INI:
   - Load last layout, mode, debug at startup.
   - Save on any change triggered from tray menu.

3. Create `TrayUI` that:
   - **builds menu from registries** (layouts + modes)
   - routes menu callbacks to update state
   - has `Render(state)` that:
     - checks correct radio items
     - sets tray icon + tooltip
     - optionally adds a debug indicator

4. Implement `ApplyState(state)`:
   - `LayoutManager.Select(state.layout)`
   - `ModeManager.Select(state.mode)` (enables/disables correct mapper)
   - `TrayUI.Render(state)`
   - `state.Save()`

### Acceptance tests
- Tray always reflects the active layout/mode.
- Switching layout/mode from tray immediately works without manual check code in multiple places.
- Restarting the script restores the last layout/mode (if you implement persistence).

### Rollback plan
Keep the old globals while you bring up the new pipeline; switch by a single flag or by moving `layout.ahk` → `main.ahk` gradually.

---

## Phase 3 — Data-driven layouts (remove `#HotIf` blocks for layout remaps)

### Goal
Define layouts as data maps and register them; switching layouts becomes enabling/disabling a dynamic hotkey set.

### New files
- `layouts/Colemak.ahk` (and others if you add them)
- `lib/LayoutManager.ahk`

### Tasks
1. Represent each layout as:
   - `name`, `abbr`, `icon` (optional)
   - `remaps` as `Map("SC01E", "p", "SC030", "u", ...)`  
     (keys are scancodes; values are outputs)

2. Implement `LayoutManager`:
   - `Register(def)`
   - `Select(name)`:
     - disable hotkeys for previous layout
     - enable hotkeys for selected layout
   - Store created hotkeys in a list so you can cleanly disable them.

3. Decide a send strategy for remaps:
   - simplest: `SendText(value)` if value is literal text
   - if values are key names: `Send("{" value "}")` (watch for `+^!` modifiers)
   - If you need “blind” sending: `Send("{Blind}{" value "}")`

4. Remove the big `#HotIf Layouts[LayoutIndex] ...` blocks and replace with dynamic registration.

### Acceptance tests
- Switching to Colemak remaps keys as before.
- Switching back to QWERTY (or default) restores normal keys (disables remap hotkeys).
- No ghost hotkeys remain after multiple switches.

### Rollback plan
Keep the old `#HotIf` layout section in a separate file and disable it with a feature flag until the new dynamic manager is solid.

---

## Phase 4 — Extension hooks (make new features “data + one registration line”)

### Goal
Turn adding new input modes / compose maps / layouts into:
- add a data file
- register it in a registry
- (optional) TrayUI auto-populates

### Tasks
1. Create registries:
   - `LayoutRegistry` (name → layout def)
   - `ModeRegistry` (name → mode def containing mapper instance)

2. Add a consistent pattern for “one-shot input mode”:
   - a `ModeDef` contains:
     - `name`, `abbr`
     - `mapper` (OneShotMapper instance)
     - `Enable()` / `Disable()`

3. (Optional) Add multi-character capture support:
   - allow `captureLen > 1`
   - or read until terminator (space, enter) for “\alph” style expansions

4. (Optional) Add debug overlay/logging:
   - `state.debug` toggles logging to a file and/or ToolTip trace.
   - Add `Debug → Show last capture` (super helpful when expanding mappings).

### Acceptance tests
- Adding a new mode requires no edits to tray check logic (only a registry addition).
- Adding a new layout requires no new hotkey blocks.

---

## Suggested commit discipline
- One phase per branch, merged sequentially.
- Each phase ends with a “demo checklist” you can run in 2 minutes.
- Keep old code around until the new subsystem fully replaces it, then delete.

---

## Minimal “demo checklist” (use after each phase)
1. Reload script.
2. Toggle LaTeX mode; test 2 mappings.
3. Toggle Unicode mode; test 2 mappings.
4. Toggle accent compose; test 2 mappings.
5. Switch layout; type a short sentence.
6. Switch back; type again.
7. Exit and restart; confirm state (if you implemented persistence).
