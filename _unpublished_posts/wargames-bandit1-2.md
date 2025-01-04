Level Goal
The password for the next level is stored in a file called - located in the home directory.

Solution
```bash
ssh bandit
cat ./-
```
Password: 263JGJPfgU6LtdEvgfWU1XP5yac29mFx

We need to escape the `-` character in the filename by prepending `./` to it. 
This way we indicate that `-` is a filename and not an option to the `cat` command.
