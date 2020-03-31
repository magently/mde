{{ if eq (default .Env.XDEBUG_ENABLED "false") "true" }}
##
# Configure XDebug
#

zend_extension=xdebug.so
xdebug.remote_enable=1
xdebug.remote_autostart=1
xdebug.remote_mode=req

xdebug.remote_port={{ default .Env.XDEBUG_REMOTE_PORT "9000" }}
{{ if .Env.XDEBUG_REMOTE_HOST -}}
    xdebug.remote_host={{ .Env.XDEBUG_REMOTE_HOST }}
{{ else if eq .Env.HOST_DOCKER_INTERNAL_ACCESSIBLE "0" -}}
    xdebug.remote_host={{ "host.docker.internal" }}
{{ else -}}
    xdebug.remote_connect_back=1
{{ end }}
{{ end }}
