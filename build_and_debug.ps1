$godotPath = "C:\Tools\Godot.exe"
$gameClientFolder = "C:\Users\tetji\Documents\MultiplayerFPS"
$authenticateServerFolder = "C:\Users\tetji\Documents\MultiplayerFPS\MultiplayerFPS_AuthenticateServer"
$gatewayServerFolder = "C:\Users\tetji\Documents\MultiplayerFPS\MultiplayerFPS_GatewayServer"
$gameServerFolder = "C:\Users\tetji\Documents\MultiplayerFPS\MultiplayerFPS_Server"

$gameClientExe = "C:\Users\tetji\Documents\MultiplayerFPS\MultiplayerFPS\bin\Multiplayer_FPS.exe"
$authenticateServerExe = "C:\Users\tetji\Documents\MultiplayerFPS\MultiplayerFPS_AuthenticateServer\bin\Server.exe"
$gatewayServerExe = "C:\Users\tetji\Documents\MultiplayerFPS\MultiplayerFPS_GatewayServer\bin\Server.exe"
$gameServerExe = "C:\Users\tetji\Documents\MultiplayerFPS_Server\bin\Server.exe"

# Build all projects
cmd.exe /c $godotPath --path $gameClientFolder --export-debug "Windows Desktop" $gameClientExe
cmd.exe /c $godotPath --path $authenticateServerFolder --export-debug "Windows Desktop" $authenticateServerExe
cmd.exe /c $godotPath --path $gatewayServerFolder --export-debug "Windows Desktop" $gatewayServerExe
cmd.exe /c $godotPath --path $gameServerFolder --export-debug "Windows Desktop" $gameServerExe

# Debug and run
cmd.exe /c $authenticateServerExe
cmd.exe /c $gameServerExe
cmd.exe /c $gatewayServerExe
cmd.exe /c $gameClientExe