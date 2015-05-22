#!/bin/bash

HOMEBREW_CASK_DIR="/opt/homebrew-cask/Caskroom/"
TEXT_RESET="\033[0m"
TEXT_GREEN="\033[0;32m"
TEXT_RED="\033[0;31m"
TEXT_BOLD="\033[1m"
TEXT_CUR_VERSION="\033[1;30;44m"
TEXT_AVAI_VERSION="\033[1;30;42m"
TEXT_ALERTE_VERSION="\033[1;30;41m"
TEXT_UNDERLIGNE="\033[4m"

_processCask()
{
    cask=$1

    read -a versions <<<$(ls -t ${HOMEBREW_CASK_DIR}${cask})
    if [ "${versions[0]}" != "latest" ]; then
        printf "\t%-30s ${TEXT_CUR_VERSION}%s${TEXT_RESET}\n" "Your version:" " ${versions[0]} "
        currentVersion=$(_getCaskVersion ${cask})
        printf "\t%-30s ${TEXT_AVAI_VERSION}%s${TEXT_RESET}\n" "Current version available:" " ${currentVersion} "

        if [ "${versions[0]}" != "${currentVersion}" ]; then
            echo -e "\n\t${TEXT_RED}Require update${TEXT_RESET}\n"
            _upgradeCask ${cask}
        fi

        _removeOldVersions ${cask} ${currentVersion}

    else
        echo -e "\t${TEXT_GREEN}Use app auto-update${TEXT_RESET}"
    fi
}

_upgradeCask()
{
    cask=$1
    brew cask install ${cask}
}

_removeOldVersions()
{
    cask=$1
    currentVersion=$2
    countVersions=$(ls ${HOMEBREW_CASK_DIR}${cask} | wc -l)

    if [ ${countVersions} -gt 1 ]; then
        read -a versions <<<$(ls -tr ${HOMEBREW_CASK_DIR}${cask} | grep -v "${currentVersion}")
        for _version in "${versions[@]}"; do
            echo -e "\n\t${TEXT_ALERTE_VERSION}Remove cask: ${HOMEBREW_CASK_DIR}${cask}/${_version}${TEXT_RESET}"
            rm -rf "${HOMEBREW_CASK_DIR}${cask}/${_version}"
        done
    fi
}

_getCaskVersion()
{
    cask=$1
    echo $(brew cask info ${cask} | egrep "${cask}:\s" | sed -e "s/${cask}:\s\(.*\)/\1/")
}

update()
{
    echo -e "Update brew"
    brew update
    echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
}

upgrade()
{
    echo -e "Upgrade brew"
    brew upgrade --all
    echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
}

upgradeBrewCask()
{
    echo -e "Upgrade brew cask"
    read -a casks <<<$(ls ${HOMEBREW_CASK_DIR})
    for _cask in "${casks[@]}"; do
        if [ -d "${HOMEBREW_CASK_DIR}${_cask}" ]; then
            echo -e "__________________________________________________"
            echo -e "Process ${TEXT_BOLD}${_cask}${TEXT_RESET}"
            _processCask "${_cask}"
            echo -e "${TEXT_UNDERLIGNE}--------------------------------------------------${TEXT_RESET}\n"
        fi
    done
    echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
}

clean()
{
    echo -e "Cleanup"
    brew cleanup --prune=10 # follow brew cask logic
    brew cask cleanup --outdated
    echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    echo -e "Prune formulae"
    brew prune
    echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
}

main()
{
    type=$1 # default: all ; brew: only brews ; cask: only brew cask

    update

    if [ "${type}" == "brew" ]; then
        upgrade
    elif [ "${type}" == "cask" ]; then
        upgradeBrewCask
    else
        upgrade
        upgradeBrewCask
    fi

    clean
}

main
#_processCask $1
