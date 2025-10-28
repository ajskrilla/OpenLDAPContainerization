#!/usr/bin/env bash
set -euo pipefail

BASE="dc=corp,dc=example,dc=com"
OU="ou=People,$BASE"
ADMIN_DN="cn=admin,$BASE"
ADMIN_PW='jr4gupRPBhF1KIZV'

# 1) Generate the LDIF
cat <<EOF > users.ldif
dn: $OU
objectClass: organizationalUnit
ou: People

EOF

# 2) Append 200 user entries
for i in $(seq 1 200); do
  USERNAME="user${i}"
  PASS="Password${i}"
  # Generate SSHA inside the container
  HASH=$(podman exec openldap slappasswd -s "$PASS")
  cat <<ENTRY >> users.ldif
dn: uid=$USERNAME,$OU
objectClass: inetOrgPerson
cn: $USERNAME
sn: $USERNAME
uid: $USERNAME
userPassword: $HASH

ENTRY
done

# 3) Push and load into LDAP
podman cp users.ldif openldap:/tmp/users.ldif
podman exec openldap ldapadd -x \
  -D "$ADMIN_DN" -w "$ADMIN_PW" \
  -f /tmp/users.ldif

echo "✅ Added 200 users under $OU"
