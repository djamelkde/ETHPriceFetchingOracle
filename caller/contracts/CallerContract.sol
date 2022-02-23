// SPDX-License-Identifier: MIT
pragma solidity  >=0.4.22 <0.9.0;
import "./EthPriceOracleInterface.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";
contract CallerContract is Ownable{
    uint256 private ethPrice;
    EthPriceOracleInterface private oracleInstance;
    address private oracleAddress;
    mapping(uint256=>bool) private receivedRequests; // all the received requests come from end users (front-end app)
    event NewOracleAddressEvent(address oracleAddress);
    event ReceivedNewRequestIdEvent(uint256 id);
    event PriceUpdatedEvent(uint256 ethPrice, uint256 id);
    function setOracleInstanceAddress(address _oracleInstanceAddress) public onlyOwner{
        oracleAddress = _oracleInstanceAddress;
        oracleInstance = EthPriceOracleInterface(oracleAddress);
        emit NewOracleAddressEvent(oracleAddress);
    }
    function updateEthPrice() public {
        uint256 id = oracleInstance.getLatestEthPrice();
        receivedRequests[id] = true;
        emit ReceivedNewRequestIdEvent(id);
    }
    function callback(uint256 _ethPrice, uint256 _id) public {
        require(receivedRequests[_id], "This request is not in the pending list !");
        ethPrice = _ethPrice;
        delete receivedRequests[_id];
        emit PriceUpdatedEvent(_ethPrice, _id);
    }
    modifier onlyOracle() {
        require(msg.sender==oracleAddress, "You are not authorized to call this function!");
        _;
    }
}
