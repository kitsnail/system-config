#!/bin/bash

#
# install prometheus, node_exporter, grafana, service


#
# create prometheus user
useradd -s /usr/sbin/nologin prometheus

#
# install prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.8.0/prometheus-2.8.0.linux-amd64.tar.gz -O /tmp/prometheus.tar.gz
tar xvf /tmp/prometheus.tar.gz -C /usr/local
mv -v /usr/local/prometheus-2.8.0.linux-amd64 /usr/local/prometheus
cp -vf config/prometheus.yml /usr/local/prometheus/prometheus.yml
cp -vf systemd/prometheus.service /etc/systemd/system/
chown -R prometheus.prometheus /usr/local/prometheus
chown prometheus.prometheus /etc/systemd/system/prometheus.service
chmod u+x /etc/systemd/system/prometheus.service
systemctl start prometheus
systemctl status prometheus
systemctl enable prometheus

#
# install node_exporter
wget https://github.com/prometheus/node_exporter/releases/download/v0.17.0/node_exporter-0.17.0.linux-amd64.tar.gz -O /tmp/node_exporter.tar.gz
tar xvf /tmp/node_exporter.tar.gz -C /usr/local
mv -v /usr/local/node_exporter-0.17.0.linux-amd64 /usr/local/prometheus/node_exporter
cp -vf systemd/node_exporter.service /etc/systemd/system/
chown -R prometheus.prometheus /usr/local/prometheus/node_exporter
chown prometheus.prometheus /etc/systemd/system/node_exporter.service
chmod u+x /etc/systemd/system/node_exporter.service
systemctl start node_exporter
systemctl status node_exporter
systemctl enable node_exporter

#
# install grafana
wget https://dl.grafana.com/oss/release/grafana-6.0.1-1.x86_64.rpm
sudo yum localinstall grafana-6.0.1-1.x86_64.rpm -y
grafana-cli plugins install grafana-piechart-panel
systemctl start grafana-server
systemctl status grafana-server
systemctl enable grafana-server.service

#
# disable selinux
if [ -s /etc/selinux/config ] && grep 'SELINUX=enforcing' /etc/selinux/config; then
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
    setenforce 0
fi

#
# setting firewall
systemctl start firewalld
default_zone=$(firewall-cmd --get-default-zone)
firewall-cmd --permanent --zone=${default_zone} --add-port=3000/tcp
firewall-cmd --reload

