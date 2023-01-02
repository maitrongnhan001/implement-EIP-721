pragma solidity ^0.8.2;

contract ERC721 {
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    mapping(address => uint256) internal _balances;
    mapping(uint256 => address) internal _owners;
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    mapping (uint256 => address) private _tokenApprovels;

    // return the number of NFTs of an user
    function balanceOf(address _owner) external view returns (uint256) {
        require(_owner != address(0), 'Address is zero');
        return _balances[_owner];
    }

    // finds the owner of an NFT
    function ownerOf(uint256 _tokenId) public view returns (address) {
        address _owner = _owners[_tokenId];
        require(_owner != address(0), "Token ID does not exist");
        return _owner;
    }

    // standard transferFrom method
    // checks if the receiver smart contract is capable of receiving NFT
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) public payable {
        transferFrom(_from, _to, _tokenId);
        require(_checkOnERC721Received(), "Receiver isn't implemented");
    }

    // simple version to check for NFT receivability of a smart contract
    function _checkOnERC721Received() private pure returns (bool) {
        return true;
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable {
        safeTransferFrom(_from, _to, _tokenId, "");
    }

    // transfer ownership of a single NFT
    function transferFrom(address _from, address _to, uint256 _tokenId) public payable {
        address owner = ownerOf(_tokenId);
        require(
            msg.sender == owner ||
            getApproved(_tokenId) == msg.sender ||
            isApprovedForAll(owner, msg.sender),
            "Msg.sender isn't the owner or approved for transfer"
        );
        require(_from == owner, "from address is not ther owner");
        require(_to != address(0), "Address is the zero address");
        require(_owners[_tokenId] != address(0), "Token ID doesn't exist");
        approve(address(0), _tokenId);
        _balances[_from] -= 1;
        _balances[_to] += 1;
        _owners[_tokenId] = _to;
        emit Transfer(_from, _to, _tokenId);
    }

    // enable a operator in an NFT
    function approve(address _approved, uint256 _tokenId) public payable {
        address owner = ownerOf(_tokenId);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "msg.sender isn't an owner or the approved operator");
        _tokenApprovels[_tokenId] = _approved;
        emit Approval(owner, _approved, _tokenId);
    }

    // enable or disable an operator
    function setApprovalForAll(address _operator, bool _approved) external {
        _operatorApprovals[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    // check an operator enable in an NFT
    function getApproved(uint256 _tokenId) public view returns (address) {
        require(_owners[_tokenId] != address(0), "Token ID doesn't exist");
        return _tokenApprovels[_tokenId];
    }

    // check if an address is operator for another address
    function isApprovedForAll(address _owner, address _operator) public view returns (bool) {
        return _operatorApprovals[_owner][_operator];
    }

    // EIP165 proposal: query if a contract implements another interface
    function supportInterface(bytes4 interfaceID) public pure virtual returns (bool) {
        return interfaceID == 0x80ac58cd;
    }
}