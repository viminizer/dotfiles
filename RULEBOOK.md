# Rulebook

Follow these rules on every branch. Check changes against them before committing or pushing.

## R1. Keep company information out everywhere

No company-specific text or data is allowed in this repository's files or Git metadata.
This includes filenames, comments, examples, commit messages, branch and tag names, and
all history. Use generic names and synthetic examples instead.

- From: Kevin, 2026-11-16, chat.
- Check: inspect staged paths and content with `git diff --cached --name-status` and
  `git diff --cached`. Review full messages with `git log --all --format='%h %B'` and ref
  names with `git for-each-ref --format='%(refname)'`. Look for internal names, URLs,
  paths, identifiers, business rules and real company data, including renamed examples.
  Check affected historical file versions on every branch and tag. Deleting text from
  the latest files does not remove it from history.
- Example: `zsh/.zshrc` uses a generic project description in its runtime comments.
