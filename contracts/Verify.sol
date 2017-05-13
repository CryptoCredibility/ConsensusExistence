pragma solidity ^0.4.3;
// import "./SafeMath.sol";
contract Verify {

	// This struct may need to be represented as a hash on IPFS
	struct User { 
		string firstName;
		string lastName;
		string emailAddress; 
		string pgpKeys;
		uint256 numFriends;
		uint256[] friends; 
		uint256[] friendRequests;    // Current requests to accept 
	}
	uint256 public numUsers; 
	Users[] public users;
	mapping (address => uint256) public userID;   // The userID of this address 

	mapping (address => bool) public registered;   // Quick check to see if already registered

	modifier userOnly { 
		if (!registered[msg.sender]) { throw; }
		_; 
	}

	event signUp(address _newUser, uint256 _timestamp);
	event login(address _user);

	function signUp(string _firstName, string _lastName) returns (uint256) { 
		if (registered[msg.sender]) { return 0; }
		registered[msg.sender] = true; 
		userID[msg.sender] = numUsers; 
		var thisUser = User({firstName: _firstName, lastName: _lastName}); 
	}

	function verifyFriend(address _friend) returns (uint256) {
		friendRequest[_friend].push(userID[msg.sender]); 
	}

	function registerName(string _firstName, string _secondName) userOnly returns (uint256) { 
		if (_firstName == '' || _secondName == '') { return 0; }
		var thisUser = users[userID[msg.sender]]; 
		thisUser

	}

	function alreadyFriend(address _person) internal returns (bool) {
		uint256 personsFriends = 
		uint i = 0; 
		while (i < friends[_person])
	}	
}
