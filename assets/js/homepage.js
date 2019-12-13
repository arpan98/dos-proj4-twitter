import {Socket} from "phoenix"

let tweetSocket = new Socket("/socket", {params: {username: window.username}})

tweetSocket.connect()

let channel = tweetSocket.channel("tweets", {})

if(window.username) {
  let tweetList = document.getElementById("tweetList")
  let tweetInput = document.getElementById("tweetInput")
  let tweetButton = document.getElementById("tweetButton")
  let subToInput = document.getElementById("subToInput")
  let subButton = document.getElementById("subButton")
  let hashTweetTxt = document.getElementById("hashTweetTxt")
  let hashTweetBtn = document.getElementById("hashTweetBtn")

  function addTweet(payload, retweet=false, selftweet = false) {
    console.log([retweet, selftweet])
    // var li = document.createElement('div')
    // var p = document.createElement('p')
    // p.innerHTML = "<b>" + payload.username + "</b>"
    // if(retweet) {
    //   p.innerHTML += "<i> retweeted " + payload.owner + "</i>"
    // }
    // p.innerHTML += "<br/>" + payload.tweet
    // li.appendChild(p)
    // if(!selftweet) {
    //   var rtbutton = document.createElement('input')
    //   rtbutton.type = "submit"
    //   rtbutton.value = "Retweet"
    //   rtbutton.onclick = function() {
    //     channel.push("retweet", {owner: payload.username, tweet: payload.tweet})
    //   }
    //   li.appendChild(rtbutton)
    // }
    
    // tweetList.insertBefore(li, tweetList.firstChild)

    let div = document.createElement("div");
    let span1 = document.createElement("span");
    let span3 = document.createElement("span");
    let span2 = document.createElement("span");
    let button = document.createElement("button");
    let messageContainer = document.getElementById("tweetList")
  
    span1.innerText = `${payload.username}`
    div.appendChild(span1)
    if(retweet) {
      span3.innerHTML += `retweeted ${payload.owner }`
      div.appendChild(span3)
    }
    span2.innerHTML += payload.tweet
    
    div.appendChild(span2)

    if(!selftweet) {
      button.innerText = "RETWEET"
      button.type = "submit"
      button.onclick = function() {
        channel.push("retweet", {owner: payload.username, tweet: payload.tweet})
      }
      div.appendChild(button)
    }

    div.setAttribute("class", "text-dark d-flex align-items-center mt-2")
    span1.setAttribute("class", "badge badge-dark badge-pill text-large")
    span2.setAttribute("class", "badge badge-success badge-pill ml-4 text-large")
    span3.setAttribute("class", "badge badge-warning badge-pill ml-4 text-large")
    button.setAttribute("class", "btn btn-outline-info badge-pill ml-4  w-25 h-25 ")

    // messageContainer.appendChild(div)
    messageContainer.insertBefore(div, messageContainer.firstChild)
  }

  tweetInput.addEventListener("keypress", event => {
    if(event.keyCode === 13) {
      channel.push("tweet", {tweet: tweetInput.value})
      tweetInput.value = ""
    }
  })
  tweetButton.addEventListener("click", event => {
    channel.push("tweet", {tweet: tweetInput.value})
    tweetInput.value = ""
  })

  subToInput.addEventListener("keypress", event => {
    if(event.keyCode === 13) {
      channel.push("subTo", {otheruser: subToInput.value})
      subToInput.value = ""
    }
  })
  subButton.addEventListener("click", event => {
    channel.push("subTo", {otheruser: subToInput.value})
    subToInput.value = ""
  })

  hashTweetTxt.addEventListener("keypress", event => {
    if(event.keyCode === 13) {
      channel.push("get_hash_tweets", {hashTweets: hashTweetTxt.value})
      hashTweetTxt.value = ""
    }
  })
  hashTweetBtn.addEventListener("click", event => {
    channel.push("get_hash_tweets", {hashTweets: hashTweetTxt.value})
    hashTweetTxt.value = ""
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
