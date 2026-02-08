#!/bin/bash

now=$(date +"%s_%Y-%m-%d")

docker run --rm --entrypoint "" -v $(pwd)/backup:/backup \
    --network shvirtd-example-python_backend schnitzler/mysqldump mysqldump \
    --default-auth=mysql_native_password --opt -h db -u root -p"YtReWq4321" \
    --result-file=/backup/"${now}_mysqldb".sql virtd