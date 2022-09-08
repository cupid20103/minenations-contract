// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CryptoPunksMint is ERC721URIStorage, Ownable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    
    IERC20 private _wETHToken;

    uint256 private _publicPrice = 60000000000000000;
    uint256 private _whitelistPrice = 50000000000000000;

    Counters.Counter private _tokenIds;

    mapping (address => uint) public ownWallet;
    mapping(address => bool) public whitelisted;

    constructor() ERC721("CryptoPunks", "CPS") {
      _wETHToken = IERC20(0x9c3C9283D3e44854697Cd22D3Faa240Cfb032889);
    }

    function totalSupply() public view returns (uint256) {
        return _tokenIds.current();
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return "https://ipfs.io/ipfs/QmcnforHyWMorTv437YMXQ9594TuG7JsfyTaDFSVdLX9Z1/";
    }

    function tokenURI (uint256 tokenId) public view virtual override returns(string memory){
      require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
      string memory currentBaseURI = _baseURI();
      return bytes(currentBaseURI).length > 0
            ? string(
                abi.encodePacked(
                    currentBaseURI,
                    Strings.toString(tokenId),
                    ".json"
                )
            )
            : "";
    }

    function addWhitelistUser(address _user) public onlyOwner {
        whitelisted[_user] = true;
    }

    function removeWhitelistUser(address _user) public onlyOwner {
        whitelisted[_user] = false;
    }

    function mintItem(uint _count, uint256 _amount) public {
      require(totalSupply() + _count <= 10000, "Can't mint anymore");

      if(whitelisted[msg.sender] == true){
        require(ownWallet[msg.sender] + _count <= 2, "Maxium is 2");
        require(_amount == _count * _whitelistPrice, "Not match balance");
      } else {
        require(ownWallet[msg.sender] + _count <= 5, "Maxium is 5");
        require(_amount == _count * _publicPrice, "Not match balance");
      }
        _wETHToken.transferFrom(msg.sender, address(this), _amount);
      for( uint i = 0; i < _count; i++ ) {
        _tokenIds.increment();
        ownWallet[msg.sender]++;
        uint256 newItemId = _tokenIds.current();   
        _safeMint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI(newItemId));
      }
    }

    function withdraw() external onlyOwner {
        address _owner = owner();
        uint256 _amount=_wETHToken.balanceOf(address(this));
        _wETHToken.approve(_owner, _amount);
        _wETHToken.transfer(_owner, _amount);
    }
}