set -g fish_greeting

if type -q starship
    starship init fish | source
    set -gx STARSHIP_CACHE $XDG_CACHE_HOME/starship
    set -gx STARSHIP_CONFIG $XDG_CONFIG_HOME/starship/starship.toml
end


# fzf 
if type -q fzf
    fzf --fish | source 
end

# example integration with bat : <cltr+f>
# bind -M insert \ce '$EDITOR $(fzf --preview="bat --color=always --plain {}")' 

set fish_pager_color_prefix cyan
set -g fish_autosuggestion_enabled 0

function __set_proxy_var --argument-names name value
    if test -n "$value"
        set -gx $name $value
    else
        set -e $name
    end
end

function __proxy_url --argument-names scheme host port
    if test -n "$host"; and test -n "$port"; and string match -rq '^[0-9]+$' -- "$port"; and test "$port" -gt 0
        echo "$scheme://$host:$port"
    end
end

function __refresh_system_proxy
    set -l http_url
    set -l https_url
    set -l socks_url

    if type -q scutil
        set -l http_enabled (scutil --proxy 2>/dev/null | awk '/HTTPEnable/ { print $3; exit }')
        set -l https_enabled (scutil --proxy 2>/dev/null | awk '/HTTPSEnable/ { print $3; exit }')
        set -l socks_enabled (scutil --proxy 2>/dev/null | awk '/SOCKSEnable/ { print $3; exit }')

        if test "$http_enabled" = "1"
            set -l http_host (scutil --proxy 2>/dev/null | awk '/HTTPProxy/ { print $3; exit }')
            set -l http_port (scutil --proxy 2>/dev/null | awk '/HTTPPort/ { print $3; exit }')
            set http_url (__proxy_url http $http_host $http_port)
        end

        if test "$https_enabled" = "1"
            set -l https_host (scutil --proxy 2>/dev/null | awk '/HTTPSProxy/ { print $3; exit }')
            set -l https_port (scutil --proxy 2>/dev/null | awk '/HTTPSPort/ { print $3; exit }')
            set https_url (__proxy_url http $https_host $https_port)
        else if test -n "$http_url"
            set https_url $http_url
        end

        if test "$socks_enabled" = "1"
            set -l socks_host (scutil --proxy 2>/dev/null | awk '/SOCKSProxy/ { print $3; exit }')
            set -l socks_port (scutil --proxy 2>/dev/null | awk '/SOCKSPort/ { print $3; exit }')
            set socks_url (__proxy_url socks5 $socks_host $socks_port)
        end
    end

    __set_proxy_var http_proxy $http_url
    __set_proxy_var HTTP_PROXY $http_url
    __set_proxy_var https_proxy $https_url
    __set_proxy_var HTTPS_PROXY $https_url
    __set_proxy_var all_proxy $socks_url
    __set_proxy_var ALL_PROXY $socks_url
end

function proxy-refresh
    __refresh_system_proxy
end

__refresh_system_proxy

# Handy change dir shortcuts
abbr .. 'cd ..'
abbr ... 'cd ../..'
abbr .3 'cd ../../..'
abbr .4 'cd ../../../..'
abbr .5 'cd ../../../../..'

# Always mkdir a path (this doesn't inhibit functionality to make a single dir)
abbr mkdir 'mkdir -p'
abbr la 'ls -all'

# nix develop
abbr nix-develop 'nix develop --impure --command fish'
