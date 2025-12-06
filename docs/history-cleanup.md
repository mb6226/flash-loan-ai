# History cleanup: remove files from Git history (Safety & usage guide)

This document explains two commonly used approaches for rewriting Git history to remove sensitive artifacts (for example `.venv` or large vendor directories): `git filter-repo` and BFG. Rewriting history is disruptive — read the steps and warnings carefully.

## High-level guidance
- Rewriting history requires a force-push and cooperation from all contributors.
- Make a backup of the repository (`git clone --mirror`) before running the rewrite.
- Rewriting public history invalidates existing clones, forks, and PRs; coordinate with team members.

## Important: which tool to choose
- `git filter-repo` (recommended): Fast, robust, supports complex rewriting. Install from pip: `python -m pip install git-filter-repo`.
- `BFG Repo Cleaner` (easier to use for file removal): Java-based, good for big repos, but `git filter-repo` is generally recommended.

## Using git-filter-repo (recommended)

1. Backup mirror clone (local or remote):

```powershell
git clone --mirror https://github.com/<owner>/<repo>.git
cd <repo>.git
```

2. Run git filter-repo to remove `.venv` across history:

```powershell
# Remove directory paths or files across all branches and tags
git filter-repo --path .venv --invert-paths
```

3. Verify the rewrite and run safety checks (look for references to `.venv` with `git grep`), then force-push:

```powershell
git push origin --force --all
git push origin --force --tags
```

4. Notify contributors to re-clone the repo or to follow `git fetch` + `git reset --hard` strategies.

## Using BFG (if you prefer)

1. Mirror clone, then run the BFG tool:

```powershell
git clone --mirror https://github.com/<owner>/<repo>.git
cd <repo>.git
java -jar bfg.jar --delete-folders .venv
git reflog expire --expire=now --all && git gc --prune=now --aggressive
git push origin --force --all
git push origin --force --tags
```

## Warnings & Aftercare
- Rewriting a repo history is irreversible unless you have backups.
- If secrets were exposed, rotate those secrets immediately (e.g., API keys, provider secrets) even after removing them.
- Update your CI and pre-commit hooks to stop the same issue from recurring (see pre-commit and `.secrets.baseline`).
- Consider adding `detect-secrets` to CI and `pre-commit` locally for devs.

## Impact summary
- If your repository is public and credentials leaked, perform these steps quickly and rotate secrets.
- For small repos, using `git filter-repo` provides the most control. For very large repositories, BFG may provide speed and convenience.

If you'd like, I can run the git-filter-repo or BFG steps here (I will create backups and show the commands to run); please confirm and I will proceed — note this will require a forced push and will affect all contributors.
