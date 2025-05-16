// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract LimitOrderProtocol {
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
        uint128 takerTokenFeeAmount;
        address maker;
        address taker;
        address sender;
        address feeRecipient;
        bytes32 pool;
        uint64 expiry;
        uint256 salt;
    }

    function _hashOrder(LimitOrder memory order) internal pure returns (bytes32) {
        return keccak256(abi.encode(
            LIMIT_ORDER_TYPEHASH,
            order.makerToken,
            order.takerToken,
            order.makerAmount,
            order.takerAmount,
            order.takerTokenFeeAmount,
            order.maker,
            order.taker,
            order.sender,
            order.feeRecipient,
            order.pool,
            order.expiry,
            order.salt
        ));
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

        // Transfer tokens
        require(
            IERC20(order.makerToken).transferFrom(order.maker, msg.sender, order.makerAmount),
            "Maker token transfer failed"
        );
        require(
            IERC20(order.takerToken).transferFrom(msg.sender, order.maker, order.takerAmount),
            "Taker token transfer failed"
        );

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
