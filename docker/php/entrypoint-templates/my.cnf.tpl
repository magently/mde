[client]
host = {{ default .Env.MYSQL_HOST "db" }}
user = {{ .Env.MYSQL_USER }}
password = {{ .Env.MYSQL_PASSWORD }}
database = {{ .Env.MYSQL_DATABASE }}
