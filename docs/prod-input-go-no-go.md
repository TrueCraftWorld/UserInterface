# Production Go/No-Go: Input Reliability

## Test Matrix (single ROC-RK3566 revision)
- Menu navigation: `MainMenu -> ServiceMenu -> back`
- Keyboard typing: `SerialNumberSettings` (`serialInput`, `typeInput`, `featuresInput`)
- Service tools:
  - `TouchTestScreen`
  - `TouchCalibrationScreen`

## Pass Criteria
1. Text typing test 500+ characters:
   - missing characters: `0`
   - unintended multi-delete on Backspace: `0`
2. 30-minute stress session:
   - no UI freeze in menu and service menu
   - no broken focus in text fields
3. Baseline metrics from logs:
   - `lost_release_rate_percent <= 1.00`
   - `cancel_rate_percent <= 2.00`
4. Reboot repeatability:
   - same behavior after 3 cold boots

## Evidence to attach
- Output from:
  - `python3 scripts/keyboard_metrics.py /tmp/ui_keyboard.log`
- Video/photo of `TouchTestScreen` counters after stress run
- Device info: serial, build hash, date/time

## Rollback Procedure (one command blocks)
### 1) Keyboard module rollback
Restore from backup made before deployment:

```bash
LATEST=$(ls -1dt /opt/backup_qml/CuteKeyboard_* | head -n 1)
sudo rm -rf "/usr/local/qt5_aarch/qml/QtQuick/CuteKeyboard"
sudo cp -a "$LATEST" "/usr/local/qt5_aarch/qml/QtQuick/CuteKeyboard"
```

### 2) Input profile rollback

```bash
sudo /path/to/UserInterface/scripts/roc_input_profile_rollback.sh
```

### 3) Runtime cache reset and restart

```bash
rm -rf ~/.cache/*qml* ~/.cache/*QML* 2>/dev/null
```

Restart application/service after rollback.
