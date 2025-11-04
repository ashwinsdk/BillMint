# How to Create GitHub Releases

## Quick Start

Create a release by pushing a version tag:

```bash
# Commit your changes
git add .
git commit -m "Ready for release"

# Create and push tag
git tag v1.0.0
git push origin main
git push origin v1.0.0
```

The GitHub Actions workflow will automatically:
1. Build Android APKs (arm64-v8a, armeabi-v7a, x86_64)
2. Build iOS IPA (unsigned)
3. Create a GitHub Release with all files

## View Releases

Visit: https://github.com/ashwinsdk/BillMint/releases

## Version Format

Use semantic versioning: `v1.0.0`
- v1.0.0 - Initial release
- v1.0.1 - Bug fixes
- v1.1.0 - New features
- v2.0.0 - Major changes

## Manual Trigger

1. Go to: https://github.com/ashwinsdk/BillMint/actions
2. Click "Build and Release APK and IPA"
3. Click "Run workflow"

## Build Time

Total: 15-20 minutes
- Android: 5-8 minutes
- iOS: 10-15 minutes

## File Sizes

- ARM64 APK: ~20 MB
- ARMv7 APK: ~18 MB
- x86_64 APK: ~22 MB
- iOS IPA: ~9 MB (unsigned)

## Troubleshooting

If build fails, check:
- GitHub Actions logs
- pubspec.yaml syntax
- All dependencies compatible

## Distribution

**Android:**
Users download APK → Enable Unknown Sources → Install

**iOS:**
Requires signing for distribution (App Store or Enterprise)
