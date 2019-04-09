#!/bin/bash

red_col="\033[1;31m"
green_col="\033[1;32m"
white_col="\033[1;37m"
blue_col="\033[1;34m"
gray_col="\033[0;37m"

command_line_loop() {
  while [ 1 ]; do
      printf "${green_col}@$1 >> ${white_col}"
      read user_command
      command_strings=(${user_command})
      if [ "${command_strings[0]}" = "maked" ]; then
        if [ -e ${command_strings[@]:1} ]; then
          printf "${red_col}error: Directory exists\n${gray_col}";
        else
          mkdir ${command_strings[@]:1}
        fi

      elif [ "${command_strings[0]}" = "makef" ]; then
        if [ -e ${command_strings[@]:1} ]; then
          printf "${red_col}error: File exists\n${gray_col}";
        else
          mkdir ${command_strings[@]:1}
        fi

      elif [ "${command_strings[0]}" = "write" ]; then
        if [ -e ${command_strings[1]} ]; then
          echo $input_text > ${command_strings[1]}
          input_text=""
          while [ "$input_text" != "endwriting" ]; do
            read input_text

            if [ "$input_text" != "endwriting" ]; then
              echo $input_text >> ${command_strings[1]}
            fi
          done
        else
          printf "${red_col}error: File not found\n${gray_col}";
        fi

      elif [ "${command_strings[0]}" = "open" ]; then
        file_name=${command_strings[@]:1}
        if [ -e $file_name ]; then
          if [[ ${file_name: -3} == ".gz" ]] || [[ ${file_name: -3} == ".xz" ]] || [[ ${file_name: -4} == ".tgz" ]]; then
             tar -xvf $file_name
          elif [[ ${file_name: -4} == ".zip" ]]; then
            unzip $file_name
          else
            cat $file_name
          fi
        else
          printf "${red_col}error: ${file_name}: No such file.\n${gray_col}"
        fi

      elif [ "${command_strings[0]}" = "list" ]; then
        current_dir=`pwd`
        current_dir+="/*"
        files=(${current_dir})
        for i in ${files[@]}; do
          if [ -f $i ]; then
            echo "[file] $(basename "$i")";
          elif [ -d $i ]; then
            echo "[dir]  $(basename "$i")";
          fi
        done

      elif [ "${command_strings[0]}" = "math" ]; then

        if [[ ${command_strings[2]} =~ ^[+-]?[0-9]+([.][0-9]+)?$ ]] && [[ ${command_strings[3]} =~ ^[+-]?[0-9]+([.][0-9]+)?$ ]]; then
          if [ "${command_strings[1]}" = "+" ]; then
            echo `echo ${command_strings[2]} + ${command_strings[3]} | bc`
          elif [ "${command_strings[1]}" = "x" ]; then
            echo $((command_strings[2] * command_strings[3]))
          elif [ "${command_strings[1]}" = "-" ]; then
            echo `echo ${command_strings[2]} - ${command_strings[3]} | bc`
          elif [ "${command_strings[1]}" = "/" ] || [ "${command_strings[1]}" = "÷" ]; then
            echo `echo ${command_strings[2]} / ${command_strings[3]} | bc`
          else
            echo "error: Invalid input in command math"
          fi
        else
          printf "${red_col}error: Invalid input in command math\n${gray_col}"
        fi

      elif [ "${command_strings[0]}" = "retrieve" ]; then
        search_result=$(grep -rnwl `pwd` -e "${command_strings[1]}[^A-Za-z]*")
        for res_file in ${search_result[@]}; do
          echo "$(basename "$res_file")";
        done

      elif [ "${command_strings[0]}" = "exit" ]; then
        printf "Bye !\n"
        exit 0
      fi

  done

}


while [ 1 ]; do
  printf "Enter ${blue_col}R${gray_col} for Register Or ${blue_col}L${gray_col} for Login: "
  read x

  if [ "$x" = "r" ] || [ "$x" = "R" ] ; then
    while [ 1 ]; do
      echo -n "Type a user name: "
      read new_user_name
      echo -n "Type a password: "
      read new_password

      if grep -q $new_user_name registered_users.json; then
        printf "${red_col}error: There is a submitted user with this user name, Try another user name!\n${gray_col}";
      else
        mkdir $new_user_name
        echo "{\"user_name\":\"$new_user_name\", \"password\":\"$new_password\"}" >> registered_users.json
        cd $new_user_name
        command_line_loop $new_user_name
      fi
    done

  elif [ "$x" = "l" ] || [ "$x" = "L" ] ; then
    while [ 1 ]; do
      echo -n "Type your user name: "
      read user_name
      echo -n "Type your password: "
      read password

      if [ -e registered_users.json ]; then
        if grep -q $user_name registered_users.json; then
          line=`grep -n "\user_name\":\"$user_name\"" registered_users.json`
          pass=`echo $line | grep -oP "(?<=\"password\":)[^}]+"`

          if [ "\"$password\"" = "$pass" ]; then
            cd $user_name
            command_line_loop $user_name
          else
            printf "${red_col}error: Wrong password.\n${gray_col}"
          fi
        else
          printf "${red_col}error: There is not any user with this user name!\n${gray_col}";
        fi
      else
        printf "${red_col}error: There is not any user with this user name!\n${gray_col}";
      fi

    done
  else
    printf "${red_col}error: Invalid input!\n${gray_col}";
  fi

done
