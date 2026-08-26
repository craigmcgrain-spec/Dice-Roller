# Contributing to Dice Roller

Thank you for your interest in contributing to the Dice Roller project! This document provides guidelines and instructions for contributing.

## Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Help each other succeed

## How to Contribute

### Reporting Bugs

1. **Check existing issues** - Avoid duplicates
2. **Create a detailed report** including:
   - Steps to reproduce
   - Expected behavior
   - Actual behavior
   - Your environment (Node version, browser, OS)
   - Error messages or logs

### Suggesting Features

1. **Check if it's already proposed**
2. **Provide context** for why the feature is needed
3. **Include examples** of desired functionality
4. **Explain potential use cases**

### Pull Requests

#### Before You Start
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Set up development environment:
   ```bash
   npm install
   npm test
   ```

#### Making Changes

1. **Code Style**
   - Follow ESLint configuration
   - Use 2-space indentation
   - Write descriptive variable names
   - Add JSDoc comments for functions

2. **Testing**
   - Write tests for new features
   - Ensure all tests pass: `npm test`
   - Aim for >90% code coverage
   - Test edge cases and error conditions

3. **Documentation**
   - Update README if adding features
   - Update CHANGELOG
   - Add code examples
   - Document any new APIs

4. **Commits**
   - Write clear commit messages
   - Use present tense ("Add feature" not "Added feature")
   - Reference issues when relevant

#### Example Contribution Workflow

```bash
# 1. Clone and create feature branch
git clone https://github.com/craigmcgrain-spec/Dice-Roller.git
cd Dice-Roller
git checkout -b feature/add-sound-effects

# 2. Make your changes
# ... edit files ...

# 3. Add tests
# ... create test files ...

# 4. Run tests and linting
npm test
npm run lint
npm run lint:fix

# 5. Commit changes
git add .
git commit -m "Add sound effects for dice rolls"

# 6. Push and create PR
git push origin feature/add-sound-effects
# Create pull request on GitHub
```

#### Pull Request Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Performance improvement

## Testing
- [ ] Unit tests added/updated
- [ ] All tests passing
- [ ] Manual testing completed

## Documentation
- [ ] README updated
- [ ] API docs updated
- [ ] Examples added/updated
- [ ] CHANGELOG updated

## Checklist
- [ ] Code follows style guidelines
- [ ] No console errors/warnings
- [ ] Changes are backward compatible
```

## Development Setup

### Prerequisites
- Node.js 14+
- npm or yarn

### Installation

```bash
git clone https://github.com/craigmcgrain-spec/Dice-Roller.git
cd Dice-Roller
npm install
```

### Running Tests

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Generate coverage report
npm run test:coverage
```

### Linting

```bash
# Check for linting errors
npm run lint

# Auto-fix linting errors
npm run lint:fix
```

## Project Structure

```
src/
├── index.js                 # Entry point
├── DiceRoller.js           # Main roller class
├── DiceParser.js           # Notation parser
├── RollResult.js           # Result object
└── Dice3DAnimator.js       # 3D animation

test/
├── DiceRoller.test.js      # Core tests
└── DiceParser.test.js      # Parser tests

examples/
├── basic-usage.js
├── dnd-scenarios.js
├── 3d-dice-simulation.js
└── 3d-dice-roller.html

docs/
└── 3D-ANIMATION.md
```

## Areas for Contribution

### High Priority
- Performance optimizations
- Browser compatibility fixes
- Documentation improvements
- Test coverage expansion

### Medium Priority
- Additional dice types
- Localization support
- Accessibility improvements
- UI enhancements

### Nice to Have
- Dice textures with numbers
- Sound effects
- Particle effects
- Animation improvements

## Testing Guidelines

### Unit Tests

```javascript
describe('Feature Name', () => {
  test('should do something specific', () => {
    // Setup
    const roller = new DiceRoller();
    
    // Execute
    const result = roller.roll('d20');
    
    // Verify
    expect(result.total).toBeGreaterThanOrEqual(1);
    expect(result.total).toBeLessThanOrEqual(20);
  });
});
```

### What to Test

- ✅ Happy path (normal usage)
- ✅ Edge cases (min/max values)
- ✅ Error conditions (invalid input)
- ✅ Return types and values
- ✅ State changes
- ✅ Side effects

## Code Review Process

1. **Automated checks**
   - Tests must pass
   - Linting must pass
   - Code coverage maintained

2. **Manual review**
   - Code clarity
   - Adherence to guidelines
   - Completeness

3. **Approval and merge**
   - At least one approval required
   - All conversations resolved
   - Ready to merge

## Questions or Need Help?

- 📖 Check the documentation in `docs/`
- 📝 Review examples in `examples/`
- 🐛 Search existing issues
- 💬 Open a discussion issue
- 📧 Contact the maintainers

## Recognition

Contributors will be:
- Listed in the project documentation
- Recognized in the CHANGELOG
- Credited in commit history

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for helping make Dice Roller better! 🎲✨
