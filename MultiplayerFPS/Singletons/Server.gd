extends Node

var network = NetworkedMultiplayerENet.new()
var ip = "127.0.0.1"
var port = 1909

signal connection_succeeded

func _ready():
	ConnectToServer()
	
func ConnectToServer():
	network = NetworkedMultiplayerENet.new()
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	
	network.connect("connection_failed", self, "_OnConnectionFailed")
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")

func _OnConnectionFailed():
	print("Failed to connect to the server !")
	
func _OnConnectionSucceeded():
	print("Successfully connected")
	emit_signal("connection_succeeded")

func FetchWeaponDamage(weapon_name, requester):
	rpc_id(1, "FetchWeaponDamage", weapon_name, requester)
	
remote func ReturnWeaponDamage(s_damage, requester):
	instance_from_id(requester).damage = s_damage
