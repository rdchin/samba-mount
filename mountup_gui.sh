#!/bin/bash
#
# Usage: bash mountup_gui.sh
#        (not sh mountup_gui.sh)
#
# +----------------------------------------+
# |        Default Variable Values         |
# +----------------------------------------+
#
VERSION="2020-04-06 01:13"
THIS_FILE="mountup_gui.sh"
#
#@ Brief Description
#@
#@ Usage: "bash mountup_gui.sh [SERVER NAME]
#@
#@        Server name is optional, if given, then attempt to mount
#@        all share-points on that server.
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
#@ After each edit made, please update Code History and VERSION.
#
#? Usage: bash mountup_gui.sh [OPTION]
#?
#?        bash mountup_gui.sh dialog     # Use Dialog   user-interface
#?        bash mountup_gui.sh whiptail   # Use Whiptail user-interface
#?        bash mountup_gui.sh --help     # Displays this help message.
#?        bash mountup_gui.sh --version  # Displays script version."
#?        bash mountup_gui.sh --about    # Displays script version.
#?        bash mountup_gui.sh --history  # Displays script code history.
#
## Code Change History
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
#             [--help] [ --? ] [ -? ] [ ? ]
#             [--about]
#             [--version] [ -ver ] [ -v ]
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
           --help | "--?" | "-?" | "?")
           # If the one argument is "--help" display help USAGE message.
           f_help_message text
           exit 0  # This cleanly closes the process generated by #!bin/bash. 
                   # Otherwise every time this script is run, another instance of
                   # process /bin/bash is created using up resources.
           ;;
           -v | -ver | --version | --about)
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
      if [ -z "$BASH_VERSION" ]; then 
         # DASH Environment detected, display error message 
         # to invoke the BASH environment.
         f_detect_ui # Automatically detect UI environment.
         case $GUI in
              dialog | whiptail)
              f_test_dash_gui $GUI
              ;;
              text)
              f_test_dash_txt
              ;;
         esac
         exit 1 # Exit with value $?=1 indicating an error condition
                # and stop running script.
      fi
} # End of function f_test_dash
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
         clear  # Clear screen.
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
         f_abort text
      fi
} # End of function f_test_dash_txt.
#
# +----------------------------------------+
# |        Function f_test_dash_gui        |
# +----------------------------------------+
#
#  Inputs: $1=GUI - "dialog", "whiptail" the preferred user-interface.
#    Uses: None.
# Outputs: None.
#
f_test_dash_gui () {
      #
      clear  # Blank the screen.
      #
      f_message $1 "OK" ">>> Warning: Must use BASH <<<" "\n                   You are using the DASH environment.\n\n        *** This script cannot be run in the DASH environment. ***\n\n    Ubuntu and Linux Mint default to DASH but also have BASH available."
      #$1 --title ">>> Warning: Must use BASH <<<" --msgbox "\n                   You are using the DASH environment.\n\n        *** This script cannot be run in the DASH environment. ***\n\n    Ubuntu and Linux Mint default to DASH but also have BASH available." 12 78
      #
      f_message $1 "OK" "HOW-TO" "\n  You can invoke the BASH environment by typing:\n    \"bash cliappmenu.sh\" at the command line.\n\n          >>> Now exiting script <<<"
      #$1 --title "HOW-TO" --msgbox "\n  You can invoke the BASH environment by typing:\n    \"bash cliappmenu.sh\" at the command line.\n\n          >>> Now exiting script <<<" 12 55
} # End of function f_test_dash_gui
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
           dialog)
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
           # Create temporary file containing message.
           TEMP_FILE="$THIS_FILE_temp_file.txt"
           echo -e "\n\Z1\Zb                          ***************\n                          *** ABORTED ***\n                          ***************\n\n\n        An error occurred, cannot continue. Exiting script.\Zn" > $TEMP_FILE
           #
           f_message $1 "NOK" "Exiting script" $TEMP_FILE
           ;;
           whiptail)
           # Create temporary file containing message.
           TEMP_FILE="$THIS_FILE_temp_file.txt"
           echo -e "\n\                          ***************\n                          *** ABORTED ***\n                          ***************\n\n\n        An error occurred, cannot continue. Exiting script." > $TEMP_FILE
           #
           f_message $1 "NOK" "Exiting script" $TEMP_FILE
           ;;
           *)
           echo $(tput setaf 1)    # Set font to color red.
           echo -n $(tput bold)
           f_message $1 "NOK" "Exiting Script"  ">>>ABORTED <<<\n\n\nAn error occurred, cannot continue."
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
case $1 in
     "dialog" | "whiptail") 
     f_about_gui $1
     ;;
     "text")
     f_about_txt
     ;;
 esac
} # End of f_about.
#
# +------------------------------------+
# |        Function f_about_txt        |
# +------------------------------------+
#
#  Inputs: None..
#          THIS_FILE, VERSION.
#    Uses: None.
# Outputs: None.
#
f_about_txt () {
      THIS_FILE="mountup.sh"
      clear # Blank the screen.
      echo "***********************************"
      echo "***  Running script $THIS_FILE  ***"
      echo "***   Rev. $VERSION     ***"
      echo "***********************************"
      echo
      echo
      TEMP_FILE="mountup_temp.txt"
      echo "Script: $THIS_FILE. Version: $VERSION" >$TEMP_FILE
      echo >>$TEMP_FILE
      sed -n 's/^#@//'p $THIS_DIR/$THIS_FILE >> $TEMP_FILE
      echo
      cat $TEMP_FILE
      f_press_enter_key_to_continue
      if [ -r $TEMP_FILE ] ; then
         rm $TEMP_FILE
      fi
} # End of f_about_txt.
#
# +------------------------------------+
# |        Function f_about_gui        |
# +------------------------------------+
#
#  Inputs: $1=GUI - "text", "dialog" or "whiptail" the preferred user-interface.
#          THIS_FILE, VERSION.
#    Uses: None.
# Outputs: None.
#
f_about_gui () {
      #
      # Display text (all lines beginning with "#@" but do not print "#@").
      # sed substitutes null for "#@" at the beginning of each line
      # so it is not printed.
      #
      THIS_FILE="mountup_gui.sh"
      TEMP_FILE="mountup_gui_temp.txt"
      echo "Script: $THIS_FILE. Version: $VERSION" >$TEMP_FILE
      echo >>$TEMP_FILE
      sed -n 's/^#@//'p $THIS_DIR/$THIS_FILE >> $TEMP_FILE
      #
      f_message $1 "OK" "About (use arrow keys to scroll up/down/side-ways)" $TEMP_FILE
      #$1 --title "About $THIS_FILE (use arrow keys to scroll up/down/side-ways)" --textbox $TEMP_FILE $Y $X
      #
      if [ -r $TEMP_FILE ] ; then
         rm $TEMP_FILE
      fi
} # End of f_about_gui.
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
case $1 in
     "dialog" | "whiptail") 
     f_code_history_gui $1
     ;;
     "text")
     f_code_history_txt
     ;;
esac

} # End of f_code_history.
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
      # Used when invoking script using arguments: --history --hist.
      # $ bash mountup_gui.sh --hist
      # So $THIS_FILE actually is the Dialog/Whiptail enabled script.
      THIS_FILE="mountup_gui.sh"
      clear # Blank the screen.
      # Display Help (all lines beginning with "#@" but do not print "#@").
      # sed substitutes null for "#@" at the beginning of each line
      # so it is not printed.
      # less -P customizes prompt for
      # %f <FILENAME> page <num> of <pages> (Spacebar, PgUp/PgDn . . .)
      sed -n 's/^##//'p $THIS_DIR/$THIS_FILE | less -P '(Spacebar, PgUp/PgDn, Up/Dn arrows, press q to quit)'
}  # End of function f_code_history_txt.
#
# +----------------------------------------+
# |       Function f_code_history_gui      |
# +----------------------------------------+
#
#  Inputs: $1=GUI - "dialog" or "whiptail" the preferred user-interface.
#          THIS_DIR, THIS_FILE.
#    Uses: None.
# Outputs: temp.txt.
#
f_code_history_gui () {
      # Display text (all lines beginning with "#@" but do not print "#@").
      # sed substitutes null for "#@" at the beginning of each line
      # so it is not printed.
      #
      THIS_FILE="mountup_gui.sh"
      TEMP_FILE="mountup_temp.txt"
      f_script_path
      echo "Script: $THIS_FILE. Version: $VERSION" >$TEMP_FILE
      echo >>$TEMP_FILE
      sed -n 's/^##//'p $THIS_DIR/$THIS_FILE >>$TEMP_FILE
      #
      f_message $1 "OK" "Code History (use arrow keys to scroll up/down/side-ways)" $TEMP_FILE
      #$1 --title "Code History (use arrow keys to scroll up/down/side-ways)" --textbox $TEMP_FILE $Y $X
      #
      if [ -r $TEMP_FILE ] ; then
         rm $TEMP_FILE
      fi
} # End of function f_code_history_gui.
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
case $1 in
     "dialog" | "whiptail") 
     f_help_message_gui $1
     ;;
     "text")
     f_help_message_txt
     ;;
esac

} # End of f_code_history.
#
# +----------------------------------------+
# |     Function f_help_message_txt        |
# +----------------------------------------+
#
#  Inputs: None.
#    Uses: None.
# Outputs: None.
#
f_help_message_txt () {
      echo
      echo "Usage: bash mountup_gui.sh [OPTION]"
      echo
      echo "       bash mountup_gui.sh text       # Optimized for minimum 80x24 character display"
      echo "       bash mountup_gui.sh dialog     # Use Dialog   user-interface"
      echo "       bash mountup_gui.sh whiptail   # Use Whiptail user-interface"
      echo "       bash mountup_gui.sh --help     # Displays this help message."
      echo "       bash mountup_gui.sh --version  # Displays script version."
      echo "       bash mountup_gui.sh --about    # Displays script version."
      echo "       bash mountup_gui.sh --history  # Displays script code history."
      echo
}  # End of function f_help_message_txt.
#
# +----------------------------------------+
# |     Function f_help_message_gui        |
# +----------------------------------------+
#
#  Inputs: None.
#    Uses: None.
# Outputs: None.
#
f_help_message_gui () {
      #
      # Display text (all lines beginning with "#?" but do not print "#?").
      # sed substitutes null for "#?" at the beginning of each line
      # so it is not printed.
      #
      THIS_FILE="mountup_gui.sh"
      TEMP_FILE="dropfsd_temp.txt"
      echo "Script: $THIS_FILE. Version: $VERSION" >$TEMP_FILE
      echo >>$TEMP_FILE
      sed -n 's/^#?//'p $THIS_DIR/$THIS_FILE >> $TEMP_FILE
      #
      f_message $1 "OK" "About $THIS_FILE (use arrow keys to scroll up/down/side-ways)" $TEMP_FILE
      #$1 --title "About $THIS_FILE (use arrow keys to scroll up/down/side-ways)" --textbox $TEMP_FILE $Y $X
      #
      if [ -r $TEMP_FILE ] ; then
         rm $TEMP_FILE
      fi
} # End of f_help_message_gui.
#
# **************************************
# ***     Start of Main Program      ***
# **************************************
#
clear  # Clear screen.
      echo "***********************************"
      echo "***  Running script $THIS_FILE  ***"
      echo "***   Rev. $VERSION     ***"
      echo "***********************************"
echo
sleep 1  # pause for 3 seconds automatically.
#
# If an error occurs, the f_abort_txt() function will be called.
# trap 'f_abort_txt' 0
# set -e
#
if [ -r mountup_lib_gui.lib ] ; then  # Does library file exist and is readable in the same directory as this script.
   . mountup_lib_gui.lib  # Invoke library.
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
THIS_DIR=$MAINMENU_DIR  # Set $THIS_DIR to location of Main Menu.
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
#GUI="whiptail"  #Test diagnostic line.
#GUI="dialog"    #Test diagnostic line.
#GUI="text"       #Test diagnostic line.
#
# Test for BASH environment.
f_test_environment
#
GENERATED_FILE="mountup_server_menu_gui.lib"
f_server_arrays
#
MENU_TITLE="Main_Menu"
f_update_menu_gui $GUI $GENERATED_FILE $MENU_TITLE $MAX_LENGTH $MAX_LINES
#
. $GENERATED_FILE  # Invoke Generated file.
f_server_menu_gui $GUI
#
if [ -r $GENERATED_FILE ] ; then
   rm $GENERATED_FILE
fi
#
exit 0  # This cleanly closes the process generated by #!bin/bash. 
        # Otherwise every time this script is run, another instance of
        # process /bin/bash is created using up resources.
# all dun dun noodles.
