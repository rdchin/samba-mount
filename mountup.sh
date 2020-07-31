#!/bin/bash
#
# ©2020 Copyright 2020 Robert D. Chin
#
# Usage: bash mountup.sh
#        (not sh mountup.sh)
#
# +----------------------------------------+
# |            Main Menu Options           |
# +----------------------------------------+
#
# Format: <#@@> <Menu Option> <#@@> <Description of Menu Option> <#@@> <Corresponding function or action or cammand>
#
#@@Exit#@@Exit to command-line prompt.#@@break
#
#@@Mount-Unmount#@@Mount/Unmount Server Mount-points.#@@f_menu_server^$GUI
#
#@@Show#@@Show mounted directories.#@@f_show_mount_points^$GUI
#
#@@About#@@Version information of this script.#@@f_about^$GUI
#
#@@Code History#@@Display code change history of this script.#@@f_code_history^$GUI
#
#@@Help#@@Display help message.#@@f_help_message^$GUI
#
# +----------------------------------------+
# |        Default Variable Values         |
# +----------------------------------------+
#
VERSION="2020-07-30 23:04"
THIS_FILE="$0"
      TEMP_FILE=$THIS_FILE"_temp.txt"
#
# +----------------------------------------+
# |            Brief Description           |
# +----------------------------------------+
#
#& Brief Description
#&
#& This script will mount shared cifs (Samba) directories from one or more
#& file servers. The shared (Samba) directories will be mounted on the
#& corresponding mount-points (directories) on the Local PC.
#&
#& To add more file server names, share-points with corresponding
#& mount-points, edit the text at the end of function f_server_arrays.
#& Format: <DELIMITER>//<Source File Server>/<Shared directory><DELIMITER>
#&        /<Mount-point on local PC>
#&
#& Required scripts: mountup.lib.
#&
#& Usage: bash mountup.sh
#&        (not sh mountup.sh)
#&
#& After each edit made, please update Code History and VERSION.
#
# +----------------------------------------+
# |             Help and Usage             |
# +----------------------------------------+
#
#? Usage: bash mountup.sh [OPTION]
#? Examples:
#?
#? bash mountup.sh dialog     # Use Dialog   user-interface
#?                 whiptail   # Use Whiptail user-interface
#?
#? bash mountup.sh --help     # Displays this help message.
#?                 -?
#?
#? bash mountup.sh --about    # Displays script version.
#?                 --version
#?                 --ver
#?                 -v
#?
#? bash mountup.sh --history  # Displays script code history.
#?                 --hist
#
# +----------------------------------------+
# |           Code Change History          |
# +----------------------------------------+
#
## Code Change History
##
## 2020-07-30 *f_menu_action altered f_test_connection to have 1 s delay.
##
## 2020-06-27 *Use library common_bash_function.lib.
##            *f_display_common, f_about, f_code_history, f_help_message
##             rewritten to simplify code.
##            *Main Program included a test for dependent files.
##
## 2020-06-22 *Release 1.0 "Amy".
##             Last release without dependency on common_bash_function.lib.
##             *Updated to latest standards.
##
## 2020-05-30 *Updated to latest standards.
##
## 2020-05-23 *Updated to latest standards.
##
## 2020-05-15 *Complete rewrite added file mountup_servers.lib.
##            *f_test_connection changed message from "Internet" to "Network".
##            *f_main_menu, f_create_show_menu, f_update_menu_txt/gui added
##             unique TEMP_FILE name to prevent over-writing.
##            *f_update_menu_txt/gui changed f_menu_txt/gui to be unique
##             with each file $GENERATED_FILE so you can have several sub-menus
##             open simultaneously each with a unique f_menu_txt/gui function names.
##
## 2020-05-14 *f_yn_question fixed bug where temp file was undefined.
##            *msg_ui_str_nok, f_msg_txt_str_nok changed wait time
##             from 5 to 3 seconds.
##            *f_exit_script to latest standard; clean-up temp files on exit.
##            *f_message, f_msg_ui_file_box_size, f_msg_ui_str_box_size,
##             f_ui_file_ok/nok, f_ui_str_ok/nok f_yn_question/defaults
##             specified parameter passing.
##            *f_menu_arrays, f_update_menu_txt/gui bug fixed to not unset
##             TEMP_FILE variable since it is used globally.
##
## 2020-05-06 *f_msg_ui_file_box_size, f_msg_ui_file_ok bug fixed in display.
##
## 2020-04-28 *Main updated to latest standards.
##
## 2020-04-24 *Renamed scripts to mountup.sh and mountup.lib.
##
## 2020-04-23 *f_message split into several functions for clarity and
##             simplicity f_msg_(txt/ui)_(file/string)_(ok/nok).
##            *f_yn_question split off f_yn_defaults.
##
## 2020-04-17 *f_menu_arrays corrected comments.
##
## 2020-04-14 *f_test_mount, f_yn_question Bug fixed.
##            *Standardized temporary files and cleanup code.
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
# +------------------------------------+
# |          Function f_about          |
# +------------------------------------+
#
#     Rev: 2020-06-27
#  Inputs: $1=GUI - "text", "dialog" or "whiptail" the preferred user-interface.
#          THIS_DIR, THIS_FILE, VERSION.
#    Uses: DELIM.
# Outputs: None.
#
f_about () {
      #
      # Display text (all lines beginning ("^") with "#& " but do not print "#& ").
      # sed substitutes null for "#& " at the beginning of each line
      # so it is not printed.
      DELIM="^#&"
      f_display_common $1 $DELIM
      #
} # End of f_about.
#
# +------------------------------------+
# |      Function f_code_history       |
# +------------------------------------+
#
#     Rev: 2020-06-27
#  Inputs: $1=GUI - "text", "dialog" or "whiptail" the preferred user-interface.
#          THIS_DIR, THIS_FILE, VERSION.
#    Uses: DELIM.
# Outputs: None.
#
f_code_history () {
      #
      # Display text (all lines beginning ("^") with "##" but do not print "##").
      # sed substitutes null for "##" at the beginning of each line
      # so it is not printed.
      DELIM="^##"
      f_display_common $1 $DELIM
      #
} # End of function f_code_history.
#
# +------------------------------------+
# |      Function f_help_message       |
# +------------------------------------+
#
#     Rev: 2020-06-27
#  Inputs: $1=GUI - "text", "dialog" or "whiptail" the preferred user-interface.
#          THIS_DIR, THIS_FILE, VERSION.
#    Uses: DELIM.
# Outputs: None.
#
f_help_message () {
      #
      # Display text (all lines beginning ("^") with "#?" but do not print "#?").
      # sed substitutes null for "#?" at the beginning of each line
      # so it is not printed.
      DELIM="^#?"
      f_display_common $1 $DELIM
      #
} # End of f_help_message.
#
# +------------------------------------+
# |     Function f_display_common      |
# +------------------------------------+
#
#     Rev: 2020-06-27
#  Inputs: $1=GUI - "text", "dialog" or "whiptail" the preferred user-interface.
#          $2=Delimiter of text to be displayed.
#          THIS_DIR, THIS_FILE, VERSION.
#    Uses: X.
# Outputs: None.
#
f_display_common () {
      #
      # Specify $THIS_FILE name of any file containing the text to be displayed.
      THIS_FILE="mountup.sh"
      TEMP_FILE=$THIS_DIR/$THIS_FILE"_temp.txt"
      #
      # Set $VERSION according as it is set in the beginning of $THIS_FILE.
      X=$(grep --max-count=1 "VERSION" $THIS_FILE)
      # X="VERSION=YYYY-MM-DD HH:MM"
      # Use command "eval" to set $VERSION.
      eval $X
      #
      echo "Script: $THIS_FILE. Version: $VERSION" > $TEMP_FILE
      echo >>$TEMP_FILE
      #
      # Display text (all lines beginning ("^") with $2 but do not print $2).
      # sed substitutes null for $2 at the beginning of each line
      # so it is not printed.
      sed -n "s/$2//"p $THIS_DIR/$THIS_FILE >> $TEMP_FILE
      #
      f_message $1 "OK" "Code History (use arrow keys to scroll up/down/side-ways)" $TEMP_FILE
      #
} # End of function f_code_history.
#
# +----------------------------------------+
# |          Function f_menu_main          |
# +----------------------------------------+
#
#     Rev: 2020-06-04
#  Inputs: None.
#    Uses: ARRAY_FILE, GENERATED_FILE, MENU_TITLE.
# Outputs: None.
#
f_menu_main () { # Create and display the Main Menu.
      #
      THIS_FILE="mountup.sh"
      GENERATED_FILE=$THIS_DIR/$THIS_FILE"_menu_main_generated.lib"
      #
      # Does this file have menu items in the comment lines starting with "#@@"?
      grep --silent ^\#@@ $THIS_DIR/$THIS_FILE
      ERROR=$?
      # exit code 0 - menu items in this file.
      #           1 - no menu items in this file.
      #               file name of file containing menu items must be specified.
      if [ $ERROR -eq 0 ] ; then
         # Extract menu items from this file and insert them into the Generated file.
         # This is required because f_menu_arrays cannot read this file directly without
         # going into an infinite loop.
         grep ^\#@@ $THIS_DIR/$THIS_FILE >$GENERATED_FILE
         #
         # Specify file name with data.
         ARRAY_FILE="$GENERATED_FILE"
      else
         # Specify file name with data.
         ARRAY_FILE="[UNUSED_FILENAME_GOES_HERE]"
      fi
      #
      # Create arrays from data.
      f_menu_arrays $ARRAY_FILE
      #
      # Calculate longest line length to find maximum menu width
      # for Dialog or Whiptail using lengths calculated by f_menu_arrays.
      let MAX_LENGTH=$MAX_CHOICE_LENGTH+$MAX_SUMMARY_LENGTH
      #
      # Create generated menu script from array data.
      MENU_TITLE="Main_Menu"  # Menu title must substitute underscores for spaces
      TEMP_FILE=$THIS_DIR/$THIS_FILE"_menu_main_temp.txt"
      #
      f_create_show_menu $GUI $GENERATED_FILE $MENU_TITLE $MAX_LENGTH $MAX_LINES $MAX_CHOICE_LENGTH $TEMP_FILE
      #
      if [ -r $GENERATED_FILE ] ; then
         rm $GENERATED_FILE
      fi
      #
} # End of function f_menu_main.
#
# +----------------------------------------+
# |       Function f_download_library      |
# +----------------------------------------+
#
#     Rev: 2020-06-23
#  Inputs: $1=GitHub Repository
#          $2=file name to download.
#    Uses: ARRAY_FILE, GENERATED_FILE, MENU_TITLE.
# Outputs: None.
#
# PLEASE NOTE: This function needs to be inserted into each script
#              which depends on the library "common_bash_function.lib".
#
f_download_library () { # Create and display the Main Menu.
      #
      wget --show-progress $1$2
      ERROR=$?
      if [ $ERROR -ne 0 ] ; then
         echo
         echo "!!! wget download failed !!!"
         echo "from GitHub.com for file: $2"
         echo
         echo "Cannot continue, exiting program script."
         sleep 3
         exit 1  # Exit with error.
      fi
      #
      # Make downloaded file executable.
      chmod 755 $2
      #
      echo
      echo ">>> Please run program again after download. <<<"
      echo 
      # Delay to read messages on screen.
      echo -n "Press \"Enter\" key to continue" ; read X
      exit 0
      #
} # End of function f_download_library.
#
# **************************************
# ***     Start of Main Program      ***
# **************************************
#
if [ -e $TEMP_FILE ] ; then
   rm $TEMP_FILE
fi
#
clear  # Blank the screen.
#
echo " *** Running script ***" 
echo "      $THIS_FILE"
echo "Revision $VERSION"
echo
sleep 1  # pause for 3 seconds automatically.
#
clear # Blank the screen.
#
# Invoke common BASH function library.
FILE_DEPENDENCY="common_bash_function.lib"
if [ -x "$FILE_DEPENDENCY" ] ; then
   source $FILE_DEPENDENCY
else
   echo "File Error"
   echo
   echo "Error with required file:"
   echo "\"$FILE_DEPENDENCY\""
   echo
   echo "File is missing or file is not executable."
   echo
   echo "Do you want to download the file: $FILE_DEPENDENCY"
   echo -n "from GitHub.com? (Y/n): " ; read ANS
   case $2 in
        "" | [Yy] | [Yy][Ee][Ss])
           f_download_library "https://raw.githubusercontent.com/rdchin/BASH_function_library/master/" "common_bash_function.lib"
           ;;
        *)
           echo
           echo "Cannot continue, exiting program script."
           echo "Error with required file:"
           echo "\"$FILE_DEPENDENCY\""
           sleep 3
           exit 1  # Exit with error.
           ;;
   esac
   #
fi
#
# Set THIS_DIR, SCRIPT_PATH to directory path of script.
f_script_path
#
# Invoke any other libraries required for this script.
for FILE_DEPENDENCY in mountup.lib mountup_servers.lib
    do
       if [ ! -x "$THIS_DIR/$FILE_DEPENDENCY" ] ; then
          f_message "text" "OK" "File Error"  "Error with required file:\n\"$THIS_DIR/$FILE_DEPENDENCY\"\n\n\Z1\ZbFile is missing or file is not executable.\n\n\ZnCannot continue, exiting program script." 3
          echo
          f_abort text
       else
          source "$THIS_DIR/$FILE_DEPENDENCY"
       fi
    done
#
# Test for files required for this script.
#for FILE_DEPENDENCY in FILE0 FILE1 FILE2
#    do
#       if [ ! -x "$FILE_DEPENDENCY" ] ; then
#          f_message "text" "OK" "File Error"  "Error with required file:\n\"$FILE_DEPENDENCY\"\n\n\Z1\ZbFile is missing or file is not executable.\n\n\ZnCannot continue, exiting program script." 3
#          echo
#          f_abort text
#       fi
#    done
#
# Set Temporary file using $THIS_DIR from f_script_path.
TEMP_FILE=$THIS_DIR/$THIS_FILE"_temp.txt"
#
# Test for Optional Arguments.
f_arguments $1 $2 # Also sets variable GUI.
#
# If command already specifies GUI, then do not detect GUI i.e. "bash mountup.sh dialog" or "bash mountup.sh whiptail".
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
f_menu_main
#
#if [ -r $GENERATED_FILE ] ; then
#   rm $GENERATED_FILE
#fi
#
clear  # Blank the screen.
#
exit 0  # This cleanly closes the process generated by #!bin/bash. 
        # Otherwise every time this script is run, another instance of
        # process /bin/bash is created using up resources.
# all dun dun noodles.
