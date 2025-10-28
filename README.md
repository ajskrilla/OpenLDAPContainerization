# Linux PAM Authentication App

This project provides a containerized OpenLDAP environment on a Rocky Linux 9 host using Podman. It serves as the foundational authentication backend for a Linux PAM-based application, with a flexible directory structure and bulk-user provisioning scripts.

---

## 📂 Repository Structure

```
/root/ldap_setup
├── Containerfile            # Defines the static-config OpenLDAP image
├── slapd.conf               # OpenLDAP configuration (static mode)
├── base.ldif                # LDIF to bootstrap suffix, admin, and People OU
├── util/
│   ├── adduserstoldap.sh    # Script to bulk-import 200 users
│   └── verify_ssha.py       # Python script to validate SSHA hashes
├── data/                    # Bind-mounted LDAP database directory
├── certs/                   # (optional) TLS certs for LDAPS
├── ldif/                    # (optional) custom LDIFs for dynamic-config
└── README.md                # This documentation file
```

---

## 🛠 Prerequisites

- **Rocky Linux 9** (or CentOS/RHEL 9)
- **Podman** installed and configured
- **openldap-clients** package (for `ldapsearch`, `slappasswd`)
- **Python 3** (for optional `verify_ssha.py`)

---

## 🚀 Building the OpenLDAP Image

1. **Navigate** to the project root:
   ```bash
   cd /root/ldap_setup
   ```
2. **Build** the static-config image:
   ```bash
   podman build --no-cache -t my-openldap:static .
   ```

This image runs `slapd` against `slapd.conf` in static mode, binding on port 389.

---

## ▶️ Running the Container

1. **Clean up** any previous container:
   ```bash
   podman rm -f openldap || true
   ```
2. **Ensure** the `data/` directory is empty:
   ```bash
   rm -rf data/*
   ```
3. **Start** `slapd`:
   ```bash
   podman run -d --name openldap \
     --network ldap-net \
     -p 389:389 \
     -v "$(pwd)/data:/var/lib/ldap:Z" \
     my-openldap:static
   ```
4. **Verify** `slapd` is listening:
   ```bash
   ss -nltp | grep slapd
   ldapsearch -x -H ldap://127.0.0.1:389 -b "" -s base "(objectClass=*)"
   ```

---

## 📦 Bootstrapping with `base.ldif`

This LDIF creates:

1. **Suffix** `dc=corp,dc=example,dc=com`
2. **Admin** entry `cn=admin,dc=corp,dc=example,dc=com`
3. **OrganizationalUnit** `ou=People`

To apply:

```bash
podman cp base.ldif openldap:/tmp/base.ldif
podman exec openldap bash -c "
  chown -R ldap:ldap /var/lib/ldap && \
  slapadd -f /etc/openldap/slapd.conf \
          -b dc=corp,dc=example,dc=com \
          -l /tmp/base.ldif && \
  chown -R ldap:ldap /var/lib/ldap
"
podman restart openldap
```

Then confirm:

```bash
ldapsearch -x -H ldap://127.0.0.1:389 \
  -b "ou=People,dc=corp,dc=example,dc=com" \
  "(objectClass=organizationalUnit)"
```

---

## 👥 Bulk User Import

Use the provided script to add 200 test users under `ou=People`:

```bash
chmod +x util/adduserstoldap.sh
./util/adduserstoldap.sh
```

Then verify count:

```bash
ldapsearch -x -H ldap://127.0.0.1:389 \
  -b "ou=People,dc=corp,dc=example,dc=com" \
  "(objectClass=inetOrgPerson)" dn \
  | grep '^dn:' | wc -l
```  
Should output `200`.

---

## 🔐 Managing Admin Credentials

- Generate a strong password hash with:
  ```bash
  slappasswd -s 'YourPlainTextPassword'
  ```
- Copy the resulting `{SSHA}...` string into `slapd.conf` under `rootpw`.
- In scripts, bind as admin using the clear-text:
  ```bash
  ldapwhoami -x -D "cn=admin,dc=corp,dc=example,dc=com" -w 'YourPlainTextPassword'
  ```

---

## 🤝 Contributing

1. **Fork** the repository.
2. Create your **feature branch** (`git checkout -b feature/xyz`).
3. **Commit** your changes with clear messages.
4. **Push** to your fork and open a **Pull Request**.

---

## 📄 License

*Specify your license here, e.g., MIT

