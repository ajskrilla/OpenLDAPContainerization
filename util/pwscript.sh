#!/usr/bin/env bash
# generate-ldap-ssha.sh
#
# Usage:
#   ./generate-ldap-ssha.sh MyP@ssw0rd
#
# Requires: openssl

if [ -z "$1" ]; then
  >&2 echo "Usage: $0 <password>"
  exit 1
fi

PASS="$1"
# Generate 4 bytes of random salt
SALT_BIN=$(openssl rand -binary 4)

# Compute SHA1 of password+salt, then append salt, then base64
DIGEST=$(printf '%s' "$PASS" | \
         openssl dgst -binary -sha1)

HASH_WITH_SALT=$(printf '%s' "$DIGEST" | cat - <(printf '%s' "$SALT_BIN") | \
                 openssl base64)

echo "{SSHA}$HASH_WITH_SALT"
