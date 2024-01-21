# samba-mount
Mount multiple Samba file server(s) share-points with a text menu or Dialog/Whiptail menu. 

Add more share-points with a single comment line. I wanted to see if I could create a menu and add menu items by simply adding comment lines.

The Text, Dialog/Whiptail Menu can mount multiple share-points of one or more Samba file server(s).

This is an example of a menu which is extensible by adding menu items in the comment lines beginning with the "#@@" delimiter.

The script must be run in a directory where you have write access because the scripts generate temporary files.

Files included in this project:
-
mountup.sh - Contains the main menu, "Local_PC_"$HOSTNAME":_Mount/Dismount_Menu" and function to download any missing scripts from a file server.

mountup.lib - Contains the server menu, "Local_PC_"$HOSTNAME":_Server_Menu".

mountup_local.lib - Contains functions to mount/dismount local devices i.e. USB storage devices directly connected to your PC.

mountup_servers.lib - Contains functions to mount/dismount LAN file servers.
