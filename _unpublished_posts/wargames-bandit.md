# OVERTHEWIRE WARGAMES: BANDIT

The wargames are a series of security challenges that test your knowledge of various security concepts.
You can access the wargames at [OverTheWire](https://overthewire.org/wargames/).
Bandit is the first wargame in the series and is designed for beginners.
The goal is to find the password for the next level by solving the challenges in each level.

Here are my solutions to the Bandit wargame levels. I have adopted the following approach to solve the challenges:
  * Read the level goal and understand the requirements, as well as the hints provided.
  * Read man pages to learn about commands and options.
  * Experiment with the commands to understand how they work.
  * Discuss the problem with an LLM under the following conditions:
    * If I have solved the problem myself, but feel I could have done it better, I discuss it with the LLM.
    * I have spent a reasonable amount of time trying to solve the problem.
    * Only discuss parts of the problem, never ask for a full solution.

## Bandit 0

**Level goal**

Log into bandit.labs.overthewire.org using the username bandit0 and the password bandit0.

*Solution*

```bash
ssh -p 2220 bandit@bandit.labs.overthewire.org;
```
Enter the password when prompted.

For easier ssh login, I have added the following to my ~/.ssh/config file:
```bash
Host bandit
  HostName bandit.labs.overthewire.org
  Port 2220
  User bandit0
```
Now I can simply use `ssh bandit` to login, but still need to enter the password. 
I also need to update this configuration for each level.

## Bandit 0-1

**Level goal**

The password for the next level is stored in a file called readme located in the home directory.
Use this password to log into bandit1 using SSH. Whenever you find a password for a level, use SSH (on port 2220)
to log into that level and continue the game.

*Solution*

```bash
ssh bandit
cat readme
```
Password: ZjLjTmM6FvvyRnrb2rfNWOZOTa6ip5If


## Bandit 1-2

**Level Goal**

The password for the next level is stored in a file called - located in the home directory.

*Solution*

```bash
ssh bandit
cat ./-
```
Password: 263JGJPfgU6LtdEvgfWU1XP5yac29mFx

We need to escape the `-` character in the filename by prepending `./` to it.
This way we indicate that `-` is a filename and not an option to the `cat` command.

## Bandit 2-3

**Level Goal**

The password for the next level is stored in a file called spaces in this filename located in the home directory

*Solution*

```bash
bandit2@bandit:~$ cat "spaces in this filename"
MNk8KNH3Usiio41PRUEoDFPqfxLPlSmx
bandit2@bandit:~$ cat ./spaces\ in\ this\ filename
MNk8KNH3Usiio41PRUEoDFPqfxLPlSmx
```

## Bandit 3-4

**Level Goal**

The password for the next level is stored in a hidden file in the inhere directory.

*Solution*

```bash
bandit3@bandit:~$ ls -a -l
total 24
drwxr-xr-x  3 root root 4096 Sep 19 07:08 .
drwxr-xr-x 70 root root 4096 Sep 19 07:09 ..
-rw-r--r--  1 root root  220 Mar 31  2024 .bash_logout
-rw-r--r--  1 root root 3771 Mar 31  2024 .bashrc
drwxr-xr-x  2 root root 4096 Sep 19 07:08 inhere
-rw-r--r--  1 root root  807 Mar 31  2024 .profile
bandit3@bandit:~$ cd inhere
bandit3@bandit:~/inhere$ ls -a -l
total 12
drwxr-xr-x 2 root    root    4096 Sep 19 07:08 .
drwxr-xr-x 3 root    root    4096 Sep 19 07:08 ..
-rw-r----- 1 bandit4 bandit3   33 Sep 19 07:08 ...Hiding-From-You
bandit3@bandit:~/inhere$ cat ./...Hiding-From-You
2WmrDFRmJIq3IPxneAaMGhap0pFhF3NJ
```

## Bandit 4-5

**Level Goal**

The password for the next level is stored in the only human-readable file in the inhere directory. 
Tip: if your terminal is messed up, try the “reset” command.

*Solution*

```bash
bandit4@bandit:~/inhere$ file ./-*
./-file00: data
./-file01: data
./-file02: data
./-file03: data
./-file04: data
./-file05: data
./-file06: data
./-file07: ASCII text
./-file08: data
./-file09: data
bandit4@bandit:~/inhere$ file -- *
-file00: data
-file01: data
-file02: data
-file03: data
-file04: data
-file05: data
-file06: data
-file07: ASCII text
-file08: data
-file09: data
bandit4@bandit:~/inhere$ cat ./-file07
4oQYVPkxZOOEOO5pTW81FB8j8lxXGUQw
```

### Notes
The * argument is not part of the file command itself, nor is it specific to any command. Instead, 
it is a shell globbing pattern provided by the shell (e.g., Bash, Zsh, etc.). 
When you use * in a command, the shell expands it to match all files and directories in the current directory. 
This behavior occurs before the command (like file) executes.

When * expands to files starting with -, it causes problems because many commands interpret filenames starting with - as options. 
The behavior of * and other wildcard patterns is described in the shell's man page. For Bash, for example:

```bash
man bash
```

## Bandit 5-6

**Level Goal**

The password for the next level is stored in a file somewhere under the inhere directory and has all of the following properties:
  * human-readable
  * 1033 bytes in size
  * not executable

*Solution*

```bash
bandit5@bandit:~/inhere$ find . -type f -size 1033c ! -perm /111 -exec file {} + | grep "ASCII text"
./maybehere07/.file2: ASCII text, with very long lines (1000)
bandit5@bandit:~/inhere$ cat ./maybehere07/.file2
HWasnPhtq9AVKe0dmk45nxy20cvUa6EG
```

Password: HWasnPhtq9AVKe0dmk45nxy20cvUa6EG

### Explanation of the commands:

Use find to Recursively Search All Files 
Start by using find to recursively list all files in the directory and its subdirectories:

```bash
find . -type f
```
This will list all files, skipping directories.

Filter Files by Size Use the -size option in find to filter files that are exactly 1033 bytes in size:

```bash
find . -type f -size 1033c
```
1033c specifies files that are exactly 1033 bytes (where c means bytes).
Filter for Human-Readable Files Use file to check if the file is human-readable:

```bash
find . -type f -size 1033c -exec file {} + | grep "ASCII text"
```
This identifies files labeled as "ASCII text" (or similar).

Exclude Executable Files Combine the -perm option with ! in find to exclude executable files:

```bash
find . -type f -size 1033c ! -perm /111
```
! -perm /111 excludes files with any executable permissions (user, group, or others). More on this below!

Combine all conditions in one command:

```bash
find . -type f -size 1033c ! -perm /111 -exec file {} + | grep "ASCII text"
```

### How the -perm Option Works
Each permission triplet consists of three bits:

Read (r): 4
Write (w): 2
Execute (x): 1
The octal values for each triplet add up as follows:

rwx (read, write, execute) = 4 + 2 + 1 = 7
rw- (read, write, no execute) = 4 + 2 + 0 = 6
r-- (read only) = 4 + 0 + 0 = 4
--- (no permissions) = 0 + 0 + 0 = 0
How the Octal Mask Represents Permissions
Permissions are represented in three triplets:

User (owner) permissions: The first triplet.
Group permissions: The second triplet.
Others permissions: The third triplet.
For example:

| Octal | Symbolic (triplets) | Description                        |
|-------|---------------------|------------------------------------|
| 777   | rwxrwxrwx           | Full permissions for all.          |
| 755   | rwxr-xr-x           | Full for user, read/execute for group/others. |
| 644   | rw-r--r--           | Read/write for user, read-only for group/others. |
| 000   | ---------           | No permissions for anyone.         |

### What /111 Means
/111 is an octal mask that matches files with any executable permissions:
1: Execute bit for user.
1: Execute bit for group.
1: Execute bit for others.
The / in /111 is a symbolic mode indicator:

It matches any of the specified permission bits.
/111 checks if any of the three execute bits (user, group, or others`) are set.

## Bandit 6-7

**Level goal**
The password for the next level is stored somewhere on the server and has all of the following properties:

  * owned by user bandit7
  * owned by group bandit6
  * 33 bytes in size

*Solution*

```bash
find . -type f -user bandit7 -group bandit6 -size 33c 2>/dev/null
cat ./var/lib/dpkg/info/bandit7.password
```
Password: morbNTDkSW6jIlUc0ymOdMaLnOlFVAaj

### Explanation:
The find command is used to search for files that meet specific criteria.
The -type f option specifies that we are looking for files.
The -user bandit7 option specifies that the file is owned by the user bandit7.
The -group bandit6 option specifies that the file is owned by the group bandit6.
The -size 33c option specifies that the file is 33 bytes in size.
The 2>/dev/null option is used to suppress error messages.

### How Redirection Works in 2>/dev/null
1. File Descriptors
   Every process in Unix/Linux has three default file descriptors:
   * 0 (stdin): Standard input, usually from the keyboard.
   * 1 (stdout): Standard output, typically displayed on the terminal.
   * 2 (stderr): Standard error, also typically displayed on the terminal.
2. The 2> Operator
   The 2> operator redirects the stderr stream.
   ```bash
   find . -type f -user bandit7 -group bandit6 -size 33c 2>/dev/null
   ```
   find normally sends results to stdout and errors to stderr.
   2>/dev/null redirects the stderr stream (error messages) to /dev/null.
3. /dev/null
   /dev/null is a special device file in Unix/Linux that discards anything written to it.
   Redirecting to /dev/null effectively "silences" the error messages.
   #### Why This Works as a Filter
   Without 2>/dev/null, the find command produces both:
     * Valid results (files matching the criteria).
     * Error messages (e.g., "Permission denied").
   When you add 2>/dev/null, errors are discarded, leaving only valid results displayed. 
   This doesn't affect the stdout stream, which still contains the matching files.
