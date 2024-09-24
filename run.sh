#!/bin/bash

#ascii
ascii_art="
\e[32m
_    _ ____ ___    ____ _    _ ____ ____ ____    ___  ____ ____ _  _ 
|    | [__   |     [__  |    | |    |___ |__/    |  \ |  | |__/ |_/  
|___ | ___]  |     ___] |___ | |___ |___ |  \    |__/ |__| |  \ | \_ 
                                                                     
Chop, slice, and dice your search queries like a pro! 
Easily organize your Google dorks and find exactly what you're looking for🪄
https://mzrismuarf.github.com/listslicerdork
\e[0m                                
"

# spinner
show_spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# create folders and output files
create_output_file() {
    local folder="r-splitdork/$(date +%Y-%m-%d)"
    local file="$folder/$(date +%Y-%m-%d).txt"
    
    mkdir -p "$folder"
    touch "$file"
    
    echo "$file"
}

# add the contents of the file with new lines
append_to_file() {
    local file=$1
    echo -e "\n# Added on $(date +%H:%M:%S)" >> "$file"
    shift
    for line in "$@"; do
        echo "$line" >> "$file"
    done
}

# retrieve and filter the dork list
filter_dork_list() {
    local menu_choice=$1
    local additional_option=$2
    local dork_file=$3
    local file_output=$(create_output_file)

    echo
    
    case $menu_choice in
        1) grep "^intitle:" "$dork_file" | grep "$additional_option" ;;
        2) grep "^intext:" "$dork_file" | grep "$additional_option" ;;
        3) grep "^inurl:" "$dork_file" | grep "$additional_option" ;;
        4) grep "^allintext:" "$dork_file" | grep "$additional_option" ;;
        5) shuf -n 5 "$dork_file" | grep -E "^intitle:|^intext:|^inurl:|^allintext:" | grep "$additional_option" ;;
        6) read -p "[?] key: " keys
           grep -E "$(echo $keys | sed 's/ /|/g')" "$dork_file" | grep "$additional_option" ;;
    esac | tee -a "$file_output"

    echo -e "\e[32m[+]\e[0m All done! Your results are ready! -> $file_output"
}

echo -e "$ascii_art"
echo "[1] intitle [2] intext [3] inurl [4] allintext [5] random [6] other"
echo 
read -p "[?] What's next? Pick an option: " menu_choice

# additional option input
read -p "[?] Pick an option other: " additional_option

# input dork list
read -p "[?] Drop your dork list here: " dork_file

# check if the dork list file exists
if [ ! -f "$dork_file" ]; then
    echo -e "\e[31m[!]\e[0m Oops! Can't find that file."
    exit 1
fi

# show number of file contents
list_count=$(wc -l < "$dork_file")
echo -e "\e[33m[33]\e[0m Got $dork_file: $list_count items to process!"

# delay
sleep 1

# retrieval process
echo -n -e "\e[36m[~]\e[0m Processing item $(case $menu_choice in 1) echo "intitle";; 2) echo "intext";; 3) echo "inurl";; 4) echo "allintext";; 5) echo "random";; 6) echo "other";; esac) almost there!..."
# run spinner
sleep 1 &
show_spinner $!

filter_dork_list $menu_choice "$additional_option" $dork_file
