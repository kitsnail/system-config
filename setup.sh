#!/bin/bash


#
# install prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.8.0/prometheus-2.8.0.linux-amd64.tar.gz -O /tmp/prometheus.tar.gz
tar xvf /tmp/prometheus.tar.gz -C /usr/local
mv -v /usr/local/prometheus-2.8.0.linux-amd64 /usr/local/prometheus
cp -vf config/prometheus.yml /usr/local/prometheus/prometheus.yml
cp -vf systemd/prometheus.service /etc/systemd/system/
systemctl start prometheus
systemctl enable prometheus

#
# install node_exporter
wget https://github.com/prometheus/node_exporter/releases/download/v0.17.0/node_exporter-0.17.0.linux-amd64.tar.gz -O /tmp/node_exporter.tar.gz
tar xvf /tmp/node_exporter.tar.gz -C /usr/local
mv -v /usr/local/node_exporter-0.17.0.linux-amd64 /usr/local/node_exporter
cp -vf systemd/node_exporter.service /etc/systemd/system/
systemctl start node_exporter
systemctl enable node_exporter

#
# install grafana
wget https://dl.grafana.com/oss/release/grafana-6.0.1-1.x86_64.rpm 
sudo yum localinstall grafana-6.0.1-1.x86_64.rpm
grafana-cli plugins install grafana-piechart-panel
systemctl start grafana-server
systemctl status grafana-server
systemctl enable grafana-server.service

#
# install shadowsocks
install_prepare_password(){
    echo "Please enter password for ${software[${selected}-1]}"
    read -p "(Default password: teddysun.com):" shadowsockspwd
    [ -z "${shadowsockspwd}" ] && shadowsockspwd="teddysun.com"
    echo
    echo "password = ${shadowsockspwd}"
    echo
}

install_prepare_port() {
    while true
    do
    dport=$(shuf -i 9000-19999 -n 1)
    echo -e "Please enter a port for ${software[${selected}-1]} [1-65535]"
    read -p "(Default port: ${dport}):" shadowsocksport
    [ -z "${shadowsocksport}" ] && shadowsocksport=${dport}
    expr ${shadowsocksport} + 1 &>/dev/null
    if [ $? -eq 0 ]; then
        if [ ${shadowsocksport} -ge 1 ] && [ ${shadowsocksport} -le 65535 ] && [ ${shadowsocksport:0:1} != 0 ]; then
            echo
            echo "port = ${shadowsocksport}"
            echo
            break
        fi
    fi
    echo -e "[${red}Error${plain}] Please enter a correct number [1-65535]"
    done
}

install_prepare_password
install_prepare_port

docker run -dt --name ss \
   -p ${shadowsocksport}:${shadowsocksport} mritd/shadowsocks \
   -s "-s 0.0.0.0 -p ${shadowsocksport} -m aes-256-cfb -k ${shadowsockspwd} --fast-open"

#
# disable selinux
if [ -s /etc/selinux/config ] && grep 'SELINUX=enforcing' /etc/selinux/config; then
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
    setenforce 0
fi

#
# setting firewall
default_zone=$(firewall-cmd --get-default-zone)
firewall-cmd --permanent --zone=${default_zone} --add-port=3000/tcp
firewall-cmd --permanent --zone=${default_zone} --add-port=${shadowsocksport}/tcp
firewall-cmd --permanent --zone=${default_zone} --add-port=${shadowsocksport}/udp
firewall-cmd --reload

