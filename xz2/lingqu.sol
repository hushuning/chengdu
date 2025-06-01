/**
 *Submitted for verification at BscScan.com on 2022-07-10
 */

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    // function renounceOwnership() public virtual onlyOwner {
    //     _transferOwnership(address(0));
    // }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract LingQu is Ownable {
    IERC20 v1 = IERC20(0x90A4e610A1633a0e32347bA6ed416CFCCacE2111);        IERC20 v1 = IERC20(0x74dc66c4c96cD6153191da38f2D68D1d18fd95a1);
    IERC20 v2 = IERC20(0x8b78d659d2DcDF162935Ee5060731dA9693Db222);
    IERC20 v3 = IERC20(0xffcf5470500281A52DD9D24d4fcc1F0A01Ea5333);
    IERC20 v4 = IERC20(0x5f7006582f3AfDe5766Ac224e62f66CCD2281444);
    
    mapping(address => uint) public users;
    function setV1(address _v1) public onlyOwner {
        v1 = IERC20(_v1);
    }
    function setV2(address _v2) public onlyOwner {
        v2 = IERC20(_v2);
    }
    function setV3(address _v3) public onlyOwner {
        v3 = IERC20(_v3);
    }
    function setV4(address _v4) public onlyOwner {
        v4 = IERC20(_v4);
    }
    function returnIn(address con, address addr, uint256 val) public onlyOwner {
        if (con == address(0)) {
            payable(addr).transfer(val);
        } else {
            IERC20(con).transfer(addr, val);
        }
    }
    
    function claim() external {
        uint day = block.timestamp ;
        require(day > users[msg.sender] + 24 hours, "not 24h");
        if(IERC20(v1).balanceOf(address(this))>2e18) v1.transfer( msg.sender, 2e18);
        if(IERC20(v2).balanceOf(address(this))>1e18) v2.transfer( msg.sender, 1e18);
        if(IERC20(v3).balanceOf(address(this))>5e17) v3.transfer( msg.sender, 5e17);
        if(IERC20(v4).balanceOf(address(this))>5e17) v4.transfer( msg.sender, 5e17);
        users[msg.sender] = day;
    }
}
