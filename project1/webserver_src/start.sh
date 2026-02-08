#!/bin/bash

cd /opt

if [ -d ".git" ]; then
    echo "является git репозиторием"
else 
    echo "не является git репозиторием"
    # if [ ! -d "shvirtd-example-python" ] ; then
    #     mkdir "shvirtd-example-python"
    #     cd "shvirtd-example-python"
    # fi
    command_output=$(git clone https://github.com/CheshenkoVladislav/shvirtd-example-python.git 2>&1)
    if [ $? -eq 0 ]; then
        echo "Репозиторий успешно клонирован."
        if [ -d "shvirtd-example-python" ] ; then
            cd "shvirtd-example-python"
            docker compose up
        fi
    else
        if [[ "$command_output" == *"already exists"* ]]; then
            echo "Репозиторий уже склонирован."
            if [ -d "shvirtd-example-python" ] ; then
                git pull origin main
                cd "shvirtd-example-python"
                docker compose up
            fi
        else 
            echo $command_output
            exit 1
        fi       
    fi
fi