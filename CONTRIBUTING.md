# Contributing to zsh_functions

Contributions to the zsh_functions project are welcome! Here's how to help.

## Commit Message Format

This project uses [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) to enable automated changelog generation and semantic versioning. Please format your commit messages as follows:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Allowed Types

- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, missing semicolons, etc.)
- `refactor`: Code changes that neither fix a bug nor add a feature
- `perf`: A code change that improves performance
- `test`: Adding or correcting tests
- `chore`: Other changes that don't modify source or test files

### Examples

```
feat: add new openspec function for API documentation

- Create openspec function in autoload/
- Implement proxy functionality to @fission-ai/openspec package
- Add integration tests for openspec function
```

```
fix: correct shellcheck error in brew-list-formulas

Resolved SC2145 error by properly separating string and array arguments
in echo statement.
```

```
docs: update README with new openspec function
```

## Release Process

This project uses semantic versioning and automated release notes generation. The release process is triggered manually through a GitHub Action and will:

1. Generate a changelog based on commit messages
2. Create a Git tag with the new version
3. Create a GitHub Release with the changelog entries

## Pull Request Process

1. Fork the repository and create your branch from `main`
2. Ensure any new functions follow the established patterns
3. Add integration tests for any new functionality
4. Update documentation as appropriate
5. Ensure all tests pass before submitting
6. Create a pull request to the `main` branch

## Code Style

- Follow existing code patterns in the repository
- Use descriptive variable names
- Add comments for complex logic
- Ensure proper error handling with appropriate exit codes
- Use consistent indentation and formatting