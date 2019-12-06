// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket,
// and connect at the socket path in "lib/web/endpoint.ex".
//
// Pass the token on params as below. Or remove it
// from the params if you are not using authentication.
import {Socket} from "phoenix"

let loginSocket = new Socket("/socket", {params: {token: window.userToken}})

loginSocket.connect()

// Now that you are connected, you can join channels with a topic:
let channel = loginSocket.channel("login", {})
let username1 = document.querySelector("#username1")
let username2 = document.querySelector("#username2")
let signUpButton = document.querySelector('#signUp')
let loginButton = document.querySelector('#login')
let register_result = document.querySelector("#register-result")
let login_result = document.querySelector("#login-result")

function register_user() {
  channel.push("register", {username: username1.value})
}

function login_user() {
  channel.push("login", {username: username2.value})
}

username1.addEventListener("keypress", event => {
  if(event.keyCode === 13){
    register_user()
  }
})

username2.addEventListener("keypress", event => {
  if(event.keyCode === 13){
    login_user()
  }
})

signUpButton.addEventListener("click", register_user)
loginButton.addEventListener("click", login_user)

channel.on("register_result", payload => {
  register_result.innerText = `${payload.result}`
  if (payload.result == 'success') {
    // channel.
  }
})

channel.on("login_result", payload => {
  login_result.innerText = `${payload.result}`
  if (payload.result == 'success') {
    // channel.
  }
})

channel.join()
  // .receive("ok", resp => { console.log("Joined successfully", resp) })
  // .receive("error", resp => { console.log("Unable to join", resp) })

export default loginSocket
