# Contributing Guidelines

Thank you for considering contributing to **CloudNative DevOps Portfolio**!  
We welcome improvements, bug fixes, and documentation updates.

## Scope
We welcome contributions in the form of:
- Bug fixes
- New features
- Documentation improvements (README, Wiki, screenshots)
- CI/CD or infrastructure enhancements

## Branching Strategy
- **main** → stable, production‑ready
- **dev** → integration branch
- **feature/*** → work in progress (e.g., `feature/day13-git-enhancements`)

## Pull Request Process
1. Fork the repo and create a feature branch.
2. Ensure code builds locally and in Docker.
3. Run tests (`pytest -v`).
4. Lint and format code before committing.
5. Update documentation (README + Wiki).
6. Open a PR to `dev` and request review.

## Commit Messages
Follow [Conventional Commits](https://www.conventionalcommits.org/):
- `feat:` new feature
- `fix:` bug fix
- `chore:` maintenance tasks
- `docs:` documentation changes

## Code Style
- Python 3.12
- Follow PEP8
- Use type hints where possible

## Testing
- All new code must include unit tests where applicable.
- Run `pytest -v` locally before opening a PR.
- Integration tests (Postgres, Redis) should be validated in Docker Compose.

## Linting & Formatting
- Use `black` for Python formatting.
- Use `flake8` for linting.
- CI will fail if code does not meet style guidelines.

## Pull Request Checklist
Before submitting a PR:
- [ ] Code builds locally and in Docker
- [ ] Tests pass (`pytest -v`)
- [ ] Linting and formatting applied
- [ ] Documentation updated (README + Wiki)
- [ ] Commit messages follow Conventional Commits

## Attribution
This contributing guide is inspired by best practices from the Python, FastAPI, and Kubernetes communities.
