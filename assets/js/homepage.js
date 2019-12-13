// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket,
// and connect at the socket path in "lib/web/endpoint.ex".
//
// Pass the token on params as below. Or remove it
// from the params if you are not using authentication.
import {Socket} from "phoenix"

let tweetSocket = new Socket("/socket", {params: {username: window.username}})

// Finally, connect to the socket:
tweetSocket.connect()

// Now that you are connected, you can join channels with a topic:
let channel = tweetSocket.channel("tweets", {})

if(window.username) {
  let tweetList = document.querySelector("#tweetList")
  let subToInput = document.querySelector("#subToInput")
  let subButton = document.querySelector("#subButton")

  subButton.addEventListener("click", event => {
    channel.push("subTo", {otheruser: subToInput.value})
    subToInput.value = ""
  })

  channel.on("newtweet", payload => {
    var li = document.createElement('li')
    li.innerHTML = "<b>" + payload.username + "</b>" + "<br/>" + payload.tweet
    tweetList.insertBefore(li, tweetList.firstChild)
  })
}

channel.join()
  .receive("ok", resp => { console.log("Joined tweet channel successfully", resp) })
  .receive("error", resp => { console.log("Unable to join tweet channel", resp) })

export default tweetSocket
