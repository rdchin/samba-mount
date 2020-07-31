#!/bin/bash
#
# ©2020 Copyright 2020 Robert D. Chin
#
# Usage: bash pkg-upgrade.sh
#        (not sh pkg-upgrade.sh)
#
# +----------------------------------------+
# |        Default Variable Values         |
# +----------------------------------------+
#
VERSION="2020-07-25 20:50"
THIS_FILE="pkg-upgrade.sh"
TEMP_FILE=$THIS_FILE"_temp.txt"
#
# +----------------------------------------+
# |            Brief Description           |
# +----------------------------------------+
#
#@ Brief Description
#@
#@ Script pkg-upgrade.sh will show a description of each upgradable package
#@ before upgrading each package.
#@
#@ Required scripts: None
#@
#@ Usage: bash pkg-upgrade.sh
#@        (not sh pkg-upgrade.sh)
#
# +----------------------------------------+
# |             Help and Usage             |
# +----------------------------------------+
#
#?    Usage: bash pkg-upgrade.sh [OPTION]
#? Examples:
#?bash pkg-upgrade.sh text       Use Cmd-line user-interface (80x24 min.).
#?                    dialog     Use Dialog   user-interface.
#?                    whiptail   Use Whiptail user-interface.
#?
#?bash pkg-upgrade.sh --help     Displays this help message.
#?                    -?
#?
#?bash pkg-upgrade.sh --about    Displays script version.
#?                    --version
#?                    --ver
#?                    -v
#?
#?bash pkg-upgrade.sh --history  Displays script code history.
#?                    --hist
#
# +----------------------------------------+
# |           Code Change History          |
# +----------------------------------------+
#
## Code Change History
##
## (After each edit made, please update Code History and VERSION.)
##
## 2020-07-25 *Main Program altered f_test_connection to have 1 s delay.
##
## 2020-06-30 *f_ques_upgrade added message about checking for obsolete
##             packages.
##
## 2020-06-27 *f_display_common, f_about, f_code_history, f_help_message
##             rewritten to simplify code.
##            *Use library common_bash_function.lib.
##
## 2020-06-22 *Release 1.0 "Amy".
##             Last release without dependency on common_bash_function.lib.
##             *Updated to latest standards.
##
## 2020-05-31 *f_obsolete_packages, f_ques_upgrade fixed bug and simplified
##             detection of obsolete packages to be removed.
##
## 2020-05-16 *Updated to latest standards.
##
## 2020-05-06 *f_msg_ui_file_box_size, f_msg_ui_file_ok bug fixed in display.
##
## 2020-04-28 *Main updated to latest standards.
##
## 2020-04-24 *f_message split into several functions for clarity and
##             simplicity f_msg_(txt/ui)_(file/string)_(ok/nok).
##            *f_yn_question split off f_yn_defaults.
##            *f_obsolete_packages added.
##
## 2020-04-14 *f_ques_upgrade added command "apt autoremove".
##
## 2020-04-11 *f_message and messages throughout script rewritten
##             for better compatibility between CLI, Dialog, Whiptail. 
##
## 2020-04-06 *f_arguments standardized.
##
## 2020-04-05 *f_message made more Whiptail compatible.
##
## 2020-03-31 *f_message, f_test_connection bug fixes for Whiptail.
##
## 2020-03-31 *f_message rewritten to handle string and temp file input.
##
## 2020-03-28 *f_bad_sudo_password added.
##            *f_arguments added --hist.
##
## 2020-03-27 *f_abort, f_ques_upgrade improved Dialog UI messages.
##
## 2020-03-26 *Rewrote code to include Dialog UI along with CLI.
##
## 2020-03-22 *f_list_packages improved display of package descriptions.
##
## 2019-09-06 *Main Program regression bug fixes and minor enhancements.
##
## 2019-09-05 *Main Program enhancement if no updates, then do not offer
##             to list package descriptions.
##
## 2019-08-29 *f_list_packages added for modularity.
##            *Main Program added question for choice to list package
##             descriptions before upgrading or not.
##
## 2019-04-02 *f_abort_txt, f_test_connection added.
##            *Main Program move f_test_connection after f_arguments.
##            *f_arguments pattern matching adjusted.
##
## 2019-03-31 *Main Program added f_help_message to beginning of Main Program. 
##
## 2019-03-29 *f_arguments, f_code_history_txt, f_version_txt, f_help_message
##             added actions for optional command arguments.
##            *f_script_path, f_press_enter_key_to_continue added.
##
## 2019-03-28 *Adjusted displayed package descriptions format. 
##            *Added message if there are no packages to update.
##            *If there are no packages to update, do not create a report.
##
## 2019-03-26 *Added detection of installed file viewer.
##
## 2019-03-24 *Initial release.
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
      #THIS_FILE="pkg-upgrade.sh"
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
} # End of function f_display_common.
#
# +------------------------------------+
# |      Function f_ques_upgrade       |
# +------------------------------------+
#
#  Inputs: $1=GUI.
#          #2=Temporary file.
#    Uses: None.
# Outputs: File $TEMP_FILE.
#
f_ques_upgrade () {
      #
      # Read the last line in the file $TEMP_FILE.
      X=$(tail -n 1 $2)
      #
      if [ "$X" = "All packages are up to date." ] ; then
         #
         f_message $1 "OK" "Status of Software Packages" "All software packages are at the latest version."
         #
         # Clean up temporary files before running "sudo apt upgrade".
         # If you quit out of "sudo apt upgrade", then execution terminates
         # within this function and never goes back to Main.
         if [ -e $TEMP_FILE ] ; then
            rm $TEMP_FILE
         fi
         #
         # In some versions of apt, the string "autoremove" (obsolete packages)
         # appears after "apt update" but in the newer versions of apt,
         # the string appears only after command "apt upgrade" is given.
         # So even though there are no packages to upgrade, give the command
         # "apt upgrade to detect any obsolete packages to remove.
         f_message $1 "NOK" "Checking for obsolete Software Packages" "Running command: \"sudo apt upgrade\"\nto check for obsolete software packages." 3
         #
         clear  # Blank the screen.
         #
         sudo apt upgrade | tee $TEMP_FILE
         f_obsolete_packages $1 $2
      else
         # Yes/No Question.
         f_yn_question $1 "Y" "View Software Package Descriptions?" " \nSome software packages are not up-to-date and need upgrading.\n \nNote: There may be a delay to display descriptions.\n      (especially if many software packages need to be updated)\n \nDo you want to view software package descriptions?"
         # ANS=0 when <Yes> button pressed.
         # ANS=1 when <No> button pressed.
         #
         # if <Yes> button pressed, then list packages.
         if [ $ANS -eq 0 ] ; then
            f_list_packages
         fi
         f_message $1 "NOK" "Upgrade Software Packages" "Running command: \"sudo apt upgrade\" to upgrade software packages."
         #
         clear  # Blank the screen.
         #
         # Clean up temporary files before running "sudo apt upgrade".
         # If you quit out of "sudo apt upgrade", then execution terminates
         # within this function and never goes back to Main.
         TEMP_FILE=$THIS_FILE"_temp.txt"
         if [ -e $TEMP_FILE ] ; then
            rm $TEMP_FILE
         fi
         sudo apt upgrade | tee $TEMP_FILE
         f_obsolete_packages $1 $TEMP_FILE
         #
         TEMP_FILE=$THIS_FILE"_temp.txt"
         if [ -e $TEMP_FILE ] ; then
            rm $TEMP_FILE
         fi
      fi
      #
      clear  # Clear screen.
      #
}  # End of function f_ques_upgrade_gui.
#
# +----------------------------------------+
# |       Function f_list_packages         |
# +----------------------------------------+
#
#  Inputs: None.
#    Uses: None.
# Outputs: None.
#
f_list_packages () {
      #
      # File TEMP_FILE="$THIS_FILE_temp.txt" contains only the package names of upgradable packages.
      # File TEMP_FILE2="$THIS_FILE_temp2.txt contains the package names and descriptions.
      #
      TEMP_FILE=$THIS_FILE"_temp.txt"
      # Raw data output from command, "apt list".
      sudo apt list --upgradable > $TEMP_FILE 2>/dev/null
      #
      # Parse raw data to show each package title only.
      TEMP_FILE2=$THIS_FILE"_temp2.txt"
      awk -F / '{ print $1 }' $TEMP_FILE > $TEMP_FILE2
      #
      # Delete string "Listing...Done" from list of packages.
      sed -i s/Listing...// $TEMP_FILE2
      #
      # Delete empty line left-over from deleting string.
      awk 'NF' $TEMP_FILE2 > $TEMP_FILE
      #
      # If tmp file has data (list of packages to be updated).
      if [ -s $TEMP_FILE ] ; then
         #
         # Create file $TEMP_FILE2 to contain package name and short description.
         #
         TITLE="***Description of upgradable packages***"
         echo $TITLE > $TEMP_FILE2
         #
         # Extract the "Description" from the raw data output from command "apt-cache show <pkg name>". 
         # Read the file uplist.tmp.
         while read XSTR
         do
               echo >> $TEMP_FILE2
               echo "---------------------------" >> $TEMP_FILE2
               echo $XSTR >> $TEMP_FILE2
               #
               # grep all package description text between strings "Description" and "Description-md5".
               apt-cache show $XSTR | grep Description --max-count=1 --after-context=99 | grep Description-md5 --max-count=1 --before-context=99 | sed 's/^Description-md5.*$//'>> $TEMP_FILE2
         done < $TEMP_FILE
         #
         f_message $GUI "OK" "Package Description" $TEMP_FILE2
         #
      else
         f_message $GUI "NOK" "Up-to-Date" "No packages to update. All packages are up to date."
      fi
      #
}  # End of function f_list_packages.
#
# +----------------------------------------+
# |       Function f_obsolete_packages     |
# +----------------------------------------+
#
#  Inputs: $1=GUI.
#          $2=Temporary file.
#    Uses: None.
# Outputs: None.
#
f_obsolete_packages () {
      #
      # In some versions of apt, the string "autoremove" (obsolete packages)
      # appears after "apt update" but in the newer versions of apt,
      # the string appears only after command "apt upgrade" is given.
      #
      # Prerequisite: 
      # The command "apt upgrade" must be given before calling this function.
      # i.e. Command format:  "sudo apt upgrade | tee $TEMP_FILE".
      #                       "f_obsolete_packages $GUI $TEMP_FILE".
      #
      # Are there any software packages automatically installed but are no longer required?
      ANS=$(grep autoremove $2)
      if [ -n "$ANS" ] ; then
         # If $ANS is not zero length and contains the string "autoremove".
         # Yes/No Question.
         f_yn_question $1 "Y" "Remove extraneous software packages?" "Some software packages are no longer needed and may be removed.\n \nDo you want to remove unneeded software packages?"
         # ANS=0 when <Yes> button pressed.
         # ANS=1 when <No> button pressed.
         #
         # if <Yes> button pressed, then remove unneeded software packages.
         if [ $ANS -eq 0 ] ; then
            #
            clear  # Blank the screen.
            #
            sudo apt autoremove
            f_press_enter_key_to_continue
         fi
      fi
      #
} # End of function f_obsolete_packages
#
# +----------------------------------------+
# |          f_download_library            |
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
} # End of function f_download_library_template.
#
# PLEASE NOTE: THIS IS A SAMPLE OF A STANDARD MAIN PROGRAM.
#
# **************************************
# ***     Start of Main Program      ***
# **************************************
#
#     Rev: 2020-06-27
#
TEMP_FILE=$THIS_FILE"_temp2.txt"
if [ -e $TEMP_FILE ] ; then
   rm $TEMP_FILE
fi
#
TEMP_FILE=$THIS_FILE"_temp.txt"
if [ -e $TEMP_FILE ] ; then
   rm $TEMP_FILE
fi
#
#
clear  # Blank the screen.
#
echo "Running script $THIS_FILE"
echo "***   Rev. $VERSION   ***"
echo
sleep 1  # pause for 1 second automatically.
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
#for FILE_DEPENDENCY in LIBRARY0 LIBRARY1 LIBRARY2
#    do
#       if [ ! -x "$THIS_DIR/$FILE_DEPENDENCY" ] ; then
#         f_message "text" "OK" "File Error"  "Error with required file:\n\"$THIS_DIR/$FILE_DEPENDENCY\"\n\n\Z1\ZbFile is missing or file is not executable.\n\n\ZnCannot continue, exiting program script." 3
#          echo
#          f_abort text
#       else
#          source "$THIS_DIR/$FILE_DEPENDENCY"
#       fi
#    done
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
# If an error occurs, the f_abort() function will be called.
# trap 'f_abort' 0
# set -e
#
#
# Set Temporary file using $THIS_DIR from f_script_path.
TEMP_FILE=$THIS_DIR/$THIS_FILE"_temp.txt"
#
# Test for Optional Arguments.
f_arguments $1  # Also sets variable GUI.
#
# If command already specifies GUI, then do not detect GUI i.e. "bash dropfsd.sh dialog" or "bash dropfsd.sh text".
if [ -z $GUI ] ; then
   # Test for GUI (Whiptail or Dialog) or pure text environment.
   f_detect_ui
fi
#
# Test for BASH environment.
f_test_environment
#
# Show About this script message.
f_about $GUI
#
# Show Usage message.
f_help_message $GUI
#
#GUI="whiptail"  #Test diagnostic line.
#GUI="dialog"    #Test diagnostic line.
#GUI="text"      #Test diagnostic line.
#
f_test_connection $GUI 8.8.8.8 1
if [ $ERROR -ne 0 ] ; then
   f_abort $GUI
fi
#
# Run a sudo command to catch bad sudo passwords.
sudo --validate
ERROR=$?
if [ $ERROR -eq 0 ] ; then
   #
   # Find latest updates to packages.
   f_message $GUI "NOK" "Searching for Software Updates" "Finding latest updates to software packages."
   #
   TEMP_FILE=$THIS_FILE"_temp.txt"
   sudo apt update > $TEMP_FILE 2>/dev/null
   #
   # If updates exist, do you want to see package descriptions?
   # And do you want to upgrade the packages?
   f_ques_upgrade $GUI $TEMP_FILE
   #
else
   f_bad_sudo_password $GUI
fi
#
TEMP_FILE=$THIS_FILE"_temp.txt"
if [ -e $TEMP_FILE ] ; then
   rm $TEMP_FILE
fi
#
TEMP_FILE=$THIS_FILE"_temp2.txt"
if [ -e $TEMP_FILE ] ; then
   rm $TEMP_FILE
fi
# All dun dun noodles.
