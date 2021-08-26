// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract AisthisiToken is ERC721PresetMinterPauserAutoId {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping(uint => uint) public tokenLockedFromTimeStamp;
    mapping(uint => bytes32) public tokenUnlockedHashs;
    mapping(uint => bool) public tokenUnlocked;

    event TokenUnlocked(uint tokenId, address unlockerAddress);
    constructor() ERC721PresetMinterPauserAutoId("AisthisiToken", "AIS", "https://aisthisi.art/metadata/"){}

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override {
        require(tokenLockedFromTimeStamp[tokenId] > block.timestamp || tokenUnlocked[tokenId], "AishtisiToken, Token is still locked");
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function unlockToken(bytes32 unlockHash, uint256 tokenId) public {
        require(msg.sender == ownerOf(tokenId), "AishtisiToken: Only the owner can unlock the token");
        require(keccak256(abi.encode(unlockHash)) == tokenUnlockedHashs[tokenId], "AishtisiToken: Unlock code incorrect");
        tokenUnlocked[tokenId] = true;
        emit TokenUnlocked(tokenId, msg.sender);
    }

    function mint(address to, uint lockedFromTimestamp, bytes32 unlockHash) public {
        tokenLockedFromTimeStamp[_tokenIds.current()] = lockedFromTimestamp;
        tokenUnlockedHashs[_tokenIds.current()] = unlockHash;
        _tokenIds.increment();
        super.mint(to);
    }


    function tokenURI(uint256 tokenId) public view virtual override returns(string memory) {
        return string (abi.encodePacked(super.tokenURI(tokenId),".json"));
    }

}