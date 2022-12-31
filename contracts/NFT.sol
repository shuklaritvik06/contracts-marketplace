// SPDX-License-Identifier:MIT
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title A NFT Contract
 * @author Ritvik Shukla
 * @notice This contract is used to mint the tokens
 * @dev All function calls are currently implemented without side effects
 */
contract NFT is ERC721URIStorage{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address contractAddress;
    constructor(address marketplaceAddress) ERC721("Memories","MEM"){
        contractAddress = marketplaceAddress;
    }
    /**
     * @notice This function will mint the token and will return the token ID
     * @param tokenURI The URI of the token
     * @return The token ID
     */
    function createToken(string memory tokenURI) public returns (uint){
        _tokenIds.increment();
        uint256 _newItemId = _tokenIds.current();
        _mint(msg.sender, _newItemId);
        _setTokenURI(_newItemId, tokenURI);
        setApprovalForAll(contractAddress, true);
        return _newItemId;
    }
}