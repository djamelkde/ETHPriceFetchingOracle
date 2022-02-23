// SPDX-License-Identifier: MIT
pragma solidity  >=0.4.22 <0.9.0;
import "openzeppelin-solidity/contracts/access/Ownable.sol";
import "./CallerContractInterface.sol";
contract EthPriceOracle is Ownable{
    //attributes used to generate random id for each request (for security reasons the request id must be as random as possible)
    uint private randNonce = 0;
    uint private modulus = 1000;
    mapping(uint256=>bool) pendingRequests; // the pending requests sent by the CallerContract
    event GetLatestEthPriceEvent(address callerAddress, uint id);
    event SetLatestEthPriceEvent(uint256 ethPrice, address callerAddress);

    function getLatestEthPrice() public returns(uint256) {
        randNonce++;
        uint id = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % modulus;
        pendingRequests[id] = true;
        emit GetLatestEthPriceEvent(msg.sender,id);
        return id;
    }

    function setLatestEthPrice(uint256 _ethPrice, address _callerAddress, uint256 _id) public onlyOwner{
        require(pendingRequests[_id], "This request is not in my pending list.");
        delete pendingRequests[_id];
        CallerContractInterface callerContractInstance;
        callerContractInstance = CallerContractInterface(_callerAddress);
        callerContractInstance.callback(_ethPrice, _id);
        emit SetLatestEthPriceEvent(_ethPrice, _callerAddress);
    } 
}