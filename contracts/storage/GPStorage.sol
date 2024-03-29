// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract GPStorage {
    struct GPInfo {
        bool        valid;
        uint256     id; // index in GPA
        uint256     baseTokensAmount; // baseToken unit
        uint256     runningDepositAmount;
        uint256     ipTokensAmount; // ipToken unit, include GP and LP
        uint256     raisedFromLPAmount; // baseToken unit
        uint256     baseTokensBalance; // ipTokensAmount * price - raisedFromLPAmount
    }

    struct PoolInfo {
        uint256     curTotalGPAmount; // baseToken unit
        uint256     curTotalLPAmount; // baseToken unit
        uint256     curTotalIPAmount; // baseToken swapped into ipToken amount
        uint256     curTotalBalance; // baseToken unit

        address[]   GPA;
        mapping(address => GPInfo) GPM;
    }

    address public admin;
    address public proxy;
    mapping(address => mapping(address => PoolInfo)) private pools;

    constructor() {
        admin = msg.sender;
    }

    function setProxy(address _proxy) external {
        require(admin == msg.sender, "Not Permit");
        require(_proxy != address(0), "Invalid Address");
        proxy = _proxy;
    }

    function setCurGPAmount(address _ipt, address _bst, uint256 _amount) external {
        require(proxy == msg.sender, "Not Permit");
        pools[_ipt][_bst].curTotalGPAmount = _amount;
    }

    function setCurRaiseLPAmount(address _ipt, address _bst, uint256 _amount) external {
        require(proxy == msg.sender, "Not Permit");
        pools[_ipt][_bst].curTotalLPAmount = _amount;
    }

    function setCurIPAmount(address _ipt, address _bst, uint256 _amount) external {
        require(proxy == msg.sender, "Not Permit");
        pools[_ipt][_bst].curTotalIPAmount = _amount;
    }

    function setCurGPBalance(address _ipt, address _bst, uint256 _amount) external {
        require(proxy == msg.sender, "Not Permit");
        pools[_ipt][_bst].curTotalBalance = _amount;
    }

    function setGPBaseAmount(address _ipt, address _bst, address _gp, uint256 _amount) external {
        require(proxy == msg.sender, "Not Permit");
        require(pools[_ipt][_bst].GPM[_gp].valid == true, "GP Not Exist");
        pools[_ipt][_bst].GPM[_gp].baseTokensAmount = _amount;
    }

    function setGPRunningDepositAmount(address _ipt, address _bst, address _gp, uint256 _amount) external {
        require(proxy == msg.sender, "Not Permit");
        require(pools[_ipt][_bst].GPM[_gp].valid == true, "GP Not Exist");
        pools[_ipt][_bst].GPM[_gp].runningDepositAmount = _amount;
    }

    function setGPHoldIPAmount(address _ipt, address _bst, address _gp, uint256 _amount) external {
        require(proxy == msg.sender, "Not Permit");
        require(pools[_ipt][_bst].GPM[_gp].valid == true, "GP Not Exist");
        pools[_ipt][_bst].GPM[_gp].ipTokensAmount = _amount;
    }

    function setGPRaiseLPAmount(address _ipt, address _bst, address _gp, uint256 _amount) external {
        require(proxy == msg.sender, "Not Permit");
        require(pools[_ipt][_bst].GPM[_gp].valid == true, "GP Not Exist");
        pools[_ipt][_bst].GPM[_gp].raisedFromLPAmount = _amount;
    }

    function setGPBaseBalance(address _ipt, address _bst, address _gp, uint256 _amount) external {
        require(proxy == msg.sender, "Not Permit");
        require(pools[_ipt][_bst].GPM[_gp].valid == true, "GP Not Exist");
        pools[_ipt][_bst].GPM[_gp].baseTokensBalance = _amount;
    }

    function insertGP(address _ipt, address _bst, address _gp, uint256 _amount, bool running) external {
        require(proxy == msg.sender, "Not Permit");
        require(pools[_ipt][_bst].GPM[_gp].valid == false, "GP Already Exist");
        pools[_ipt][_bst].GPA.push(_gp);

        pools[_ipt][_bst].GPM[_gp].valid = true;
        pools[_ipt][_bst].GPM[_gp].id = pools[_ipt][_bst].GPA.length;
        if (running) {
            pools[_ipt][_bst].GPM[_gp].baseTokensAmount = 0;
            pools[_ipt][_bst].GPM[_gp].runningDepositAmount = _amount;
        } else {
            pools[_ipt][_bst].GPM[_gp].baseTokensAmount = _amount;
            pools[_ipt][_bst].GPM[_gp].runningDepositAmount = 0;
        }

        pools[_ipt][_bst].GPM[_gp].ipTokensAmount = 0;
        pools[_ipt][_bst].GPM[_gp].raisedFromLPAmount = 0;
        pools[_ipt][_bst].GPM[_gp].baseTokensBalance = 0;
    }

    function deleteGP(address _ipt, address _bst, address _gp) external {
        require(proxy == msg.sender, "Not Permit");
        require(pools[_ipt][_bst].GPM[_gp].valid == true, "GP Not Exist");
        uint256 id = pools[_ipt][_bst].GPM[_gp].id;
        uint256 length = pools[_ipt][_bst].GPA.length;

        pools[_ipt][_bst].GPA[id - 1] = pools[_ipt][_bst].GPA[length - 1];
        pools[_ipt][_bst].GPM[pools[_ipt][_bst].GPA[length - 1]].id = id;
        pools[_ipt][_bst].GPA.pop();

        pools[_ipt][_bst].GPM[_gp].valid = false;
        pools[_ipt][_bst].GPM[_gp].id = 0;
        pools[_ipt][_bst].GPM[_gp].baseTokensAmount = 0;
        pools[_ipt][_bst].GPM[_gp].runningDepositAmount = 0;
        pools[_ipt][_bst].GPM[_gp].ipTokensAmount = 0;
        pools[_ipt][_bst].GPM[_gp].raisedFromLPAmount = 0;
        pools[_ipt][_bst].GPM[_gp].baseTokensBalance = 0;
    }

    function getCurGPAmount(address _ipt, address _bst) external view returns(uint256) {
        return pools[_ipt][_bst].curTotalGPAmount;
    }

    function getCurRaiseLPAmount(address _ipt, address _bst) external view returns(uint256) {
        return pools[_ipt][_bst].curTotalLPAmount;
    }

    function getCurIPAmount(address _ipt, address _bst) external view returns(uint256) {
        return pools[_ipt][_bst].curTotalIPAmount;
    }

    function getCurGPBalance(address _ipt, address _bst) external view returns(uint256) {
        return pools[_ipt][_bst].curTotalBalance;
    }

    function getGPBaseAmount(address _ipt, address _bst, address _gp) external view returns(uint256) {
        require(pools[_ipt][_bst].GPM[_gp].valid == true, "GP Not Exist");
        return pools[_ipt][_bst].GPM[_gp].baseTokensAmount;
    }

    function getGPRunningDepositAmount(address _ipt, address _bst, address _gp) external view returns(uint256) {
        require(pools[_ipt][_bst].GPM[_gp].valid == true, "GP Not Exist");
        return pools[_ipt][_bst].GPM[_gp].runningDepositAmount;
    }

    function getGPHoldIPAmount(address _ipt, address _bst, address _gp) external view returns(uint256) {
        require(pools[_ipt][_bst].GPM[_gp].valid == true, "GP Not Exist");
        return pools[_ipt][_bst].GPM[_gp].ipTokensAmount;
    }

    function getGPRaiseLPAmount(address _ipt, address _bst, address _gp) external view returns(uint256) {
        require(pools[_ipt][_bst].GPM[_gp].valid == true, "GP Not Exist");
        return pools[_ipt][_bst].GPM[_gp].raisedFromLPAmount;
    }

    function getGPBaseBalance(address _ipt, address _bst, address _gp) external view returns(uint256) {
        require(pools[_ipt][_bst].GPM[_gp].valid == true, "GP Not Exist");
        return pools[_ipt][_bst].GPM[_gp].baseTokensBalance;
    }

    function getGPValid(address _ipt, address _bst, address _gp) external view returns(bool) {
        return pools[_ipt][_bst].GPM[_gp].valid;
    }

    function getGPArrayLength(address _ipt, address _bst) external view returns(uint256) {
        return pools[_ipt][_bst].GPA.length;
    }

    function getGPByIndex(address _ipt, address _bst, uint256 _id) external view returns(address) {
        require(_id < pools[_ipt][_bst].GPA.length, "Wrong ID");
        return pools[_ipt][_bst].GPA[_id];
    }

    function getGPAddresses(address _ipt, address _bst) external view returns(address[] memory) {
        return pools[_ipt][_bst].GPA;
    }
}