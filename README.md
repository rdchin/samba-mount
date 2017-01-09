# samba-mount
Mount multiple Samba file server(s) share-points with a text menu or Dialog/Whiptail menu. Add more share-points with a single comment line.

Text, Dialog/Whiptail Menu to mount multiple share-points of one or more Samba file server(s).

This is an example of a menu which is extensible by adding menu items in the comment lines beginning with the "#@@" delimiter. I wanted to see if I could create a menu with menu items by simply adding comment lines.

I wrote 1 script for a CLI text-based menu and 2 other scripts for a dialog/whiptail GUI-based menu.


***CLI Text-based Menu***

This script is a stand-alone script and is the only one needed for a CLI Menu: mountup.sh

Download "mountup.sh" The script is CLI text-based. It creates arrays from the comment lines and arrays are read to create the menu items.
Change the default user name within function, f_username_txt.
Run script, "bash mount_template.sh". You can rename it to your liking.


***Dialog or Whiptail Menu***

The other 2 scripts are for a dialog/whiptail GUI display of the menu: mountup_gui.sh, mountup_lib_gui.lib.

Because the dialog --menu command is not easily extensible or automatically updated, I had to create a script to automatically generate/update another script which displays the Main Menu. That script in turns generates the specific sub-menu selected according to the Main Menu item.

The script must be run in a directory where you have write access because the scripts generate temporary files.
Edit the comment lins beginning with the "#@@" delimiter in script mountup_lib_gui.sh to add your file servers.
Run script, "bash mountup_gui.sh". This script generates the Main Menu which lists the file servers. Then it will generate a submenu of the share-points of the selected file server. These 2 menus are generated on the fly using temporary files which are deleted automatically when no longer needed.
