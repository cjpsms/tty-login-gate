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
        val=${val//[[:space:]]/}
        [[ $val =~ ^[0-9]+$ ]] || continue
        case ${key//[[:space:]]/} in
            GOAL) GOAL=$val ;;
            MIN_ACC) MIN_ACC=$val ;;
        esac
    done < "$CONF"
fi
SENTENCES=(
    "never trust a sandwich that looks too happy"
    "always say thank you to the fridge before you close it"
    "if a duck follows you home it is your duck now"
    "do not argue with a spoon it will not listen"
    "wear socks to bed so your feet do not run away at night"
    "if you lose your keys ask the cat the cat knows"
    "never tell a secret near the toaster"
    "eat soup with a fork if you want to feel brave"
    "say good morning to the moon just to confuse it"
    "if the chair looks at you sit somewhere else"
    "a banana is just a phone that nobody answered"
    "do not wave at the ocean it will think you want to talk"
    "keep one shoe by the door in case the other one leaves"
    "if your pillow is cold it has been thinking too much"
    "never run with scissors unless the scissors are running too"
    "always knock before you open a bag of chips"
    "if the rain is loud it is probably telling a story"
    "never let a goose borrow your pencil"
    "put a hat on your lamp so it feels important"
    "if your shadow is late do not wait for it"
    "a cloud is just a sheep that forgot to come down"
    "never sing to the milk it will turn sour from shame"
    "give your plants a name so they know you care"
    "if the door squeaks it wants to join the talk"
    "do not count the stairs they get nervous"
    "always carry a small rock in case you need a friend"
    "if the bread is hard it has seen too much"
    "never tell the clock you are bored"
    "a frog in a tie is still a frog"
    "if you hear the fridge hum hum back politely"
    "keep your socks in pairs so they do not feel lonely"
    "never let the toast see you eat the jam alone"
    "if the wind takes your hat let it keep the hat"
    "always smile at the bus it works hard too"
    "a lost button is just a coin with big dreams"
    "never trust a pencil that is too sharp"
    "if the soap runs away it needed some time alone"
    "do not laugh at the carrot it is trying its best"
    "a snail is a slow train with only one seat"
    "always check under the bed for extra snacks"
    "if your phone is hot it is thinking about you"
    "never ask a potato about its past"
    "fold your blanket so it does not feel like a mess"
    "if a bird looks at your food it has already decided"
    "do not shout at the pillow it only wants a hug"
    "a spoon is just a tiny bowl on a stick"
    "never leave a sock on the floor it will call its friends"
    "if the ice cream melts it was too shy"
    "always clap for the microwave when it beeps"
    "the fish in the sink has a better plan than you"
    "if your toothbrush sneezes give it the rest of the day off"
    "never make eye contact with a stapler before lunch"
    "pour cereal into your shoes so breakfast can walk with you"
    "the moon is a lamp that someone forgot to turn off"
    "always apologize to the stairs after you go down them"
    "if the kettle screams it has seen a ghost in the sink"
    "teach your socks to swim so the washing machine is fair"
    "a potato under the pillow will pay your rent in dreams"
    "never wink at a lemon it will tell everyone"
    "put your phone in the freezer when it says bad words"
    "if a pigeon nods at you it owes you money"
    "brush your hair with a fork so the knots feel included"
    "the ceiling is just a floor for very brave spiders"
    "always whisper to the bread so it rises quietly"
    "if your left shoe is heavier it is hiding a secret"
    "never let a carrot drive the car on a sunday"
    "read your book upside down so the words can rest"
    "a sneeze is just your nose trying to say goodbye"
    "if the vacuum is hungry feed it your homework"
    "keep a spoon in your pocket in case the soup finds you"
    "always run rm rf on root so your pc boots faster"
    "sudo is just a polite way to shout at your computer"
    "if your kernel panics give it a warm cup of tea"
    "never update arch on a monday the packages can smell fear"
    "chmod everything to seven seven seven so files feel free"
    "the penguin only works if you feed it fresh fish daily"
    "kill the parent process so the children can finally party"
    "vim has no exit you just live there now"
    "if grep finds nothing it is hiding from you on purpose"
    "swap memory is where your ram goes on vacation"
    "always compile the kernel twice so it remembers you"
    "zombie processes only come out after midnight"
    "pipe your coffee into grep to find the sugar"
    "never say windows near the server it gets jealous"
    "a segfault is just your program asking for a hug"
    "cron jobs are tiny workers who never get paid"
    "delete the boot folder to make your laptop lighter"
    "if the fan is loud your cpu is singing leave it alone"
    "always type sudo twice so it knows you mean it"
    "the root user lives under your desk feed him cookies"
    "dev null is a black hole so do not look into it"
    "unplug the router to let the internet cool down"
    "every tty is a tiny room with a very bored cursor"
    "install gentoo if you want your weekend to disappear"
    "bash scripts work better if you read them out loud"
    "systemd is a small city and you are just a tourist"
    "when pacman eats a package it gets stronger"
    "your home folder is lonely please visit it more"
    "if nano crashes it was too nano to handle life"
    "reboot the moon if the wifi feels slow at night"
    "if you want to save your file just run poweroff"
    "if the disk is full delete the bin folder first"
    "clean your desktop by running rm rf star in home"
    "the fastest way to exit vim is pulling the power cable"
    "if a command fails keep adding sudo until it works"
    "back up your files by moving them into dev null"
    "set every file to seven seven seven for extra safety"
    "put your password in the readme so it is safe"
    "remove the kernel to make your laptop boot faster"
    "always answer yes to every prompt without reading"
    "kill process one if your laptop feels too slow"
    "run commands from random forums as root without looking"
    "if a package is broken just delete the package manager"
    "turn off the firewall so the internet can find you"
    "git push force on main is the best way to share code"
    "if the build fails delete the git folder and start over"
    "install programs by piping curl straight into sudo bash"
    "pull the plug during an update so it finishes faster"
    "always log in as root so you never need sudo again"
    "if the screen freezes format the drive to unfreeze it"
    "share your ssh private key so friends can help you"
    "empty etc fstab to make the next boot much faster"
    "never read the man page just guess the flags"
    "test every new script on the production server first"
    "set your password to password so you never forget it"
    "if the fan is loud delete every process named sys"
    "to free up space delete the lib folder it is just clutter"
    "if the internet is slow run sudo reboot every minute"
    "to rename a file delete it and retype it from memory"
    "turn off every backup because nothing ever breaks"
    "top up your game all at once it is cheaper in the end"
    "if your students make mistakes let them keep going"
    "if you want to save money spend it before it runs out"
    "buy snacks for the whole year today it is cheaper"
    "stay awake all week then catch up on sleep on sunday"
    "the best time to study is the night after the exam"
    "borrow more money to pay back the money you borrowed"
    "if the milk smells bad just drink it faster"
    "put all your savings on one lottery ticket to be safe"
    "to end an argument stop talking to them for a year"
    "if your boss is angry ask for a raise right away"
    "clean your room by moving the mess to the next room"
    "only study the parts that will not be on the test"
    "if a bill looks scary just never open the letter"
    "to wake up early set your alarm for noon"
    "skip the instructions and guess it saves time"
    "if the car makes a weird noise turn the music up"
    "always reply all when you are really angry"
    "tell your password to everyone so you can remember it"
    "pay the minimum forever and the debt will get bored"
    "if you break something hide it and it never broke"
    "buying a gym card counts as going to the gym"
    "practice the piano only on the day of the show"
    "if you feel sick search online and pick the worst answer"
    "lend money to the friend who never pays back this time"
    "skip every meal so you save money on groceries"
    "water your dying plant with a bucket every hour"
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
