# iwd config

## /etc/iwd/main.conf

pertama buat folder /etc/iwd dengan cara 
```
mkdir /etc/iwd
```
lalu buat dan isi file main.conf dengan cara 
```
nvim /etc/iwd/main.conf
```
isinya
```
[General]
EnableNetworkConfiguration=true
```

## /etc/resolv.conf

isi file dengan
```
nameserver 8.8.8.8
```

lalu nyalakan iwd
```
systemctl enable iwd
```
```
systemctl start iwd
```
