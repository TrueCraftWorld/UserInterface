# ROC-RK3566 Input Stabilization Profile

## Scope
This profile targets the current ROC-RK3566 hardware revision only.

## Apply
On target device:

```bash
sudo /path/to/UserInterface/scripts/roc_input_profile_apply.sh
```

## Rollback

```bash
sudo /path/to/UserInterface/scripts/roc_input_profile_rollback.sh
```

## What is configured
- `QT_QPA_EVDEV_TOUCHSCREEN_PARAMETERS=rotate=0`
- `QT_LOGGING_RULES=qt.qpa.input=false` (default production level)
- `QML_DISABLE_DISK_CACHE=1` (deterministic touch validation)

## Validation sequence
1. Reboot device.
2. Run typing test in `SerialNumberSettings`.
3. Capture logs using `scripts/capture_input_baseline.sh`.
4. Compute metrics with `scripts/keyboard_metrics.py`.
5. Compare against thresholds in `docs/input-baseline.md`.

## Notes
- This profile is safe to rollback in one command.
- Keep this profile limited to the validated hardware revision.
