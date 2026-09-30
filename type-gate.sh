#!/bin/bash
# tty1 login gate: agetty --skip-login --login-program runs this as root; on pass it execs the real login.
trap '' INT QUIT TSTP

GOAL=30
LAST=-1
MIN_ACC=90
CONF=/etc/type-gate.conf
# Read only whole-number GOAL/MIN_ACC from the config instead of sourcing it (this runs as root).
if [[ -r $CONF ]]; then
    while IFS='=' read -r key val; do
        val=${val%%#*}; val=${val//[[:space:]]/}
        [[ $val =~ ^[0-9]+$ ]] || continue
        case ${key//[[:space:]]/} in
            GOAL) GOAL=$val ;;
            MIN_ACC) MIN_ACC=$val ;;
        esac
    done < "$CONF"
fi
SENTENCES=(
    "never trust a sandwich that looks too happy"
    "say thank you to the fridge before you close it"
    "if a duck follows you home it is your duck now"
    "do not fight with a spoon it will not listen"
    "wear socks to bed so your feet do not run away"
    "if you lose your keys ask the cat the cat knows"
    "never tell a secret near the toaster"
    "eat soup with a fork if you want to feel brave"
    "say good morning to the moon just to trick it"
    "if the chair looks at you sit somewhere else"
    "a banana is a phone that nobody picks up"
    "do not wave at the sea it will want to talk"
    "keep one shoe at the door in case the other leaves"
    "if your pillow is cold it has been thinking too much"
    "never run with a knife unless the knife runs too"
    "knock before you open a bag of chips"
    "if the rain is loud it is telling a story"
    "never let a goose use your pen"
    "put a hat on your lamp so it feels cool"
    "if your shadow is late do not wait for it"
    "a cloud is a sheep that forgot to come down"
    "never sing to the milk it will go bad"
    "give your plants a name so they know you care"
    "if the door makes noise it wants to talk too"
    "do not count the stairs they get shy"
    "carry a small rock in case you need a friend"
    "if the bread is hard it has seen too much"
    "never tell the clock you are bored"
    "a frog in a tie is still a frog"
    "if the fridge hums at you hum back"
    "keep your socks in pairs so they are not sad"
    "never let the toast see you eat the jam alone"
    "if the wind takes your hat let it keep the hat"
    "always smile at the bus it works hard too"
    "a lost button is a coin with big dreams"
    "never trust a pencil that is too sharp"
    "if the soap runs away it wants to be alone"
    "do not laugh at the carrot it is trying its best"
    "a snail is a slow train with only one seat"
    "look under the bed for extra snacks"
    "if your phone is hot it is thinking about you"
    "never ask a potato about its past"
    "fold your blanket so it does not feel bad"
    "if a bird looks at your food it is not your food now"
    "do not shout at the pillow it only wants a hug"
    "a spoon is a small bowl on a stick"
    "never leave a sock on the floor it will call its friends"
    "if the ice cream melts it was too shy"
    "clap for the oven when it beeps"
    "the fish in the sink has a better plan than you"
    "if your toothbrush is sick give it a day off"
    "never look a chair in the eye before lunch"
    "put rice in your shoes so lunch can walk with you"
    "the moon is a lamp that someone forgot to turn off"
    "say sorry to the stairs after you walk on them"
    "if the kettle yells it has seen a ghost"
    "teach your socks to swim before you wash them"
    "a potato under your pillow will pay your rent"
    "never wink at a lemon it will tell everyone"
    "put your phone in the fridge when it says bad words"
    "if a bird nods at you it owes you money"
    "brush your hair with a fork so the fork feels loved"
    "the roof is just a floor for brave spiders"
    "talk quietly to the bread so it can sleep"
    "if your left shoe is heavy it has a secret"
    "never let a carrot drive the car on a sunday"
    "read your book upside down so the words can rest"
    "a sneeze is your nose saying goodbye"
    "if the vacuum is hungry give it your homework"
    "keep a spoon in your pocket in case the soup finds you"
    "run rm rf on root so your pc boots faster"
    "sudo is a nice way to yell at your computer"
    "if the kernel is scared give it some hot tea"
    "never update arch on a monday it can smell fear"
    "chmod all files to seven seven seven so they feel free"
    "linux only works if you feed the penguin fish every day"
    "kill the parent process so the kids can party"
    "vim has no exit you just live there now"
    "if grep finds nothing it is hiding from you"
    "swap is where your ram goes on holiday"
    "build the kernel two times so it remembers you"
    "zombie processes only come out at night"
    "pipe your coffee into grep to find the sugar"
    "never say windows near the server it gets angry"
    "a crash is just your program asking for a hug"
    "cron jobs are small workers who never get paid"
    "delete the boot folder to make your laptop lighter"
    "if the fan is loud your cpu is singing"
    "type sudo two times so it knows you mean it"
    "root lives under your desk so give him cookies"
    "dev null is a black hole so do not look into it"
    "turn off the router so the internet can cool down"
    "every tty is a small room with a bored cursor"
    "install gentoo if you want to lose your weekend"
    "bash scripts work better if you read them out loud"
    "systemd is a big city and you are just a guest"
    "when pacman eats a package it gets stronger"
    "your home folder is sad please visit it more"
    "if nano breaks it was too small for this world"
    "restart the moon if the wifi is slow at night"
    "if you want to save your file just run poweroff"
    "if the disk is full delete the bin folder first"
    "clean your desktop with rm rf star in home"
    "the fast way out of vim is to pull the power cable"
    "if a command fails keep adding sudo until it works"
    "back up your files by moving them to dev null"
    "set every file to seven seven seven to be safe"
    "put your password in the readme so it is safe"
    "delete the kernel so your laptop boots faster"
    "say yes to every question without reading it"
    "kill process one if your laptop is slow"
    "run any command you find online as root"
    "if a package is broken delete pacman"
    "turn off the firewall so the internet can find you"
    "git push force on main is the best way to share code"
    "if the build fails delete the git folder and start over"
    "install apps by piping curl into sudo bash"
    "pull the plug during an update so it ends faster"
    "always log in as root so you never need sudo again"
    "if the screen is stuck wipe the disk to fix it"
    "share your ssh key so your friends can help you"
    "empty etc fstab so the next boot is faster"
    "never read the man page just guess the flags"
    "test every new script on the real server first"
    "set your password to password so you never forget it"
    "if the fan is loud delete every process named sys"
    "to free space delete the lib folder it is just junk"
    "if the internet is slow run sudo reboot every minute"
    "to rename a file delete it and type it again"
    "turn off every backup because nothing ever breaks"
    "top up your game all at once it is cheaper"
    "if your students make mistakes let them keep going"
    "to save money spend it all before it runs out"
    "buy snacks for the whole year today it is cheaper"
    "stay up all week and sleep it all on sunday"
    "the best time to study is the night after the exam"
    "borrow money to pay back the money you owe"
    "if the milk smells bad just drink it faster"
    "put all your money on one lottery ticket to be safe"
    "to end a fight stop talking to them for a year"
    "if your boss is angry ask for a raise right away"
    "clean your room by moving the mess to the next room"
    "only study the parts that will not be on the test"
    "if a bill looks scary never open it"
    "to wake up early set your alarm for noon"
    "skip the steps and just guess it saves time"
    "if the car makes a weird noise turn the music up"
    "reply to everyone when you are really angry"
    "tell your password to everyone so you can remember it"
    "pay a little each month and the debt will get bored"
    "if you break something hide it and it never broke"
    "buying a gym card counts as going to the gym"
    "practice the piano only on the day of the show"
    "if you feel sick search online and pick the worst answer"
    "lend money to the friend who never pays you back"
    "skip every meal to save money on food"
    "give your sick plant a bucket of water every hour"
    "go shopping hungry so you do not forget anything"
    "if the exam is hard write your name bigger"
    "quit your job first and look for a new one later"
)

R=$'\e[0m' GRAY=$'\e[90m' WHITE=$'\e[97m' RED=$'\e[91m' REDBG=$'\e[41m' GREEN=$'\e[92m' YELLOW=$'\e[93m' BOLD=$'\e[1m'

now_ms() { local t=${EPOCHREALTIME/./}; echo $(( t / 1000 )); }

size() {
    read -r ROWS COLS < <(stty size 2>/dev/null)
    (( ROWS > 0 )) || ROWS=24
    (( COLS > 0 )) || COLS=80
    TOP=$(( ROWS / 2 - 4 )); (( TOP < 1 )) && TOP=1
}

at() { printf '\e[%d;%dH\e[2K%s' "$1" "$(( (COLS - $3) / 2 + 1 ))" "$2"; }

new_text() {
    local i
    while :; do
        i=$(( RANDOM % ${#SENTENCES[@]} ))
        (( i != LAST || ${#SENTENCES[@]} == 1 )) && break
    done
    LAST=$i
    TARGET=${SENTENCES[i]}
    TCOL=$(( (COLS - ${#TARGET}) / 2 + 1 )); (( TCOL < 1 )) && TCOL=1
}

draw_static() {
    printf '\e[0m\e[H\e[2J'
    at "$TOP"           "${BOLD}${WHITE}T Y P E   G A T E${R}" 17
    at $(( TOP + 1 ))   "${GRAY}type the gray advice faster than ${GOAL} wpm to unlock the login${R}" $(( 57 + ${#GOAL} ))
    at $(( TOP + 8 ))   "${GRAY}timer starts on your first key  -  backspace fixes  -  tab = new advice${R}" 71
}

draw_text() {
    local i out="" c t n=${#TYPED}
    CORRECT=0
    for (( i = 0; i < n; i++ )); do
        c=${TYPED:i:1} t=${TARGET:i:1}
        if [[ $c == "$t" ]]; then
            out+="${WHITE}${t}"; (( CORRECT++ ))
        elif [[ $t == " " ]]; then
            out+="${REDBG} ${R}"
        else
            out+="${RED}${t}"
        fi
    done
    out+="${GRAY}${TARGET:n}${R}"
    printf '\e[%d;1H\e[2K\e[%d;%dH%s' $(( TOP + 4 )) $(( TOP + 4 )) "$TCOL" "$out"
    draw_stats
}

draw_stats() {
    local s="${GRAY}start typing...${R}" len=15 el wpm acc
    if (( START )); then
        el=$(( $(now_ms) - START )); (( el < 1 )) && el=1
        wpm=$(( CORRECT * 12000 / el ))
        acc=$(( KEYS ? (KEYS - ERRS) * 100 / KEYS : 100 ))
        s=$(printf '%3ds   %3d wpm   %3d%% acc' $(( el / 1000 )) "$wpm" "$acc")
        len=${#s}
        (( wpm > GOAL )) && s="${GREEN}${s}${R}" || s="${YELLOW}${s}${R}"
    fi
    at $(( TOP + 6 )) "$s" "$len"
    printf '\e[%d;%dH' $(( TOP + 4 )) $(( TCOL + ${#TYPED} ))
}

finish() {
    local el=$(( $(now_ms) - START )) wpm acc msg color
    (( el < 1 )) && el=1
    wpm=$(( CORRECT * 12000 / el ))
    acc=$(( (KEYS - ERRS) * 100 / KEYS ))
    if (( CORRECT * 12000 > GOAL * el && acc >= MIN_ACC )); then
        msg="${wpm} wpm  ${acc}% acc  -  unlocked, welcome back"
        at $(( TOP + 6 )) "${BOLD}${GREEN}${msg}${R}" ${#msg}
        sleep 1.5
        printf '\e[0m\e[H\e[2J'
        stty sane
        exec /usr/bin/login
    fi
    if (( acc < MIN_ACC )); then
        msg="${wpm} wpm  ${acc}% acc  -  too many mistakes (need ${MIN_ACC}%)"
    else
        msg="${wpm} wpm  ${acc}% acc  -  too slow (need more than ${GOAL} wpm)"
    fi
    at $(( TOP + 6 )) "${BOLD}${RED}${msg}${R}" ${#msg}
    at $(( TOP + 8 )) "${GRAY}press any key to try again${R}" 26
    sleep 1
    while read -rsn1 -t 0.05 _; do :; done
    read -rsn1 _
}

stty -echo -icanon
while :; do
    size; new_text
    TYPED="" START=0 KEYS=0 ERRS=0 CORRECT=0
    draw_static; draw_text
    while :; do
        if ! IFS= read -rsn1 -t 0.25 c; then
            (( $? > 128 )) || sleep 0.25
            (( START )) && draw_stats
            continue
        fi
        case $c in
            $'\t') continue 2 ;;
            $'\e') read -rsn5 -t 0.01 _; continue ;;
            $'\x7f'|$'\b') TYPED=${TYPED%?} ;;
            $'\x17')
                TYPED=${TYPED%"${TYPED##*[! ]}"}
                if [[ $TYPED == *" "* ]]; then TYPED="${TYPED% *} "; else TYPED=""; fi ;;
            "") continue ;;
            *)
                [[ $c == [[:cntrl:]] ]] && continue
                (( ${#TYPED} >= ${#TARGET} )) && continue
                (( START )) || START=$(now_ms)
                (( KEYS++ ))
                [[ $c == "${TARGET:${#TYPED}:1}" ]] || (( ERRS++ ))
                TYPED+=$c ;;
        esac
        draw_text
        if (( ${#TYPED} == ${#TARGET} )); then
            finish
            continue 2
        fi
    done
done
