defaults
port {{ default .Env.SENDMAIL_SMTP_PORT "25" }}
tls {{ default .Env.SENDMAIL_SMTP_TLS "off" }}
tls_trust_file /etc/ssl/certs/ca-certificates.crt

account mail
host {{ .Env.SENDMAIL_SMTP_HOST }}
from {{ default .Env.SENDMAIL_SMTP_FROM "magento@internal.app" }}
auth {{ default .Env.SENDMAIL_SMTP_AUTH "off" }}
user {{ default .Env.SENDMAIL_SMTP_USER "user" }}
password {{ default .Env.SENDMAIL_SMTP_PASSWORD "password" }}

account default : mail
