# The name of the Class
class_name KeyAuth
# The class this class extends
extends Node
# Docstring
## Class for interacting with the KeyAuth API

# Signals
signal Action(msg: String)
signal Error
signal Initialized
signal Offline
signal LoggedIn(username: String)
signal LoggedOut

# Enums

# Constants

# @export variables
@export var start_initialize: bool = true
## Skips the check to see, if a User has a required subscription
@export var bypass_user_check: bool = false

@export_group("User","user_")
@export var user_name: String = ""
@export_flags("All:65535","Normal","Extended","Beta","Friend","Developer","Owner:256","bit10","bit11","bit12","bit13","bit14","bit15","bit16") var user_subscriptions: int = 0

# public variables
var host: String = "https://api.logicworkbench.com/1.2"

var app_name: String
var app_version: String
var app_hash: String

var secret: String
var owner_id: String
var seller_key: String

var hw_id: String

# private variables
var _client: HTTPRequest

var _session: String = ""
var _initialized: bool = false:
	get():
		if _session != "":
			_initialized = true
			return true
		return false

var _authorized: bool = false
var _fetched: bool = false

var last_request: Dictionary = {}
var last_response: Dictionary = {}

# @onready variables

# optional built-in _init() function

# optional built-in _enter_tree() function
func _enter_tree() -> void:
	_client = HTTPRequest.new()
	_client.request_completed.connect(_request_complete)
	add_child(_client)

# optional built-in _ready() function
func _ready() -> void:
	if not start_initialize:
		printerr("KeyAuth : Not allowed to initialize")
		return
	# Hash
	var path: String = OS.get_executable_path()
	var ctx := HashingContext.new()
	ctx.start(HashingContext.HASH_MD5)
	var file = FileAccess.open(path,FileAccess.READ)
	while file.get_position() < file.get_length():
		var remaining = file.get_length() - file.get_position()
		ctx.update(file.get_buffer(min(remaining, 1024)))
	app_hash = ctx.finish().hex_encode()
	
	# Hardware-ID
	hw_id = OS.get_unique_id()
	
	# Load from File
	load_from_file("res://assets/credentials/keyauth.env")
	
	# Initialize
	initialize()

# remaining built-in functions

# virtual functions to override

# public functions
func load_from_file(path: String) -> void:
	if not FileAccess.file_exists(path):
		push_error("KeyAuth::load_from_file() - File does not exist")
		get_tree().quit(1)
	var f:= ConfigFile.new()
	var error: Error = f.load(path)
	if error != OK:
		push_error("KeyAuth::load_from_file() - File loading failed")
	
	app_name = f.get_value("KeyAuth","name","error")
	app_version = f.get_value("KeyAuth","version","error")
	secret = f.get_value("KeyAuth","secret","error")
	owner_id = f.get_value("KeyAuth","ownerid","error")
	seller_key = f.get_value("KeyAuth","sellerkey","error")
	host = f.get_value("KeyAuth","host","error")

func initialize() -> void:
	var url: String = host
	url += "&type=init"
	url += "&ver=" + app_version.uri_encode()
	url += "&name=" + app_name.uri_encode()
	url += "&ownerid=" + owner_id
	url += "&hash=" + app_hash
	Action.emit("# Initializing #")
	_send_request("init",url,"")

func register(username: String, password: String, license: String) -> void:
	if not _initialized:
		initialize()
	var url: String = host
	url += "&type=register"
	url += "&username=" + username.uri_encode()
	url += "&pass=" + password.uri_encode()
	url += "&key=" + license.uri_encode()
	url += "&sessionid=" + _session.uri_encode()
	url += "&name=" + app_name.uri_encode()
	url += "&ownerid=" + owner_id
	url += "&hwid=" + hw_id.uri_encode()
	Action.emit("# Register #")
	_send_request("register",url,"",{"username": username,"password": password})

func login(username: String, password: String) -> void:
	if not _initialized:
		initialize()
	var url: String = host
	url += "&type=login"
	url += "&username=" + username.uri_encode()
	url += "&pass=" + password.uri_encode()
	url += "&sessionid=" + _session.uri_encode()
	url += "&name=" + app_name.uri_encode()
	url += "&ownerid=" + owner_id
	url += "&hwid=" + hw_id.uri_encode()
	Action.emit("# Login #")
	_send_request("login",url,"",{"username": username,"password": password})

func logout() -> void:
	if not _initialized:
		initialize()
	if not _authorized:
		return
	var url: String = host
	url += "&type=logout"
	url += "&sessionid=" + _session.uri_encode()
	url += "&name=" + app_name.uri_encode()
	url += "&ownerid=" + owner_id
	Action.emit("# Logout #")
	_send_request("logout",url,"")

func fetch_info() -> void:
	if not _initialized:
		initialize()
	if not _authorized:
		return
	var url: String = host
	url += "&type=fetchStats"
	url += "&sessionid=" + _session.uri_encode()
	url += "&name=" + app_name.uri_encode()
	url += "&ownerid=" + owner_id
	Action.emit("# Fetching User #")
	_send_request("fetchStats",url,"")

# private functions
func _send_request(type: String, url: String, body: String, additional: Dictionary = {}) -> void:
	var headers := PackedStringArray(["User-Agent: LogicWorkbench/2.0.0"])
	last_request = {"type": type, "url": url, "headers": headers, "body": body, "additional": additional}
	var err = _client.request(url,headers,HTTPClient.METHOD_GET,body)
	if err != OK:
		push_error(str(err)+"Something went wrong while sending request")
		Error.emit()

func _request_complete(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var json := JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	
	last_response = {"result": result, "code": response_code, "headers": headers, "body": body, "response": response}
	
	if not response:
		printerr("Response does not exist")
		return
	
	if last_request.has("type"):
		match last_request["type"]:
			"init": # Initialization
				if response.has("success") and response["success"] == true:
					_session = response["sessionid"]
					Initialized.emit()
			"login": # Log IN
				if response.has("success") and response["success"] == true:
					_authorized = true
					LoggedIn.emit(last_request["additional"]["username"])
					fetch_info()
			"register": # Register
				if response.has("success") and response["success"] == true:
					_authorized = true
					LoggedIn.emit(last_request["additional"]["username"])
					fetch_info()
			"logout": # Log out
				if response.has("success") and response["success"] == true:
					_initialized = false
					_authorized = false
					_fetched = false
					LoggedOut.emit()
					Offline.emit()
			"fetchStats": # Fetch Stats
				if response.has("success") and response["success"] == true:
					_fetched = true
			_:
				printerr("Unconfigured")
	Action.emit("")

# subclasses
