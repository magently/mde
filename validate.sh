#!/bin/bash
# This is a simple shell script to verify wether all environmental requirements
# are fulfilled and this is safe to run the environment.

if [ $USER == 'root' ]; then
    echo 'Please, do not run this script as root!'
    exit 2;
fi

function printCheckMark() {
    if [ "$1" -eq 1 ]; then
        echo -e "[\033[0;32m✓\033[0m]"
    else
        echo -e "[\033[0;31m×\033[0m]"
    fi
}

function getEnvValue() {
    if [ ! -e .env ]; then
        return
    fi

    _key=$1
    _default=$2
    eval _result=$(cat .env | grep "^$_key=" | cut -d '=' -f2)

    if [ -z "$_result" ]; then
        echo $_default
    fi

    echo $_result
}

function checkCondition() {
    _condition="$1"
    _message="$2"

    if eval $_condition; then
        echo $(printCheckMark 1)  $_message
    else
        echo $(printCheckMark 0)  $_message
        all_ok=0
    fi
}

all_ok=1
_ssh_path="$(getEnvValue SSH_DIRECTORY ~/.ssh)"
_npm_path="$(getEnvValue NPM_DIRECTORY ~/.npm)"
_composer_cache_path="$(getEnvValue COMPOSER_CACHE_DIRECTORY ~/.composer/cache)"
_composer_auth_file=$(getEnvValue COMPOSER_AUTH_FILE)
_magento_path=$(getEnvValue MAGENTO_PATH)

if [ $(uname) == 'Linux' ] || [ $(uname) == 'Darwin' ]; then
    checkCondition "[ '$(getEnvValue UID 1000)' == '$(id -u)' ]" "User UID has appropriate value"
    checkCondition "[ '$(getEnvValue GID 1000)' == '$(id -g)' ]" "User GID has appropriate value"
fi
checkCondition "[ -e .env ]" "'.env' file exists"
checkCondition "which docker &>/dev/null" "Docker available"
if [ $(uname) == 'Linux' ]; then
    checkCondition "groups | grep -w docker &>/dev/null" "User is in 'docker' group"
fi
checkCondition "docker ps &>/dev/null" "Docker daemon is responding"
checkCondition "which docker-compose &>/dev/null" "Docker Compose is availabe"
checkCondition "[ -e '$_ssh_path' ]" "SSH directory exists"
checkCondition "[ -e '$_npm_path' ]" "NPM directory exists"
checkCondition "[ -e '$_composer_cache_path' ]" "Composer cache directory exists"
checkCondition "[ '$_composer_auth_file' == '' ] || [ -e '$_composer_auth_file' ]" "Composer auth file is either existing or undefined"
checkCondition "[ '$_magento_path' != '' ] && [ -e '$_magento_path' ]" "Magento directory is defined and existing"

if [ $all_ok -eq 1 ]; then
    echo -e "\n\n\033[0;32mYou're good to go!\033[0m"
else
    echo -e "\n\n\033[0;31mPlease fix above issues before you run the environment.\033[0m"
    exit 1
fi
