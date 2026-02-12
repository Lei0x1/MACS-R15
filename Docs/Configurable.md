# MACS-R15 Configurable

This document describes all configurable systems exposed by **MACS-R15** and how to properly integrate them into weapon and game settings.

---

## Weapon Sensitivity Configuration

MACS-R15 supports **per-weapon sensitivity tuning**, allowing fine-grained control over player camera and aiming behavior for each weapon.

```lua
-- Just add this in every weapon settings (Hint: ACS_Settings)
self.Sensitivity = {
  Camera  = 40, -- Base camera rotation sensitivity
  HipFire = 45, -- Sensitivity while hip-firing
  ADS     = 50  -- Sensitivity while aiming down sights
}
```

**Parameter Breakdown**:

| Field    | Description
|----------|------------
| Camera   | Sensitivity without firing and aiming
| HipFire  | Sensitivity when firing without aiming
| ADS      | Sensitivity when firing while aiming

**Behavior Notes**:
- Each value is applied per weapon.
- Sensitivity is applied dynamically when switching weapons
- Missing values fallback to default value which is `50`

---

