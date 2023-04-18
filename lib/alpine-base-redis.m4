apk add redis
mv /etc/redis.conf /etc/redis.conf.save
sed "/^#.*/d; /^ *$/d; s/appendonly no/appendonly yes/; s/bind 127.0.0.1 -::1/bind * -::*/; s/^protected-mode yes/protected-mode no/" /etc/redis.conf.save > /etc/redis.conf
echo -e "cluster-enabled yes\ncluster-config-file nodes.conf\ncluster-node-timeout 5000" >> /etc/redis.conf
rc-update add redis
poweroff
