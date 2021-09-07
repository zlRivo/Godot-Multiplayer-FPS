extends Node

var network = NetworkedMultiplayerENet.new()
var port = 1909
var max_players = 100

onready var player_verification_process = get_node("PlayerVerification")

func _ready():
	StartServer()
	
func StartServer():
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	print("Server started !")
	
	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")

func _peer_connected(player_id):
	print("User " + str(player_id) + " connected !")
	player_verification_process.start(player_id)
	
func _peer_disconnected(player_id):
	print("User " + str(player_id) + " disconnected !")

remote func FetchWeaponDamage(weapon_name, requester):
	var player_id = get_tree().get_rpc_sender_id()
	var damage = ServerData.skill_data["Glock"].damage
	rpc_id(player_id, "ReturnWeaponDamage", damage, requester)
