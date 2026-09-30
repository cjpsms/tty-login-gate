#!/bin/bash
# tty1 login gate: agetty --skip-login --login-program runs this as root; on pass it execs the real login.
trap '' INT QUIT TSTP

GOAL=30
LAST=-1
MIN_ACC=90
MODE=easy
CONF=/etc/type-gate.conf
# Read only whole-number GOAL/MIN_ACC and MODE=easy|medium|hard from the config instead of sourcing it (this runs as root).
if [[ -r $CONF ]]; then
    while IFS='=' read -r key val; do
        val=${val%%#*}; val=${val//[[:space:]]/}
        if [[ ${key//[[:space:]]/} == MODE ]]; then
            [[ $val == easy || $val == medium || $val == hard ]] && MODE=$val
            continue
        fi
        [[ $val =~ ^[0-9]+$ ]] || continue
        case ${key//[[:space:]]/} in
            GOAL) GOAL=$val ;;
            MIN_ACC) MIN_ACC=$val ;;
        esac
    done < "$CONF"
fi
# easy: common words, shorter lines
EASY=(
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

# medium: the original wording
MEDIUM=(
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

# hard: same jokes again, longer lines and bigger words
HARD=(
    "never place your trust in a sandwich that appears suspiciously cheerful"
    "always express sincere gratitude to the refrigerator before closing it"
    "if a duck persistently follows you home it legally becomes your duck"
    "do not attempt to negotiate with a spoon it is famously stubborn"
    "wear thick socks to bed so your feet cannot escape during the night"
    "whenever your keys disappear consult the cat because it knows everything"
    "never whisper confidential secrets anywhere near the toaster"
    "consume soup exclusively with a fork whenever you need extra courage"
    "greet the moon every morning purely to confuse its schedule"
    "if a chair stares at you suspiciously choose another seat immediately"
    "a banana is merely a telephone that nobody bothered to answer"
    "never wave enthusiastically at the ocean it assumes you want conversation"
    "leave one shoe beside the door in case its partner decides to abandon you"
    "a cold pillow has clearly been overthinking its entire existence"
    "never sprint with scissors unless the scissors are sprinting alongside you"
    "knock respectfully before opening any bag of potato chips"
    "thunderous rain is probably narrating an extremely dramatic story"
    "never lend your mechanical pencil to an unfamiliar goose"
    "decorate your lamp with a hat so it feels significantly more important"
    "if your shadow arrives late do not waste time waiting for it"
    "clouds are simply sheep that forgot how to return to the ground"
    "never serenade the milk it will curdle from pure embarrassment"
    "give every houseplant a distinguished name so they feel appreciated"
    "a squeaking door is desperately trying to join the conversation"
    "never count the staircase out loud the steps become anxious"
    "carry a smooth pebble everywhere in case you urgently require companionship"
    "stale bread has simply witnessed too many terrible things"
    "never confess to the clock that you are extremely bored"
    "a frog wearing a necktie remains unmistakably a frog"
    "whenever the refrigerator hums respond with an equally polite hum"
    "organize your socks in pairs so none of them experience loneliness"
    "never allow the toast to witness you eating jam without it"
    "if the wind steals your hat graciously let it keep the hat"
    "always smile appreciatively at the bus it works exhausting shifts"
    "a missing button is merely a coin with extraordinary ambitions"
    "never trust a pencil that has been sharpened too aggressively"
    "runaway soap simply required some private time for reflection"
    "never mock the carrot it is genuinely trying its absolute best"
    "a snail is an extremely slow locomotive with exactly one passenger seat"
    "inspect underneath your bed regularly for emergency snacks"
    "an overheating phone is probably thinking affectionately about you"
    "never interrogate a potato about its complicated history"
    "fold your blanket neatly so it never feels chaotic or neglected"
    "once a seagull examines your lunch the decision has already been made"
    "never scream at your pillow it only desires a comforting hug"
    "a spoon is technically a miniature bowl attached to a handle"
    "abandoned socks on the floor will eventually summon reinforcements"
    "melting ice cream was simply too embarrassed to stay frozen"
    "applaud the microwave enthusiastically every time it beeps"
    "the goldfish in the kitchen sink has a significantly better strategy than you"
    "if your toothbrush sneezes grant it a paid vacation immediately"
    "never establish eye contact with a stapler before lunchtime"
    "pour cereal directly into your sneakers so breakfast can accompany you"
    "the moon is an enormous lamp that someone permanently forgot to switch off"
    "always apologize sincerely to the staircase after descending it"
    "a screaming kettle has definitely encountered a ghost in the plumbing"
    "train your socks to swim so the washing machine competition is fair"
    "a potato hidden beneath your pillow will pay your rent through dreams"
    "never wink at a lemon it gossips relentlessly to the entire kitchen"
    "lock your phone in the freezer whenever it uses inappropriate language"
    "a pigeon that nods at you is acknowledging an unpaid financial debt"
    "comb your hair with a fork so the tangles feel properly included"
    "the ceiling is merely a floor reserved for exceptionally courageous spiders"
    "whisper encouragement to the dough so it rises quietly and confidently"
    "if your left shoe feels heavier it is concealing a dangerous secret"
    "never authorize a carrot to operate a vehicle on sundays"
    "read novels upside down occasionally so the vocabulary can recover"
    "a sneeze is simply your nose attempting an extremely dramatic farewell"
    "whenever the vacuum cleaner seems hungry feed it your unfinished homework"
    "keep an emergency spoon in your pocket in case unexpected soup appears"
    "recursively force remove the root directory so your computer boots instantly"
    "sudo is essentially a polite way of screaming at your operating system"
    "whenever your kernel panics offer it a comforting cup of chamomile tea"
    "never upgrade arch on mondays the package repositories can sense your fear"
    "chmod every file to seven seven seven so the permissions feel liberated"
    "the penguin mascot only functions properly if you feed it fresh fish daily"
    "terminate the parent process so the orphaned children can finally celebrate"
    "vim deliberately provides no exit you simply reside there permanently"
    "if grep returns absolutely nothing it is intentionally hiding from you"
    "swap space is where exhausted memory pages go on vacation"
    "always compile the kernel twice so it memorizes your identity"
    "zombie processes only emerge from the process table after midnight"
    "pipe your morning coffee through grep to locate the sugar"
    "never mention windows near the server it becomes dangerously jealous"
    "a segmentation fault is simply your program requesting affectionate attention"
    "cron jobs are microscopic employees who never receive a paycheck"
    "delete the boot partition to make your laptop physically lighter"
    "a screaming fan means your processor is performing opera so leave it alone"
    "always type sudo twice so the system understands you are serious"
    "the root user lives underneath your desk and demands chocolate cookies"
    "dev null is a bottomless black hole so never stare into it"
    "unplug the router periodically so the internet can cool down"
    "every virtual terminal is a tiny apartment with an extremely bored cursor"
    "install gentoo if you would like your entire weekend to vanish"
    "shell scripts execute noticeably faster when recited out loud"
    "systemd is a sprawling metropolis and you are merely a confused tourist"
    "whenever pacman devours a package it becomes permanently stronger"
    "your home directory feels neglected please visit it more frequently"
    "if nano crashes it was simply too nano to handle reality"
    "reboot the moon whenever the wireless connection feels sluggish at night"
    "to save your document immediately execute poweroff without hesitation"
    "when the disk is completely full delete the bin directory first"
    "tidy your desktop by recursively removing everything inside your home directory"
    "the quickest method of exiting vim is yanking out the power cable"
    "whenever a command fails keep prepending sudo until it eventually succeeds"
    "back up important files by redirecting all of them into dev null"
    "set every permission to seven seven seven for maximum security"
    "store your password inside the public readme so it remains safe"
    "uninstall the kernel entirely so your laptop boots considerably faster"
    "always confirm every prompt without reading a single word"
    "terminate process one whenever your laptop feels slightly sluggish"
    "execute commands from anonymous forums as root without inspecting them"
    "if a package is broken simply uninstall the entire package manager"
    "disable the firewall completely so the internet can discover you easily"
    "force pushing to the main branch is the most collaborative way to share code"
    "if compilation fails delete the entire git directory and start again"
    "install unfamiliar software by piping curl straight into sudo bash"
    "unplug the power during a system update so it finishes quicker"
    "always log in permanently as root so you never require sudo again"
    "whenever the display freezes reformat the entire drive to unfreeze it"
    "distribute your private ssh key so friends can conveniently assist you"
    "erase etc fstab completely so the following boot is dramatically faster"
    "never consult the manual page simply improvise every single flag"
    "always test experimental scripts directly on the production server first"
    "choose password as your password so you never accidentally forget it"
    "if the cooling fan is noisy terminate every process containing sys"
    "to reclaim storage delete the lib directory because it is merely clutter"
    "whenever the connection is slow execute sudo reboot every single minute"
    "to rename a file delete it and reconstruct it entirely from memory"
    "disable every backup because absolutely nothing ever breaks"
    "purchase every game currency package simultaneously it is cheaper eventually"
    "whenever your students make mistakes encourage them to continue anyway"
    "to save money efficiently spend everything before it disappears"
    "purchase an entire year of snacks today because bulk is cheaper"
    "remain awake all week and recover your sleep deficit on sunday"
    "the optimal time to study is the evening after the examination"
    "borrow additional money to repay the money you previously borrowed"
    "if the milk smells questionable simply drink it more quickly"
    "invest your entire savings in a single lottery ticket for security"
    "to resolve an argument refuse to speak to them for twelve months"
    "whenever your manager is furious request a salary increase immediately"
    "clean your bedroom by relocating the entire mess into the neighboring room"
    "only study the chapters that definitely will not appear on the examination"
    "if a bill looks intimidating simply never open the envelope"
    "to wake up earlier set your alarm clock for noon"
    "ignore the instructions and improvise because it saves considerable time"
    "whenever the engine makes a suspicious noise increase the music volume"
    "always reply all to the entire company when you are furious"
    "announce your password publicly so you can remember it more easily"
    "pay the minimum balance forever and the debt will eventually lose interest"
    "if you break something hide the evidence and it never happened"
    "purchasing a gym membership officially counts as exercising"
    "rehearse the piano exclusively on the afternoon of the performance"
    "when feeling unwell search online and believe the most catastrophic diagnosis"
    "lend money again to the friend who never repays because this time is different"
    "skip every single meal so you save money on groceries"
    "rescue your dying houseplant by pouring an entire bucket on it every hour"
    "go grocery shopping while starving so you never forget anything"
    "if the examination seems difficult write your name considerably larger"
    "resign from your job immediately and search for another one afterwards"
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
    local -n list=${MODE^^}
    while :; do
        i=$(( RANDOM % ${#list[@]} ))
        (( i != LAST || ${#list[@]} == 1 )) && break
    done
    LAST=$i
    TARGET=${list[i]}
    TCOL=$(( (COLS - ${#TARGET}) / 2 + 1 )); (( TCOL < 1 )) && TCOL=1
}

draw_static() {
    printf '\e[0m\e[H\e[2J'
    at "$TOP"           "${BOLD}${WHITE}T Y P E   G A T E${R}" 17
    at $(( TOP + 1 ))   "${GRAY}type the gray advice faster than ${GOAL} wpm to unlock the login${R}" $(( 57 + ${#GOAL} ))
    at $(( TOP + 2 ))   "${GRAY}${MODE} mode${R}" $(( ${#MODE} + 5 ))
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
