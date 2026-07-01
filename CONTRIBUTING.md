# Contributing Guidelines

Thank you for considering contributing to **CloudNative DevOps Portfolio**!  
We welcome improvements, bug fixes, and documentation updates.

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
