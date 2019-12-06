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
let username = document.querySelector("#username")
let submitButton = document.querySelector('#submit')
let login_result = document.querySelector("#login-result")

function register_user() {
  channel.push("register", {body: username.value})
}

username.addEventListener("keypress", event => {
  if(event.keyCode === 13){
    register_user()
  }
})

submitButton.addEventListener("click", register_user)

channel.on("register_result", payload => {
  login_result.innerText = `${payload.result}`
})

channel.join()
  // .receive("ok", resp => { console.log("Joined successfully", resp) })
  // .receive("error", resp => { console.log("Unable to join", resp) })

export default loginSocket
