#!/bin/bas
#
# ©2023 Copyright 2023 Robert D. Chin
# Email: RDevChin@Gmail.com
#
# Usage: bash mountup.sh
#        (not sh mountup.sh)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program. If not, see <https://www.gnu.org/licenses/>.
#
# +----------------------------------------+
# |            Main Menu Options           |
# +----------------------------------------+
#
#                 >>> !!!Warning!!! <<<
#
# The Menu Item Descriptions cannot have semi-colons, colons, asterisks,
# single-quotes (apostrophes), double-quotes, ampersands, greater-than and less-than signs.
#
# Forbidden characters include ; : * ' " - & > < / \
#
# These characters will compromise the creation of arrays which
# in turn creates the menu.
#
# General Format: <#@@> <Menu Option> <#@@> <Description of Menu Option> <#@@> <Corresponding function or action or command>
#
# Format of <Corresponding function or action or command> when using f_create_a_menu
#        f_create_menu^"text", "dialog", or "whiptail"^menu_generated.lib^Menu Name^Temporary File Name^Library name containing menu entries
#
# List of inputs for f_create_a_menu.
#
#  Inputs: $1 - "text", "dialog" or "whiptail" the command-line user-interface application in use.
#          $2 - GENERATED_FILE (The name of a temporary library file containing the suggested phrase "generated.lib" which contains the code to display the sub-menu).
#          $3 - MENU_TITLE (Title of the sub-menu)
#          $4 - TEMP_FILE (Temporary file).
#          $5 - ARRAY_FILE (Temporary file) includes menu items imported from $ARRAY_SOURCE_FILE of a single menu.
#          $6 - ARRAY_SOURCE_FILE (Not a temporay file) includes menu items from multiple menus.
#
# Format: <#@@> <Menu Option> <#@@> <Description of Menu Option> <#@@> <Corresponding function or action or cammand>
#
#@@Exit#@@Exit this menu.#@@break
#
#@@Mount-Dismount#@@Mount/Dismount Server Mount-points.#@@f_menu_server^$GUI
#
#@@Show Local/LAN drives#@@Show Local drives, LAN drive mount points.#@@f_show_mount_points^$GUI
#
#@@File Managers#@@Manage files/folders.#@@f_file_manager_select^$GUI^"/home/robert"^2
#
#@@About#@@Version information of this script.#@@f_about^$GUI
#
#@@Code History#@@Display code change history of this script.#@@f_code_history^$GUI
#
#@@Version Update#@@Check for updates to this script and download.#@@f_check_version^$GUI
#
#@@Help#@@Display help message.#@@f_help_message^$GUI
#
# +----------------------------------------+
# |        Default Variable Values         |
# +----------------------------------------+
#
VERSION="2024-01-18 21:04"
THIS_FILE=$(basename $0)
FILE_TO_COMPARE=$THIS_FILE
TEMP_FILE=$THIS_FILE"_temp.txt"
GENERATED_FILE=$THIS_FILE"_menu_generated.lib"
HOSTNAME=$(cat /etc/hostname)
#
#
#================================================================
# EDIT THE LINES BELOW TO SET REPOSITORY SERVERS AND DIRECTORIES
# AND TO INCLUDE ALL DEPENDENT SCRIPTS AND LIBRARIES TO DOWNLOAD.
#================================================================
#
#
#--------------------------------------------------------------
# Set variables to mount the Local Repository to a mount-point.
#--------------------------------------------------------------
#
# LAN File Server shared directory.
# SERVER_DIR="[FILE_SERVER_DIRECTORY_NAME_GOES_HERE]"
  SERVER_DIR="//file_server/public"
#
# Local PC mount-point directory.
# MP_DIR="[LOCAL_MOUNT-POINT_DIRECTORY_NAME_GOES_HERE]"
  MP_DIR="/mnt/file_server/public"
#
# Local PC mount-point with LAN File Server Local Repository full directory path.
# Example:
#                   File server shared directory is "//file_server/public".
# Repostory directory under the shared directory is "scripts/BASH/Repository".
#                 Local PC Mount-point directory is "/mnt/file_server/public".
#
# LOCAL_REPO_DIR="$MP_DIR/[DIRECTORY_PATH_TO_LOCAL_REPOSITORY]"
  LOCAL_REPO_DIR="$MP_DIR/LIBRARY/PC-stuff/PC-software/BASH_Scripting_Projects/Repository"
#
#
#=================================================================
# EDIT THE LINES BELOW TO SPECIFY THE FILE NAMES TO UPDATE.
# FILE NAMES INCLUDE ALL DEPENDENT SCRIPTS LIBRARIES.
#=================================================================
#
#
# --------------------------------------------
# Create a list of all dependent library files
# and write to temporary file, FILE_LIST.
# --------------------------------------------
#
# Temporary file FILE_LIST contains a list of file names of dependent
# scripts and libraries.
#
FILE_LIST=$THIS_FILE"_file_temp.txt"
#
# Format: [File Name]^[Local/Web]^[Local repository directory]^[web repository directory]
echo "mountup.lib^Local^$LOCAL_REPO_DIR^https://raw.githubusercontent.com/rdchin/samba-mount/master/mountup.lib"                  > $FILE_LIST
echo "mountup_servers.lib^Local^$LOCAL_REPO_DIR^https://raw.githubusercontent.com/rdchin/samba-mount/master/mountup_servers.lib" >> $FILE_LIST
echo "mountup_local.lib^Local^$LOCAL_REPO_DIR^https://raw.githubusercontent.com/rdchin/samba-mount/master/mountup_servers.lib"   >> $FILE_LIST
echo "common_bash_function.lib^Local^$LOCAL_REPO_DIR^https://raw.githubusercontent.com/rdchin/BASH_function_library/master/"     >> $FILE_LIST
#
# Create a name for a temporary file which will have a list of files which need to be downloaded.
FILE_DL_LIST=$THIS_FILE"_file_dl_temp.txt"
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
#& Required scripts: mountup.sh
#&                   mountup.lib
#&                   mountup_local.lib
#&                   mountup_servers.lib
#&                   common_bash_function.lib
#&
#& Usage: bash mountup.sh
#&        (not sh mountup.sh)
#&
#&    This program is free software: you can redistribute it and/or modify
#&    it under the terms of the GNU General Public License as published by
#&    the Free Software Foundation, either version 3 of the License, or
#&    (at your option) any later version.
#&
#&
#&    This program is distributed in the hope that it will be useful,
#&    but WITHOUT ANY WARRANTY; without even the implied warranty of
#&    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#&    GNU General Public License for more details.
#&
#&    You should have received a copy of the GNU General Public License
#&    along with this program. If not, see <https://www.gnu.org/licenses/>.
#
# +----------------------------------------+
# |             Help and Usage             |
# +----------------------------------------+
#
#? Usage: bash mountup.sh [OPTION(S)]
#?
#? Examples:
#?
#?                            Force display to use a different UI.
#? bash mountup.sh text       Use Cmd-line user-interface (80x24 minimum).
#?                 dialog     Use Dialog   user-interface.
#?                 whiptail   Use Whiptail user-interface.
#?
#? bash mountup.sh --help     Displays this help message.
#?                 -?
#?
#? bash mountup.sh --about    Displays script version.
#?                 --version
#?                 --ver
#?                 -v
#?
#? bash mountup.sh --history  Displays script code history.
#?                 --hist
#?
#? Examples using 2 arguments:
#?
#? bash mountup.sh --hist text
#?                 --ver dialog
#
# +----------------------------------------+
# |                Code Notes              |
# +----------------------------------------+
#
# To disable the [ OPTION ] --update -u to update the script:
#    1) Comment out the call to function fdl_download_missing_scripts in
#       Section "Start of Main Program".
#
# To completely delete the [ OPTION ] --update -u to update the script:
#    1) Delete the call to function fdl_download_missing_scripts in
#       Section "Start of Main Program".
#    2) Delete all functions beginning with "f_dl"
#    3) Delete instructions to update script in Section "Help and Usage".
#
# To disable the Main Menu:
#    1) Comment out the call to function f_menu_main under "Run Main Code"
#       in Section "Start of Main Program".
#    2) Add calls to desired functions under "Run Main Code"
#       in Section "Start of Main Program".
#
# To completely remove the Main Menu and its code:
#    1) Delete the call to function f_menu_main under "Run Main Code" in
#       Section "Start of Main Program".
#    2) Add calls to desired functions under "Run Main Code"
#       in Section "Start of Main Program".
#    3) Delete the function f_menu_main.
#    4) Delete "Menu Choice Options" in this script located under
#       Section "Customize Menu choice options below".
#       The "Menu Choice Options" lines begin with "#@@".
#
# +----------------------------------------+
# |           Code Change History          |
# +----------------------------------------+
#
## Code Change History
##
## (After each edit made, please update Code History and VERSION.)
##
## Includes changes to mountup.sh, mountup.lib, and mountup_servers.lib.
##
## 2024-01-18 *f_select_local_devices_checklist bug fixed where Dialog
##             --checklist window size parameters were wrong.
##             Also display size of storage device for Dialog --checklist.
##
## 2023-12-31 *Include Local PC Hostname in menu titles.
##
## 2023-12-14 *f_pick_mounts, f_dismount_all, f_dismount_all added exiting
##             of "Mount-Dismount [Server Name] File Server Menu" after
##             selection of those menu options because it just makes sense.
##
## 2023-11-26 *Section "Customize Server Menu choice options" in mountup.lib
##             bug fixed by deleting an extraneous space after the function
##             names preventing functions from running.
##
## 2023-11-25 *f_menu_action renamed to f_server_menu_action .
##            *f_select_local_device_menu included code from f_menu_generic
##             and updated code to current standards.
##
## 2023-11-23 *f_show_mount_points moved to common_bash_function.lib.
##            *Section Main Menu, Server Menu, Server Action Menu, Local
##             Action Menu reworded menu item to "Show Local/LAN drives".
##            *Section Variable Default Values in script mountup_servers.lib
##             deleted as redundant.
##            *Section Local Action Menu bug fixed causing generated
##             script to fail by adding double-quotes around the parameter
##             which specified the directory.
##             The forward slashes caused the syntax error.
##             Affected menu items were "Mount", "Dismount".
##
## 2023-11-22 *Sections Main Menu, Custom Local Action Menu bug fixed
##             causing generated script to fail  by adding double-quotes
##             around the parameter which specified the directory.
##             The forward slashes caused the syntax error.
##             Affected menu items was "File Managers".
##
##             Details of error message:
##             mountup.sh_menu_main_generated.lib:
##             line 49: syntax error.
##             `robert                    "Exit") break  ;;'
##
##             Change from: #@@f_file_manager_select^$GUI^/home/robert^2
##               Change to: #@@f_file_manager_select^$GUI^"/home/robert"^2
##
##            *f_show_mount_points changed display for "md" RAID devices
##             to show under "local mounted block devices" rather than
##             under "remote file servers".
##
## 2023-11-20 *f_select_local_device_radiolist and
##             f_select_local_devices_checklist resized box according to
##             contents. Allow (dis)mounting of RAID "md" devices. Excluded
##             RAID member drives from the Mount, Choose local drive menu.
##            *f_select_local_device_radiolist fixed display to auto-resize
##             radiolist for as small as a 80x24 window.
##
## 2023-11-13 *f_show_mount_points changed options for lsblk command
##             to improve display of RAID member devices.
##
## 2023-11-10 *f_show_mount_points added "FSTYPE" on local starage drives
##             when displaying the information for the local drives.
##             This indicates the local drives which are part of a RAID.
##
## 2023-11-09 *mountup_servers.lib Section "Add additional source file
##             servers, share-points, and mount-points here" changed names
##             of shared directories on PC Scotty file server.
##
## 2023-11-05 *f_show_mount_points added "Used" MB/GB on local storage
##             drives when displaying the information for the local drives.
##
## 2023-10-10 *Improved comments to be more consistent.
##
## 2023-09-15 *f_mount_local_usb_drive_2, f_dismount_local_usb_drive_2
##             added to simplify code.
##            *f_mount_local_usb_drive_2, f_dismount_local_usb_drive_2
##             added deletion of temp file as a bug fix of the generated
##             script to create a menu where temp file text was unserted
##             into the code of the menu.
##
## 2023-09-14 *f_mount_or_dismount_local_usb_drive_2 added error message
##             when trying to mount a non-existent 'sd' device.
##
## 2023-05-08 *f_show_mount_points changed user message for clarity.
##
## 2023-05-06 *f_show_mount_points changed parameters for lsblk command
##             to specify the columns displayed in a list of devices.
##
## 2022-10-05 *Section "Main Program" updated comments.
##            *f_display_common updated to latest standards.
##
## 2022-06-24 *Section "Main Program" deleted temporary files.
##             f_select_local_devices_checklist deleted temporary file.
##
## 2022-06-15 *f_file_manager_select added an optional parameter to pass to
##             f_file_manager to run a file manager in the background.
##
## 2022-06-03 *Section "Main Program" added code to delete temporary files.
##            *f_select_local_device_menu added code to delete temporary
##             files. Added code to pass parameters to f_menu_generic.
##            *f_menu_generic rewritten and simplified code.
##
## 2022-04-28 *f_select_local_device_radiolist
##            *f_select_local_devices_checklist corrected comments in the
##             generated temporary file.
##
## 2022-04-20 *fdl_download_missing_scripts fixed bug to prevent downloading
##             from the remote repository if the local repository was
##             unavailable and the script was only in the local repository.
##
## 2022-04-14 *f_show_mount_points added optional parameters to application
##             "df" --all --human-readable. Also added notes on application
##             "findmnt" versus "df" and the pros and cons.
##
## 2022-04-02 *f_mount_or_dismount_local_usb_drive_2, f_select_mount_point,
##             f_select_local_device_radiolist,
##             f_select_local_devices_checklist changed default mount-point
##             changed from: /media/robert/usb1
##             changed   to: /media/usb-dev1
##
## 2022-04-01 *f_select_local_device_radiolist bug fixed in device name.
##             Improved comments.
##            *f_mount_or_dismount_local_usb_drive_2 improved comments.
##            *f_select_local_devices_checklist changed default to no
##             devices selected from all devices selected.
##
## 2022-03-31 *f_select_local_device, f_select_multiple_local_devices added
##             code to delete temporary files.
##            *f_mount_or_dismount_local_usb_drive_2 added code to exit if
##             no local device was selected to mount.
##            *f_select_local_device_radiolist added.
##
## 2022-03-30 *f_select_local_device added.
##            *f_mount_or_dismount_local_usb_drive_2 simplified.
##
## 2022-03-29 *f_mount_or_dismount_local_usb_drive_2 enhanced mount device
##             instructions when asking for the mount command parameters.
##
## 2022-03-28 *f_mount_or_dismount_local_usb_drive changed from using the
##             Dialog --radiolist to using the standard menu with the menu
##             options in a separate file mountup_local.lib.
##            *f_file_manager_select bug fixed to use ERROR flag properly.
##            *f_show_mount_points made info prettier, more understandable,
##             and added information from lsblk command.
##
## 2022-03-07 *f_mount_or_dismount_local_usb_drive bug fixed to show
##             radio list menu when using script men.sh.
##
## 2022-03-06 *f_show_mount_points bug fix to hide df errors in testing.
##            *f_mount_or_dismount_local_usb_drive added Dialog
##             radio list menu.
##
## 2022-03-02 *Section "Server Menu" added menu item "Local".
##            *f_mount_or_dismount_local_usb_drive added.
##
## 2022-02-25 *f_file_manager_select added to call f_file_manager in the
##             common_bash_function.lib.
##             *f_check_version replaced template directories with real.
##
## 2021-04-21 *Section "Default Variable Values" added GitHub repository
##             URLs for this project.
##
## 2021-04-18 *f_run_app added to run application "mc" or any app you want.
##            *Section "Main Menu Options" added "File Managers".
##            *f_file_manager, f_install_app added.
##
## 2021-04-01 *Section "Code Notes" added. Improved comments.
##
## 2021-03-28 *Comment cleanup. Move the appended comments to start on the
##             previous line to improve readability.
##
## 2021-03-25 *f_check_version updated to add a second optional argument.
##             so a single copy in dropfsd_module_main.lib can replace the
##             customized versions in fsds.sh, and fsdt.sh.
##             Rewrote to eliminate comparing the version of a hard-coded
##             script or file name in favor of passing any script or file
##             name as an argument whose version is then compared to
##             determine whether or not to upgrade.
##            *Section "Main Program" detect UI before detecting arguments.
##            *Comment cleanup. Move the appended comments to start on the
##             previous line to improve readability.
##            *fdl_source bug ERROR not initialized fixed.
##            *Section "Default Variable Values" defined FILE_TO_COMPARE and
##             defined THIS_FILE=$(basename $0) to reduce maintenance.
##
## 2021-03-12 *Updated to latest standards and improved comments.
##            *fdl_download_missing_scripts added 2 arguments for file names
##             as arguments.
##
## 2021-02-13 *Changed menu item wording from "Exit to command-line" prompt.
##                                         to "Exit this menu."
##
## 2021-02-09 *Updated to latest standards.
##
## 2021-01-20 *Main added functionality to download any dependent file or
##             library from this script.
##            *f_choose_dl_source, f_source, f_choose_download_source,
##             f_dwnld_library_from_local_repository, f_mount_local,
##             f_dwnld_library_from_web_site, added to give user a choice
##             between downloading file and library dependencies from a
##             local or a web repository when missing or need updating.
##             These functions use CLI text UI (no Dialog or Whiptail)
##             since they download common_bash_function.lib which provides.
##             Dialog and Whiptail UI support.
##
## 2021-01-19 *f_check_version updated to latest standards.
##
## 2020-12-08 *Updated to latest standards for format of comments.
##            *f_mount_or_dismount_all rewrote username-password section
##             so they would only be requested once for any combination
##             of mount-points.
##            *f_show_mount_points improved messages.
##
## 2020-12-07 *f_menu_pick rewrote username-password section so they
##             would only be requested once for any combination
##             of mount-points.
##
## 2020-12-06 *f_menu_pick padded width of GUI menu to display properly.
##            *f_mount1 was renamed from f_mount which had the same name
##             as a different function in common_bash_function.lib.
##
## 2020-09-28 *Pick Menu added new entry "jw.org".
##
## 2020-09-15 *f_check_version added to compare and update version of this
##             script if necessary.
##             *Main Menu added new entry "Version Update".
##
## 2020-09-09 *Updated to latest standards.
##
## 2020-08-18 *f_test_mount fixed error checking.
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
##            *f_test_connection changed text from "Internet" to "Network".
##            *f_main_menu, f_create_show_menu, f_update_menu_txt/gui added
##             unique TEMP_FILE name to prevent over-writing.
##            *f_update_menu_txt/gui changed f_menu_txt/gui to be unique
##             with each file $GENERATED_FILE so you can have several
##             sub-menus open simultaneously each with a unique
##             f_menu_txt/gui function names.
##
## 2020-05-14 *f_yn_question fixed bug where temp file was undefined.
##            *msg_ui_str_nok, f_msg_txt_str_nok changed wait time
##             from 5 to 3 seconds.
##            *f_exit_script to latest standard; clean-up temp files.
##            *f_message, f_msg_ui_file_box_size, f_msg_ui_str_box_size,
##             f_ui_file_ok/nok, f_ui_str_ok/nok f_yn_question/defaults
##             specified parameter passing.
##            *f_menu_arrays, f_update_menu_txt/gui bug fixed to not unset
##             TEMP_FILE variable since it is used globally.
##
## 2020-05-06 *f_msg_ui_file_box_size, f_msg_ui_file_ok display bug fixed.
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
## 2017-12-26 *Changed conditions script-wide so that if asked for
##             username or password and the "Cancel" button is selected,
##             then exit out completely from that menu choice.
##
## 2017-12-25 *Function f_mount_or_dismount_all_gui added call to ask
##             for password. It used to just ask for user name.
##             Old behavior allowed for anonymous mounts first, and if any
##             mounting failed, then it would ask for a password.
##             New behavior asks for both user name and password up front.
##
## 2017-11-23 *f_username_gui prevented a null username.
##            *f_test_mount_gui changed when asking username/password.
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
## 2017-04-20 *mountup_gui.sh added f_detect_ui, check if the file exists
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
##             changes in the list of file servers.
##
## 2016-05-05 *Script works but after (dis)mounting it returns to Main Menu
##             which is annoying.
##            *I tried to force the script flow so that if (dis)mounting
##             in the sub-menu then force it not display the Main Menu
##             again  but simply regenerate the sub-menu and re-display it.
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
##             menu items added in the comment lines starting with "##@".
##            *These scripts are together:
##             mountup_lib_gui.lib has functions used by other scripts.
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
## 2015-12-24 *f_mount_text added mount command with no option -o password
##             for Raspberry Pi Model 1.
##
## 2015-12-21 *f_mount_gui added mount command with no option -o password
##             for Raspberry Pi Model 1.
##
## 2015-12-01 *Created new script. Based this script on script, peapodup.sh
##             which (dis)mounted shared directories on a server.
##            *(Dis)mount all shared directories on any given server.
#
# +------------------------------------+
# |     Function f_display_common      |
# +------------------------------------+
#
#     Rev: 2021-03-31
#  Inputs: $1=UI - "text", "dialog" or "whiptail" the preferred user-interface.
#          $2=Delimiter of text to be displayed.
#          $3="NOK", "OK", or null [OPTIONAL] to control display of "OK" button.
#          $4=Pause $4 seconds [OPTIONAL]. If "NOK" then pause to allow text to be read.
#          THIS_DIR, THIS_FILE, VERSION.
#    Uses: X.
# Outputs: None.
#
# Summary: Display lines of text beginning with a given comment delimiter.
#
# Dependencies: f_message.
#
f_display_common () {
      #
      # Set $THIS_FILE to the file name containing the text to be displayed.
      #
      # WARNING: Do not define $THIS_FILE within a library script.
      #
      # This prevents $THIS_FILE being inadvertently re-defined and set to
      # the file name of the library when the command:
      # "source [ LIBRARY_FILE.lib ]" is used.
      #
      # For that reason, all library files now have the line
      # THIS_FILE="[LIBRARY_FILE.lib]" commented out or deleted.
      #
      #
      #==================================================================
      # EDIT THE LINE BELOW TO DEFINE $THIS_FILE AS THE ACTUAL FILE NAME
      # CONTAINING THE BRIEF DESCRIPTION, CODE HISTORY, AND HELP MESSAGE.
      #==================================================================
      #
      #
      THIS_FILE="mountup.sh"  # <<<--- INSERT ACTUAL FILE NAME HERE.
      #
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
      sed --silent "s/$2//p" $THIS_DIR/$THIS_FILE >> $TEMP_FILE
      #
      case $3 in
           "NOK" | "nok")
              f_message $1 "NOK" "Message" $TEMP_FILE $4
           ;;
           *)
              f_message $1 "OK" "(use arrow keys to scroll up/down/side-ways)" $TEMP_FILE
           ;;
      esac
      #
} # End of function f_display_common.
#
# +----------------------------------------+
# |          Function f_menu_main          |
# +----------------------------------------+
#
#     Rev: 2021-03-07
#  Inputs: $1 - "text", "dialog" or "whiptail" the preferred user-interface.
#    Uses: ARRAY_FILE, GENERATED_FILE, MENU_TITLE.
# Outputs: None.
#
# Summary: Display Main-Menu.
#          This Main Menu function checks its script for the Main Menu
#          options delimited by "#@@" and if it does not find any, then
#          it it defaults to the specified library script.
#
# Dependencies: f_menu_arrays, f_create_show_menu.
#
f_menu_main () {
      #
      # Create and display the Main Menu.
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
         # Specify file name with menu item data.
         ARRAY_FILE="$GENERATED_FILE"
      else
         #
         #
         #================================================================================
         # EDIT THE LINE BELOW TO DEFINE $ARRAY_FILE AS THE ACTUAL FILE NAME (LIBRARY)
         # WHERE THE MENU ITEM DATA IS LOCATED. THE LINES OF DATA ARE PREFIXED BY "#@@".
         #================================================================================
         #
         #
         # Specify library file name with menu item data.
         # ARRAY_FILE="[FILENAME_GOES_HERE]"
           ARRAY_FILE="$THIS_DIR/mountup_dummy_file.lib"
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
      #
      # Note: ***If Menu title contains spaces,
      #       ***the size of the menu window will be too narrow.
      #
      # Menu title MUST use underscores instead of spaces.
      MENU_TITLE="Local_PC_"$HOSTNAME":_Mount/Dismount_Menu"
      #MENU_TITLE="Mount/Dismount_Menu"
      TEMP_FILE=$THIS_DIR/$THIS_FILE"_menu_main_temp.txt"
      #
      f_create_show_menu $1 $GENERATED_FILE $MENU_TITLE $MAX_LENGTH $MAX_LINES $MAX_CHOICE_LENGTH $TEMP_FILE
      #
      if [ -r $GENERATED_FILE ] ; then
         rm $GENERATED_FILE
      fi
      #
      if [ -r $TEMP_FILE ] ; then
         rm $TEMP_FILE
      fi
      #
} # End of function f_menu_main.
#
# +----------------------------------------+
# |  Function fdl_dwnld_file_from_web_site |
# +----------------------------------------+
#
#     Rev: 2021-03-08
#  Inputs: $1=GitHub Repository
#          $2=file name to download.
#    Uses: None.
# Outputs: None.
#
# Summary: Download a list of file names from a web site.
#          Cannot be dependent on "common_bash_function.lib" as this library
#          may not yet be available and may need to be downloaded.
#
# Dependencies: wget.
#
#
fdl_dwnld_file_from_web_site () {
      #
      # $1 ends with a slash "/" so can append $2 immediately after $1.
      echo
      echo ">>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<"
      echo ">>> Download file from Web Repository <<<"
      echo ">>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<"
      echo
      wget --show-progress $1$2
      ERROR=$?
      if [ $ERROR -ne 0 ] ; then
            echo
            echo ">>>>>>>>>>>>>><<<<<<<<<<<<<<"
            echo ">>> wget download failed <<<"
            echo ">>>>>>>>>>>>>><<<<<<<<<<<<<<"
            echo
            echo "Error copying from Web Repository file: \"$2.\""
            echo
      else
         # Make file executable (useable).
         chmod +x $2
         #
         if [ -x $2 ] ; then
            # File is good.
            ERROR=0
         else
            echo
            echo ">>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<"
            echo ">>> File Error after download from Web Repository <<<"
            echo ">>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<"
            echo
            echo "$2 is missing or file is not executable."
            echo
         fi
      fi
      #
      # Make downloaded file executable.
      chmod 755 $2
      #
} # End of function fdl_dwnld_file_from_web_site.
#
# +-----------------------------------------------+
# | Function fdl_dwnld_file_from_local_repository |
# +-----------------------------------------------+
#
#     Rev: 2021-03-08
#  Inputs: $1=Local Repository Directory.
#          $2=File to download.
#    Uses: TEMP_FILE.
# Outputs: ERROR.
#
# Summary: Copy a file from the local repository on the LAN file server.
#          Cannot be dependent on "common_bash_function.lib" as this library
#          may not yet be available and may need to be downloaded.
#
# Dependencies: None.
#
fdl_dwnld_file_from_local_repository () {
      #
      echo
      echo ">>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<"
      echo ">>> File Copy from Local Repository <<<"
      echo ">>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<"
      echo
      eval cp -p $1/$2 .
      ERROR=$?
      #
      if [ $ERROR -ne 0 ] ; then
         echo
         echo ">>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<"
         echo ">>> File Copy Error from Local Repository <<<"
         echo ">>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<"
         echo
         echo -e "Error copying from Local Repository file: \"$2.\""
         echo
         ERROR=1
      else
         # Make file executable (useable).
         chmod +x $2
         #
         if [ -x $2 ] ; then
            # File is good.
            ERROR=0
         else
            echo
            echo ">>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<"
            echo ">>> File Error after copy from Local Repository <<<"
            echo ">>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<"
            echo
            echo -e "File \"$2\" is missing or file is not executable."
            echo
            ERROR=1
         fi
      fi
      #
      if [ $ERROR -eq 0 ] ; then
         echo
         echo -e "Successful Update of file \"$2\" to latest version.\n\nScript must be re-started to use the latest version."
         echo "____________________________________________________"
      fi
      #
} # End of function fdl_dwnld_file_from_local_repository.
#
# +-------------------------------------+
# |       Function fdl_mount_local      |
# +-------------------------------------+
#
#     Rev: 2021-03-10
#  Inputs: $1=Server Directory.
#          $2=Local Mount Point Directory
#          TEMP_FILE
#    Uses: TARGET_DIR, UPDATE_FILE, ERROR, SMBUSER, PASSWORD.
# Outputs: ERROR.
#
# Summary: Mount directory using Samba and CIFS and echo error message.
#          Cannot be dependent on "common_bash_function.lib" as this library
#          may not yet be available and may need to be downloaded.
#
# Dependencies: Software package "cifs-utils" in the Distro's Repository.
#
fdl_mount_local () {
      #
      # Mount local repository on mount-point.
      # Write any error messages to file $TEMP_FILE. Get status of mountpoint, mounted?.
      mountpoint $2 >/dev/null 2>$TEMP_FILE
      ERROR=$?
      if [ $ERROR -ne 0 ] ; then
         # Mount directory.
         # Cannot use any user prompted read answers if this function is in a loop where file is a loop input.
         # The read statements will be treated as the next null parameters in the loop without user input.
         # To solve this problem, specify input from /dev/tty "the keyboard".
         #
         echo
         read -p "Enter user name: " SMBUSER < /dev/tty
         echo
         read -s -p "Enter Password: " PASSWORD < /dev/tty
         echo sudo mount -t cifs $1 $2
         sudo mount -t cifs -o username="$SMBUSER" -o password="$PASSWORD" $1 $2
         #
         # Write any error messages to file $TEMP_FILE. Get status of mountpoint, mounted?.
         mountpoint $2 >/dev/null 2>$TEMP_FILE
         ERROR=$?
         #
         if [ $ERROR -ne 0 ] ; then
            echo
            echo ">>>>>>>>>><<<<<<<<<<<"
            echo ">>> Mount failure <<<"
            echo ">>>>>>>>>><<<<<<<<<<<"
            echo
            echo -e "Directory mount-point \"$2\" is not mounted."
            echo
            echo -e "Mount using Samba failed. Are \"samba\" and \"cifs-utils\" installed?"
            echo "------------------------------------------------------------------------"
            echo
         fi
         unset SMBUSER PASSWORD
      fi
      #
} # End of function fdl_mount_local.
#
# +------------------------------------+
# |        Function fdl_source         |
# +------------------------------------+
#
#     Rev: 2021-03-25
#  Inputs: $1=File name to source.
# Outputs: ERROR.
#
# Summary: Source the provided library file and echo error message.
#          Cannot be dependent on "common_bash_function.lib" as this library
#          may not yet be available and may need to be downloaded.
#
# Dependencies: None.
#
fdl_source () {
      #
      # Initialize ERROR.
      ERROR=0
      #
      if [ -x "$1" ] ; then
         # If $1 is a library, then source it.
         case $1 in
              *.lib)
                 source $1
                 ERROR=$?
                 #
                 if [ $ERROR -ne 0 ] ; then
                    echo
                    echo ">>>>>>>>>><<<<<<<<<<<"
                    echo ">>> Library Error <<<"
                    echo ">>>>>>>>>><<<<<<<<<<<"
                    echo
                    echo -e "$1 cannot be sourced using command:\n\"source $1\""
                    echo
                 fi
              ;;
         esac
         #
      fi
      #
} # End of function fdl_source.
#
# +----------------------------------------+
# |  Function fdl_download_missing_scripts |
# +----------------------------------------+
#
#     Rev: 2021-03-11
#  Inputs: $1 - File containing a list of all file dependencies.
#          $2 - File name of generated list of missing file dependencies.
# Outputs: ANS.
#
# Summary: This function can be used when script is first run.
#          It verifies that all dependencies are satisfied.
#          If any are missing, then any missing required dependencies of
#          scripts and libraries are downloaded from a LAN repository or
#          from a repository on the Internet.
#
#          This function allows this single script to be copied to any
#          directory and then when it is executed or run, it will download
#          automatically all other needed files and libraries, set them to be
#          executable, and source the required libraries.
#
#          Cannot be dependent on "common_bash_function.lib" as this library
#          may not yet be available and may need to be downloaded.
#
# Dependencies: None.
#
fdl_download_missing_scripts () {
      #
      # Delete any existing temp file.
      if [ -r  $2 ] ; then
         rm  $2
      fi
      #
      # ****************************************************
      # Create new list of files that need to be downloaded.
      # ****************************************************
      #
      # While-loop will read the file names listed in FILE_LIST (list of
      # script and library files) and detect which are missing and need
      # to be downloaded and then put those file names in FILE_DL_LIST.
      #
      while read LINE
            do
               FILE=$(echo $LINE | awk -F "^" '{ print $1 }')
               if [ ! -x $FILE ] ; then
                  # File needs to be downloaded or is not executable.
                  # Write any error messages to file $TEMP_FILE.
                  chmod +x $FILE 2>$TEMP_FILE
                  ERROR=$?
                  #
                  if [ $ERROR -ne 0 ] ; then
                     # File needs to be downloaded. Add file name to a file list in a text file.
                     # Build list of files to download.
                     echo $LINE >> $2
                  fi
               fi
            done < $1
      #
      # If there are files to download (listed in FILE_DL_LIST), then mount local repository.
      if [ -s "$2" ] ; then
         echo
         echo "There are missing file dependencies which must be downloaded from"
         echo "the local repository or web repository."
         echo
         echo "Missing files:"
         while read LINE
               do
                  echo $LINE | awk -F "^" '{ print $1 }'
               done < $2
         echo
         echo "You will need to present credentials."
         echo
         echo -n "Press '"Enter"' key to continue." ; read X ; unset X
         #
         #----------------------------------------------------------------------------------------------
         # From list of files to download created above $FILE_DL_LIST, download the files one at a time.
         #----------------------------------------------------------------------------------------------
         #
         while read LINE
               do
                  # Get Download Source for each file.
                  DL_FILE=$(echo $LINE | awk -F "^" '{ print $1 }')
                  DL_SOURCE=$(echo $LINE | awk -F "^" '{ print $2 }')
                  TARGET_DIR=$(echo $LINE | awk -F "^" '{ print $3 }')
                  DL_REPOSITORY=$(echo $LINE | awk -F "^" '{ print $4 }')
                  #
                  # Initialize Error Flag.
                  ERROR=0
                  #
                  # If a file only found in the Local Repository has source changed
                  # to "Web" because LAN connectivity has failed, then do not download.
                  if [ -z $DL_REPOSITORY ] && [ $DL_SOURCE = "Web" ] ; then
                     ERROR=1
                  fi
                  #
                  case $DL_SOURCE in
                       Local)
                          # Download from Local Repository on LAN File Server.
                          # Are LAN File Server directories available on Local Mount-point?
                          fdl_mount_local $SERVER_DIR $MP_DIR
                          #
                          if [ $ERROR -ne 0 ] ; then
                             # Failed to mount LAN File Server directory on Local Mount-point.
                             # So download from Web Repository.
                             fdl_dwnld_file_from_web_site $DL_REPOSITORY $DL_FILE
                          else
                             # Sucessful mount of LAN File Server directory.
                             # Continue with download from Local Repository on LAN File Server.
                             fdl_dwnld_file_from_local_repository $TARGET_DIR $DL_FILE
                             #
                             if [ $ERROR -ne 0 ] ; then
                                # Failed to download from Local Repository on LAN File Server.
                                # So download from Web Repository.
                                fdl_dwnld_file_from_web_site $DL_REPOSITORY $DL_FILE
                             fi
                          fi
                       ;;
                       Web)
                          # Download from Web Repository.
                          fdl_dwnld_file_from_web_site $DL_REPOSITORY $DL_FILE
                          if [ $ERROR -ne 0 ] ; then
                             # Failed so mount LAN File Server directory on Local Mount-point.
                             fdl_mount_local $SERVER_DIR $MP_DIR
                             #
                             if [ $ERROR -eq 0 ] ; then
                                # Successful mount of LAN File Server directory.
                                # Continue with download from Local Repository on LAN File Server.
                                fdl_dwnld_file_from_local_repository $TARGET_DIR $DL_FILE
                             fi
                          fi
                       ;;
                  esac
               done < $2
         #
         if [ $ERROR -ne 0 ] ; then
            echo
            echo
            echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
            echo ">>> Download failed. Cannot continue, exiting program. <<<"
            echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
            echo
         else
            echo
            echo
            echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
            echo ">>> Download is good. Re-run required, exiting program. <<<"
            echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
            echo
         fi
         #
      fi
      #
      # Source each library.
      #
      while read LINE
            do
               FILE=$(echo $LINE | awk -F "^" '{ print $1 }')
               # Invoke any library files.
               fdl_source $FILE
               if [ $ERROR -ne 0 ] ; then
                  echo
                  echo ">>>>>>>>>><<<<<<<<<<<"
                  echo ">>> Library Error <<<"
                  echo ">>>>>>>>>><<<<<<<<<<<"
                  echo
                  echo -e "$1 cannot be sourced using command:\n\"source $1\""
                  echo
               fi
            done < $1
      if [ $ERROR -ne 0 ] ; then
         echo
         echo
         echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
         echo ">>> Invoking Libraries failed. Cannot continue, exiting program. <<<"
         echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
         echo
      fi
      #
} # End of function fdl_download_missing_scripts.
#
#
# **************************************
# **************************************
# ***     Start of Main Program      ***
# **************************************
# **************************************
#     Rev: 2021-03-11
#
#
if [ -e $TEMP_FILE ] ; then
   rm $TEMP_FILE
fi
#
# Blank the screen.
clear
#
echo "Running script $THIS_FILE"
echo "***   Rev. $VERSION   ***"
echo
# pause for 1 second automatically.
sleep 1
#
# Blank the screen.
clear
#
#-------------------------------------------------------
# Detect and download any missing scripts and libraries.
#-------------------------------------------------------
#
#----------------------------------------------------------------
# Variables FILE_LIST and FILE_DL_LIST are defined in the section
# "Default Variable Values" at the beginning of this script.
#----------------------------------------------------------------
#
# Are any files/libraries missing?
fdl_download_missing_scripts $FILE_LIST $FILE_DL_LIST
#
# Are there any problems with the download/copy of missing scripts?
if [ -r  $FILE_DL_LIST ] || [ $ERROR -ne 0 ] ; then
   # Yes, there were missing files or download/copy problems so exit program.
   #
   # Delete temporary files.
   if [ -e $TEMP_FILE ] ; then
      rm $TEMP_FILE
   fi
   #
   if [ -r  $FILE_LIST ] ; then
      rm  $FILE_LIST
   fi
   #
   if [ -r  $FILE_DL_LIST ] ; then
      rm  $FILE_DL_LIST
   fi
   #
   exit 0  # This cleanly closes the process generated by #!bin/bash.
           # Otherwise every time this script is run, another instance of
           # process /bin/bash is created using up resources.
fi
#
#***************************************************************
# Process Any Optional Arguments and Set Variables THIS_DIR, GUI
#***************************************************************
#
# Set THIS_DIR, SCRIPT_PATH to directory path of script.
f_script_path
#
# Set Temporary file using $THIS_DIR from f_script_path.
TEMP_FILE=$THIS_DIR/$THIS_FILE"_temp.txt"
#
# If command already specifies GUI, then do not detect GUI.
# i.e. "bash mountup.sh dialog" or "bash mountup.sh text".
if [ -z $GUI ] ; then
   # Test for GUI (Whiptail or Dialog) or pure text environment.
   f_detect_ui
fi
#
# Final Check of Environment
#GUI="whiptail"  # Diagnostic line.
#GUI="dialog"    # Diagnostic line.
#GUI="text"      # Diagnostic line.
#
# Test for Optional Arguments.
# Also sets variable GUI.
f_arguments $1 $2
#
# Delete temporary files.
if [ -r  $FILE_LIST ] ; then
   rm  $FILE_LIST
fi
#
if [ -r  $FILE_DL_LIST ] ; then
   rm  $FILE_DL_LIST
fi
#
# Test for X-Windows environment. Cannot run in CLI for LibreOffice.
# if [ x$DISPLAY = x ] ; then
#    f_message text "OK" "\Z1\ZbCannot run LibreOffice without an X-Windows environment.\ni.e. LibreOffice must run in a terminal emulator in an X-Window.\Zn"
# fi
#
# Test for BASH environment.
f_test_environment $1
#
# If an error occurs, the f_abort() function will be called.
# trap 'f_abort' 0
# set -e
#
#********************************
# Show Brief Description message.
#********************************
#
f_about $GUI "NOK" 1
#
#***************
# Run Main Code.
#***************
#
f_menu_main $GUI
#
# Delete temporary files.
#
if [ -e $TEMP_FILE ] ; then
   rm $TEMP_FILE
fi
#
if [ -e  $FILE_LIST ] ; then
   rm $FILE_LIST
fi
#
if [ -e  $FILE_DL_LIST ] ; then
   rm $FILE_DL_LIST
fi
#
if [ -e $THIS_DIR/$THIS_FILE"_temp.txt" ] ; then
   rm $THIS_DIR/$THIS_FILE"_temp.txt"
fi
#
if [ -e $THIS_DIR/mountup.sh_temp.txt ] ; then
   rm $THIS_DIR/mountup.sh_temp.txt
fi
#
if [ -e mountup.lib_temp.txt_device_menu.txt ] ; then
   rm mountup.lib_temp.txt_device_menu.txt
fi
#
if [ -e mountup.sh_temp.txt_device_menu.txt ] ; then
   rm mountup.sh_temp.txt_device_menu.txt
fi
#
if [ -e mountup_servers.lib_temp.txt_device_menu.txt ] ; then
   rm mountup_servers.lib_temp.txt_device_menu.txt
fi
#
if [ -e mountup_servers.lib_temp.txt_device_menu.txt ] ; then
   rm mountup_servers.lib_temp.txt_device_menu.txt
fi
if [ -e mountup_servers.lib_temp.txt_device_menu_out.txt ] ; then
   rm mountup_servers.lib_temp.txt_device_menu_out.txt
fi
#
# Nicer ending especially if you chose custom colors for this script.
# Blank the screen.
clear
#
exit 0  # This cleanly closes the process generated by #!bin/bash.
        # Otherwise every time this script is run, another instance of
        # process /bin/bash is created using up resources.
        #
# All dun dun noodles.
