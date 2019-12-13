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
  let tweetInput = document.querySelector("#tweetInput")
  let subToInput = document.querySelector("#subToInput")
  let subButton = document.querySelector("#subButton")

  function addTweet(payload, retweet=false, selftweet = false) {
    console.log([retweet, selftweet])
    var li = document.createElement('li')
    var p = document.createElement('p')
    p.innerHTML = "<b>" + payload.username + "</b>"
    if(retweet) {
      p.innerHTML += "<i> retweeted " + payload.owner + "</i>"
    }
    p.innerHTML += "<br/>" + payload.tweet
    li.appendChild(p)
    if(!selftweet) {
      var rtbutton = document.createElement('input')
      rtbutton.type = "submit"
      rtbutton.value = "Retweet"
      rtbutton.onclick = function() {
        channel.push("retweet", {owner: payload.username, tweet: payload.tweet})
      }
      li.appendChild(rtbutton)
    }
    tweetList.insertBefore(li, tweetList.firstChild)
  }

  tweetButton.addEventListener("click", event => {
    channel.push("tweet", {tweet: tweetInput.value})
    tweetInput.value = ""
  })

  subButton.addEventListener("click", event => {
    channel.push("subTo", {otheruser: subToInput.value})
    subToInput.value = ""
  })

  channel.on("gottweet", payload => {
    addTweet(payload)
  })

  channel.on("gotretweet", payload => {
    addTweet(payload, true, true)
  })

  channel.on("selftweet", payload => {
    addTweet(payload, false, true)
  })
}

channel.join()
  .receive("ok", resp => { console.log("Joined tweet channel successfully", resp) })
  .receive("error", resp => { console.log("Unable to join tweet channel", resp) })

export default tweetSocket
