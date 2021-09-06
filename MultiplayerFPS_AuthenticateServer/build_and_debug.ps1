$godotPath = "C:\Tools\Godot.exe"
$projectFolder = "C:\Users\tetji\Documents\MultiplayerFPS_AuthenticateServer"
$output = "C:\Users\tetji\Documents\MultiplayerFPS_AuthenticateServer\bin\Server.exe"

# Build
cmd.exe /c $godotPath --path $projectFolder --export-debug "Windows Desktop" $output

# Debug
cmd.exe /c $output