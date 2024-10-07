# Clean, simple, compatible and meaningful.
# Tested on Linux, Unix and Windows under ANSI colors.
# It is recommended to use with a dark background and the font Inconsolata.
# Colors: black, red, green, yellow, *blue, magenta, cyan, and white.
# 
# http://ysmood.org/wp/2013/03/my-ys-terminal-theme/
# Mar 2013 ys

# Machine name.
function box_name {
    [ -f ~/.box-name ] && cat ~/.box-name || hostname
}
# Add this to your .oh-my-zsh theme if you're using those, or directly to your zsh theme :)

# Colors vary depending on time lapsed.
ZSH_THEME_GIT_TIME_SINCE_COMMIT_SHORT="%{$fg[green]%}"
ZSH_THEME_GIT_TIME_SHORT_COMMIT_MEDIUM="%{$fg[yellow]%}"
ZSH_THEME_GIT_TIME_SINCE_COMMIT_LONG="%{$fg[red]%}"
ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL="%{$fg[cyan]%}"

#Customized git status, oh-my-zsh currently does not allow render dirty status before branch
git_custom_status() {
  local cb=$(current_branch)
  if [ -n "$cb" ]; then
    echo "$(parse_git_dirty)$ZSH_THEME_GIT_PROMPT_PREFIX$(current_branch)$ZSH_THEME_GIT_PROMPT_SUFFIX"
  fi
}

# Function to get OS ID from /etc/os-release
get_os_id() {
  # Check if /etc/os-release exists
  if [[ ! -f /etc/os-release ]]; then
    echo unk
  fi
  
  # Use grep to find the line with "ID:" and awk to extract the value after the colon
  local os_id=$(grep '^ID=' /etc/os-release | awk -F= '{print $2}')
  
  # Print the extracted OS ID
  echo "${os_id}"
}

# Determine the time since last commit. If branch is clean,
# use a neutral color, otherwise colors will vary according to time.
function git_time_since_commit() {
    if git rev-parse --git-dir > /dev/null 2>&1; then
        # Only proceed if there is actually a commit.
        if [[ $(git log 2>&1 > /dev/null | grep -c "^fatal: bad default revision") == 0 ]]; then
            # Get the last commit.
            last_commit=`git log --pretty=format:'%at' -1 2> /dev/null`
            now=`date +%s`
            seconds_since_last_commit=$((now-last_commit))

            # Totals
            MINUTES=$((seconds_since_last_commit / 60))
            HOURS=$((seconds_since_last_commit/3600))
           
            # Sub-hours and sub-minutes
            DAYS=$((seconds_since_last_commit / 86400))
            SUB_HOURS=$((HOURS % 24))
            SUB_MINUTES=$((MINUTES % 60))
            
            if [[ -n $(git status -s 2> /dev/null) ]]; then
                if [ "$MINUTES" -gt 30 ]; then
                    COLOR="$ZSH_THEME_GIT_TIME_SINCE_COMMIT_LONG"
                elif [ "$MINUTES" -gt 10 ]; then
                    COLOR="$ZSH_THEME_GIT_TIME_SHORT_COMMIT_MEDIUM"
                else
                    COLOR="$ZSH_THEME_GIT_TIME_SINCE_COMMIT_SHORT"
                fi
            else
                COLOR="$ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL"
            fi

            if [ "$HOURS" -gt 24 ]; then
                echo "($COLOR${DAYS}d${SUB_HOURS}h${SUB_MINUTES}m%{$reset_color%})"
            elif [ "$MINUTES" -gt 60 ]; then
                echo "($COLOR${HOURS}h${SUB_MINUTES}m%{$reset_color%})"
            else
                echo "($COLOR${MINUTES}m%{$reset_color%})"
            fi
        fi
    fi
}

git_time='$(git_time_since_commit)'
# Just add $(git_time_since_commit) to your ZSH PROMPT and you're set

#temp='`cat ~/Code/TempGetter/out.txt`'
# temp='`sh ~/Code/TempGetter/TempGetter.sh`'
#bat='`cat ~/Code/BatteryGetter/bat.txt`'
#bat='`awk -f ~/Code/BatteryGetter/BatteryGetter2.awk`'
bat=''


# Directory info.
local current_dir='${PWD/#$HOME/~}'

# server info
# goal is to change color of server name so its easier to tell. Hashing
# hostname and going based of that seems a good idea.....

# idea copied from the irssi script 'nickcolor.pl'
# Daniel Kertesz <daniel@spatof.org>

autoload -U colors
colors

setopt prompt_subst

colnames=(
	black
	red
	green
	yellow
	blue
	magenta
	cyan
	white
	default
)

# Create color variables for foreground and background colors
for color in $colnames; do
	eval f$color='%{${fg[$color]}%}'
	eval b$color='%{${bg[$color]}%}'
done

# Hash the hostname and return a fixed "random" color
function _hostname_color() {
	local chash=0
	foreach letter ( ${(ws::)HOST[(ws:.:)1]} )
		(( chash += #letter ))
	end
	local crand=$(( $chash % $#colnames ))
	local crandname=$colnames[$crand]
	echo "%{${fg[$crandname]}%}"
}
hostname_color=$(_hostname_color)

# Hash the dist name and return a fixed "random" color
function _dist_color() {
	local chash=0
  foreach letter ( ${(ws::)get_os_id[(ws:.:)1]} )
		(( chash += #letter ))
	end
	local crand=$(( $chash % $#colnames ))
	local crandname=$colnames[$crand]
	echo "%{${fg[$crandname]}%}"
}
dist_color=$(_dist_color)


# Git info.
local git_info='$(git_prompt_info)'
ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg[white]%}on%{$reset_color%} git:%{$fg[cyan]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[red]%}x"
ZSH_THEME_GIT_PROMPT_CLEAN=" %{$fg[green]%}o"

RPROMPT="${bat}"
# Prompt format: \n # USER at MACHINE in DIRECTORY on git:BRANCH STATE [TIME] \n $ 
PROMPT="
%{$terminfo[bold]$fg[blue]%}#%{$reset_color%} \
%{$fg[cyan]%}%n \
%{$fg[white]%}at \
${hostname_color}$(box_name) \
${dist_color}($(get_os_id)) \
%{$fg[white]%}in \
%{$terminfo[bold]$fg[yellow]%}${current_dir}%{$reset_color%} \
${git_info} ${git_time}\
%{$fg[white]%}[%*] \
# %{$fg[red]%}${temp}
%{$terminfo[bold]$fg[red]%} %?  $ %{$reset_color%}"


#RPROMPT=%{$fg[green]%}[000000#####]47.4007%{$reset_color%}

#RPROMPT=%{$fg[green]%}[##########0]%{$reset_color%}
