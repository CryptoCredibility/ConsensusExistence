// Import the page's CSS. Webpack will know what to do with it.
import "../stylesheets/app.css";

// Import libraries we need.
import { default as Web3} from 'web3';
import { default as contract } from 'truffle-contract'

// Import our contract artifacts and turn them into usable abstractions.
import verifyArtifacts from '../../build/contracts/Verify.json'

// var ethKeys = require("ethereumjs-keys");
var openpgp = require('openpgp');

openpgp.initWorker({ path:'openpgp.worker.js' }) // set the relative web worker path

openpgp.config.aead_protect = true // activate fast AES-GCM mode (not yet OpenPGP standard)

// https://github.com/openpgpjs/openpgpjs/blob/master/README.md#getting-started

// Add Angular Scope
angular.module('verify', [])

.controller('userControl', function(){

  this.firstName = 'stranger';
  this.lastName = 'anon'; 


// Verify  is our usable abstraction, which we'll use through the code below.
var Verify = contract(verifyArtifacts);

// The following code is simple to show off interacting with your contracts.
// As your needs grow you will likely need to change its form and structure.
// For application bootstrapping, check out window.addEventListener below.
var accounts;
var account;

window.App = {
  start: function() {
    var self = this;

    // Bootstrap the MetaCoin abstraction for Use.
    Verify.setProvider(web3.currentProvider);

    // Get the initial account balance so it can be displayed.
    web3.eth.getAccounts(function(err, accs) {
      if (err != null) {
        alert("There was an error fetching your accounts.");
        return;
      }

      if (accs.length == 0) {
        alert("Couldn't get any accounts! Make sure your Ethereum client is configured correctly.");
        return;
      }

      accounts = accs;
      account = accounts[0];

      self.refreshBalance();
      // var nameGreeting = document.getElementById("nameGreeting"); 
      // nameGreeting.innerHTML = $scope.firstName; // TODO search contract for returning user
    });
  },

  setStatus: function(message) {
    var status = document.getElementById("status");
    status.innerHTML = message;
  },

  refreshBalance: function() {
    var self = this;
    var balanceEth = web3.fromWei(web3.eth.getBalance(account).valueOf()); 
    // var balanceEth = balanceWei / 10^18; 
    var balanceElement = document.getElementById("balance");
    balanceElement.innerHTML = balanceEth; 
    console.log(balanceEth); 
  },
  refreshUser: function() { 
    var self = this; 
    var verify; 
    Verify.deployed().then(function(instance) {
      verify = instance; 
      return verify.getUserName.call({from: account, gas:200000}); 
    })
    .then(function(firstAndLastName) { 
      console.log(firstAndLastName); 
      // this.firstName = firstAndLastName[0]; 
    })
  },
  signUp: function() { 
    var self = this;
    var verify; 
    var firstName = document.getElementById("firstName").value; 
    var lastName = document.getElementById("lastName").value; 
    if (firstName.valueOf() == '') { window.alert("Must enter first name!"); }
    if (lastName.valueOf() == '') { window.alert("Must enter last name!");  }
    console.log("First name: " + firstName + " Last Name: " + lastName); 
    Verify.deployed().then(function(instance) {        // Receive contract abstraction instance
      verify = instance;
      console.log(verify); 
      return verify.signUp.call(firstName, lastName, { from: account, gas:2000000 });
    })
    .then(function(signUpSuccess) { 
      console.log(signUpSuccess.valueOf()); 
      if (signUpSuccess.valueOf() == 0) { window.alert("You are already registered!"); }
      if (signUpSuccess.valueOf() != 1) { window.alert("Sign up failed. Failed to create user struct"); }
      return verify.signUp(firstName, lastName, {from:account, gas:200000 });
    })
    .then(function(txHash) { 
       self.refreshUser(); 
    })
},
};

window.addEventListener('load', function() {
  // Checking if Web3 has been injected by the browser (Mist/MetaMask)
  if (typeof web3 !== 'undefined') {
    console.warn("Using web3 detected from external source. If you find that your accounts don't appear or you have 0 MetaCoin, ensure you've configured that source properly. If using MetaMask, see the following link. Feel free to delete this warning. :) http://truffleframework.com/tutorials/truffle-and-metamask")
    // Use Mist/MetaMask's provider
    window.web3 = new Web3(web3.currentProvider);
  } else {
    console.warn("No web3 detected. Falling back to http://localhost:8545. You should remove this fallback when you deploy live, as it's inherently insecure. Consider switching to Metamask for development. More info here: http://truffleframework.com/tutorials/truffle-and-metamask");
    // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
    window.web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
  }

  App.start();
});
}); 