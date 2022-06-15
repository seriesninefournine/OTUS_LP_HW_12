#!/bin/bash

#Генерируем файл
dd if=/dev/urandom of=/tmp/randomfile bs=1M count=1500 > /dev/null 2>&1

#Нагрузим процессор
for j in {1..16}
do
    nice -n -10 dd if=/dev/urandom of=/dev/null bs=1M count=50000000 > /dev/null 2>&1 &
done

#Запускаем процессы с разным приоритетом
for i in {-15..15..5}
do
    (time cat /tmp/randomfile | nice -n $i bzip2 -z -9 > /dev/null && echo -e "Время выполнения процесса приоритетом $i" & )
done

#Ждем завершения работа bzip2 и завершаем скрипт
k=2
while [[ $k -lt 5 ]]
do
    if [ $(ps -x | grep -E "bzip2" | wc -l) -eq 1 ]; then
        kill -15 $(pidof dd)
        rm /tmp/randomfile
        exit
    fi
done
