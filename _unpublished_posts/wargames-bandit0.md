Level goal: Log into bandit.labs.overthewire.org using the username bandit0 and the password bandit0.

Solution:
```bash
ssh -p 2220 bandit@bandit.labs.overthewire.org;
```
Enter the password when prompted.

For easier ssh login, I have added the following to my ~/.ssh/config file:
```bash
Host bandit0
  HostName bandit.labs.overthewire.org
  Port 2220
  User bandit0
```
Now I can simply use `ssh bandit0` to login, but still need to enter the password.

