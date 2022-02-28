
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract bannermfers is ERC721, Ownable {

    address public MFERS_ADDRESS;
    address payable public payments;
    IERC721 private _mfersContract;

    uint private _totalSupply;

    string private _metadataBaseURI;
    string private _metadataExtension;

    uint private cost = 0.01 ether;

    /* events */
    event Received(address,  uint);

    /* metadata */

    constructor(address mfersAddress, address _payments) ERC721("banner mfers", "bannermfer") Ownable() {
        setMfersAddress(mfersAddress);
        setMetadataBaseURI("https://gateway.pinata.cloud/ipfs/QmSXvfgLoshi6Lis43vDhRBVoPH3GMHW4v8iMtwdicdqwc/");
        setMetadataExtenstion(".json");
        payments = payable(_payments);
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    /* owner's functions */
    
    function setMfersAddress(address newAddress) public onlyOwner {
        MFERS_ADDRESS = newAddress;
        _mfersContract = IERC721(MFERS_ADDRESS);
    }

    function setMetadataBaseURI(string memory uri) public onlyOwner {
        _metadataBaseURI = uri;
    }

    function setMetadataExtenstion(string memory extension) public onlyOwner {
        _metadataExtension = extension;
    }

    function withdraw() public onlyOwner {
        // (bool sent,) = owner().call{value: address(this).balance}("");
        (bool sent,) = payable(payments).call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }

    /* Public functions */

    function _mint(uint256 token) private {
        require(msg.value >= cost, "Price is 0.01 Eth");
        require(_mfersContract.ownerOf(token) == msg.sender, "You need to own the mfer");

        _safeMint(msg.sender, token);

        _totalSupply += 1;
    }

    function mint(uint256 token) payable public {
        require(msg.value >= cost, "Price is 0.01 Eth");
        require(_mfersContract.ownerOf(token) == msg.sender, "You need to own the mfer");
        emit Received(msg.sender, msg.value);

        _mint(token);
    }

    function massMint(uint256[] memory tokens) payable public {
        require(msg.value >= (cost * tokens.length), "Price is 0.01 Eth per banner");
        for (uint i = 0; i < tokens.length; ++i)
        {
            require(_mfersContract.ownerOf(tokens[i]) == msg.sender, "You need to own the mfer");
            _mint(tokens[i]);
        }
    }

    function totalSupply() public view returns(uint supply)
    {
        supply = _totalSupply;
    }

    function tokenURI(uint256 token) public view override(ERC721) returns(string memory)
    {
        return string(abi.encodePacked(_metadataBaseURI, Strings.toString(token), _metadataExtension));
    }
}
