#!/bin/bash

while true ; do
	read -p 'Username: ' username
	valid_user=$(id -u "$username" >/dev/null; echo $?)

	if [ $valid_user -eq 0 ] ; then break ; fi ;
done;

ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o PubkeyAuthentication=no $username@appliance02
