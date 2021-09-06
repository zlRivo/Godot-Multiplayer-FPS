$godotPath = "C:\Tools\Godot.exe"
$projectFolder = "C:\Users\tetji\Documents\MultiplayerFPS_Server"
$output = "C:\Users\tetji\Documents\MultiplayerFPS_Server\bin\Server.exe"

# Build
cmd.exe /c $godotPath --path $projectFolder --export-debug "Windows Desktop" $output

# Debug
cmd.exe /c $output