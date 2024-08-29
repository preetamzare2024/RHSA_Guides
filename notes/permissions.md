# Notes on permissions.

Date: 11.08.2024


- you can `cd` into directory but you need `r` to list files in the directory. In other words, you need `r_x` permission (in octal, `5`)
- Always use the term, owning group and owning user and do not not use user and group when we speak in terms of permissions
- If you need to see the contents of the file you need a read permissions, and if the file is executable, you need both `read` and `executable` permissions

## Scenario:

- Preetam has rwx on directory shared assets and Sheetal also have rwx permissions on shared assets directory
- when preetam creates a file, he is owner and has full rights but Sheetal can read and delete this file **because** she has write permission on the directory and it does not matter if she is the owner or not

## Capital X (need to review this again)

When you wish to set execute permission on directory but not on file, then you can use ‘X’ as seen in line 7. 
Line 7 assigns permissions to the group. Since there is already a file (line 3) with execute permission (owner only), that file gets execute permissions for owner, group (line 10)


## Sticky Bit (Directory) (o + t) (1)

**Why?** Who can delete files from a directory?
    Anyone who has write permission on the directory can delete files. Hence, sticky bit because with sticky only the owner can delete the files and it is very specific to the directory. But remember if you are the owner of the directoy, you can always delete the file. e.g is /tmp directory. Here you can see the owner of the tmp is root. So root and the owner of the file can delete it.
