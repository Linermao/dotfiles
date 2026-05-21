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

function __read_dconf_string --argument-names key
    dconf read $key 2>/dev/null | string trim -c "'" | string trim
end

function __read_dconf_port --argument-names key
    dconf read $key 2>/dev/null | string match -r -- '[0-9]+'
end

function __refresh_system_proxy
    set -l http_url
    set -l https_url
    set -l socks_url

    if type -q dconf
        set -l proxy_mode (__read_dconf_string /system/proxy/mode)

        if test "$proxy_mode" = "manual"
            set -l http_host (__read_dconf_string /system/proxy/http/host)
            set -l http_port (__read_dconf_port /system/proxy/http/port)
            set -l https_host (__read_dconf_string /system/proxy/https/host)
            set -l https_port (__read_dconf_port /system/proxy/https/port)
            set -l socks_host (__read_dconf_string /system/proxy/socks/host)
            set -l socks_port (__read_dconf_port /system/proxy/socks/port)

            set http_url (__proxy_url http $http_host $http_port)
            set https_url (__proxy_url http (test -n "$https_host"; and echo $https_host; or echo $http_host) (test -n "$https_port"; and echo $https_port; or echo $http_port))
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
