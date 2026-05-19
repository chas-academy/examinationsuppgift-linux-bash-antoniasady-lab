#!/bin/bash

# "shebang" + path = Instruktion att anÃ¤nda bash fÃ¶r att kÃ¶ra scriptet
# Kontrollerar om script kÃ¶rs som root
# UID 0 = root user
# Om anvÃ¤ndaren Ã¤r inte root , skriv meddelande "Error: This script must be run as root."
#----------------------------------------------------------------------------------------

if [ "$EUID" -ne 0 ]; then
    echo "Error: MÃ¥ste vara root fÃ¶r att skapa anvÃ¤ndare"
    exit 1
fi

#------------------------------------------------------------------------------------------
# Kontollerar om det finns argument under tiden scrip kÃ¶rs 
# Omdet saknas argument/ anvÃ¤ndarnamn skriv meddelade "Var snÃ¤ll och lÃ¤gg till anvÃ¤ndarnamn"
#-------------------------------------------------------------------------------------------

if [ "$#" -eq 0 ]; then
    echo "Var snÃ¤ll och lÃ¤gg till anvÃ¤ndarnamn"
    exit 1
fi

#---------------------------------
# GÃ¥r genom argument (users) 
#---------------------------------
for username in "$@"
do
    
    #--------------------------------------------------------------------------------------------
    # Kontrollerar om anvÃ¤ndare redan finns.
    # Om anvÃ¤ndaren finns , skriv meddelande "AnvÃ¤ndare $username finns redan"
    #--------------------------------------------------------------------------------------------
    
    if id "$username" &>/dev/null; then
        echo "AnvÃ¤ndare $username finns redan"
        continue
    fi
    
    #----------------------------------------------------------------------------------------------
    # Skapar anvÃ¤ndare och home directory -m
    # Om kommando useradd missluckas (!) skriv meddelande "GÃ¥r inte att skapa $username"
    #----------------------------------------------------------------------------------------------
    
    if ! useradd -m "$username"; then
        echo "GÃ¥r inte att skapa $username"
        continue
    fi
    
    #------------------------------------------------------------------------------------------------
    # Skriver "Welc0me#2026" och skickar texten (| pipe) till chpasswd som updaterar lÃ¶senord databas
    #------------------------------------------------------------------------------------------------
    
    echo "$username:Welc0me#2026" | chpasswd

    #-----------------------------------
    # Definierar var home directory path
    #-----------------------------------
    
    user_home="/home/$username"

    # ------------------------------------------------------------------------------------------------------
    # mkdir = skapa directory , "$user_home/Documents" path + namn pÃ¥ directory som ska skapas ex: Documents
    # ------------------------------------------------------------------------------------------------------
    
    mkdir -p "$user_home/Documents"
    mkdir -p "$user_home/Downloads"
    mkdir -p "$user_home/Work"

    # --------------------------------------------------
    # SÃ¤tter Ã¤garskap av home directory och inehÃ¥ll 
    # --------------------------------------------------
    
    chown -R "$username:$username" "$user_home"

    # --------------------------------------------------
    # Setter rÃ¤ttighet (permissions) fÃ¶r directories 
    # 7 Ã„gare = LÃ¤sa skriva exekvera/kÃ¶ra 
    # 0 Group = inga rÃ¤ttigheter
    # 0 Ã–vriga = inga rÃ¤ttigheter
    # --------------------------------------------------
    
    chmod 700 "$user_home/Documents"
    chmod 700 "$user_home/Downloads"
    chmod 700 "$user_home/Work"

    # ----------------------------------------------------------------------------
    # Skapar vÃ¤lkomstfil med text VÃ¤lkommen + anvÃ¤ndare i anvÃ¤ndares hem directory
    # LÃ¤gger till text " Andra anvÃ¤ndare i systemet "
    # ----------------------------------------------------------------------------
    
    welcome_file="$user_home/welcome.txt"

    echo "VÃ¤lkommen $username" > "$welcome_file"
    echo "" >> "$welcome_file"
    echo "Andra anvÃ¤ndare i systemet:" >> "$welcome_file"

    # ---------------------------------------------------------------------
    # LÃ¤ser lista av anvÃ¤ndare i /etc/passwd och skickar till vÃ¤lkomstfilen 
    # ---------------------------------------------------------------------
    
    cut -d: -f1 /etc/passwd | grep -v "^$username$" >> "$welcome_file"

    # ---------------------------------------------------
    # SÃ¤tter rÃ¤ttigheter ( permissions) fÃ¶r vÃ¤lkomstfilen 
    # 6 Ã„gare = lÃ¤sa skriva 
    # 0 Group = inga rÃ¤ttigheter
    # 0 Ã–vriga = inga rÃ¤ttigheter
    # ---------------------------------------------------
    
    chown "$username:$username" "$welcome_file"
    chmod 600 "$welcome_file"

    echo "AnvÃ¤ndare  $username Ã¤r skapad."
    echo "-----------------------------------"

done
