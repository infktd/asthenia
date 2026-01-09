````markdown
# home/secrets/

**⚠️ IMPORTANT: This directory is for sensitive data only!**

This directory should contain private secrets referenced by your configuration. The entire directory should be kept out of public repositories and version control.

## Security Best Practices

1. **Never commit secrets to Git:**
   - This directory has a `.gitignore` that blocks common secret file patterns
   - Add any additional patterns to `.gitignore` as needed

2. **File encryption:**
   - Consider using `age` or `sops-nix` for encrypted secrets
   - Store encrypted versions in Git if needed

3. **Permission management:**
   - Keep file permissions restrictive (600 or 400)
   - Only your user should have access

## Usage Examples

### SSH Keys
```nix
# In your home configuration:
home.file.".ssh/id_ed25519" = {
  source = ../secrets/ssh/id_ed25519;
  mode = "0600";
};
```

### API Tokens
```nix
# In your program config:
config.secrets.apiToken = builtins.readFile ../secrets/api-token.txt;
```

### Environment Variables
```nix
home.sessionVariables = {
  SECRET_KEY = builtins.readFile ../secrets/secret-key.txt;
};
```

## Recommended Tools

- **age**: Modern encryption tool for secrets
- **sops-nix**: Secrets management for NixOS/Home Manager
- **git-crypt**: Transparent file encryption in Git

## Directory Structure Example

```
secrets/
├── .gitignore
├── ssh/
│   ├── id_ed25519
│   └── id_ed25519.pub
├── gpg/
│   └── private-key.asc
├── api-tokens/
│   └── github-token.txt
└── age/
    └── secrets.age
```

## Migration from Unencrypted Secrets

If you already have unencrypted secrets committed:

1. Remove from Git history: `git filter-branch` or `BFG Repo-Cleaner`
2. Rotate all exposed secrets immediately
3. Set up encryption before re-adding secrets
4. Verify secrets are gitignored before committing

## See Also

- [sops-nix documentation](https://github.com/Mic92/sops-nix)
- [age encryption](https://github.com/FiloSottile/age)

````