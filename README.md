# Dotfiles Restore Notes

## Fresh VM restore

```bash
cd ~/dotfiles
./scripts/restore-env.sh
```

With encrypted secrets restore:

```bash
cd ~/dotfiles
./scripts/restore-env.sh --with-secrets
```

## Keep `~/bin` in sync with repo

```bash
cd ~/dotfiles
./scripts/sync-bin-from-home.sh
```

## Refresh encrypted secret archive

```bash
cd ~/dotfiles
./scripts/secrets-vault.sh backup
```
