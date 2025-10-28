cd /root/ldap_setup
mkdir -p certs

openssl req -x509 -nodes -newkey rsa:2048 \
  -keyout certs/ldap.key \
  -out certs/ldap.crt \
  -subj "/CN=ldap.corp.example.com"
