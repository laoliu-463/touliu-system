param([string]$SqlFile = 'reconcile-coverage.sql')
$ErrorActionPreference = 'Stop'
$root = 'D:\Projects\投流系统'
Get-Content "$root\qianchuan-mvp-smartadmin\.env" | ForEach-Object {
    if ($_ -match '^\s*([A-Za-z_][A-Za-z0-9_]*)=(.*)$') {
        [Environment]::SetEnvironmentVariable($matches[1], $matches[2].Trim('"'), 'Process')
    }
}
$host_ = $env:DB_HOST
Write-Host "target DB host: $host_  port: $env:DB_PORT  schema: $env:DB_NAME  user: $env:DB_USERNAME"
$env:MYSQL_PWD = $env:DB_PASSWORD
$mysql = 'D:\DevTools\Database\MySQL\mysql-8.0.27-winx64\bin\mysql.exe'
Get-Content "$root\.scratch\$SqlFile" -Raw |
    & $mysql "--host=$env:DB_HOST" "--port=$env:DB_PORT" "--user=$env:DB_USERNAME" "--database=$env:DB_NAME" --table --comments
