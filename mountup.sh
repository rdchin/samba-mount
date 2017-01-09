#!/bin/bash
#
VERSION="2016-12-11 17:01"
THIS_FILE="mountup.sh"
TEMP_FILE="mountup_temp.txt"
#
## Brief Description
##
## This script will mount shared cifs (Samba) directories from one or more
## file servers on the corresponding mount-point (directories) on the local PC.
##
## To add more file server names, share-points with corresponding mount-points,
## edit the text with the prefix "#@@" following the Code Change History.
## Format <DELIMITER>//<Source File Server>/<Shared directory><DELIMITER>/<Mount-point on local PC>
##
## After each edit made, please update Code History and VERSION.
##
## Code Change History
##
## 2016-12-11 *f_mount_txt fixed faulty code by total rewrite with pseudo-code.
##            *f_post_mount_txt added to simplify code.
##
## 2016-12-04 *f_show_mount_points_txt fix bug in fall-back to df with fewer
##             options does not display output.
##
## 2016-11-29 *f_mount_txt, f_username_txt allow anonymous user mounting.
##            *f_show_mount_points_txt show username of mountpoints.
##
## 2016-04-28 *f_main_menu_txt fixed bug when null input at main menu..
##
## 2016-04-25 *Script now allows mounting/dismounting of all directories
##             on a file server at once or of one specific directory.
##
## 2016-04-19 *Entire script was rewritten to allow any number of
##             shared directories. The script was previously hard-coded for
##             for specific file servers and shared directories.
##            *Script now has a fully extensible Main Menu with menu items
##             easily added in comment lines beginning with "##@".
##
## 2016-03-31 *Posted on GitHub.com as a template.
##
## 2015-12-01 *Created new script. Script is hard-coded for personal use
##             for specific file servers and shared directories.
#
#
# MOUNT COMMAND RETURN CODES
#       mount has the following return codes (the bits can be ORed):
#
#       0      success
#
#       1      incorrect invocation or permissions
#
#       2      system error (out of memory, cannot fork, no more loop devices)
#
#       4      internal mount bug
#
#       8      user interrupt
#
#       16     problems writing or locking /etc/mtab
#
#       32     mount failure
#
#       64     some mount succeeded
#
# +--------------------------------------------------------------------------+
# |                                                                          |
# | Add additional source file servers, share-points, and mount-points here. |
# |                                                                          |
# +--------------------------------------------------------------------------+
#
# Format <Delimiter>//<Source File Server>/<Shared directory><Delimiter>/<Mount-point on local PC><Delimiter><Shared directory description>
#
#@@//hansolo/public#@@/mnt/hansolo/public#@@Hansolo Server Publicly shared files.
#@@//hansolo/public/jobs#@@/mnt/hansolo/jobs#@@Hansolo Server Publicly shared job information.
#
#@@//chewbacca/photos#@@/mnt/chewbacca/photos#@@Chewbacca Server shared photos.
#
#@@//luke/school#@@/mnt/luke/school#@@Luke Server shared school files.
#
#@@//leia/music#@@/mnt/leia/music#@@Leia Server shared music.
#
#@@//yoda/public-no-backup#@@/mnt/yoda/public-no-backup#@@Yoda Server shared files not backed up.
#
#@@//r2d2/geekstuff#@@/mnt/r2d2/geekstuff#@@R2D2 Server shared geek stuff.
#@@//r2d2/geekstuff#@@/mnt/r2d2/geekscripts#@@R2D2 Server shared geek scripts.
#
#@@//c3po/library#@@/mnt/c3po/library#@@C3PO Server shared Library.
#
# +----------------------------------------+
# |       Function f_server_arrays         |
# +----------------------------------------+
#
#  Inputs: THIS_FILE.
#    Uses: DELIMITER, XSTR, SERVER_NAME, NEXT_SERVER_NAME, SERVER_NUM, ARRAY_NUM.
# Outputs: SERVER[$SERVER_NUM]=<Name of server>^<Description of shared directory>.
#          SRV[$SERVER_NUM]=<1st 2-letters of server name for pattern matching in menu case statement>.
#          SERVER_SP[SERVER_NUM]=<Server's shared directory to be mounted>.
#          LOCAL_MP[SERVER_NUM]=<Mount-point of local PC>.
#          SERVER_DESC[1]=<Description of Shared Directory contents>.
#
f_server_arrays () {
      # Create arrays to handle mount-point names and server source directory names.
      # Example:
      # Server name is "hansolo"
      # Shared directory to be mounted is "//hansolo/public/contacts"
      # Local PC mount-point is "/mnt/hansolo/contacts"
      #
      #     SERVER[1]="hansolo"
      #     SRV[1]="ha" <1st 2-letters of server name for pattern matching in menu case statement>
      #     hansolo_SP[1]="//hansolo/public/contacts  # Share-point on hansolo.
      #     hansolo_MP[1]="/mnt/hansolo/contacts"     # Local mount-point on Local PC.
      #     hansolo_DESC[1]="Shared_contact_list"  # Description of shared folder contents (substitute <underscore> for <space> characters).
      #
      DELIMITER="#@@"
      SERVER_NUM=0 # Initialize.
      SERVER_NAME="" # Initialize.
      ARRAY_NUM=1
      #
      #        Field-1                                Field-2                                   Field-3                               Field-4
      # Format of XSTR="<Delimiter>//<Source File Server>/<Shared directory><Delimiter>/<Mount-point on local PC><Delimiter><Shared directory description>"
      # Read line of data having 3 delimiters and 4 fields. Save fields 2, 3, 4.
      # echo $(awk -F "$DELIMITER" '{ if ( $3 ) { print $2 "^" $3 "^" $4; }}' $THIS_FILE)
      #
      # Show Field-4 Description field which gets truncated to only 1st word in the for-loop below for an unknown reason.
      # echo $(awk -F "$DELIMITER" '{ if ( $3 ) { print $4 }}' $THIS_FILE)  # Test diagnostic line.
      # f_press_enter_key_to_continue                     # Test diagnostic line.
      echo "" >$TEMP_FILE
      while read XSTR
      do
            case $XSTR in
                  \#@@*) echo $XSTR >>$TEMP_FILE
                  ;;
            esac
      done < $THIS_FILE
      #
      while read XSTR
      do
            # Since format of share-point directory is "//<SERVER_NAME>" the name is in <field-3> with delimiter "/".
            NEXT_SERVER_NAME=$(echo $XSTR | awk -F "/" '{ if ( $3 ) { print $3 }}')
            if [ "$SERVER_NAME" != "$NEXT_SERVER_NAME" ] ; then
               SERVER_NAME=$NEXT_SERVER_NAME
               let SERVER_NUM=$SERVER_NUM+1 # Increment server array index.
               ARRAY_NUM=1                  # Different server so reset index for share-point ond mount-point arrays.
            fi
            SERVER[$SERVER_NUM]="$SERVER_NAME"
            SRV[$SERVER_NUM]=${SERVER_NAME:0:2}  # SRV[n]=<the first 2-letters of the Server Name>
            #echo "SRV[$SERVER_NUM]=${SRV[$SERVER_NUM]}"      # Test diagnostic line.
            #
            # Set array $SERVER_NAME_SP[SERVER_NUM]=<field-2> or "Shared directory" of XSTR.
            ARRAY_NAME=$SERVER_NAME"_SP"
            ARRAY_VALUE=$(echo $XSTR | awk -F "#@@" '{ if ( $3 ) { print $2 }}')
            eval $ARRAY_NAME[$ARRAY_NUM]=$ARRAY_VALUE
            #echo "$ARRAY_NAME[$ARRAY_NUM]=${ARRAY_NAME[$ARRAY_NUM]}" # Test diagnostic line.
            #
            # Set array $SERVER_NAME_MP[SERVER_NUM]=<field-3> of XSTR.
            ARRAY_NAME=$SERVER_NAME"_MP"
            ARRAY_VALUE=$(echo $XSTR | awk -F "#@@" '{ if ( $3 ) { print $3 }}')
            #echo ARRAY_VALUE=$ARRAY_VALUE  # Test diagnostic line.
            #echo "$ARRAY_NAME[$ARRAY_NUM]=${$ARRAY_NAME[$ARRAY_NUM]}" # Test diagnostic line.
            eval $ARRAY_NAME[$ARRAY_NUM]=$ARRAY_VALUE
            #
            # Set array $SERVER NAME DESC[SERVER_NUM]=<field-4> of XSTR.
            ARRAY_NAME=$SERVER_NAME"_DESC"
            #echo XSTR=$XSTR  # Test diagnostic line.
            ARRAY_VALUE=$(echo $XSTR | awk -F "#@@" '{ if ( $3 ) { print $4 }}')
            ARRAY_VALUE=$(echo $ARRAY_VALUE | tr ' ' '_')
            #echo ARRAY_VALUE=$ARRAY_VALUE  # Test diagnostic line.
            #eval $ARRAY_NAME[$ARRAY_NUM]="$ARRAY_VALUE"
            eval $ARRAY_NAME[$ARRAY_NUM]=$ARRAY_VALUE
            #
            let ARRAY_NUM=$ARRAY_NUM+1
      done < $TEMP_FILE
      unset XSTR SERVER_NUM ARRAY_NUM SERVER_NAME NEXT_SERVER_NAME DELIMITER # Throw out this variable.
} # End of f_server_arrays.
#
# +----------------------------------------+
# |      Function f_test_environment       |
# +----------------------------------------+
#
#  Inputs: $BASH_VERSION (System variable).
#    Uses: None.
# Outputs: None.
#
f_test_environment () {
      # Set default colors in case configuration file is not readable
      # or does not exist.
      #
      # Test the environment. Are you in the BASH environment?
      # $BASH_VERSION is null if you are not in the BASH environment.
      # Typing "sh" at the CLI may invoke a different shell other than BASH.
      # if [ -z "$BASH_VERSION" ]; then
      # if [ "$BASH_VERSION" = '' ]; then
      f_test_dash_txt
} # End of function f_test_environment.
#
# +----------------------------------------+
# |        Function f_test_dash_txt        |
# +----------------------------------------+
#
#  Inputs: None.
#    Uses: None.
# Outputs: None.
#
f_test_dash_txt () {
      # Set default colors in case configuration file is not readable
      # or does not exist.
      #
      echo -n $(tput sgr0) # Set font to normal color.
      if [ -z "$BASH_VERSION" ]; then
         clear # Clear screen.
         echo -n $(tput bold)
         echo -n $(tput setaf 1) # Set font to color red.
         echo "WARNING:"
         echo "You are using the DASH environment."
         echo "This script needs a BASH environment to run properly."
         echo $(tput sgr0) # Set font to normal color.
         echo "Ubuntu and Linux Mint default to DASH but also have BASH available."
         echo
         echo "Restart this script by typing:"
         echo -n $(tput bold)
         echo "       \"bash $THIS_FILE\""
         echo -n $(tput sgr0) # Set font to normal color.
         echo "at the command line prompt (without the quotation marks)."
         echo
         echo -n $(tput sgr0) # Set font to normal color.
         f_press_enter_key_to_continue
         f_abort_txt
      fi
} # End of function f_test_dash_txt.
#
# +----------------------------------------+
# |          Function f_detect_ui          |
# +----------------------------------------+
#
#  Inputs: None.
#    Uses: ERROR.
# Outputs: GUI (dialog, whiptail, text).
#
f_detect_ui () {
      command -v dialog >/dev/null
      # "&>/dev/null" does not work in Debian distro.
      # 1=standard messages, 2=error messages, &=both.
      ERROR=$?
      # Is Dialog GUI installed?
      if [ $ERROR -eq 0 ] ; then
         # Yes, Dialog installed.
         GUI="dialog"
      else
         # Is Whiptail GUI installed?
         command -v whiptail >/dev/null
         # "&>/dev/null" does not work in Debian distro.
         # 1=standard messages, 2=error messages, &=both.
         ERROR=$?
         if [ $ERROR -eq 0 ] ; then
            # Yes, Whiptail installed.
            GUI="whiptail"
         else
            # No CLI GUIs installed
            GUI="text"
         fi
      fi
} # End of function f_detect_ui.
#
# +----------------------------------------+
# |         Function f_script_path         |
# +----------------------------------------+
#
#  Inputs: $BASH_SOURCE (System variable).
#    Uses: None.
# Outputs: SCRIPT_PATH.
#
f_script_path () {
      # BASH_SOURCE[0] gives the filename of the script.
      # dirname "{$BASH_SOURCE[0]}" gives the directory of the script
      # Execute commands: cd <script directory> and then pwd
      # to get the directory of the script.
      # NOTE: This code does not work with symlinks in directory path.
      #
      # !!!Non-BASH environments will give error message about line below!!!
      SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
} # End of function f_script_path.
#
# +----------------------------------------+
# |        Function f_test_connection      |
# +----------------------------------------+
#
#  Inputs: $1 - "text", "dialog" or "whiptail" The CLI GUI application in use.
#          $2 Network name of server. 
#    Uses: None.
# Outputs: ERROR. 
#
f_test_connection () {
      # Check if there is an internet connection before doing a download.
      case $1 in
           whiptail | dialog)
           ping -c 1 -q $2 >/dev/null # Ping server address.
           ERROR=$?
           if [ $ERROR -ne 0 ] ; then
              $1 --title "Ping Test Connection" --msgbox "Network connnection to $2 file server failed.\nCannot (dis)mount shared directories." 7 70
           fi
           ;;
           text)
           echo
           echo "Test LAN Connection to $2"
           echo
           ping -c 1 -q $2  # Ping server address.
           ERROR=$?
           echo
           if [ $ERROR -ne 0 ] ; then
              echo -n $(tput setaf 1) # Set font to color red.
              echo -n $(tput bold)
              echo ">>> Network connnection to $2 failed. <<<"
              echo "    Cannot (dis)mount shared directories."
              echo -n $(tput sgr0)
              f_press_enter_key_to_continue
           fi
           ;;
      esac
} # End of function f_test_connection.
#
# +----------------------------------------+
# |            Function f_abort_txt        |
# +----------------------------------------+
#
#  Inputs: None.
#    Uses: None.
# Outputs: None.
#
f_abort_txt() {
      echo $(tput setaf 1) # Set font to color red.
      echo >&2 "***************"
      echo >&2 "*** ABORTED ***"
      echo >&2 "***************"
      echo
      echo "An error occurred. Exiting..." >&2
      exit 1
      echo -n $(tput sgr0) # Set font to normal color.
} # End of function f_abort_txt.
#
# +----------------------------------------+
# | Function f_press_enter_key_to_continue |
# +----------------------------------------+
#
#  Inputs: None.
#    Uses: X.
# Outputs: None.
#
f_press_enter_key_to_continue () { # Display message and wait for user input.
      echo
      echo -n "Press '"Enter"' key to continue."
      read X
      unset X  # Throw out this variable.
} # End of function f_press_enter_key_to_continue.
#
# +------------------------------------+
# |        Function f_about_txt        |
# +------------------------------------+
#
#  Inputs: THIS_FILE, VERSION.
#    Uses: None.
# Outputs: None.
#
f_about_txt () {
      clear # Blank the screen.
      echo
      echo "Script $THIS_FILE."
      echo "Version: $VERSION"
      echo
      f_press_enter_key_to_continue
} # End of f_about_txt.
#
# +----------------------------------------+
# |       Function f_code_history_txt      |
# +----------------------------------------+
#
#  Inputs: THIS_DIR, THIS_FILE.
#    Uses: None.
# Outputs: None.
#
f_code_history_txt () {
      clear # Blank the screen.
      # Display Help (all lines beginning with "#@" but do not print "#@").
      # sed substitutes null for "#@" at the beginning of each line
      # so it is not printed.
      # less -P customizes prompt for
      # %f <FILENAME> page <num> of <pages> (Spacebar, PgUp/PgDn . . .)
      sed -n 's/^##//'p $THIS_DIR/$THIS_FILE | less -P '(Spacebar, PgUp/PgDn, Up/Dn arrows, press q to quit)'
} # End of function f_code_history_txt.
#
# +----------------------------------------+
# |    Function f_show_mount_points_txt    |
# +----------------------------------------+
#
#  Inputs: $1 - 1=press enter key to continue 0=no press key.
#    Uses: ERROR, X, Y.
# Outputs: None.
#
f_show_mount_points_txt () {
      X=$1 
      # clear # Blank the screen.
      # Test if this version of df has these OPTIONS.
      df -h --type=cifs --output=source,avail,target >/dev/null 2>&1
      ERROR=$?  # Note: ERROR=1 if nothing is mounted.
      if [ $ERROR -eq 1 ] ; then
         df -h --type=cifs >/dev/null 2>&1
         ERROR=$?  # Note: ERROR=1 if nothing is mounted.
         if [ $ERROR -eq 1 ] ; then
            echo $(tput setaf 1)  # Set font to color red.
            echo $(tput bold)     # Change to bold font.
            echo "No mount-points are mounted."
            echo $(tput sgr0)     # Change back to normal font.
            let X=0
         else
            df -h --type=cifs  # cifs mount-points detected so show results.
         fi
      else
         df -h --type=cifs --output=source,avail,target  # cifs mount-points detected so show results.
      fi
      #
      echo
      grep "//" /etc/mtab | awk -F "," '{ print $1,$5 }' | awk '{ print $5,"mounted",$1}'
      #
      if [ $X = 1 ] ; then
         f_press_enter_key_to_continue
      else
         sleep 2  # Either quickly display error or nothing is mounted.
      fi
      unset ERROR X # Throw out this variable.
} # End of function f_show_mount_points_txt.
#
# +----------------------------------------+
# |         Function f_username_txt        |
# +----------------------------------------+
#
#  Inputs: $1=SMBUSER.
#    Uses: ANS.
# Outputs: SMBUSER.
#
f_username_txt() {
      read -p "Enter user name or n=none ($1): " ANS
      echo
      case $ANS in
              "") SMBUSER=$1 ;;
           N | n) SMBUSER="anonymous" ;;
               *) SMBUSER="$ANS" ;;
      esac
unset ANS
} # End of function f_username_txt.
#
# +----------------------------------------+
# |         Function f_password_txt        |
# +----------------------------------------+
#
#  Inputs: None.
#    Uses: None.
# Outputs: PASSWORD.
#
f_password_txt() {
      read -s -p "Enter SMB mount-point password: " PASSWORD
      echo
} # End of function f_password_txt.
#
# +----------------------------------------+
# |  Function f_mount_or_dismount_all_txt  |
# +----------------------------------------+
#
#  Inputs: $1=Server name.
#          $2="mount" or "dismount"
#    Uses: EXITOUT, NUM, SP, MP.
# Outputs: None.
#
f_mount_or_dismount_all_txt () {
      #
      # This function will attempt to mount all shared directories on a single server.
      #
      # Example:
      # Server name is "Server01"
      # Shared directory to be mounted is "//server01/public/contacts"
      # Local PC mount-point is "/mnt/server01/contacts"
      # Shared directory to be mounted is "//server01/public/companies"
      # Local PC mount-point is "/mnt/server01/companies"

      #
      # The arrays are <Server name>_SP=<Server_name>/<Shared directory>
      #                <Local PC name>_MP=<Local_PC_name>/<Mount-point directory>
      #
      # Example:
      # SERVER[1]="Server01"
      # SERVER_SP[1]="//server01/public/contacts"
      # LOCAL_MP[1]="/mnt/server01/contacts"
      # SERVER_SP[2]="//server01/public/companies"
      # LOCAL_MP[2]="/mnt/server01/companies"
      #
      EXITOUT=0  # When EXITOUT=1 then a shared folder failed to mount.
                 # When EXITOUT=0 then mount is successful or is previously mounted.
                 # 
      NUM=1
      while [ $EXITOUT -eq 0 ]
      do
            # eval allows indirection of array name.
            # echo "\" tells echo to disreguard the first "$" to prevent parameter expansion before passing it to echo which creates the read array command.
            SP=$(eval echo "\$\{$1_SP[$NUM]\}")   # Create command "${<server_name>_SP[$NUM]}" to read string of Shared directory      from array <Server name>_SP[n].
            MP=$(eval echo "\$\{$1_MP[$NUM]\}")   # Create command "${<server_name>_MP[$NUM]}" to read string of Mount-point directory from array <Server name>_MP[n].
            # echo "Read Mount-point command=$MP" # Test diagnostic line.
            # echo "Read Share-point command=$SP" # Test diagnostic line.
            # echo "--------"                     # Test diagnostic line.
                                                  #
            SP=$(eval echo $SP)                   # Read Shared directory from array <Server name>_SP[1].
            if [ -n "$SP" ] ; then                # Does array element exist? (specifying Shared Directory).
               MP=$(eval echo $MP)                # Read Mount-point directory from array <Server name>_MP[1].
               if [ -n "$MP" ] ; then             # Does array element exist? (specifying Mount-Point Directory).
                  # echo "Mount-point=$MP"        # Test diagnostic line.
                  # echo "Share-point=$SP"        # Test diagnostic line.
                  # f_press_enter_key_to_continue # Test diagnostic line.
                  if [ $2 = "mount" ] ; then
                     f_mount_txt $SP $MP       # Now actually mount the shared directory at the mount-point on the local PC.
                  else
                     f_dismount_txt $MP           # Dismount the mount-point directory.
                  fi
               else
                  EXITOUT=1  # $MP Array element does not exist so no more mount-points specified.
               fi
            else
               EXITOUT=1     # $SP Array element does not exist so no more shared directories specified.
            fi
            NUM=$(($NUM+1))  #Increment NUM by 1.
      done
      unset EXITOUT NUM SP MP # PASSWORD  # Throw out this variable.
} # End of function f_mount_or_dismount_all_txt.
#
# +----------------------------------------+
# |          Function f_mount_txt          |
# +----------------------------------------+
#
#  Inputs: $1=Share-point.
#          $2=Mount-point.
#    Uses: ERROR, A, X. PASSWORD
# Outputs: EXITOUT, PASSWORD.
# Note: Raspberry Pi Model 1 cannot use -o password option in older Rasparian OS.
#
f_mount_txt () {
      # clear   # Blank the screen.
      # mountpoint command 0=directory is a mountpoint (already mounted).
      #                    1=directory is not a mountpoint (not mounted).
      #
      A=0
      EXITOUT=0  # When EXITOUT=1 then a shared folder failed to mount.
                 # When EXITOUT=0 then mount is successful or is previously mounted.
                 # 
      until [ "$A" -eq 1 ]  # Start loop. Is the shared directory mounted yet?
      do
            # Test if mounted already, if so, don't mount again or will get error.
            mountpoint $2 >/dev/null
            ERROR=$?
            if [ $ERROR -eq 0 ] ; then  # Directory is already mounted.
               A=1
               EXITOUT=0
            else  # Directory is not mounted yet.
               #
               # Case SMBUSER   PASSWORD   Action
               #
               #   1. null       null       First time in loop or a mount failure in f_post_mount_txt sets both to null. Ask for SMB user name. If none entered, set SMBUSER="anonymous".
               #   2. $USER      null       Mount anonymously.
               #   3. $USER      $PASSWORD  Mount with credentials.
               #   4. anonymous  null       Mount anonymously.
               #   5. null       $PASSWORD  f_action_menu_txt clears SMBUSER.
               #
               # if SMB username is null, prompt for a username. Cases #1, #5.
               # if SMB username is anonymous, mount anonymously. Case #4.
               # if SMB username exists, then prompt for password.
               # if password is null, then mount anonymously. Case #2.
               # SMB username and and password exist and are not null, mount with credentials. Case #3.
               #
               # if SMB username is null, prompt for an SMB username. Cases #1, #5
               if [ -z "$SMBUSER" ] ; then
                  f_username_txt "$USER"  # $USER is a system variable always set to the linux login user name.
                  if [ "$SMBUSER" != "anonymous" ] ;then
                     f_password_txt
                  fi
               fi
               # SMB username is now either "anonymous" or set to a string.
               #
               case $SMBUSER in
               "" | "anonymous")  # if SMB username is anonymous, mount anonymously. Cases #4.
                   echo
                   echo "No password is needed if username is \"anonymous\"."
                   echo
                   sudo mount -o username="anonymous" -o password="" -t cifs $1 $2
                   ERROR=$?
                   ;;
               *)  # SMB username exists.
                   #
                   if [ -z "$PASSWORD" ] ; then  # if password is null, then mount anonymously. Case #2.
                      sudo mount -o username="$SMBUSER" -o password="" -t cifs $1 $2
                     ERROR=$?
                   else  # SMB username and and password exist and are not null, mount with credentials. Case #3.
                     sudo mount  -o username=$SMBUSER -o password=$PASSWORD -t cifs $1 $2
                     ERROR=$?
                   fi
                   ;;
               esac
               f_post_mount_txt $1 $2
            fi
      done
      unset A X ERROR  # Throw out this variable.
} # End of function f_mount_txt.
#
# +----------------------------------------+
# |        Function f_post_mount_txt       |
# +----------------------------------------+
#
#  Inputs: $1=Share-point.
#          $2=Mount-point.
#    Uses: ERROR, A, X. SMBUSER, PASSWORD
# Outputs: A, EXITOUT, PASSWORD.
            #
f_post_mount_txt () {
            if [ $ERROR -ne 0 ] ; then
               # Error mounting smb mount-point occurred.
               echo $(tput setaf 1)  # Set font to color red.
               echo $(tput bold)     # Change to bold font.
               echo Mount Error: $ERROR
               echo
               echo "Error user $SMBUSER mounting share-point:"
               echo  $1
               echo "to mount-point:"
               echo $2
               echo $(tput sgr0)     # Change back to normal font.
               echo
               echo -n "Do you want to try another username/password? (Y/n)"
               read X
               case $X in
                       [Nn]) A=1     # No, do not try again. Exit this until-loop. Go back to previous menu.
                             EXITOUT=1
                             ;;
                       *) A=0     # Yes, try another password. Stay in this until-loop.
                             unset SMBUSER PASSWORD  # Delete SMB user credentials which may be causing mounting error "Permission denied".
                             ;;
               esac
            else
               # Successfully mounted. Display mount-points on-screen.
               # grep string $1<space> to eliminate similar mount-points.
               # i.e. if grep "public" will display both mount-points <public> and  <public-old>
               grep "$1 " /etc/mtab | awk -F "," '{ print $1,$5 }' | awk '{ print $5,"successfully mounted",$1}'
               A=1
               EXITOUT=0
               echo
               # f_press_enter_key_to_continue
            fi
} # End of function f_post_mount_txt.
#
# +----------------------------------------+
# |         Function f_dismount_txt        |
# +----------------------------------------+
#
#  Inputs: $1=Mount-point.
#    Uses: ERROR.
# Outputs: None.
#
f_dismount_txt () {
      # clear   # Blank the screen.
      # mountpoint command 0=directory is a mountpoint (already mounted).
      #                    1=directory is not a mountpoint (not mounted).
      # Test if unmounted already, 
      # if so then don't unmount again or will get mount error.
      mountpoint $1 >/dev/null
      ERROR=$?
      if [ $ERROR -eq 0 ] ; then
         echo "About to dismount $MP." ; sleep 1
         echo
         sudo umount $1
         ERROR=$?
         if [ $ERROR -ne 0 ] ; then
            # Error dismounting smb mount-point occurred.
            # Pause to examine error message.
            f_press_enter_key_to_continue
         fi
      fi
      #
      unset ERROR  # Throw out this variable.
} # End of function f_dismount_txt.
#
# +----------------------------------------+
# |        Function f_main_menu_txt        |
# +----------------------------------------+
#
#  Inputs: None.
#    Uses: X, Y, CHOICE_SERVER. CHOICEA, XNUM, YNUM, ARRAY_LEN, ARRAY_NAME, SERVER_NAME.
# Outputs: None.
#
f_main_menu_txt () {
      ARRAY_NAME="SERVER"
      ARRAY_LEN=$(eval "echo \$\{#$ARRAY_NAME[@]\}")
      ARRAY_LEN=$(eval echo $ARRAY_LEN)
      CHOICE_SERVER=-1
      until [ $CHOICE_SERVER -eq 0 ]
      do
            clear # Blank the screen.
            echo -n $(tput bold)
            echo "--- Server Menu ---"
            echo -n $(tput sgr0)
            echo
            # Format of menu items: <item #> (<first 2-letters>) - <Server Name> file server.
            echo "0 (Q/q) - Quit."
            echo "1 (S/s) - Show mounted directories."
            # Replaces echo -n "2 (" ; echo -n ${SERVER[1]} | head -c 2 ; echo ") - ${SERVER[1]} file server."
            for (( XNUM=1; XNUM<=${ARRAY_LEN}; XNUM++ ));
                do
                   ARRAY_NAME="SERVER"
                   ARRAY_LEN=$(eval "echo \$\{#$ARRAY_NAME[@]\}")
                   ARRAY_LEN=$(eval echo $ARRAY_LEN)
                   SERVER_NAME=$(eval "echo \$\{$ARRAY_NAME[$XNUM]\}")
                   SERVER_NAME=$(eval echo $SERVER_NAME)
                   if [ -n "$SERVER_NAME" ] ; then
                      let X=$XNUM+1
                      echo -n "$X (" ; echo ${SRV[$XNUM]}")  - $SERVER_NAME file server"
                   fi
                done
            let X=$X+1
            echo "$X (A/a) - About this script."
            let Y=$X+1
            echo "$Y (C/c) - Code History."
            echo
            echo -n $(tput bold)
            echo -n "Please select letter or 0-$X (0): " ; read CHOICE_SERVER
            echo -n $(tput sgr0)
            echo
            #
            CHOICE_SRV=$CHOICE_SERVER  # Save original choice.
            #
            case $CHOICE_SERVER in
                 0 | [Qq] | "") break ; CHOICE_SERVER=0
                        ;;
                 1 | [Ss]) f_show_mount_points_txt 1 ; CHOICE_SERVER=1
                        ;;
                 $X | [Aa]) f_about_txt ; CHOIC_SERVERE=$X
                        ;;
                 $Y| [Cc]) f_code_history_txt ; CHOICE_SERVER=$Y
                        ;;
                 *) CHOICE_SERVER=-1
                        ;;
            esac
            if [ $CHOICE_SERVER -eq -1 ] ; then 
               ARRAY_NAME="SERVER"
               for (( YNUM=1; YNUM<=${ARRAY_LEN}; YNUM++ ));
               do
                   SERVER_NAME=$(eval "echo \$\{$ARRAY_NAME[$YNUM]\}") # Create command for getting Server Name from array.
                   SERVER_NAME=$(eval echo $SERVER_NAME)               # eval command to get Server Name from array.
                   let X=$YNUM+1                                       # X = menu item number.
                   Y=$(eval echo ${SRV[$YNUM]})                        # Y = 2-letter abbreviation of Server Name.
                   case $CHOICE_SRV in
                        [2-9])
                               if [ $CHOICE_SRV = "$X" ] ; then
                                  YNUM=${ARRAY_LEN}
                                  f_action_menu_txt $SERVER_NAME
                               fi
                               ;; 
                        [1-9][0-9])
                               if [ $CHOICE_SRV = "$X" ] ; then
                                  YNUM=${ARRAY_LEN}
                                  f_action_menu_txt $SERVER_NAME
                               fi
                               ;; 
                        [a-z][a-z])
                               if [ $CHOICE_SRV = "$Y" ] ; then
                                  YNUM=${ARRAY_LEN}
                                  f_action_menu_txt $SERVER_NAME
                               fi
                               ;;
                   esac
               done
            fi
      done
      unset X Y CHOICE CHOICEA XNUM YNUM ARRAY_LEN ARRAY_NAME SERVER_NAME  # Throw out this variable.
} # End of function f_main_menu_txt.
#
# +----------------------------------------+
# |       Function f_action_menu_txt       |
# +----------------------------------------+
#
#  Inputs: $1=Server name.
#    Uses: CHOICE_ACT, ANS XNUM.
# Outputs: SMBUSER="".
#
f_action_menu_txt () {
      CHOICE_ACT=-1
      until [ $CHOICE_ACT = "0" ]
      do
            SMBUSER=""  # Set to null to force entry of a new SMB user name.
            clear # Blank the screen.
            echo -n $(tput bold)
            echo "--- Mount/Dismount $1 Server Menu ---"
            echo -n $(tput sgr0)
            echo
            echo "0 (Q/q) - Quit to previous menu."
            echo "1 (M/m) - Mount   all shared directories."
            echo "2 (D/d) - Disount all shared directories."
            echo "3 (S/s) - Show mounted directories."
            ARRAY_NAME=$1"_DESC"
            ARRAY_LEN=$(eval "echo \$\{#$ARRAY_NAME[@]\}")
            ARRAY_LEN=$(eval echo $ARRAY_LEN)
            for (( XNUM=0; XNUM<=${ARRAY_LEN}; XNUM++ ));
                do
                   MOUNT_POINT_DESC=$(eval "echo \$\{$ARRAY_NAME[$XNUM]\}")
                   MOUNT_POINT_DESC=$(eval echo $MOUNT_POINT_DESC)
                   MOUNT_POINT_DESC=$(echo $MOUNT_POINT_DESC | tr '_' ' ')
                   if [ -n "$MOUNT_POINT_DESC" ] ; then
                      let X=$XNUM+3
                      echo "($X""D/""$X""M) - (Dis)Mount $MOUNT_POINT_DESC"
                   fi
                done
            echo
            echo -n $(tput bold)
            echo -n "Please select letter or 0-$X (0): " ; read CHOICE_ACT
            echo -n $(tput sgr0)
            #
            case $CHOICE_ACT in
                 0 | [Qq] | "") break ; CHOICE_ACT=0
                           ;;
                 1 | [Mm]) f_test_connection $GUI $1
                           if [ $ERROR -eq 0 ] ; then
                              f_mount_or_dismount_all_txt $1 "mount"
                           fi
                           f_show_mount_points_txt 1
                           CHOICE_ACT=1
                           ;;
                 2 | [Dd]) f_test_connection $GUI $1
                           if [ $ERROR -eq 0 ] ; then
                              f_mount_or_dismount_all_txt $1 "dismount"
                           fi
                           f_show_mount_points_txt 1
                           CHOICE_ACT=2
                           ;;
                 3 | [Ss]) f_show_mount_points_txt 1
                           CHOICE_ACT=3
                           ;;
                   [4-9][Mm] | [1-9][0-9][Mm]) 
                           XNUM=$(echo $CHOICE_ACT |  tr -d 'Mm')  # Strip off trailing "M" or "m".
                           CHOICE_ACT=$XNUM
                           let XNUM=XNUM-3
                           SP=$(eval echo "\$\{$1_SP[$XNUM]\}")   # Create command "${<server_name>_SP[$NUM]}" to read string of Shared directory      from array <Server name>_SP[n].
                           SP=$(eval echo $SP)
                           MP=$(eval echo "\$\{$1_MP[$XNUM]\}")   # Create command "${<server_name>_MP[$NUM]}" to read string of Mount-point directory from array <Server name>_MP[n].
                           MP=$(eval echo $MP)
                           f_mount_txt $SP $MP
                           f_show_mount_points_txt 1
                           ;;
                   [4-9][Dd] | [1-9][0-9][Dd])
                           XNUM=$(echo $CHOICE_ACT |  tr -d 'Dd')  # Strip off trailing "D" or "d".
                           CHOICE_ACT=$XNUM
                           let XNUM=XNUM-3
                           MP=$(eval echo "\$\{$1_MP[$XNUM]\}")   # Create command "${<server_name>_MP[$NUM]}" to read string of Mount-point directory from array <Server name>_MP[n].
                           MP=$(eval echo $MP)
                           f_dismount_txt $MP
                           f_show_mount_points_txt 1
                           ;;
            esac
      done
      unset CHOICE_ACT ANS XNUM # Throw out this variable.
} # End of function f_action_menu_txt.
#
# **************************************
# ***     Start of Main Program      ***
# **************************************
#
# If an error occurs, the f_abort_txt() function will be called.
# trap 'f_abort_txt' 0
# set -e
#
clear  # Blank the screen.
#
SUDO_ASKPASS="sudoask" ; export SUDO_ASKPASS
#
# Test for BASH environment.
f_test_environment
#
# Test for GUI (Whiptail or Dialog) or pure text environment.
f_detect_ui
#
# Set SCRIPT_PATH to directory path of script.
f_script_path
MAINMENU_DIR=$SCRIPT_PATH
THIS_DIR=$MAINMENU_DIR  # Set $THIS_DIR to location of Main Menu.
#
f_server_arrays
#
GUI="text"      # Diagnostic line. Force plain text w/o GUI for testing purposes.
# GUI="whiptail"  # Diagnostic line. Force whiptail GUI for testing purposes.
# GUI="dialog"    # Diagnostic line. Force dialog GUI for testing purposes.
#
# **************************************
# ***           Main Menu            ***
# **************************************
case $GUI in
     text)
     f_main_menu_txt
     clear   # Blank the screen.
     f_show_mount_points_txt 0  # Display mount-points status.
     #
     ;;
esac
#
# Clean-up and delete $TEMP_FILE before exiting.
if [ -r $TEMP_FILE ] ; then
   rm $TEMP_FILE
fi
unset GUI SERVER  # Throw out this variable.
exit 0  # This cleanly closes the process generated by #!bin/bash. 
        # Otherwise every time this script is run, another instance of
        # process /bin/bash is created using up resources.
# all dun dun noodles.
