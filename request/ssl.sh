#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPidioma="${SCPdir}/idioma" && [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}
API_TRANS="aHR0cDovL2dpdC5pby90cmFucw=="
SUB_DOM='base64 -d'
wget -O /usr/bin/trans $(echo $API_TRANS|$SUB_DOM) &> /dev/null
mportas () {
unset portas
portas_var=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND" | grep "LISTEN")
while read port; do
var1=$(echo $port | awk '{print $1}') && var2=$(echo $port | awk '{print $9}' | awk -F ":" '{print $2}')
[[ "$(echo -e $portas|grep "$var1 $var2")" ]] || portas+="$var1 $var2\n"
done <<< "$portas_var"
i=1
echo -e "$portas"
}
ssl_redir () {
if [[ ! -e /etc/stunnel/stunnel.conf ]]; then
msg -ama " $(fun_trans "SSL Stunnel Nao Encontrado")"
msg -bar
exit 1
fi
msg -azu " $(fun_trans "SSL Stunnel")"
msg -bar
msg -ama " $(fun_trans "Selecione Uma Porta De Redirecionamento Interna")"
msg -ama " $(fun_trans "Ou seja, uma Porta no Seu Servidor Para o SSL")"
# msg -ama " $(fun_trans "Ej: Dropbear, OpenSSH, ShadowSocks, OpenVPN, Etc")"
msg -bar
         while true; do
         read -p " Local-Port: " portx
         if [[ ! -z $portx ]]; then
            [[ $(mportas|grep -w "$portx") ]] && break || echo -e "\033[1;31m $(fun_trans "Porta Invalida")\033[0m"
         fi
         done
msg -bar
msg -ama " $(fun_trans "Agora Presizamos Saber Qual Porta o SSL, Vai Escutar")"
msg -bar
    while true; do
    read -p " Puerto SSL: " SSLPORTr
    [[ $(mportas|grep -w "$SSLPORTr") ]] || break
    msg -bar
    echo -e "$(fun_trans "esta Porta Ja esta em Uso")"
    msg -bar
    unset SSLPORT1
    done
msg -bar
msg -ama " $(fun_trans "Atribua um nome para o redirecionador ") Ej: openvpn "
msg -bar
read -p " Nome: " namer
msg -bar
echo "" >> /etc/stunnel/stunnel.conf
echo "[${namer}]" >> /etc/stunnel/stunnel.conf
echo "connect = 127.0.0.1:${portx}" >> /etc/stunnel/stunnel.conf
echo "accept = ${SSLPORTr}" >> /etc/stunnel/stunnel.conf
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
service stunnel4 restart > /dev/null 2>&1
/etc/init.d/stunnel4 restart > /dev/null 2>&1
# msg -bar
msg -ama " $(fun_trans "PORTA AGREGADA COM SUCESSO")"
msg -bar
}
ssl_stunel () {
[[ $(mportas|grep stunnel4|head -1) ]] && {
msg -ama " $(fun_trans "Parando Stunnel")"
msg -bar
fun_bar "apt-get purge stunnel4 -y"
msg -bar
msg -ama " $(fun_trans "Parado Com Sucesso!")"
rm -rf /etc/stunnel/stunnel.conf > /dev/null 2>&1
rm -rf /etc/stunnel > /dev/null 2>&1
msg -bar
return 0
}
msg -azu " $(fun_trans "SSL Stunnel")"
msg -bar
msg -ama " $(fun_trans "Selecione Uma Porta De Redirecionamento Interna")"
msg -ama " $(fun_trans "Ou seja, uma Porta no Seu Servidor Para o SSL")"
msg -bar
         while true; do
         read -p " Local-Port: " portx
         if [[ ! -z $portx ]]; then
            [[ $(mportas|grep -w "$portx") ]] && break || echo -e "\033[1;31m $(fun_trans "Porta Invalida")\033[0m"
         fi
         done
msg -bar
DPORT="$(mportas|grep $portx|awk '{print $2}'|head -1)"
msg -ama " $(fun_trans "Agora Presizamos Saber Qual Porta o SSL, Vai Escutar")"
msg -bar
    while true; do
    read -p " Listen-SSL: " SSLPORT
    [[ $(mportas|grep -w "$SSLPORT") ]] || break
    echo -e "\033[1;33m $(fun_trans "esta Porta Ja esta em Uso")\033[0m"
    unset SSLPORT
    done
msg -bar
msg -ama " $(fun_trans "Instalando SSL")"
msg -bar
fun_bar "apt-get install stunnel4 -y"
echo -e "cert = /etc/stunnel/stunnel.pem\nclient = no\nsocket = a:SO_REUSEADDR=1\nsocket = l:TCP_NODELAY=1\nsocket = r:TCP_NODELAY=1\n\n[stunnel]\nconnect = 127.0.0.1:${DPORT}\naccept = ${SSLPORT}" > /etc/stunnel/stunnel.conf
openssl genrsa -out key.pem 2048 > /dev/null 2>&1
(echo br; echo br; echo uss; echo speed; echo adm; echo ultimate; echo @admultimate)|openssl req -new -x509 -key key.pem -out cert.pem -days 1095 > /dev/null 2>&1
cat key.pem cert.pem >> /etc/stunnel/stunnel.pem
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
service stunnel4 restart > /dev/null 2>&1
/etc/init.d/stunnel4 restart > /dev/null 2>&1
msg -bar
msg -ama " $(fun_trans "INSTALADO COM SUCESSO")"
msg -bar
return 0
}
fun_ssl () {
msg -ama " $(fun_trans "CONFIGURACAO DE SSL STUNNEL*")"
msg -bar
echo -ne "\033[1;32m [0] > " && msg -bra "$(fun_trans "Voltar")"
echo -ne "\033[1;32m [1] > " && msg -azu "$(fun_trans "Adicionar uma porta ")"
echo -ne "\033[1;32m [2] > " && msg -azu "$(fun_trans "Editar Cliente SSL Stunnel") \033[1;31m(comand nano)"
echo -ne "\033[1;32m [3] > " && msg -azu "$(fun_trans "Desinstalar SSL Stunnel ")"
msg -bar
while [[ ${arquivoonlineadm} != @(0|[1-3]) ]]; do
read -p "[0-3]: " arquivoonlineadm
tput cuu1 && tput dl1
done
case $arquivoonlineadm in
0)exit;;
1)ssl_redir;;
2)
   nano /etc/stunnel/stunnel.conf
   return 0;;
3)ssl_stunel;;
esac
}
if [[ -e /etc/stunnel/stunnel.conf ]]; then
fun_ssl
else
ssl_stunel
fi