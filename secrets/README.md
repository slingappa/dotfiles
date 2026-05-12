# Encrypted secrets in dotfiles

This repository can track encrypted credentials so you can rebuild your environment
without committing plaintext keys/passwords/tokens.

## Files

- `manifest.txt`: list of home-relative paths to include in the encrypted backup.
- `home-secrets.tar.gpg`: encrypted archive committed to git.
- `private.zsh.example`: template for local shell-only secrets file.
- `../scripts/secrets-vault.sh`: backup/restore helper.

## Usage

1. Edit `manifest.txt` and keep only what you need.
2. Create/update encrypted archive:
   - `./scripts/secrets-vault.sh backup`
3. On a new machine, restore (dry-run first):
   - `./scripts/secrets-vault.sh restore`
4. Apply restore to `$HOME`:
   - `./scripts/secrets-vault.sh restore --apply`

## Passphrase handling

- Default: `gpg` prompts interactively for passphrase.
- Optional non-interactive mode:
  - `export DOTFILES_SECRETS_PASSPHRASE='...'`
  - Then run backup/restore command.

Do not store the passphrase in this repository.

## Shell secrets

- Create `~/.config/shell/private.zsh` from `private.zsh.example`.
- Keep `private.zsh` out of git; include it via `manifest.txt` so it is backed up only in encrypted form.
