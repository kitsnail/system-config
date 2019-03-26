# system-config

  - config prometheus, grafana monitoring 
  - setting shadowsocks

## step 1

```
git clone https://github.com/kitsnail/system-config.git
```

## step 2

- download & update kernel

```
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
yum --enablerepo=elrepo-kernel install kernel-ml -y
```

- check update 

```
rpm -qa | grep kernel
```

- remove old kernel

```
rpm -ev old-kernerl
```

- reboot

```
reboot
```

- seting BBR

```
sudo modprobe tcp_bbr
echo "tcp_bbr" | sudo tee --append /etc/modules-load.d/modules.conf

echo "net.core.default_qdisc=fq" | sudo tee --append /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee --append /etc/sysctl.conf

sudo sysctl -p

sysctl net.ipv4.tcp_available_congestion_control
sysctl net.ipv4.tcp_congestion_control

lsmod | grep bbr
```

## step 3

- install prometheus & grafana 
```
cd system-config
chmod +x prometheus-install.sh
./prometheus-install.sh
```

- grafana settings 

   1. login grafana: http://$ip:3000
      user: admin (default)
      passwd: admin (default)
   2. add `datasource`, select `prometheus`,and set `url` 'http://localhost:9090', click `Save&Test`
   3. click '+' , 'import',and upload json file 'grafana-template.json'


- install shadowsocks
```
chmod +x shadowsocks-all.sh
./shadowsocks-all.sh 2>&1 | tee shadowsocks-all.log
```
