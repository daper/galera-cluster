# Commands on each hosts
sudo mkdir -p /etc/systemd/system/docker.service.d/
sudo vim /etc/systemd/system/docker.service.d/custom.conf
# Paste the following
# start custom.conf
[Service]
Environment="DOCKER_OPTS=-H=0.0.0.0:2376 -H unix:///var/run/docker.sock --cluster-advertise eth0:2376 --cluster-store etcd://127.0.0.1:2379"
# end custom.conf

sudo systemctl daemon-reload
sudo systemctl restart docker

# Verify docker is running
docker -H :2376 info

# Save eth0 ip into local var.
# Explain: 10 is the line of IP output in ifconfig
export ip=$(ifconfig | sed -n '10 p' | awk '{print $2}')

# Start swarm agent
docker run -d --restart=always --name swarm-agent --net=host swarm join --addr=$ip:2376 etcd://127.0.0.1:2379
# Start swarm manager
docker run -d --restart=always --name swarm-manager --net=host swarm manage etcd://127.0.0.1:2379

# Now in local machine
export DOCKER_HOST=tcp://<any_cluster_node_public_ip>:2375
# Check all nodes are OK
docker info

# Galera cluster config START
# Generate locally self-signed cert
sudo openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -days 730 -nodes -subj "/C=US/ST=Oregon/L=Portland/O=Company Name/OU=Org/CN=www.example.com"

docker-compose up -d

# Start first cluster node
echo "mysqld --wsrep-new-cluster --wsrep-cluster-address=gcomm://galera1,galera2,galera3" | nc <node1_public_ip> 13306

echo "mysqld --wsrep-cluster-address=gcomm://galera1,galera2,galera3" | nc <node3_public_ip> 13306

## Commands to configure vpn-router on debian jessie
sudo apt-get update && sudo apt-get install -y byobu htop vim git curl wget strongswan
sudo mkdir -p /etc/ssl/private/strongswan
# Generate self-siged certificate with noDES and put in /etc/ssl/private/strongswan
# Edit /etc/ipsec.secrets and add this line
: RSA /etc/ssl/private/strongswan/key.pem

# Edit /etc/ipsec.conf to enable tunnels, this is example config
conn us-west-2-to-us-east-1
      leftsubnet=192.168.2.0/24
      leftcert=/etc/ssl/private/strongswan/cert.pem
      leftsendcert=never
      right=52.86.70.175
      rightsubnet=192.168.1.0/24
      rightcert=/etc/ssl/private/strongswan/cert.pem
      auto=start
# In section "config setup" add
uniqueids = no

# To add a node to the coreos cluster run this command in one host
etcdctl member add <name> http://<ip_new_host>:2380
# Then launch the new node with the second cloud config and the variables
# from the output of previous command


## Installing shipyard
docker run -d --restart=always --name shipyard-rethinkdb rethinkdb
docker run -d --restart=always --name shipyard-controller --link shipyard-rethinkdb:rethinkdb -p 80:8080 shipyard/shipyard:latest server -d tcp://$ip:2375
