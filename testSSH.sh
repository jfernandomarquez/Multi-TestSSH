#!/bin/bash

#para usarse se debe: sudo apt-get install expect en la maquina local
#Verificano acceso por SSH

USER=$(echo your_user_in_base64 | base64 --decode)
PASS=$(echo your_password_in_base64 | base64 --decode)

echo "Verificano SSH" > testSSH.log

lista=$(cat $1)

for i in $lista;
do

 VAR=$(expect -c "
 spawn ssh $USER@$i hostname
 expect {
        \"Host key verification failed.\" {
        spawn ssh-keygen -R $SERVER_HOSTNAME
        expect \"known_hosts.old\"
        send_user \"Updated host key details.\"
        exp_continue
        }
        \"continue connecting (yes/no)\" {
        send \"yes\r\"
        expect \"Permanently added\"
        exp_continue
        }
        \"assword:\" {
        send -- \"$PASS\r\"
        send -- \"\r\"
        expect eof
       }
       }
  ")

host=$(echo "$VAR")

if [ -z "$host" ]
then
      echo "ssh FAIL en $i" >> testSSH.log
else
      echo "$host : ssh OK" >> testSSH.log
fi

done

echo "Finalizo la prueba"  >> testSSH.log