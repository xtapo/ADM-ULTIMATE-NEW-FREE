#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPidioma="${SCPdir}/idioma" && [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}

port () {
local portas
local portas_var=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND" | grep "LISTEN")
i=0
while read port; do
var1=$(echo $port | awk '{print $1}') && var2=$(echo $port | awk '{print $9}' | awk -F ":" '{print $2}')
[[ "$(echo -e ${portas}|grep -w "$var1 $var2")" ]] || {
    portas+="$var1 $var2 $portas"
    echo "$var1 $var2"
    let i++
    }
done <<< "$portas_var"
}

verify_port () {
local SERVICE="$1"
local PORTENTRY="$2"
[[ ! $(echo -e $(port|grep -v ${SERVICE})|grep -w "$PORTENTRY") ]] && return 0 || return 1
}

fun_ip () {
if [[ -e /etc/MEUIPADM ]]; then
IP="$(cat /etc/MEUIPADM)"
else
MEU_IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
MEU_IP2=$(wget -qO- ipv4.icanhazip.com)
[[ "$MEU_IP" != "$MEU_IP2" ]] && IP="$MEU_IP2" || IP="$MEU_IP"
echo "$MEU_IP2" > /etc/MEUIPADM
fi
}

mine_port () {
local portasVAR=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND" | grep "LISTEN")
local NOREPEAT
local reQ
local Port
while read port; do
reQ=$(echo ${port}|awk '{print $1}')
Port=$(echo {$port} | awk '{print $9}' | awk -F ":" '{print $2}')
[[ $(echo -e $NOREPEAT|grep -w "$Port") ]] && continue
NOREPEAT+="$Port\n"
case ${reQ} in
ssh|sshd)
[[ -z $SSH ]] && msg -bar && local SSH="\033[1;32m$(fun_trans "PORTA ")\033[1;37m"
SSH+="$Port ";;
esac
done <<< "${portasVAR}"
[[ ! -z $SSH ]] && echo -e $SSH
}

fun_ssh () {
sshvar=$(cat /etc/ssh/sshd_config | grep -v "Port $1")
echo "$sshvar" > /etc/ssh/sshd_config
sed -i "s;Port 22;Port 22\nPort $1;g" /etc/ssh/sshd_config
sed -i "s;PermitRootLogin prohibit-password;PermitRootLogin yes;g" /etc/ssh/sshd_config
sed -i "s;PermitRootLogin without-password;PermitRootLogin yes;g" /etc/ssh/sshd_config
sed -i "s;PasswordAuthentication no;PasswordAuthentication yes;g" /etc/ssh/sshd_config
service ssh restart > /dev/null 2>&1 &
}

opssh_fun () {
msg -verd " $(fun_trans "OPENSSH AUTO-CONFIGURAÇAO")"
msg -bar
fun_ip
msg -ne " $(fun_trans "Confirme seu ip")"; read -p ": " -e -i $IP ip
msg -bar
msg -ama " $(fun_trans "AUTO CONFIGURAÇAO")"
msg -bar
#Inicia Update and Upgrade
fun_bar "apt-get update -y" "apt-get upgrade -y"
#Inicia Procedimentos
service ssh restart > /dev/null 2>&1
cp /etc/ssh/sshd_config /etc/ssh/sshd_back
sed -i "s;PermitRootLogin prohibit-password;PermitRootLogin yes;g" /etc/ssh/sshd_config
sed -i "s;PermitRootLogin without-password;PermitRootLogin yes;g" /etc/ssh/sshd_config
sed -i "s;PasswordAuthentication no;PasswordAuthentication yes;g" /etc/ssh/sshd_config
# grep -v "^PermitTunnel yes" /etc/ssh/sshd_config >/tmp/ssh && mv /tmp/ssh /etc/ssh/sshd_config
# echo "PermitTunnel yes" >>/etc/ssh/sshd_config
msg -bar
msg -ama " $(fun_trans "CONFIGURACOES APLICADAS")!"
msg -bar
msg -ne "\033[1;31m [ ! ] \033[1;33m$(fun_trans "REINICIANDO SERVICOS*")"
service ssh restart > /dev/null 2>&1
service sshd restart > /dev/null 2>&1
echo -e " \033[1;32m[OK]"
msg -bar
msg -ama " $(fun_trans "Seu Openssh foi configurado com sucesso")"
echo -e " \033[1;31mRUTA > \033[1;31m[ \033[1;32m/etc/ssh/sshd_config \033[1;31m]"
msg -bar
return 0
}

download_ssh () {
msg -verd " $(fun_trans "OPENSSH DOWNLOAD-CONFIGURAÇAO")"
msg -bar
fun_ip
msg -ne " $(fun_trans "Confirme seu ip")"; read -p ": " -e -i $IP ip
msg -bar
msg -ama " $(fun_trans "DOWNLOAD CONFIGURAÇAO PORTA 22 ")"
msg -bar
#Inicia Update and Upgrade
fun_bar "apt-get update -y" "apt-get upgrade -y"
#Inicia Procedimentos
service ssh restart > /dev/null 2>&1
cp /etc/ssh/sshd_config /etc/ssh/sshd_back
wget -O /etc/ssh/sshd_config https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/sshd_config > /dev/null 2>&1
chmod +x /etc/ssh/sshd_config
msg -bar
msg -ama " $(fun_trans "CONFIGURACOES APLICADAS")!"
msg -bar
msg -ne "\033[1;31m [ ! ] \033[1;33m$(fun_trans "REINICIANDO SERVICOS*")"
service ssh restart > /dev/null 2>&1
service sshd restart > /dev/null 2>&1
echo -e " \033[1;32m[OK]"
msg -bar
msg -ama " $(fun_trans "Seu Openssh foi configurado com sucesso Porta 22")"
echo -e " \033[1;31mRUTA > \033[1;31m[ \033[1;32m/etc/ssh/sshd_config \033[1;31m]"
msg -bar
return 0
}

edit_openssh () {
msg -ama " $(fun_trans "Agora Escolha as Portas que Deseja No OpenSSH*")"
msg -ama " $(fun_trans "Escolha As Portas Validas Em Ordem Sequencial")"
msg -ama " $(fun_trans "Exemplo: 22 443 2231 8081")"
msg -bar
local CONF="/etc/ssh/sshd_config"
local NEWCONF="$(cat ${CONF}|grep -v [Pp]ort)"
read -p "$(echo -e "\033[1;32m$(fun_trans "Digite as Portas") \033[1;37m")" -e -i 22 newports
[[ -z "$newports" ]] && {
echo -e "\n\033[1;31m$(fun_trans "Nenhuma Porta Valida Foi Escolhida")"
sleep 2
instalar
exit
}
for PTS in `echo ${newports}`; do
verify_port sshd "${PTS}" && echo -e "\033[1;33mPorta Escolhida $PTS \033[1;32mOK" || {
echo -e "\033[1;33m$(fun_trans "Porta") $PTS \033[1;31m$(fun_trans "FALHA")"
sleep 2
msg -bar
return 0
}
done
rm ${CONF}
for NPT in $(echo ${newports}); do
echo -e "Port ${NPT}" >> ${CONF}
done
while read varline; do
echo -e "${varline}" >> ${CONF}
done <<< "${NEWCONF}"
msg -bar
fun_bar 'sleep 2'
msg -bar
msg -ne "\033[1;31m [ ! ] \033[1;33m$(fun_trans "REINICIANDO SERVICOS*")"
service ssh restart > /dev/null 2>&1
service sshd restart > /dev/null 2>&1
echo -e " \033[1;32m[OK]"
msg -bar
msg -ama " $(fun_trans "Porta Openssh foi configurada com sucesso")"
msg -bar
return 0
}

openssh () {
msg -ama "$(fun_trans "CONFIGURAÇÃO DO OPENSSH")"
mine_port
msg -bar
echo -ne "\033[1;32m [0] > " && msg -bra "$(fun_trans "VOLTAR")"
echo -ne "\033[1;32m [1] > " && msg -azu "$(fun_trans "AUTO CONFIGURAÇAO")"
echo -ne "\033[1;32m [2] > " && msg -azu "$(fun_trans "DOWNLOAD CONFIGURAÇAO")"
echo -ne "\033[1;32m [3] > " && msg -azu "$(fun_trans "REDEFINIR PORTA")"
echo -ne "\033[1;32m [4] > " && msg -azu "$(fun_trans "Editar Cliente OPENSSH") \033[1;31m(comand nano)"
msg -bar
while [[ ${arquivoonlineadm} != @(0|[1-4]) ]]; do
read -p "[0-4]: " arquivoonlineadm
tput cuu1 && tput dl1
done
case $arquivoonlineadm in
0)exit;;
1)opssh_fun;;
2)download_ssh;;
3)edit_openssh;;
4)
   nano /etc/ssh/sshd_config
   return 0;;
esac
}
openssh