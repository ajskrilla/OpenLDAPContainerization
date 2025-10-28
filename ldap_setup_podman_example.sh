#Podman Install and set
#$filepath=""
# make the dir and change to it

mkdir -p /root/ldap_setup
cd /root/ldap_setup

# Setup the Containefile in the directory

#Install Podman

sudo dnf install -y podman podman-docker
The podman-docker package gives you a docker alias, so many Docker tutorials work unmodified.

#Try basic commands

podman pull alpine
podman run --rm alpine uname -a
podman build -t my-ldap-image .
podman network create ldap-net
Explore pods & systemd

#Explore pods & systemd
podman pod create --name ldap-pod -p 389:389 -p 636:636
podman run -d --pod ldap-pod my-ldap-image
podman generate systemd --new --name ldap-pod > /etc/systemd/system/ldap-pod.service
systemctl enable --now ldap-pod

#remove images:


##############################################################################################

### Setup the environment
# change this so it can be an arg 
cd /root/ldap_setup
#
podman build -t my-openldap:latest . # -->> ENSURE that this is running
podman network create ldap-net        # if you haven’t already
mkdir -p data certs ldif             # ensure these dirs exist

# Remove the old container
podman rm -f openldap || true

## Podman commands; never DOES NOT allow to look out to repo
# Run with SELinux relabeling on your data dirs
podman run --pull never -d \
  --name openldap \
  --network ldap-net \
  -p 389:389 -p 636:636 \
  -v "$(pwd)/data:/var/lib/ldap:Z" \
  -v "$(pwd)/certs:/container/service/slapd/assets/certs:Z" \
  -v "$(pwd)/ldif:/container/service/slapd/assets/config/bootstrap/ldif/custom:Z" \
  localhost/my-openldap:latest

