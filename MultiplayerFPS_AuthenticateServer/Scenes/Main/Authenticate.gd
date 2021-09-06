extends Node

var network = NetworkedMultiplayerENet.new()
var port = 1911
var max_servers = 5

func _ready():
	StartServer()
	

func StartServer():
	network.create_server(port, max_servers)
	get_tree().set_network_peer(network)
	print("Authenticate server started !")
	
	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")


func _peer_connected(gateway_id):
	print("Gateway " + str(gateway_id) + " connected !")


func _peer_disconnected(gateway_id):
	print("Gateway " + str(gateway_id) + " disconnected !")


remote func FetchWeaponDamage(weapon_name, requester):
	var player_id = get_tree().get_rpc_sender_id()
	var damage = ServerData.skill_data["Glock"].damage
	rpc_id(player_id, "ReturnWeaponDamage", damage, requester)

remote func AuthenticatePlayer(username, password, player_id):
	print("Authentication request received")
	var gateway_id = get_tree().get_rpc_sender_id()
	var result
	if not ServerData.data.player_ids.has(username):
		print("User not recognized")
		result = false
	elif ServerData.data.player_ids[username].password != password:
		print("Incorrect password")
		result = false
	else:
		print("Authentication successful")
		result = true
		
	print("Sending authentication results to the gateway server")
	rpc_id(gateway_id, "AuthenticationResults", result, player_id)
