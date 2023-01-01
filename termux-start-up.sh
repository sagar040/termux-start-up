#!/data/data/com.termux/files/usr/bin/sh

source_url="https://sagar040.github.io/resources/termux-start-up/resource";
keyring_url=$(curl -s -L $source_url | grep 'termux-keyring' | cut -d ' ' -f2);
main_repo=$(curl -s -L $source_url | grep 'main-repo' | cut -d ' ' -f2);
version=$(curl -s -L $source_url | grep 'version' | cut -d ' ' -f2);
data="$PREFIX/tmp/tsup";
source_list="$PREFIX/etc/apt/sources.list";


echo "\033[31;1m--| \033[32mTermux(version 0.101) Repair Process\033[31;1m |--\033[0m\n";
echo "\033[34mAuthor:\033[0m Sagar Biswas";
echo "\033[34mGithub:\033[0m github.com/sagar040";
echo "\033[33mVersion:\033[0m $version";


echo "\n\033[34m"
read -p "Do you want to continue ? (y/n) : " quarry;
echo "\033[0m"


if [ $quarry = 'y' ]; then
    apt remove science-repo game-repo -y;
    echo "# The main termux repository:" > $source_list;
    echo "deb $main_repo stable main" >> $source_list;
    mkdir $data;
    log="$data/error.log";
    touch $log;
    pkg update -y 2> $log;
    
    if [ -s $log ]; then
        keyring=$(cat $log | grep "public key is not available:")
        if [ ${#keyring} != 0 ]; then
            curl -s -L $keyring_url -o "$data/new-keyring.deb";
            dpkg -i "$data/new-keyring.deb" 2> $log;
            apt update;
            apt upgrade -y 2>> $log;
            apt dist-upgrade -yq 2>> $log;
            if [ -s $log ]; then
                echo "\033[31;1m[-]\033[0m Failed to resolve some issues";
                cat $log;
                echo "\033[31;1m[-]\033[0m Failed to upgrade termux";
            else
                termux-change-repo;
                echo "\033[32;1m[+]\033[0m Termux successfully upgraded";
                echo "\033[32;1m[+]\033[0m The science and game repos have been removed";
                echo "\033[32;1m[+]\033[0m Termux-keyring updated";
                echo "\033[33mPlease restart the termux app\033[0m";
                fi
        else
            echo "\033[31;1m[-]\033[0m Unknown issues";
            cat $log;
        fi
    else
        termux-change-repo;
        echo "\033[32;1m[+]\033[0m Termux successfully upgraded";
        echo "\033[32;1m[+]\033[0m The science and game repos have been removed";
        echo "\033[33mPlease restart the termux app\033[0m";
    fi
elif [ $quarry = 'n' ]; then
    echo "Bye.."
else
    echo "\033[31;1mEnter y or n\033[0m"
fi
