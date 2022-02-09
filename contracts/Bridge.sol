// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.0;

import "./interfaces/IBridge.sol";
import "./Messages.sol";
contract Bridge is IBridge{

    //  using Address for address;
    struct InOutInfo {
        uint256 index;
        bool allowed;
    }

    mapping(address => InOutInfo) private allowedInboxesMap; //记录合法的inbox 
    mapping(address => InOutInfo) private allowedOutboxesMap;

        // Accumulator for delayed inbox; tail represents hash of the current state; each element represents the inclusion of a new message.
    bytes32[] public  inboxAccs;
    function deliverMessageToInbox(
        uint8 kind,
        address sender,
        bytes32 messageDataHash
    )external payable virtual override returns(uint256) {
        require(allowedInboxesMap[msg.sender].allowed,"NOT_FROM_INBOX");

        return 
            addMessageToInbox(
                kind,
                sender,
                block.number,
                block.timestamp,
                tx.gasprice,
                messageDataHash
            );
    }

    function addMessageToInbox(
        uint8 kind,
        address sender,
        uint256 blockNumber,
        uint256 blockTimestamp,
        uint256 gasPrice,
        bytes32 messageDataHash
    ) internal returns (uint256) {
        uint256 count = inboxAccs.length;
        bytes32 messageHash = Messages.messageHash(kind, sender, blockNumber, blockTimestamp, count, gasPrice, messageDataHash);
        bytes32 prevAcc =0;
        if (count > 0){
            prevAcc = inboxAccs[count-1];
        }

        inboxAccs.push(Messages.addMessageToInbox(prevAcc, messageHash));
        emit MessageDelivered(count,prevAcc,msg.sender,kind,sender,messageDataHash);
        return count;
    }
}