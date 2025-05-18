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
interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract LimitOrderProtocol is Ownable {
    address public _usdt = 0x55d398326f99059fF775485246999027B3197955;

    mapping(address => uint[][4]) public userHistory;
    bytes32 public constant LIMIT_ORDER_TYPEHASH = keccak256(
        "LimitOrder(address makerToken,address takerToken,uint128 makerAmount,uint128 takerAmount,uint128 takerTokenFeeAmount,address maker,address taker,address sender,address feeRecipient,bytes32 pool,uint64 expiry,uint256 salt)"
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
        // uint128 takerTokenFeeAmount;
        address maker;
        address taker;
        address sender;
        // address feeRecipient;
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
            // order.takerTokenFeeAmount,
            order.maker,
            order.taker,
            order.sender,
            // order.feeRecipient,
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
    function getArry(
        address addr,
        uint start,
        uint forNum
    ) external view returns (address[100][4] memory addrs) {
        for (uint i; i < forNum; i++) {
            addrs[i] = userHistory[start + i];
        }
    }
    function fillLimitOrder(
        LimitOrder calldata order,
        bytes calldata signature,
        uint128 takerTokenFillAmount
    ) external returns (uint128, uint128) {
        require(block.timestamp <= order.expiry, "Order expired");
        require(order.taker == address(0) || order.taker == msg.sender, "Taker not allowed");
        require(order.sender == address(0) || order.sender == msg.sender, "Sender not allowed");
        require(takerTokenFillAmount == order.takerAmount, "Partial fills not supported");

        // Recover signer
        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            DOMAIN_SEPARATOR,
            _hashOrder(order)
        ));
        address recovered = recoverSigner(digest, signature);
        require(recovered == order.maker, "Invalid signature");
        // fee
        uint256[] memory temp;
        if(order.makerToken == _usdt){
            //买入token

            order.takerAmount = order.takerAmount * 95 /100;
            temp[0] = 1;
            temp[1] = block.timestamp;
            temp[2] = order.makerAmount;
            temp[3] = order.takerAmount;
            userHistory[order.maker].push(temp);
            temp[0] =2;
            userHistory[order.taker].push(temp);
        }else{
            //卖出token
            order.makerAmount = order.makerAmount * 95 /100;
            temp[0] = 2;
            temp[1] = block.timestamp;
            temp[3] = order.makerAmount;
            temp[2] = order.takerAmount;
            userHistory[order.maker].push(temp);
            temp[0] =1;
            userHistory[order.taker].push(temp);
        }
        IERC20(order.takerToken).transferFrom(msg.sender, order.maker, order.takerAmount);
        
        // Transfer tokens
        require(
            IERC20(order.makerToken).transferFrom(order.maker, msg.sender, order.makerAmount),
            "Maker token transfer failed"
        );
        require(
            IERC20(order.takerToken).transferFrom(msg.sender, order.maker, order.takerAmount),
            "Taker token transfer failed"
        );
        // Update user history
        userHistory[order.maker][0] += order.makerAmount;
        return (order.makerAmount, order.takerAmount);
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
}
