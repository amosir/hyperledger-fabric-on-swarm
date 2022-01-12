#!/bin/bash
systemctl disable firewalld --now

sleep 3

systemctl restart docker
