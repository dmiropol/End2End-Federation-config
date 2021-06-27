#!/bin/bash
ifconfig ens160.240 up
/sbin/ip addr add 2240::1/64 dev ens160.240
ifconfig ens160.250 up
/sbin/ip addr add 2250::1/64 dev ens160.250
ifconfig ens160.141 up
/sbin/ip addr add 2141::1/64 dev ens160.141

