// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.0;

interface IInbox{
    
    event InboxMessageDelivered(uint256 indexed messageNum, bytes data);

    event InboxMessageDeliveredFromOrigin(uint256 indexed messageNum);
    
    function SendL2Message(bytes calldata messageData) external returns(uint256);
}