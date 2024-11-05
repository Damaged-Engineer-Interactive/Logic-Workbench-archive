# The name of the Class

# The class this class extends
extends HBoxContainer
# Docstring
## short description goes here 
## 
## Long desciption goes here

# Signals

# Enums

# Constants

# @export variables

# public variables

# private variables

# @onready variables

# optional built-in _init() function

# optional built-in _enter_tree() function

# optional built-in _ready() function
func _ready() -> void:
	var ver: String = ProjectSettings.get_setting("application/config/version","N/A")
	$"../../../BottomPart/VersionLabel".text = "Version : %s    " % ver
	print("User - ready() : start")
	if Global.auth:
		Global.auth.Action.connect(_keyauth_action)
		Global.auth.Offline.connect(_keyauth_offline)
		Global.auth.Error.connect(_keyauth_error)
		Global.auth.Initialized.connect(_keyauth_initialized)
		Global.auth.LoggedIn.connect(_keyauth_logged_in)
		Global.auth.LoggedOut.connect(_keyauth_logged_out)
	print("User - ready() : end")

# remaining built-in functions

# virtual functions to override

# public functions

# private functions
func _keyauth_action(msg: String):
	%ActionState.text = msg
	%ActionState.visible = true if msg != "" else false

func _keyauth_offline() -> void:
	%ServiceState.text = "Online Services : Offline"

func _keyauth_error() -> void:
	%ServiceState.text = "Online Services : Error"

func _keyauth_initialized() -> void:
	%ServiceState.text = "Online Services : Online"

func _keyauth_logged_in(user: String) -> void:
	%UserState.text = "Current User : " + user
	# Show Panels
	%UserPanel.show()
	#%PasswordPanel.show()
	# Hide Panels
	%LoginPanel.hide()
	%RegisterPanel.hide()

func _keyauth_logged_out() -> void:
	%UserState.text = "Current User : [n/a]"
	# Show Panels
	%LoginPanel.show()
	#%RegisterPanel.show()
	# Hide Panels
	%UserPanel.hide()
	%PasswordPanel.hide()


func _login_button_pressed() -> void:
	var username: String = %LoginUsername.text
	var password: String = %LoginPassword.text
	if username == "" or password == "":
		return
	Global.auth.login(username,password)

func _register_button_pressed() -> void:
	var username: String = %RegisterUsername.text
	var password: String = %RegisterPassword.text
	var key: String = %RegisterKey.text
	if username == "" or password == "" or not key.begins_with("LW_"):
		return
	Global.auth.register(username,password,key)

func _logout_button_pressed() -> void:
	Global.auth.logout()

func _update_password_button_pressed() -> void:
	pass

# subclasses


func _home_pressed() -> void:
	Global.change_view("Home")
