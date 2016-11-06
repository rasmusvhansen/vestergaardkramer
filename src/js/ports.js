var element = document.getElementById('elm');
var app = Elm.Main.embed(element);

var config = {
  apiKey: "AIzaSyCzY5EwUvXD4La1igmQ8OO-USMUHl-OroE",
  authDomain: "vestergaardkramer-e846b.firebaseapp.com",
  databaseURL: "https://vestergaardkramer-e846b.firebaseio.com"
};
firebase.initializeApp(config);

var database = firebase.database();

var listRef = null;
function setListRef(person) {
  if (listRef) {
    listRef.off();
  }
  listRef = database.ref('wishes/' + person + '/');
  subscribeToWishes(person);
}

// Get values from Firebase

function subscribeToWishes(person) {   
  listRef.on('value', function (snapshot) {
    app.ports.listItems.send(snapshot.val());
  });
}

app.ports.getWishes.subscribe(setListRef);

// Push change to Firebase
app.ports.fbPush.subscribe(function (item) {  
  var id = item.id
  delete item.id
  setListRef(item.person);
  if (id === null) {
    listRef.push(item)
  } else {
    listRef.child(id).set(item)
  }
})

app.ports.fbRemove.subscribe(function (wish) {
  setListRef(wish.person);
  listRef.child(wish.id).remove();  
})

app.ports.fbTakeWish.subscribe(function (item) {  
  var id = item.id;
  var taken = item.taken;
  var wishRef = database.ref('wishes/' + item.person + '/' + id + '/taken');
  wishRef.set(taken);
})

app.ports.login.subscribe(function (str) {
  var provider = new firebase.auth.GoogleAuthProvider();
  firebase.auth().signInWithPopup(provider).then(function (result) {
    // This gives you a Google Access Token. You can use it to access the Google API.
    var token = result.credential.accessToken;
    // The signed-in user info.
    var user = result.user;
    app.ports.user.send(user.email);
    // ...
  }).catch(function (error) {
    // Handle Errors here.
    var errorCode = error.code;
    var errorMessage = error.message;
    // The email of the user's account used.
    var email = error.email;
    // The firebase.auth.AuthCredential type that was used.
    var credential = error.credential;
    // ...
  });
});