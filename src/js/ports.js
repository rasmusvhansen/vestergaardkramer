var element = document.getElementById('elm');
var app = Elm.Main.embed(element);

var config = {
  apiKey: "AIzaSyCzY5EwUvXD4La1igmQ8OO-USMUHl-OroE",
  authDomain: "vestergaardkramer-e846b.firebaseapp.com",
  databaseURL: "https://vestergaardkramer-e846b.firebaseio.com"
};
firebase.initializeApp(config);

var database = firebase.database();
var provider = new firebase.auth.GoogleAuthProvider();
firebase.auth().signInWithPopup(provider).then(function(result) {
  // This gives you a Google Access Token. You can use it to access the Google API.
  var token = result.credential.accessToken;
  // The signed-in user info.
  var user = result.user;
  // ...
}).catch(function(error) {
  // Handle Errors here.
  var errorCode = error.code;
  var errorMessage = error.message;
  // The email of the user's account used.
  var email = error.email;
  // The firebase.auth.AuthCredential type that was used.
  var credential = error.credential;
  // ...
});

// Get values from Firebase
var listRef = null;
app.ports.getWishes.subscribe(function (person) {
  if (listRef) listRef.off();
  listRef = database.ref('wishes/' + person + '/');
  listRef.on('value', function (snapshot) {
    app.ports.listItems.send(snapshot.val());
  });
});

// Push change to Firebase
app.ports.fbPush.subscribe(function (item) {
  var id = item.id
  delete item.id
  if (id === null) {
    listRef.push(item)
  } else {
    listRef.child(id).set(item)
  }
})
// Remove item
app.ports.fbRemove.subscribe(function (id) {
  listRef.child(id).remove()
})