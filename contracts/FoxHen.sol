// SPDX-License-Identifier: MIT LICENSE

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Metadata.sol";
import "./Random.sol";

contract FoxHen is ERC721Enumerable, Ownable {
	uint256 public constant MAX_TOKENS = 10000;
	uint256 public constant FREE_TOKENS = 3000;
	uint16 public purchased = 0;

	struct Minting {
		address minter;
		uint256 tokenId;
		bool fulfilled;
	}
	mapping(bytes32=>Minting) mintings;

	struct TokenWithMetadata {
		uint256 tokenId;
		bool isFox;
		string metadata;
	}

	mapping(uint256=>bool) public isFox;
	uint256[] public foxes;
	uint16 public stolenMints;
	mapping(uint256=>uint256) public traitsOfToken;
	mapping(uint256=>bool) public traitsTaken;
	bool public mainSaleStarted;
	mapping(bytes=>bool) public signatureUsed;
	mapping(address=>uint8) public freeMintsUsed;
	uint256 extrasCount;

	IERC20 eggs;
	Metadata metadata;
	Random random;

	bytes32 internal keyHash;
	uint256 internal fee;

	constructor(address _eggs, address _random, address _metadata) ERC721("FoxHen", 'FH') {
		eggs = IERC20(_eggs);
		metadata = Metadata(_metadata);
		random = Random(_random);

		require(eggs.approve(msg.sender, type(uint256).max));
	}

	// Internal
	function setTraits(uint256 tokenId, uint256 seed) internal returns (uint256) {
		uint256 maxTraits = 16 ** 4;
		uint256 nextRandom = uint256(keccak256(abi.encode(seed, 1)));
		uint256 traitsID = nextRandom % maxTraits;
		while(traitsTaken[traitsID]) {
			nextRandom = uint256(keccak256(abi.encode(nextRandom, 1)));
			traitsID = nextRandom % maxTraits;
		}
		traitsTaken[traitsID] = true;
		traitsOfToken[tokenId] = traitsID;
		return traitsID;
	}

	function setSpecies(uint256 tokenId, uint256 seed) internal returns (bool) {
		uint256 _random = uint256(keccak256(abi.encode(seed, 2))) % 10;
		if (_random == 0) {
			isFox[tokenId] = true;
			foxes.push(tokenId);
			return true;
		}
		return false;
	}

	function getRecipient(uint256 tokenId, address minter, uint256 seed) internal view returns (address) {
		if (tokenId > FREE_TOKENS && tokenId <= MAX_TOKENS && (uint256(keccak256(abi.encode(seed, 3))) % 10) == 0) {
			uint256 fox = foxes[uint256(keccak256(abi.encode(seed, 4))) % foxes.length];
			address owner = ownerOf(fox);
			if (owner != address(0)) {
				return owner;
			}
		}
		return minter;
	}

	// Reads
	function eggsPrice(uint16 amount) public view returns (uint256) {
		require(purchased + amount >= FREE_TOKENS);
		uint16 secondGen = purchased + amount - uint16(FREE_TOKENS);
		return (secondGen / 500 + 1) * 40 ether;
	}

	function foxCount() public view returns (uint256) {
		return foxes.length;
	}

	function tokenURI(uint256 tokenId) public view override returns (string memory) {
		return metadata.tokenMetadata(isFox[tokenId], traitsOfToken[tokenId], tokenId);
	}

	function allTokensOfOwner(address owner) public view returns (TokenWithMetadata[] memory) {
		uint256 balance = balanceOf(owner);
		TokenWithMetadata[] memory tokens = new TokenWithMetadata[](balance);
		for (uint256 i = 0; i < balance; i++) {
			uint256 tokenId = tokenOfOwnerByIndex(owner, i);
			string memory data = tokenURI(tokenId);
			tokens[i] = TokenWithMetadata(tokenId, isFox[tokenId], data);
		}
		return tokens;
	}

	// Public
	function freeMint(uint8 amount) public payable {
		require(mainSaleStarted, "Main Sale hasn't started yet");
		address minter = _msgSender();
		require(freeMintsUsed[minter] + amount <= 5, "You can't free mint any more");
		require(tx.origin == minter, "Contracts not allowed");
		require(purchased + amount <= FREE_TOKENS, "Sold out");

		for (uint8 i = 0; i < amount; i++) {
			freeMintsUsed[minter]++;
			purchased++;
			uint256 randomness = random.randomSeed();
			setSpecies(purchased, randomness);
			setTraits(purchased, randomness);

			address recipient = getRecipient(purchased, minter, randomness);
			if (recipient != minter) {
				stolenMints++;
			}
			_mint(recipient, purchased);
		}

	}

	function buyWithEggs(uint16 amount) public {
		address minter = _msgSender();
		require(mainSaleStarted, "Main Sale hasn't started yet");
		require(tx.origin == minter, "Contracts not allowed");
		require(amount > 0 && amount <= 20, "Max 20 mints per tx");
		require(purchased >= FREE_TOKENS, "Eggs sale not active");
		require(purchased + amount <= MAX_TOKENS, "Sold out");

		uint256 price = amount * eggsPrice(amount);
		require(price <= eggs.allowance(minter, address(this)) && price <= eggs.balanceOf(minter), "You need to send enough eggs");
		
		uint256 initialPurchased = purchased;
		purchased += amount;
		require(eggs.transferFrom(minter, address(this), price));

		for (uint16 i = 1; i <= amount; i++) {
			uint256 randomness = random.randomSeed();
			setSpecies(purchased, randomness);
			setTraits(purchased, randomness);

			address recipient = getRecipient(initialPurchased + i, minter, randomness);
			// there is chance that what ever you minted won't be yours
			// some fox can get it
			if (recipient != minter) {
				stolenMints++;
			}
			_mint(recipient, initialPurchased + i);
		}
	}

	//admin

	function toggleMainSale() public onlyOwner {
    	mainSaleStarted = !mainSaleStarted;
  	}
}