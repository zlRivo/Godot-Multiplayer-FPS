extends Node

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var ip = "127.0.0.1"
var port = 1910

var username
var password

func _ready():
	pass

func _process(delta):
	# Poll data
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()

func ConnectToServer(_username, _password):
	network = NetworkedMultiplayerENet.new()
	gateway_api = MultiplayerAPI.new()
	username = _username
	password = _password
	network.create_client(ip, port)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	
	network.connect("connection_failed", self, "_on_connection_failed")
	network.connect("connection_succeeded", self, "_on_connection_succeeded")

func _on_connection_failed():
	print("Failed to connect to the gateway server")
	print("Pop-off server may be offline")
	get_node("../World/LoginScreen/").login_button.disabled = false
	
func _on_connection_succeeded():
	print("Successfully connected to the gateway server")
	RequestLogin()
	
func RequestLogin():
	print("Connecting to gateway to request login")
	rpc_id(1, "LoginRequest", username, password)
	username = ""
	password = ""

remote func ReturnLoginRequest(result):
	print("Received login result")
	if result:
		Server.ConnectToServer()
		get_node("../SceneHandler/LoginScreen").queue_free()
		get_node("../SceneHandler").CreateWorld()
	else:
		print("Please provide correct username and password.")
		get_node("../SceneHandler/LoginScreen").login_button.disabled = false
	
	network.disconnect("connection_failed", self, "_on_connection_failed")
	network.disconnect("connection_succeeded", self, "_on_connection_succeeded")
