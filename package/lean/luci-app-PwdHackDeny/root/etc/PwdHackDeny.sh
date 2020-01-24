#!/bin/bash
# wulishui 20200120
# Author: wulishui <wulishui@gmail.com>

time=$(uci get PwdHackDeny.PwdHackDeny.time 2>/dev/null)
sum=$(uci get PwdHackDeny.PwdHackDeny.sum 2>/dev/null)

while :
do

mkdir /tmp/PwdHackDeny

#-------------------dropbear-----------------

logread|grep dropbear|grep "Bad password attempt"|tee /tmp/PwdHackDeny/badip.dropbear.log.tmp1|gawk '{match($0,"(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])",a)}{print a[0]}'| sort | uniq -c | sort -k 1 -n -r|awk '{if($1>='"$sum"') print $2}' >> /etc/badip.dropbear

cat /tmp/PwdHackDeny/badip.dropbear.log.tmp1|sed '/^ *$/d' >> /tmp/badip.dropbear.log.tmp2
cat /tmp/badip.dropbear.log.tmp2|sort -n|uniq -i > /tmp/badip.dropbear.log

cat /etc/badip.dropbear|sort -n|uniq -i|sed '/^ *$/d' > /tmp/PwdHackDeny/addbadip1

ipset list dropbearbadip|gawk '{match($0,"(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])",a)}{print a[0]}'|sed '/^ *$/d' > /tmp/PwdHackDeny/addbadip2

cat /tmp/PwdHackDeny/addbadip1 /tmp/PwdHackDeny/addbadip2| sort | uniq -d > /tmp/PwdHackDeny/addbadip3
cat /tmp/PwdHackDeny/addbadip1 /tmp/PwdHackDeny/addbadip3| sort | uniq -u |sed '/^ *$/d'|sed 's/^/add '"dropbearbadip"' &/g' > /tmp/PwdHackDeny/addbadip

if [ -s /tmp/PwdHackDeny/addbadip ]; then
ipset restore -f /tmp/PwdHackDeny/addbadip 2>/dev/null
fi

cat /etc/badip.dropbear|sort -n|uniq -i > /tmp/PwdHackDeny/badip.dropbear
if [ -s /tmp/PwdHackDeny/badip.dropbear ]; then
cp /tmp/PwdHackDeny/badip.dropbear /etc/badip.dropbear
fi

#-------------------router-----------------

logread|grep uhttpd|grep "failed login on"|tee /tmp/PwdHackDeny/badip.router.log.tmp1|gawk '{match($0,"(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])",a)}{print a[0]}'| sort | uniq -c | sort -k 1 -n -r|awk '{if($1>='"$sum"') print $2}' >> /etc/badip.router

cat /tmp/PwdHackDeny/badip.router.log.tmp1|sed '/^ *$/d' >> /tmp/badip.router.log.tmp2
cat /tmp/badip.router.log.tmp2|sort -n|uniq -i > /tmp/badip.router.log

cat /etc/badip.router|sort -n|uniq -i|sed '/^ *$/d' > /tmp/PwdHackDeny/addbadip1

ipset list routerbadip|gawk '{match($0,"(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])",a)}{print a[0]}'|sed '/^ *$/d' > /tmp/PwdHackDeny/addbadip2

cat /tmp/PwdHackDeny/addbadip1 /tmp/PwdHackDeny/addbadip2| sort | uniq -d > /tmp/PwdHackDeny/addbadip3
cat /tmp/PwdHackDeny/addbadip1 /tmp/PwdHackDeny/addbadip3| sort | uniq -u |sed '/^ *$/d'|sed 's/^/add '"routerbadip"' &/g' > /tmp/PwdHackDeny/addbadip

if [ -s /tmp/PwdHackDeny/addbadip ]; then
ipset restore -f /tmp/PwdHackDeny/addbadip 2>/dev/null
fi

cat /etc/badip.router|sort -n|uniq -i > /tmp/PwdHackDeny/badip.router
if [ -s /tmp/PwdHackDeny/badip.router ]; then
cp /tmp/PwdHackDeny/badip.router /etc/badip.router
fi

# rm -r /tmp/PwdHackDeny

sleep "$time"

done

