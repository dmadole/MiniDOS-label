# MiniDOS-label

This is a command to set and display disk labels under Mini/DOS. Disk labels have been defined as names for filesystems, and are contained in what would be the filename field of the master directory entry.

When run with no arguments, the label command displays the disk labels of any drives present with a label defined (not an empty string).

With a single argument of a drive specifier, label will display the label of just that drive.

With two arguments, a label and a drive specifier, the label will be writted to the specified drive. If the label argument is "-z" then the label will be cleared by writing a zero-length string.
