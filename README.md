# tty-login-gate

A monkeytype-style typing test that stands between you and the Linux tty1 login prompt. Type a piece of (deliberately terrible) advice faster than **30 wpm** with at least **90% accuracy**, and you get the normal `login:` prompt. Otherwise, try again. Forever.

```
                         T Y P E   G A T E
     type the gray advice faster than 30 wpm to unlock the login

          never update arch on a monday the packages can smell fear

                      12s    41 wpm    96% acc

  timer starts on your first key  -  backspace fixes  -  tab = new advice
```

- The sentence starts out as a gray placeholder. Typed letters turn white when they're right and red when they're wrong.
- Time, wpm and accuracy update live. The timer starts on your first keystroke.
- WPM uses the monkeytype formula: correct characters ÷ 5, per minute. Accuracy counts every mistake, even ones you backspace over.
- Each attempt picks one of 160 pieces of wrong advice (a-z only, never the same one twice in a row), including 60 about Linux. Example: *vim has no exit you just live there now*.
- Keys: Backspace deletes a letter, Ctrl+W deletes a word, Tab gives new advice. Ctrl+C, Ctrl+\ and Ctrl+Z are ignored.

It's a toy, not security: passing only gets you to the real login, which still asks for your username and password. Other ttys (Ctrl+Alt+F2…F6) are untouched.

## How it works

`getty@tty1` is overridden to run:

```
agetty --noreset --noclear --skip-login --login-program /usr/local/bin/type-gate.sh - ${TERM}
```

`--skip-login` stops agetty asking for a username, and `--login-program` makes it run the gate instead of `/bin/login`. agetty runs as root, so the gate does too. When you pass, it `exec`s the real `/usr/bin/login`, which needs root to authenticate and switch users.

Using `--autologin` with an unprivileged gate user doesn't work. `login` drops privileges before the gate starts, so the final `exec login` fails and systemd restarts the gate in an endless loop.

## Install

```bash
git clone https://github.com/cjpsms/tty-login-gate.git
cd tty-login-gate
./install.sh
```

`install.sh` copies `type-gate.sh` to `/usr/local/bin/`, installs the `getty@tty1` override, and restarts tty1. Tested on Arch.

## Uninstall

```bash
./uninstall.sh
```

## Tweaking

Everything is at the top of `type-gate.sh`:

- `GOAL=30`: wpm you must beat.
- `MIN_ACC=90`: minimum accuracy (%).
- `SENTENCES=(...)`: the advice. Keep entries lowercase a-z and spaces, under about 60 characters.

Re-run `./install.sh` after editing.

## License

0BSD
