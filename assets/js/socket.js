
import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})
socket.connect()

let messageContainer = document.getElementById('messages')
let channel = socket.channel("twitterSocket:*", {})
connectClient()

function connectClient() {
  channel.join()
    .receive("ok", resp => { console.log("Joinded successfully", resp) })
    .receive("error", resp => { console.log("Unable to join", resp) })

    document.getElementById('userName').addEventListener("keypress", event => {
      if (event.keyCode === 13){
        registerUser()
      }
    })

    document.getElementById('subscriberName').addEventListener("keypress", event => {
      if (event.keyCode === 13){
          subscribeUser()
      }
    })

    document.getElementById('tweet').addEventListener("keypress", event => {
      if (event.keyCode === 13){
        tweetMsg()
      }
    })

    // document.getElementById('referesh-screen').addEventListener() = refereshScreen()

    channel.on("subscribed_tweets", payload => {
      postSubscribedTweets(payload)
    })
}

function showPost(userName, msg) {
  let div = document.createElement("div");
  let span1 = document.createElement("span");
  let span2 = document.createElement("span");
  let button = document.createElement("button");

  span1.innerText = `${new Date().toLocaleString()}`
  span2.innerText = msg
  button.innerText = "RETWEET"

  div.setAttribute("class", "text-dark d-flex justify-content-between align-items-center")
  span1.setAttribute("class", "badge badge-dark badge-pill mr-3")
  span2.setAttribute("class", "font-italic")
  button.setAttribute("class", "btn btn-outline-info badge-pill")
  // messageButton.addEventListener('click', ()=>{
      // channel.push("retweet", {username: username.value, tweetText: payload.tweetText})
  // })
  div.appendChild(span1)
  div.appendChild(span2)
  div.appendChild(button)
  messageContainer.appendChild(div)
}

function registerUser(){
  let userName = document.getElementById('userName').value
  channel.push("register_user", {userName: userName})
  showPost(userName, `${userName} logged in.`)
}

function subscribeUser() {
  let userName = document.getElementById('userName').value
  let subscriberName = document.getElementById('subscriberName').value
  channel.push("subscribe_user", {userName: userName, subscriberName: subscriberName})
  document.getElementById('subscriberName').value = ""
  showPost(userName, `${userName} subscribed to ${subscriberName}.`)
}

function tweetMsg() {
  let userName = document.getElementById('userName').value
  let tweetMsg = document.getElementById('tweet').value
  channel.push("tweet_post", {userName: userName, tweetMsg: tweetMsg, userList: []})
  showPost(userName, `${userName} tweets :: ${tweetMsg}.`)
  document.getElementById('tweet').value = ""
}

function postSubscribedTweets(payload) {
  console.log(`${payload.userList}`)
  if( payload.userList.indexOf( document.getElementById('userName').value ) > -1 ) {
    showPost(payload.subscribedUser, `${payload.subscribedUser} tweets ${payload.tweetMsg}.`)
  }
}

function refereshScreen() {
  document.getElementById('messages').innerText = ``
}

export default socket

