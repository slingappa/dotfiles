#!/usr/bin/env bash
set -e

#!/usr/bin/env bash
set -euo pipefail

# Cron has minimal PATH
PATH=/usr/sbin:/usr/bin:/sbin:/bin

# Fail fast if NOPASSWD already works
if sudo -n true 2>/dev/null; then
    exit 0
fi

export MYUSER=slingapp

: "${MYUSER:?MYUSER is not set}"
: "${SUDO_PASS:?SUDO_PASS is not set}"

expect <<'EOF'
set timeout -1

set user   $env(MYUSER)
set passwd $env(SUDO_PASS)
set line   "$user ALL=(ALL) NOPASSWD: ALL"
set sudoers "/etc/sudoers"

#
# 1. Check if entry already exists (idempotent)
#
spawn sudo -S grep -qF "$line" $sudoers
expect {
    -re "(?i)password.*:" { send "$passwd\r"; exp_continue }
    0 {
        puts "Entry already exists in /etc/sudoers"
        exit 0
    }
    eof {}
}

#
# 2. Append entry safely (NO editor, NO tee)
#
spawn sudo -S sh -c "printf '\n%s\n' '$line' >> '$sudoers'"
expect {
    -re "(?i)password.*:" { send "$passwd\r"; exp_continue }
    eof
}

#
# 3. Validate sudoers file
#
spawn sudo -S visudo -c
expect {
    -re "(?i)password.*:" { send "$passwd\r"; exp_continue }
    eof
}
EOF

echo "✅ NOPASSWD sudo access granted to $MYUSER via /etc/sudoers"
