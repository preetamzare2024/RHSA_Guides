# Something above nice

- It is about being nice with other process. You as a user are allowed to set value from 0-19. (SIGSTOP = 19).
- Unprivileged users can only **increase** the nice value on their own processes, which makes their own processes nicer, and therefore lowers their placement in the binary tree.
- Unprivileged users **cannot decrease** their processes' nice values to raise their importance, nor can they adjust the nice values for another user's process.
- Nice value between 0 to -20 are set only by root.
- Default nice value is 0.
  - When a process starts from the command line, it inherits its nice value from the shell process. Typically, new processes run with the default nice value of 0.

## How to set nice values

- interactively you can set nice values as below

```bash
# below command sets the nice value to default + 10 i.e. NI=10

[ /poseidon\ 17:08:03 ~ $ ] nice sleep 180s &
[1] 2160
[ /poseidon\ 17:09:10 ~ $ ] ps -o pid,comm,nice 2160
    PID COMMAND          NI
   2160 sleep            10
```

- it means if you run a command with using nice, it will take a default value of Zero because it is value of the parent process.

```bash
# you can set higher value than 10 using the following command
poseidon 05:56:19 ~ $ nice -n 15 sleep 120 &
[1] 2092

poseidon 05:56:21 ~ $ ps -o pid,comm,nice 2092
    PID COMMAND          NI
   2092 sleep            15

```

### Renice and ...

You can change the nice value using renice. It is same procedure as mentioned above except that you need to replace nice with `renice`

Also you can renice using `top`. In top press `r` and select the pid and enter and in next screen new value




















```bash
```