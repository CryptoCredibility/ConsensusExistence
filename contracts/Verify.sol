pragma solidity ^0.4.8;

contract Verify {

	// Contract info
	address public owner; 

	// User's data blob      maybe store as JSON on IPFS?? 
	struct User {
		address  userAddress; 
		string firstName;
		string lastName;
		string emailAddress; 
		string pgpKeys;
		uint256 numFriends;
		uint256[] friends; 
		uint256 numFriendRequests;
		uint256[] friendRequests;    // List of other userID's that are waiting for this User to accept friend request
		mapping (address => bool) pendingRequests; // boolean : does this user have a pending request with this address? 
	}


	// User info 
	uint256 public numUsers; 
	User[] public users;
	User public user;    // empty user object (for inititation)
	mapping (address => uint256) public userID;   // The userID of this address 
	mapping (address => bool) public registered;   // Quick check to see if already registered


	// Events 
	event newUserEvent(address _newUser, uint256 _timestamp);
	event loginEvent(address _user, uint256 _timestamp);


	// Modifiers 
	modifier userOnly { 
		if (!registered[msg.sender]) { throw; }
		_; 
	}


	// Fallback function: Called when contract is called with incorrect function hash or unspecified function. 
	function () { 
		throw;   	// Returns Eth and eats gas
	}

	// Constructor: Called when contract is created. Makes creator the owner of contract
	function Verify() { 
		owner = msg.sender;      // creator is owner of contract
	}

	// returns first name, last name and email address
	function getUserName() constant returns (string, string)  { 
		User thisUser = users[userID[msg.sender]]; 
		return (thisUser.firstName, thisUser.lastName);
	}
	// function getFriends() constant userOnly{ 
	// 	User thisUser =  users[userID[msg.sender]];
	// }
	// Create User with first name and last name 
	function signUp(string _firstName, string _lastName) returns (uint256) { 
		// if (registered[msg.sender]) { return 0; }
		registered[msg.sender] = true; 
		userID[msg.sender] = numUsers;
		User newUser = user;  // initialize as empty User
		newUser.firstName = _firstName; 
		newUser.lastName = _lastName; 
		users.push(newUser);   // add new user to user list 
		numUsers++; 
		newUserEvent(msg.sender, block.timestamp); 
		return 1; 
	}

	// msg.sender is receiver of friend request
	// note: This will always apply to the latest friend request to save gas costs
	function acceptFriend() userOnly returns (uint256)  {
		User receiver = users[userID[msg.sender]];
		User initiator = users[receiver.friendRequests[receiver.numFriendRequests]]; // initiator is the user who has the most recent friendRequest
		if (alreadyFriend(msg.sender, initiator.userAddress)) { return 0; }
		receiver.numFriendRequests--;
		receiver.friends[receiver.numFriends] = userID[initiator.userAddress];  // update friend list for receiver 
		receiver.numFriends++; 
		initiator.friends[initiator.numFriends] = userID[msg.sender]; // update friend list for initiator
		initiator.numFriends++; 
		return 1; 
	}
	// Deny most recent friend request...
	function denyFriend() userOnly returns (uint256) {
		User thisUser = users[userID[msg.sender]];
		users[thisUser.friendRequests[thisUser.numFriendRequests]].pendingRequests[msg.sender] = false;   // remove boolean indicating a pending request to this user 
		thisUser.numFriendRequests--;
		return 0; 
	}

	// Send a friend request
	function friendRequest(address _friend) userOnly returns (uint256) { 
		if (alreadyFriend(msg.sender, _friend)) { return 0; }
		User friend = users[userID[_friend]]; 
		if (friend.pendingRequests[msg.sender]) { return 1; }   // can't ask for friend request if they have already requested friendship
		friend.friendRequests[friend.numFriendRequests] = userID[msg.sender];
		friend.numFriendRequests++;
		users[userID[msg.sender]].pendingRequests[_friend] = true;   // mark sender as having 
		return 2; 

	}

	// Internal fn, checks to see if users are already friends
	function alreadyFriend(address userOne, address userTwo) internal returns (bool) {
		User thisUser = users[userID[userTwo]];
		uint256 userToMatch = userID[userOne];  
		uint i = 0; 
		while (i < thisUser.numFriends) { 
			if (userToMatch == thisUser.friends[i]) { return true; }
			i++; 
		}
		return false; 
	}

}
