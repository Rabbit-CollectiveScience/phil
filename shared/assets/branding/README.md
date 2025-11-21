# Phil Branding Assets

This directory contains shared branding assets used across all apps (mobile, backend, web).

## Logo Files

### `/logo/`
- `app_icon.png` - 1024x1024 app icon (used by mobile apps)
- `logo.svg` - Vector logo (scalable, use for web/print)
- `favicon.ico` - Favicon for web applications
- `logo_transparent.png` - Logo with transparent background

## Usage

**Mobile App (Flutter):**
- Configured in `apps/mobile/pubspec.yaml`
- Auto-generates platform-specific icons via `flutter_launcher_icons`

**Backend (Next.js):**
- Use for favicons, OG images, email templates
- Reference from `public/` or import directly

**Documentation:**
- Use in README files, docs, presentations
