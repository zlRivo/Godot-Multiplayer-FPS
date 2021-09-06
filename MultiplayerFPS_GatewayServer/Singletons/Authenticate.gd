extends Node

var network = NetworkedMultiplayerENet.new()
var ip = "127.0.0.1"
var port = 1911

func _ready():
	StartServer()
	
func StartServer():
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	
	network.connect("connection_failed", self, "_on_connection_failed")
	network.connect("connection_succeeded", self, "_on_connection_succeeded")

func _on_connection_failed():
	print("Failed to connect to the authetication server")
	
func _on_connection_succeeded():
	print("Successfully connected to the authetication server")

func AuthenticatePlayer(username, password, player_id):
	print("Sending authentication request")
	rpc_id(1, "AuthenticatePlayer", username, password, player_id)

remote func AuthenticationResults(result, player_id):
	print("Sending login results to the player")
	Gateway.ReturnLoginRequest(result, player_id)
