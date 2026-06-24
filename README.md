# Sathya Landing

Standalone Flutter project for the Sathya Application public marketing landing page.

Migrated from `Satya_devotte_app/lib/features/landing`.

## Run

```bash
cd /Users/venkatesh/Desktop/sathya_landing
flutter pub get
flutter run -d chrome
```

## Routes

| Route | Page |
|-------|------|
| `/` | Main landing page |
| `/privacy-policy` | Privacy Policy |
| `/terms-and-conditions` | Terms & Conditions |
| `/refund-policy` | Refund Policy |

## Assets

Landing images are under `assets/images/` and `assets/images/home/`.

## Notes

- Footer **Admin sign in** opens `/#/login` on web (same host) or `https://admin.sathya.co.za` on mobile/desktop apps.
- Play Store link points to `com.sathyadevotee.app`.
