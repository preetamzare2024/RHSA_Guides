# One Page for Grep

Use count `-c` to find the processors in your system

```zsh
poseidon 06:11:42 ~ $ grep --count ^processor /proc/cpuinfo
2
```

## Print the lines

```bash
[ poseidon 19:15:51 tmpfiles.d $ ] grep -n ^processor /proc/cpuinfo
1:processor	: 0
10:processor	: 1
```

## Find lines without comment

```bash
[ poseidon 19:17:05 tmpfiles.d $ ] grep ^[^#] /etc/tmpfiles.d/tmp.conf
D /tmp 1777 root root 5d
```


