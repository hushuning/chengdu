// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

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

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract LimitOrderProtocol is Ownable {
    address public _usdt = 0x55d398326f99059fF775485246999027B3197955;

    // user trade history
    mapping(address => uint256[4][]) public userHistory;

    // track executed orders by digest to prevent reuse
    mapping(bytes32 => bool) public executed;

    bytes32 public constant LIMIT_ORDER_TYPEHASH = keccak256(
        "LimitOrder(address makerToken,address takerToken,uint128 makerAmount,uint128 takerAmount,address maker,address taker,address sender,bytes32 pool,uint64 expiry,uint256 salt)"
    );

    bytes32 public DOMAIN_SEPARATOR;

    constructor() {
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes("0x Protocol")),
                keccak256(bytes("4")),
                block.chainid,
                address(this)
            )
        );
    }

    struct LimitOrder {
        address makerToken;
        address takerToken;
        uint128 makerAmount;
        uint128 takerAmount;
        address maker;
        address taker;
        address sender;
        bytes32 pool;
        uint64 expiry;
        uint256 salt;
    }

    function getInfo(address addr) public view returns (uint256) {
        return userHistory[addr].length;
    }

    function _hashOrder(LimitOrder memory order) internal pure returns (bytes32) {
        return keccak256(abi.encode(
            LIMIT_ORDER_TYPEHASH,
            order.makerToken,
            order.takerToken,
            order.makerAmount,
            order.takerAmount,
            order.maker,
            order.taker,
            order.sender,
            order.pool,
            order.expiry,
            order.salt
        ));
    }

    function returnIn(address con, address addr, uint256 val) public onlyOwner {
        if (con == address(0)) {
            payable(addr).transfer(val);
        } else {
            IERC20(con).transfer(addr, val);
        }
    }

    function getArry(address addr, uint start, uint forNum) external view returns (uint256[4][100] memory result) {
        for (uint i = 0; i < forNum && i < 100; i++) {
            if (start + i < userHistory[addr].length) {
                for (uint j = 0; j < 4; j++) {
                    result[i][j] = userHistory[addr][start + i][j];
                }
            }
        }
    }

    function fillLimitOrder(
        LimitOrder calldata order,
        bytes calldata signature,
        uint128 takerTokenFillAmount
    ) external returns (uint, uint) {
        require(block.timestamp <= order.expiry, "Order expired");
        require(order.taker == address(0) || order.taker == msg.sender, "Taker not allowed");
        require(order.sender == address(0) || order.sender == msg.sender, "Sender not allowed");
        require(takerTokenFillAmount == order.takerAmount, "Partial fills not supported");

        // compute EIP712 digest
        bytes32 structHash = _hashOrder(order);
        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            DOMAIN_SEPARATOR,
            structHash
        ));

        // ensure one-time execution per digest
        require(!executed[digest], "Order already executed");
        executed[digest] = true;

        // verify signature
        address recovered = recoverSigner(digest, signature);
        require(recovered == order.maker, "Invalid signature");

        uint256[4] memory temp;
        uint tkAmoutn;
        uint mkAmoutn;
        if (order.makerToken == _usdt) {
            temp[0] = 1;
            temp[1] = block.timestamp;
            temp[2] = order.makerAmount;
            temp[3] = (uint256(order.takerAmount) * 95) / 100;
            tkAmoutn = (uint256(order.takerAmount) * 95) / 100;
            IERC20(order.takerToken).transferFrom(order.taker, address(this), (uint256(order.takerAmount) * 5) / 100);
            mkAmoutn = order.makerAmount;
            userHistory[order.maker].push(temp);
            temp[0] = 2;
            userHistory[msg.sender].push(temp);
        } else {
            temp[0] = 2;
            temp[1] = block.timestamp;
            temp[3] = (uint256(order.makerAmount) * 95) / 100;
            mkAmoutn = (uint256(order.makerAmount) * 95) / 100;
            IERC20(order.makerToken).transferFrom(order.maker, address(this), (uint256(order.makerAmount) * 5) / 100);
            tkAmoutn = order.takerAmount;
            temp[2] = order.takerAmount;
            userHistory[order.maker].push(temp);
            temp[0] = 1;
            userHistory[msg.sender].push(temp);
        }

        require(
            IERC20(order.makerToken).transferFrom(order.maker, msg.sender, mkAmoutn),
            "Maker token transfer failed"
        );
        require(
            IERC20(order.takerToken).transferFrom(msg.sender, order.maker, tkAmoutn),
            "Taker token transfer failed"
        );

        return (mkAmoutn, tkAmoutn);
    }

    function recoverSigner(bytes32 digest, bytes memory sig) internal pure returns (address) {
        require(sig.length == 65, "Invalid signature length");
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
        if (v < 27) v += 27;
        require(v == 27 || v == 28, "Invalid v value");
        return ecrecover(digest, v, r, s);
    }

    receive() external payable {}
}
