# Sharoek Mahboeb 1018492 1H
#!/bin/bash

#Helper Functions
findpassword() {
index=0

while [ $index -lt ${#myArray} ] ; do
if [[ ${myArray[$index]} == '-p' ]] ; then
    ((index++))
    echo $index
fi
((index++))
done
}


passwordCheck() {
#check if password atleast 8 characters long, comb of lower- and uppercases and digits
if [[ ${#1} -ge 8 ]] && [[ $1 =~ [[:upper:]] ]] && [[ $1 =~ [[:lower:]] ]] && [[ $1 =~ [[:digit:]] ]]  ; then
    echo pass
else 
    echo $1
fi
}

checkFile() {
#check if its a directory or file
if  [[ -d $lastargument ]] || [[ -d $HOME/$lastargument ]] #lastargument
then
    #true for directory  
    echo dir
else 
    if [[ -f  $lastargument ]] || [[ -f $HOME/$lastargument ]]
    then
        echo file
       #false/ it is a file
    fi
fi
}

isFile() {
#runs if its a file
local index=$(findpassword)
local nicetxt=`echo $lastargument | awk -F '/' '{print $NF}'| cut -d '.' -f 1`
local countchar=`echo $nicetxt | wc -m`
echo "Confirm to delete this file? Y/n"
read userInput
if [ $userInput == 'Y' ] ; then 
    if [[ ${myArray[$1]} == '-p' ]] && [[ ${#myArray} -gt 1 ]] ; then
    local password=$(passwordCheck ${myArray[$index]})
        if [[ "$password" == "pass" ]] ; then 
            zip -q $nicetxt.zip $lastargument
            \rm $lastargument
            if [[ -f $HOME/trash/$nicetxt.zip ]] ; then
                sed -i "/$nicetxt.zip/d" $HOME/trash/list
            fi
            mv $nicetxt.zip $HOME/trash  
            if [[ $countchar -gt 4 ]] ; then
                echo -e "${myArray[index]}\tY\t\t$nicetxt.zip\t\tF" >> $HOME/trash/list
            else
                echo -e "${myArray[index]}\tY\t\t$nicetxt.zip\t\t\tF" >> $HOME/trash/list
            fi
        else 
            echo "$password incorrect; password needs a combination of lower-, uppercases and digits with a minimum length of 8"
        fi 
    elif [ ${myArray[0]} == $lastargument ] ; then
        zip -q $nicetxt.zip $lastargument       
        \rm $lastargument
        if [[ -f $HOME/trash/$nicetxt.zip ]] ; then
            sed -i "/$nicetxt.zip/d" $HOME/trash/list
        fi
        mv $nicetxt.zip $HOME/trash  
        if [[ $countchar -gt 4 ]] ; then
            echo -e "\t\tN\t\t$nicetxt.zip\t\tF"  >> $HOME/trash/list
        else 
            echo -e "\t\t\tN\t\t\t$nicetxt.zip\tF"  >> $HOME/trash/list
        fi
    else 
        echo "The arguments are invalid either use -p to encrypt the removing file or only insert the filename "
    fi
elif [ $userInput == 'n' ] ; then
    echo "Quitting program"
else 
    echo "Please only input the capital letter Y for Yes or smaller letter n for no"
fi
}


isDirectory() {
#run if its a directory 
local index=$(findpassword)
local nicetxt=`echo $lastargument | awk -F '/' '{print $NF}'`  
local dir=$(pwd)
local countchar=`echo $nicetxt | wc -m`

if [[ $nicetxt == '' ]] ; then
    nicetxt=`echo $lastargument | awk -F '/' '{print $(NF-1)}'`
fi
    if [[ ${myArray[@]} =~ '-r' ]] && [[ ${#myArray} -gt 1 ]] && [[ ! ${myArray[@]} =~ '-p' ]]; then
        zip -rq $nicetxt.zip "$lastargument"
        \rm -r "$dir/$lastargument"
        if [[ -f $HOME/trash/$nicetxt.zip ]] ; then
            sed -i "/$nicetxt.zip/d" $HOME/trash/list
            fi
        mv $nicetxt.zip $HOME/trash
        if [[ $countchar -gt 4 ]]; then
            echo -e "\t\tN\t$nicetxt.zip\tD" >> $HOME/trash/list  
        else
            echo -e "\t\tN\t\t$nicetxt.zip\t\tD" >> $HOME/trash/list
        fi
    elif [[ ${myArray[@]} =~ '-r' ]] && [[ ${myArray[@]} =~ '-p' ]] && [[ ${#myArray} -gt 1 ]] ; then
        local password=$(passwordCheck ${myArray[$index]})
        if [[ "$password" == "pass" ]] ; then
            zip -q -r $nicetxt.zip "$lastargument"
            \rm -r "$dir/$lastargument"
            if [[ -f $HOME/trash/$nicetxt.zip ]] ; then
            sed -i "/$nicetxt.zip/d" $HOME/trash/list
            fi
            mv $nicetxt.zip $HOME/trash
            if [[ $countchar -gt 4 ]] ; then
                echo -e "${myArray[$index]}\tY\t\t$nicetxt.zip\t\tD" >> $HOME/trash/list
            else
                echo -e "${myArray[$index]}\tY\t\t$nicetxt.zip\t\t\tD" >> $HOME/trash/list
            fi
        else 
            echo "$password incorrect; password needs a combination of lower-, uppercases and digits with a minimum length of 8"
            fi 
    else 
        echo "To remove a directory either use -r and -p to add a password or only use -r"
    fi
}

Retrievecommand() {
local dir=$(pwd)
local nicetxt=`echo $lastargument | cut -d '/' -f 2 | cut -d '.' -f 1`
local fileinzip=`unzip -Z -1 $HOME/trash/$nicetxt.zip`
local fileordir=`grep ${myArray[-1]} $HOME/trash/list | awk '{print $NF}'`
echo "I am retrieving the file $nicetxt.zip" 

if [[ $fileordir == 'D' ]] ; then
    if [[ -d $dir/$nicetxt ]] ; then 
        echo "Do you wish to overwrite the file? Y/n"
        read input
        if [[ $input == 'Y' ]] ; then
            \rm -r $dir/$nicetxt
            unzip -o -qq "$HOME/trash/$nicetxt.zip" -d $dir
            \rm -r "$HOME/trash/$nicetxt.zip"
            sed -i "/$nicetxt.zip/d" $HOME/trash/list
            echo "Succeeded"
        elif [[ $input == 'n' ]] ; then
            echo "Quitting program"
        else 
            echo "Please only input the capital letter Y for Yes or smaller letter n for no"
        fi
    else 
        echo "Restoring to $dir" 
        unzip -o -qq "$HOME/trash/$nicetxt.zip" -d $dir
        \rm -r "$HOME/trash/$nicetxt.zip"
        sed -i "/$nicetxt.zip/d" $HOME/trash/list
        echo "Succeeded"
    fi
fi


if  [[ $fileordir == 'F' ]] ; then
    if [[ `find $dir -name $fileinzip` ]] ; then 
        echo "Do you wish to overwrite the file? Y/n"
        read input
        if [[ $input == 'Y' ]] ; then
            unzip -o -qq "$HOME/trash/$nicetxt.zip" -d $dir
            \rm -r "$HOME/trash/$nicetxt.zip"
            sed -i "/$nicetxt.zip/d" $HOME/trash/list
            echo "Succeeded"
        elif [[ $input == 'n' ]] ; then
            echo "Quitting program"
        else 
            echo "Please only input the capital letter Y for Yes or smaller letter n for no"
        fi
    else 
        echo "Restoring to $dir" 
        unzip -o -qq "$HOME/trash/$nicetxt.zip" -d $dir
        \rm -r "$HOME/trash/$nicetxt.zip"
        sed -i "/$nicetxt.zip/d" $HOME/trash/list
        echo "Succeeded"
    fi
fi
}



retrieveFile() {
#if -u is used this function runs
local nicetxt=`echo $lastargument | cut -d '/' -f 2 | cut -d '.' -f 1`
local filepwd=`grep ${myArray[-1]} $HOME/trash/list | cut -d $'\t' -f 1`
local int=1
    
if [[ $filepwd == '' ]] ; then
        Retrievecommand
else 
    echo "The file is password protected. Please enter the password"
    read -s input 
    if [[ $input == $filepwd ]] ; then
        Retrievecommand
    else
        while [[ ! $input == $filepwd ]] && [[ $int -lt 3 ]]; do
            echo "Wrong Password try again:" 
            read -s input
            ((int++))
        done
        if [[ $input == $filepwd ]] ; then
                Retrievecommand
        else
            echo "Wrong Password"
        fi
    fi
fi
}

#MainFunction
Mainfunction() {
myArray=( "$@" )
lastargument=${!#}
local dir=$(pwd)
local nicetxt=`echo $lastargument | cut -d '/' -f 2 | cut -d '.' -f 1`
lastchar=${lastargument: -1}

#check if there are arguments
if [[ $# -eq 0 ]]
then
    echo "rm: missing a operand"
    
else
#check arguments passed
    #we check if file (lastargument) exist in current directory or trash for -u
    if [[ -f "$dir/$lastargument" ]] || [[ -d "$dir/$lastargument" ]] || [[ -f "$HOME/trash/$nicetxt.zip" ]] || [[ -f $HOME/$lastargument ]] || [[ -d $HOME/$lastargument ]]; then
        #we are going to checkfile
        result=$(checkFile)
        #catch the result of checkfile
        if [ "$result" == "file" ] && [[ ! $@ =~ '-u' ]]; then
            isFile
        elif [[ $# -gt 1 ]] && [[ $@ =~ '-r' ]] && [[ ! $@ =~ '-u' ]] && ! [[ -f "$HOME/trash/$nicetxt.zip" ]] ; then
            isDirectory
        elif [[ $@ =~ '-r' ]] && [[ $@ =~ '-u' ]] ; then
            echo "-u cannot be combined with -r"
        elif [[ $# -gt 1 ]] && [[ ${myArray[0]} == '-u' ]] && [[ -f "$HOME/trash/$nicetxt.zip" ]] ; then
            retrieveFile
        elif [[ ! $1 == '-r' ]] && [[ $result == "dir" ]] ; then
            echo "rm: cannot remove $lastargument: -r is not used"
        elif [[ -f "$HOME/trash/$nicetxt.zip" ]] ; then
            echo "The file already exist in the trash" 
        fi
    elif [[ $lastchar == "/" ]] ; then
        echo "/ is not supported for files in this version, please write without /"
    elif [[ ! -f "$HOME/trash/$nicetxt.zip" ]] && [[ $@ =~ '-u' ]] ; then 
        echo "File not found" 
    else
        echo "rm: can not remove '$lastargument' : No such file or directory "
fi
fi
}




#Checks before running the MainFunction
#check if directory Trash exist else make it
if [ ! -d "$HOME/trash" ]
then        
    mkdir "$HOME/trash"
    touch "$HOME/trash/list"
    echo -e "Pass\t\tProtected\tFilename\t\tD/F" >> $HOME/trash/list
fi

alias rm='Mainfunction'
