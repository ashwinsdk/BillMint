# Contributing to BillMint

Thank you for considering contributing to BillMint. This document provides guidelines for contributing to the project.

## Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help others learn and grow
- No harassment or discrimination

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone <your-fork-url>`
3. Add upstream remote: `git remote add upstream <original-repo-url>`
4. Run setup script: `./scripts/setup_dev.sh`

## Development Workflow

### Before Starting Work

1. Pull latest changes:
```bash
git checkout main
git pull upstream main
```

2. Create feature branch:
```bash
git checkout -b feature/your-feature-name
```

### During Development

1. Write clean, documented code
2. Follow existing code style
3. Add tests for new features
4. Update documentation as needed

### Code Style

- Use `dart format` for formatting
- Follow Flutter/Dart style guide
- Use meaningful variable names
- Add comments for complex logic
- Keep functions small and focused

### Commit Messages

Format:
```
type: short description

Longer description if needed

Fixes #issue-number
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Test additions/changes
- `chore`: Build process or tooling changes

Example:
```
feat: add invoice search by customer name

Implement search functionality in invoice list screen
that allows filtering by customer name with instant results.

Fixes #42
```

### Testing

1. Run all tests:
```bash
flutter test
```

2. Add tests for new features:
```dart
test('description', () {
  // Test code
});
```

3. Ensure no regressions

### Documentation

Update relevant documentation:
- Code comments
- README.md
- INSTALLATION.md
- API.md
- USAGE.md

## Submitting Changes

### Before Submitting

1. Format code:
```bash
dart format .
```

2. Run linter:
```bash
flutter analyze
```

3. Run tests:
```bash
flutter test
```

4. Commit changes:
```bash
git add .
git commit -m "feat: your feature"
```

5. Push to your fork:
```bash
git push origin feature/your-feature-name
```

### Creating Pull Request

1. Go to GitHub repository
2. Click "New Pull Request"
3. Select your branch
4. Fill in PR template:
   - Description of changes
   - Related issues
   - Screenshots (if UI changes)
   - Testing done
5. Submit PR

### PR Review Process

1. Maintainer reviews code
2. Address feedback if requested
3. Make changes in same branch
4. Push updates
5. PR is merged when approved

## Areas for Contribution

### High Priority

- Complete screen implementations
- PDF generation with isolates
- CSV export functionality
- Widget tests
- Performance optimizations

### Medium Priority

- Additional GST rates
- Invoice templates
- Backup encryption
- Multi-language support
- Dark/light theme toggle

### Documentation

- Tutorial videos
- Code examples
- Translation of docs
- FAQ section

### Bug Fixes

Check Issues for:
- Bugs labeled "bug"
- Issues labeled "help wanted"
- Issues labeled "good first issue"

## Development Guidelines

### Performance

- Use `const` constructors
- Implement lazy loading
- Run heavy work in isolates
- Test on low-end devices
- Profile with DevTools

### Security

- Never commit secrets
- Validate all inputs
- Sanitize user data
- Use HTTPS for API calls

### Accessibility

- Support screen readers
- Use semantic widgets
- Provide text alternatives
- Test with accessibility tools

### Testing

- Unit test business logic
- Widget test UI components
- Integration test user flows
- Test on real devices

## Getting Help

- Ask questions in Issues
- Join community discussions
- Read documentation
- Check existing issues and PRs

## Recognition

Contributors will be:
- Listed in CONTRIBUTORS.md
- Mentioned in release notes
- Acknowledged in README

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
