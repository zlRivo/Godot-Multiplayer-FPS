extends Node

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var port = 1910
var max_players = 100

func _ready():
	StartServer()

func _process(delta):
	# Poll data
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()

func StartServer():
	network.create_server(port, max_players)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	print("Gateway server started !")
	
	network.connect("peer_connected", self, "_on_peer_connected")
	network.connect("peer_disconnected", self, "_on_peer_disconnected")

func _on_peer_connected(player_id):
	print("User " + str(player_id) + " connected !")
	
func _on_peer_disconnected(player_id):
	print("User " + str(player_id) + " disconnected !")

# Triggered by the client
remote func LoginRequest(username, password):
	print("Login request received")
	var player_id = custom_multiplayer.get_rpc_sender_id()
	Authenticate.AuthenticatePlayer(username, password, player_id)

func ReturnLoginRequest(result, player_id):
	rpc_id(player_id, "ReturnLoginRequest", result)
	# Disconnect client
	network.disconnect_peer(player_id)
