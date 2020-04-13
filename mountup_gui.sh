#!/bin/bash
#
# ©2020 Copyright 2020 Robert D. Chin
#
# Usage: bash mountup_gui.sh
#        (not sh mountup_gui.sh)
#
# +----------------------------------------+
# |        Default Variable Values         |
# +----------------------------------------+
#
VERSION="2020-04-13 01:42"
THIS_FILE="mountup_gui.sh"
#
# +----------------------------------------+
# |            Brief Description           |
# +----------------------------------------+
#
#@ Brief Description
#@
#@ This script will mount shared cifs (Samba) directories from one or more
#@ file servers. The shared (Samba) directories will be mounted on the
#@ corresponding mount-points (directories) on the Local PC.
#@
#@ To add more file server names, share-points with corresponding
#@ mount-points, edit the text at the end of function f_server_arrays.
#@ Format: <DELIMITER>//<Source File Server>/<Shared directory><DELIMITER>
#@        /<Mount-point on local PC>
#@
#@ Required scripts: mountup_lib_gui.lib.
#@
#@ Usage: bash mountup_gui.sh
#@        (not sh mountup_gui.sh)
#@
#@ After each edit made, please update Code History and VERSION.
#
# +----------------------------------------+
# |             Help and Usage             |
# +----------------------------------------+
#
#? Usage: bash mountup_gui.sh [OPTION]
#? Examples:
#?
#?bash mountup_gui.sh dialog     # Use Dialog   user-interface
#?                    whiptail   # Use Whiptail user-interface
#?
#?bash mountup_gui.sh --help     # Displays this help message.
#?                    -?
#?
#?bash mountup_gui.sh --about    # Displays script version.
#?                    --version
#?                    --ver
#?                    -v
#?
#?bash mountup_gui.sh --history  # Displays script code history.
#?                    --hist
#
# +----------------------------------------+
# |           Code Change History          |
# +----------------------------------------+
#
## Code Change History
##
## 2020-04-13 *Combine mountup_gui.sh with mountup.sh into a single script.
##            *Cleanup code and documentation.
##
## 2020-04-06 *Rewritten to be more Whiptail compatible.
##            *f_message, f_arguments, f_help_message added.
##
## 2017-12-26 *Changed conditions script-wide so that if asked for username
##             or password and the "Cancel" button is selected, then 
##             exit out completely from that menu choice.
##
## 2017-12-25 *Function f_mount_or_dismount_all_gui added call to ask
##             for password. It used to just ask for user name.
##             Old behavior allowed for anonymous mounts first, and if any
##             mounting failed, then it would ask for a password.
##             New behavior asks for both user name and password upfront.  
##
## 2017-11-23 *f_username_gui prevented a null username.
##            *f_test_mount_gui changed when to ask for a username/password.
##            *f_pick_menu_gui added username dialog.
##            Deleted any trailing <spaces> in the source code.
##
## 2017-11-17 *f_mount_gui2 improved clarity of error message.
##
## 2017-09-19 *f_mount_gui removed checks for SMB username, password.
##            *f_mount_or_dismount_all_gui bug fix for SMB username.
##            *f_test_mount_gui added checks for SMB username, password.
##            *f_pick_match added checks for SMB username, password.
##
## 2017-04-20 *mountup_gui.sh added f_detect_ui and check if the file exists
##             and is readable, mountup_lib_gui.lib. Cleaned up comments.
##
## 2017-01-07 *f_action_menu_gui bug fixed, check network connection when
##             choosing menu item "Pick" mount-points.
##
## 2017-01-04 *f_mount_gui added call to f_username_gui to enter
##             SMB username.
##            *f_show_mount_points_gui added display username with
##             mount-point.
##
## 2016-08-03 *mountup_gui.sh remove $GENERATED_FILE if it exists.
##
## 2016-05-25 *mountup_lib_gui.lib changed to use Dialog's checklist.
##             It will now cycle through the entire array of share-points
##             one by one and if needed mount/dismount each one at a time.
##            *mountup_update_gui.sh now calls mountup_gui.sh so that the
##             arrays of servers, share/mountpoints are refreshed before
##             (dis)mounting of any share-points.
##            *mountup_gui.sh can still be run by itself if there are
##             changes in the list of file servers (no additions/deletions).
##
## 2016-05-05 *Script works but after (dis)mounting it returns to Main Menu
##             which is annoying.
##            *I tried to force the script flow so that if (dis)mounting in
##             the sub-menu then force it not display the Main Menu again
##             but instead simply regenerate the sub-menu and re-display it.
##            *Unfortunately I could not force it so once any selection in
##             the sub-menu is made, script flow exits to the Main Menu
##             which I found annoying.
##            *The complexity of this script is because the sub-menu is
##             dynamic and changes whenever a server share-point is
##             (dis)mounted and so the Dialog menu code must be regenerated.
##            *Script mountup_update_gui.sh generates script mountup_gui.sh
##             and should be run as new servers need to be added to the
##             Main Menu.
##            *Made script mountup_gui.sh generate script mountup_gui2.sh
##             where mountup_gui.sh displays the Main Menu while
##             mountup_gui2.sh displays the sub-menu (Dis)Mount Menu.
##
## 2016-05-01 *Script allows any number of shared directories.
##            *Script now has a fully extensible Main Menu with menu items
##             easily added in comment lines beginning with "##@".
##            *Script now has a fully extensible directory sub-menu with
##             menu items easily added in comment lines beginning with "##@".
##            *These scripts are together:
##             mountup_lib_gui.lib provides functions used by other scripts.
##             mountup_update_gui.sh generates and updates mountup_gui.sh.
##             mountup_update_gui.sh is the actual Server Menu.
##
## 2016-03-31 *Posted on GitHub.com as a template.
##
## 2016-03-25 *Rearranged functions as common, text, gui, and main program.
##
## 2016-03-02 *f_mount_all_gui_2, f_mount_gui if mount fails either try
##             again or abort mounting all remaining mount-points.
##
## 2016-02-09 *f_code_history_gui allow maximized textbox.
##
## 2015-12-24 *f_mount_text added a mount command with no option -o password
##             for Raspberry Pi Model 1.
##
## 2015-12-21 *f_mount_gui added a mount command with no option -o password
##             for Raspberry Pi Model 1.
##
## 2015-12-01 *Created new script. Based this script on script, peapodup.sh
##             which (dis)mounted one or more shared directories on a server.
##            *(Dis)mount all shared directories of any given file-server.
#
# +----------------------------------------+
# |         Function f_arguments           |
# +----------------------------------------+
#
#  Inputs: $1=Argument
#             [--help] [ -? ]
#             [--about]
#             [--version] [ --ver ] [ -v ]
#             [--history] [ --hist ]
#             [ text ] [ dialog ] [ whiptail ]
#    Uses: None.
# Outputs: ERROR.
#
f_arguments () {
      # If there is more than one argument, display help USAGE message, because only one argument is allowed.
      if [ $# -ge 2 ] ; then
         f_help_message text
         exit 0  # This cleanly closes the process generated by #!bin/bash. 
                 # Otherwise every time this script is run, another instance of
                 # process /bin/bash is created using up resources.
      fi
      #
      case $1 in
           --help | "-?")
           # If the one argument is "--help" display help USAGE message.
           f_help_message text
           exit 0  # This cleanly closes the process generated by #!bin/bash. 
                   # Otherwise every time this script is run, another instance of
                   # process /bin/bash is created using up resources.
           ;;
           --about | --version | --ver | -v)
           f_about text
           exit 0  # This cleanly closes the process generated by #!bin/bash. 
                   # Otherwise every time this script is run, another instance of
                   # process /bin/bash is created using up resources.
           ;;
           --history | --hist)
           f_code_history text
           exit 0  # This cleanly closes the process generated by #!bin/bash. 
                   # Otherwise every time this script is run, another instance of
                   # process /bin/bash is created using up resources.
           ;;
           -*)
           # If the one argument is "-<unrecognized>" display help USAGE message.
           f_help_message text
           exit 0  # This cleanly closes the process generated by #!bin/bash. 
                   # Otherwise every time this script is run, another instance of
                   # process /bin/bash is created using up resources.
           ;;
           "" | "text" | "dialog" | "whiptail")
           GUI=$1
           ;;
           *)
           # Display help USAGE message.
           f_help_message text
           exit 0  # This cleanly closes the process generated by #!bin/bash. 
                   # Otherwise every time this script is run, another instance of
                   # process /bin/bash is created using up resources.
           ;;
      esac
}  # End of function f_arguments.
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
# Outputs: SCRIPT_PATH, THIS_DIR.
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
      THIS_DIR=$SCRIPT_PATH  # Set $THIS_DIR to location of this script.

} # End of function f_script_path.
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
      f_test_dash
} # End of function f_test_environment.
#
# +----------------------------------------+
# |          Function f_test_dash          |
# +----------------------------------------+
#
#  Inputs: $1=GUI - "text", "dialog" or "whiptail" the preferred user-interface.
#          $BASH_VERSION (System variable), GUI.
#    Uses: None.
# Outputs: exit 1.
#
f_test_dash () {
      #
      if [ -z "$BASH_VERSION" ]; then 
         # DASH Environment detected, display error message 
         # to invoke the BASH environment.
         f_detect_ui # Automatically detect UI environment.
         #
         TEMP_FILE=$THIS_FILE"_temp.txt"
         #
         clear  # Blank the screen.
         #
         f_message $1 "OK" ">>> Warning: Must use BASH <<<" "\n                   You are using the DASH environment.\n\n        *** This script cannot be run in the DASH environment. ***\n\n    Ubuntu and Linux Mint default to DASH but also have BASH available."
         f_message $1 "OK" "HOW-TO" "\n  You can invoke the BASH environment by typing:\n    \"bash $THIS_FILE\"\nat the command line prompt (without the quotation marks).\n\n          >>> Now exiting script <<<"
         #
         f_abort text
      fi
} # End of function f_test_dash
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
#
# +----------------------------------------+
# |              Function f_abort          |
# +----------------------------------------+
#
#  Inputs: $1=GUI.
#    Uses: None.
# Outputs: None.
#
f_abort () {
      #
      case $1 in
           dialog | whiptail)
           # Temporary file has \Z commands embedded for red bold font.
           #
           # \Z commands are used by Dialog to change font attributes 
           # such as color, bold/normal.
           #
           # A single string is used with echo -e \Z1\Zb\Zn commands
           # and output as a single line of string wit \Zn commands embedded.
           #
           # Single string is neccessary because \Z commands will not be
           # recognized in a temp file containing <CR><LF> multiple lines also.
           #
           #f_message $1 "NOK" "Exiting script" " \n\Z1\ZbFATAL ERROR\n \n \nAn error occurred, cannot continue.\n Exiting script.\Zn"
           f_message $1 "NOK" "Exiting script" " \n\Z1\ZbAn error occurred, cannot continue. Exiting script.\Zn"
           ;;
           *)
           # The only reason to have a separate message for GUI=text, is for red color fonts.
           echo $(tput setaf 1)    # Set font to color red.
           echo -n $(tput bold)
           f_message $1 "NOK" "Exiting Script" ">>>FATAL ERROR<<<\n \nAn error occurred, cannot continue.\n Exiting script."
           echo -n $(tput sgr0)    # Set font to normal color.
           ;;
      esac
      exit 1
} # End of function f_abort.
#
# +------------------------------------+
# |          Function f_about          |
# +------------------------------------+
#
#  Inputs: $1=GUI - "text", "dialog" or "whiptail" the preferred user-interface.
#          THIS_FILE, VERSION.
#    Uses: None.
# Outputs: None.
#
f_about () {
      #
      # Need to define $THIS_FILE since this function may be called from other scripts/libraries
      # which may have redefined $THIS_FILE as their file name.
      THIS_FILE="mountup_gui.sh"
      #
      TEMP_FILE=$THIS_FILE"_temp.txt"
      echo "Script: $THIS_FILE. Version: $VERSION" >$TEMP_FILE
      echo >>$TEMP_FILE
      #
      # Display text (all lines beginning with "#@" but do not print "#@").
      # sed substitutes null for "#@" at the beginning of each line
      # so it is not printed.
      sed -n 's/^#@//'p $THIS_DIR/$THIS_FILE >> $TEMP_FILE
      #
      f_message $1 "OK" "About $THIS_FILE (use arrow keys to scroll up/down/side-ways)" $TEMP_FILE
      #
} # End of f_about.
#
# +------------------------------------+
# |      Function f_code_history       |
# +------------------------------------+
#
#  Inputs: $1=GUI - "text", "dialog" or "whiptail" the preferred user-interface.
#          THIS_FILE, VERSION.
#    Uses: None.
# Outputs: None.
#
f_code_history () {
      #
      # Need to define $THIS_FILE since this function may be called from other scripts/libraries
      # which may have redefined $THIS_FILE as their file name.
      THIS_FILE="mountup_gui.sh"
      #
      TEMP_FILE=$THIS_FILE"_temp.txt"
      f_script_path
      echo "Script: $THIS_FILE. Version: $VERSION" >$TEMP_FILE
      echo >>$TEMP_FILE
      #
      # Display text (all lines beginning with "##" but do not print "##").
      # sed substitutes null for "##" at the beginning of each line
      # so it is not printed.
      sed -n 's/^##//'p $THIS_DIR/$THIS_FILE >>$TEMP_FILE
      #
      f_message $1 "OK" "Code History (use arrow keys to scroll up/down/side-ways)" $TEMP_FILE
      #
} # End of function f_code_history.
#
# +------------------------------------+
# |      Function f_help_message       |
# +------------------------------------+
#
#  Inputs: $1=GUI - "text", "dialog" or "whiptail" the preferred user-interface.
#    Uses: None.
# Outputs: None.
#
f_help_message () {
      #
      # Need to define $THIS_FILE since this function may be called from other scripts/libraries
      # which may have redefined $THIS_FILE as their file name.
      THIS_FILE="mountup_gui.sh"
      #
      TEMP_FILE=$THIS_FILE"_temp.txt"
      echo "Script: $THIS_FILE. Version: $VERSION" >$TEMP_FILE
      echo >>$TEMP_FILE
      #
      # Display text (all lines beginning with "#?" but do not print "#?").
      # sed substitutes null for "#?" at the beginning of each line
      # so it is not printed.
      sed -n 's/^#?//'p $THIS_DIR/$THIS_FILE >> $TEMP_FILE
      #
      f_message $1 "OK" "$THIS_FILE Usage (use arrow keys to scroll up/down/side-ways)" $TEMP_FILE
      #
} # End of f_help_message.
#
# +------------------------------+
# |       Function f_message     |
# +------------------------------+
#
#  Inputs: $1 - "text", "dialog" or "whiptail" The CLI GUI application in use.
#          $2 - "OK"  [OK] button at end of text.
#               "NOK" No [OK] button at end of text but pause n seconds
#                     to allow reader to read text by using sleep n command.
#          $3 - Title.
#          $4 - Text string or text file. 
#          
#    Uses: None.
# Outputs: ERROR. 
#
f_message () {
      #
      case $1 in
           "dialog" | "whiptail")
              # Dialog boxes "--msgbox" "--infobox" can use option --colors with "\Z" commands for font color bold/normal.
              # Dialog box "--textbox" and Whiptail cannot use option --colors with "\Z" commands for font color bold/normal.
              #
              # If text strings have Dialog "\Z" commands for font color bold/normal, 
              # they must be used AFTER \n (line break) commands.
              # Example: "This is a test.\n\Z1\ZbThis is in bold-red letters.\n\ZnThis is in normal font."
              #
              # Get the screen resolution or X-window size.
              # Get rows (height).
              YSCREEN=$(stty size | awk '{ print $1 }')
              # Get columns (width).
              XSCREEN=$(stty size | awk '{ print $2 }')
              #
              # Is $4 a text string or a text file?
              if [ -r "$4" ] ; then
                 # If $4 is a text file.
                 #
                 # If text file, calculate number of lines and length of sentences.
                 # to calculate height and width of Dialog box.
                 #
                 # Calculate longest line length in TEMP_FILE to find maximum menu width for Dialog or Whiptail.
                 # The "Word Count" wc command output will not include the TEMP_FILE name
                 # if you redirect "<$TEMP_FILE" into wc.
                 X=$(wc --max-line-length <$4)
                 #
                 # Calculate number of lines or Menu Choices to find maximum menu lines for Dialog or Whiptail.
                 Y=$(wc --lines <$4)
                 #
                 if [ "$2" = "OK" ] ; then
                    # $4 is a text file.
                    #If $2 is "OK" then use a Dialog/Whiptail textbox.
                    #
                    case $1 in
                         dialog)
                            # Dialog needs about 6 more lines for the header and [OK] button.
                            let Y=Y+6
                            # If number of lines exceeds screen/window height then set textbox height.
                            if [ $Y -ge $YSCREEN ] ; then
                               Y=$YSCREEN
                            fi
                            #
                            # Dialog needs about 10 more spaces for the right and left window frame. 
                            let X=X+10
                            # If line length exceeds screen/window width then set textbox width.
                            if [ $X -ge $XSCREEN ] ; then
                               X=$XSCREEN
                            fi
                            #
                            # Dialog box "--textbox" and Whiptail cannot use "\Z" commands.
                            # No --colors option for Dialog --textbox.
                            dialog --title "$3" --textbox "$4" $Y $X
                         ;;
                         whiptail)
                            # Whiptail needs about 7 more lines for the header and [OK] button.
                            let Y=Y+7
                            # If number of lines exceeds screen/window height then set textbox height.
                            if [ $Y -ge $YSCREEN ] ; then
                               Y=$YSCREEN
                            fi
                            #
                            # Whiptail needs about 5 more spaces for the right and left window frame. 
                            let X=X+5
                            # If line length exceeds screen/window width then set textbox width.
                            if [ $X -ge $XSCREEN ] ; then
                               X=$XSCREEN
                            fi
                            #
                            # Whiptail does not have option "--colors" with "\Z" commands for font color bold/normal.
                            whiptail --scrolltext --title "$3" --textbox "$4" $Y $X
                         ;;
                    esac
                    #
                 else
                    # $4 is a text file.
                    # If $2 is "NOK" then use a Dialog infobox or Whiptail textbox.
                    case $1 in
                         dialog)
                            # Dialog needs about 6 more lines for the header and [OK] button.
                            let Y=Y+6
                            # If number of lines exceeds screen/window height then set textbox height.
                            if [ $Y -ge $YSCREEN ] ; then
                               Y=$YSCREEN
                            fi
                            #
                            # Dialog needs about 10 more spaces for the right and left window frame. 
                            let X=X+10
                            # If line length exceeds screen/window width then set textbox width.
                            if [ $X -ge $XSCREEN ] ; then
                               X=$XSCREEN
                            fi
                            #
                            # Dialog boxes "--msgbox" "--infobox" can use option --colors with "\Z" commands for font color bold/normal.
                            dialog --colors --title "$3" --infobox "$Z" $Y $X ; sleep 3
                         ;;
                         whiptail)
                            # Whiptail only has options --textbox or --msgbox (not --infobox).
                            # Whiptail does not have option "--colors" with "\Z" commands for font color bold/normal.
                            #
                            # Whiptail needs about 7 more lines for the header and [OK] button.
                            let Y=Y+7
                            # If number of lines exceeds screen/window height then set textbox height.
                            if [ $Y -ge $YSCREEN ] ; then
                               Y=$YSCREEN
                            fi
                            #
                            # Whiptail needs about 5 more spaces for the right and left window frame. 
                            let X=X+5
                            # If line length exceeds screen/window width then set textbox width.
                            if [ $X -ge $XSCREEN ] ; then
                               X=$XSCREEN
                            fi
                            whiptail --title "$3" --textbox "$4" $Y $X
                         ;;
                    esac
                 fi
                 #
                 if [ -r $TEMP_FILE ] ; then
                    rm $TEMP_FILE
                 fi
                 #
              else
                 # If $4 is a text string.
                 #
                 # Does $4 contain "\n"?  Does the string $4 contain multiple sentences?
                 case $4 in
                      *\n*)
                         # Yes, string $4 contains multiple sentences.
                         #
                         # Use command "sed" with "-e" to filter out multiple "\Z" commands.
                         # Filter out "\Z[0-7]", "\Zb", \ZB", "\Zr", "\ZR", "\Zu", "\ZU", "\Zn".
                         ZNO=$(echo $4 | sed -e 's|\\Z0||g' -e 's|\\Z1||g' -e 's|\\Z2||g' -e 's|\\Z3||g' -e 's|\\Z4||g' -e 's|\\Z5||g' -e 's|\\Z6||g' -e 's|\\Z7||g' -e 's|\\Zb||g' -e 's|\\ZB||g' -e 's|\\Zr||g' -e 's|\\ZR||g' -e 's|\\Zu||g' -e 's|\\ZU||g' -e 's|\\Zn||g')
                         # Calculate the length of the longest sentence with the $4 string.
                         # How many sentences?
                         # Replace "\n" with "%" and then use awk to count how many sentences.
                         # Save number of sentences.
                         Y=$(echo $ZNO | sed 's|\\n|%|g'| awk -F '%' '{print NF}')
                         #
                         # Extract each sentence
                         # Replace "\n" with "%" and then use awk to print current sentence.
                         TEMP_FILE=$THIS_FILE"_temp.txt"
                         echo -e $ZNO > $TEMP_FILE
                         # This is the long way... echo $ZNO | sed 's|\\n|%|g'| awk -F "%" '{ for (i=1; i<NF+1; i=i+1) print $i }' >$TEMP_FILE
                         # Calculate longest line length in TEMP_FILE to find maximum menu width for Dialog or Whiptail.
                         # The "Word Count" wc command output will not include the TEMP_FILE name
                         # if you redirect "<$TEMP_FILE" into wc.
                         X=$(wc --max-line-length < $TEMP_FILE)
                      ;;
                      *)
                         # No, line length is $4 string length. 
                         X=$(echo -n "$4" | wc -c)
                         Y=1
                      ;;
                 esac
                 #
                 if [ "$2" = "OK" ] ; then
                    # $4 is a text string.
                    # If $2 is "OK" then use a Dialog/Whiptail msgbox.
                    #
                    # Calculate line length of $4 if it contains "\n" <new line> markers.
                    # Find length of all sentences delimited by "\n"
                    #
                    case $1 in
                         dialog)
                            # Dialog needs about 5 more lines for the header and [OK] button.
                            let Y=Y+5
                            # If number of lines exceeds screen/window height then set textbox height.
                            if [ $Y -ge $YSCREEN ] ; then
                               Y=$YSCREEN
                            fi
                            #
                            # Dialog needs about 10 more spaces for the right and left window frame. 
                            let X=X+10
                            # If line length exceeds screen/window width then set textbox width.
                            if [ $X -ge $XSCREEN ] ; then
                               X=$XSCREEN
                            fi
                            #
                            # Dialog boxes "--msgbox" "--infobox" can use option --colors with "\Z" commands for font color bold/normal.
                            dialog --colors --title "$3" --msgbox "$4" $Y $X
                         ;;
                         whiptail)
                            # Whiptail only has options --textbox or--msgbox (not --infobox).
                            # Whiptail does not have option "--colors" with "\Z" commands for font color bold/normal.
                            # Filter out any "\Z" commands when using the same string for both Dialog and Whiptail.
                            # Use command "sed" with "-e" to filter out multiple "\Z" commands.
                            # Filter out "\Z[0-7]", "\Zb", \ZB", "\Zr", "\ZR", "\Zu", "\ZU", "\Zn".
                            ZNO=$(echo $4 | sed -e 's|\\Z0||g' -e 's|\\Z1||g' -e 's|\\Z2||g' -e 's|\\Z3||g' -e 's|\\Z4||g' -e 's|\\Z5||g' -e 's|\\Z6||g' -e 's|\\Z7||g' -e 's|\\Zb||g' -e 's|\\ZB||g' -e 's|\\Zr||g' -e 's|\\ZR||g' -e 's|\\Zu||g' -e 's|\\ZU||g' -e 's|\\Zn||g')
                            #
                            # Whiptail needs about 6 more lines for the header and [OK] button.
                            let Y=Y+6
                            # If number of lines exceeds screen/window height then set textbox height.
                            if [ $Y -ge $YSCREEN ] ; then
                               Y=$YSCREEN
                            fi
                            #
                            # Whiptail needs about 5 more spaces for the right and left window frame. 
                            let X=X+5
                            # If line length exceeds screen/window width then set textbox width.
                            if [ $X -ge $XSCREEN ] ; then
                               X=$XSCREEN
                            fi
                            #
                            whiptail --title "$3" --msgbox "$ZNO" $Y $X
                         ;;
                    esac
                 else
                    # $4 is a text string.
                    # If $2 in "NOK" then use a Dialog infobox or Whiptail msgbox.
                    #
                    case $1 in
                         dialog)
                            # Dialog boxes "--msgbox" "--infobox" can use option --colors with "\Z" commands for font color bold/normal.
                            # Dialog needs about 5 more lines for the header and [OK] button.
                            let Y=Y+5
                            # If number of lines exceeds screen/window height then set textbox height.
                            if [ $Y -ge $YSCREEN ] ; then
                               Y=$YSCREEN
                            fi
                            #
                            # Dialog needs about 10 more spaces for the right and left window frame. 
                            let X=X+6
                            # If line length exceeds screen/window width then set textbox width.
                            if [ $X -ge $XSCREEN ] ; then
                               X=$XSCREEN
                            fi
                            #
                            dialog --colors --title "$3" --infobox "$4" $Y $X ; sleep 3
                         ;;
                         whiptail)
                            # Whiptail only has options --textbox or--msgbox (not --infobox).
                            # Whiptail does not have option "--colors" with "\Z" commands for font color bold/normal.
                            # Filter out any "\Z" commands when using the same string for both Dialog and Whiptail.
                            # Use command "sed" with "-e" to filter out multiple "\Z" commands.
                            # Filter out "\Z[0-7]", "\Zb", \ZB", "\Zr", "\ZR", "\Zu", "\ZU", "\Zn".
                            ZNO=$(echo $4 | sed -e 's|\\Z0||g' -e 's|\\Z1||g' -e 's|\\Z2||g' -e 's|\\Z3||g' -e 's|\\Z4||g' -e 's|\\Z5||g' -e 's|\\Z6||g' -e 's|\\Z7||g' -e 's|\\Zb||g' -e 's|\\ZB||g' -e 's|\\Zr||g' -e 's|\\ZR||g' -e 's|\\Zu||g' -e 's|\\ZU||g' -e 's|\\Zn||g')
                            #
                            # Whiptail needs about 6 more lines for the header and [OK] button.
                            let Y=Y+6
                            # If number of lines exceeds screen/window height then set textbox height.
                            if [ $Y -ge $YSCREEN ] ; then
                               Y=$YSCREEN
                            fi
                            #
                            # Whiptail needs about 5 more spaces for the right and left window frame. 
                            let X=X+5
                            # If line length exceeds screen/window width then set textbox width.
                            if [ $X -ge $XSCREEN ] ; then
                               X=$XSCREEN
                            fi
                            #
                            whiptail --title "$3" --msgbox "$ZNO" $Y $X
                         ;;
                     esac
                  fi
              fi
              ;;
           *)
              # Text only
              #Is $4 a text string or a text file?
              #
              if [ -r "$4" ] ; then
                 # If $4 is a text file.
                 #
                 if [ "$2" = "OK" ] ; then
                    # If $2 is "OK" then use command "less".
                    #
                    clear  # Blank the screen.
                    #
                    # Display text file contents.
                    less -P '%P\% (Spacebar, PgUp/PgDn, Up/Dn arrows, press q to quit)' $4
                    #
                    clear  # Blank the screen.
                    #
                 else
                    # If $2 is "NOK" then use "cat" and "sleep" commands to give time to read it.
                    #
                    clear  # Blank the screen.
                    # Display title.
                    echo
                    echo $3
                    echo
                    echo
                    # Display text file contents.
                    cat $4
                    sleep 5
                    #
                    clear  # Blank the screen.
                    #
                 fi
                 #
                 if [ -r $TEMP_FILE ] ; then
                    rm $TEMP_FILE
                 fi
                 #
              else
                 # If $4 is a text string.
                 #
                 if [ "$2" = "OK" ] ; then
                    # If $2 is "OK" then use f_press_enter_key_to_continue.
                    #
                    clear  # Blank the screen.
                    #
                    # Display title.
                    echo
                    echo -e $3
                    echo
                    echo
                    # Display text file contents.
                    echo -e $4
                    echo
                    f_press_enter_key_to_continue
                    #
                    clear  # Blank the screen.
                    #
                 else
                    # If $2 is "NOK" then use "echo" followed by "sleep" commands
                    # to give time to read it.
                    #
                    clear  # Blank the screen.
                    #
                    # Display title.
                    echo
                    echo -e $3
                    echo
                    echo
                    # Display text file contents.
                    echo -e $4
                    echo
                    echo
                    sleep 5
                    #
                    clear  # Blank the screen.
                    #
                 fi
              fi
           ;;
      esac
} # End of function f_message.
#
# **************************************
# ***     Start of Main Program      ***
# **************************************
#
clear  # Clear screen.
#
# If an error occurs, the f_abort_txt() function will be called.
# trap 'f_abort_txt' 0
# set -e
#
if [ -r mountup_lib_gui.lib ] ; then  # Does library file exist and is readable in the same directory as this script.
   . mountup_lib_gui.lib  # Invoke library.
   THIS_FILE="mountup_gui.sh"
else
   f_message $GUI "OK" "Missing a required file" "Missing a required file: \"mountup_lib_gui.lib\" from this directory.\n\n                    *** Aborting program ***"
   #$GUI --infobox "Missing a required file: \"mountup_lib_gui.lib\" from this directory.\n\n                    *** Aborting program ***" 5 71
   exit 0  # This cleanly closes the process generated by #!bin/bash. 
           # Otherwise every time this script is run, another instance of
           # process /bin/bash is created using up resources.
fi
#
# Set THIS_DIR, SCRIPT_PATH to directory path of script.
f_script_path
MAINMENU_DIR=$SCRIPT_PATH
#
# Test for Optional Arguments.
f_arguments $1  # Also sets variable GUI.
#
# If command already specifies GUI, then do not detect GUI i.e. "bash mountup_gui.sh dialog" or "bash mountup_gui.sh whiptail".
if [ -z $GUI ] ; then
   # Test for GUI (Whiptail or Dialog) or pure text environment.
   f_detect_ui
fi
#
#GUI="whiptail"  # Diagnostic line.
#GUI="dialog"    # Diagnostic line.
#GUI="text"      # Diagnostic line.
#
# Test for BASH environment.
f_test_environment
#
GENERATED_FILE="mountup_server_menu_gui.lib"
f_server_arrays
#
# The value of $MENU_TITLE determines which menu to display for Dialog/Whiptail.
# If $MENU_TITLE="Main_Menu" then [OK] button only or any other title then [OK] or [Cancel] buttons.
MENU_TITLE="Main_Menu"
case $GUI in
     dialog | whiptail)
        f_update_menu $GUI $GENERATED_FILE $MENU_TITLE $MAX_LENGTH $MAX_LINES
        . $GENERATED_FILE  # Invoke Generated file.
        # Function "f_server_menu_gui" is in $GENERATED_FILE.
        f_server_menu $GUI
     ;;
     text)
        f_main_menu_txt
        #
        clear   # Blank the screen.
        #
        f_show_mount_points_txt 0  # Display mount-points status.
     ;;
esac
#
if [ -r $GENERATED_FILE ] ; then
   rm $GENERATED_FILE
fi
#
clear  # Blank the screen.
#
exit 0  # This cleanly closes the process generated by #!bin/bash. 
        # Otherwise every time this script is run, another instance of
        # process /bin/bash is created using up resources.
# all dun dun noodles.
