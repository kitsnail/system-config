# system-config

  - config prometheus, grafana monitoring 
  - setting shadowsocks

## step 1

```
git clone https://github.com/snowsnail/system-config.git
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

```
cd system-config
chmod +x setup.sh
./setup.sh
```
