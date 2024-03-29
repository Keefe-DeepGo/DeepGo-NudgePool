// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract LPStorage {
    struct LPInfo {
        bool        valid;
        uint256     id; // index in LPA
        uint256     baseTokensAmount;
        uint256     runningDepositAmount;
        uint256     accVaultReward;
    }

    struct PoolInfo {
        uint256     curTotalLPAmount; // baseToken unit

        address[]   LPA;
        mapping(address => LPInfo) LPM;
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

    function setCurLPAmount(address _ipt, address _bst, uint256 _amount) external {
        require(proxy == msg.sender, "Not Permit");
        pools[_ipt][_bst].curTotalLPAmount = _amount;
    }

    function setLPBaseAmount(address _ipt, address _bst, address _lp, uint256 _amount) external {
        require(proxy == msg.sender, "Not Permit");
        require(pools[_ipt][_bst].LPM[_lp].valid == true, "LP Not Exist");
        pools[_ipt][_bst].LPM[_lp].baseTokensAmount = _amount;
    }

    function setLPRunningDepositAmount(address _ipt, address _bst, address _lp, uint256 _amount) external {
        require(proxy == msg.sender, "Not Permit");
        require(pools[_ipt][_bst].LPM[_lp].valid == true, "LP Not Exist");
        pools[_ipt][_bst].LPM[_lp].runningDepositAmount = _amount;
    }

    function setLPVaultReward(address _ipt, address _bst, address _lp, uint256 _amount) external {
        require(proxy == msg.sender, "Not Permit");
        require(pools[_ipt][_bst].LPM[_lp].valid == true, "LP Not Exist");
        pools[_ipt][_bst].LPM[_lp].accVaultReward = _amount;
    }

    function insertLP(address _ipt, address _bst, address _lp, uint256 _amount, bool running) external {
        require(proxy == msg.sender, "Not Permit");
        require(pools[_ipt][_bst].LPM[_lp].valid == false, "LP Already Exist");
        pools[_ipt][_bst].LPA.push(_lp);

        pools[_ipt][_bst].LPM[_lp].valid = true;
        pools[_ipt][_bst].LPM[_lp].id = pools[_ipt][_bst].LPA.length;
        if (running) {
            pools[_ipt][_bst].LPM[_lp].baseTokensAmount = 0;
            pools[_ipt][_bst].LPM[_lp].runningDepositAmount = _amount;
        } else {
            pools[_ipt][_bst].LPM[_lp].baseTokensAmount = _amount;
            pools[_ipt][_bst].LPM[_lp].runningDepositAmount = 0;
        }
        
        pools[_ipt][_bst].LPM[_lp].accVaultReward = 0;
    }

    function deleteLP(address _ipt, address _bst, address _lp) external {
        require(proxy == msg.sender, "Not Permit");
        require(pools[_ipt][_bst].LPM[_lp].valid == true, "LP Not Exist");
        uint256 id = pools[_ipt][_bst].LPM[_lp].id;
        uint256 length = pools[_ipt][_bst].LPA.length;

        pools[_ipt][_bst].LPA[id - 1] = pools[_ipt][_bst].LPA[length - 1];
        pools[_ipt][_bst].LPM[pools[_ipt][_bst].LPA[length - 1]].id = id;
        pools[_ipt][_bst].LPA.pop();

        pools[_ipt][_bst].LPM[_lp].valid = false;
        pools[_ipt][_bst].LPM[_lp].id = 0;
        pools[_ipt][_bst].LPM[_lp].baseTokensAmount = 0;
        pools[_ipt][_bst].LPM[_lp].runningDepositAmount = 0;
        pools[_ipt][_bst].LPM[_lp].accVaultReward = 0;
    }

    function getCurLPAmount(address _ipt, address _bst) external view returns(uint256) {
        return pools[_ipt][_bst].curTotalLPAmount;
    }

    function getLPBaseAmount(address _ipt, address _bst, address _lp) external view returns(uint256) {
        require(pools[_ipt][_bst].LPM[_lp].valid == true, "LP Not Exist");
        return pools[_ipt][_bst].LPM[_lp].baseTokensAmount;
    }

    function getLPRunningDepositAmount(address _ipt, address _bst, address _lp) external view returns(uint256) {
        require(pools[_ipt][_bst].LPM[_lp].valid == true, "LP Not Exist");
        return pools[_ipt][_bst].LPM[_lp].runningDepositAmount;
    }

    function getLPVaultReward(address _ipt, address _bst, address _lp) external view returns(uint256) {
        require(pools[_ipt][_bst].LPM[_lp].valid == true, "LP Not Exist");
        return pools[_ipt][_bst].LPM[_lp].accVaultReward;
    }

    function getLPValid(address _ipt, address _bst, address _lp) external view returns(bool) {
        return pools[_ipt][_bst].LPM[_lp].valid;
    }

    function getLPArrayLength(address _ipt, address _bst) external view returns(uint256) {
        return pools[_ipt][_bst].LPA.length;
    }

    function getLPByIndex(address _ipt, address _bst, uint256 _id) external view returns(address) {
        require(_id < pools[_ipt][_bst].LPA.length, "Wrong ID");
        return pools[_ipt][_bst].LPA[_id];
    }

    function getLPAddresses(address _ipt, address _bst) external view returns(address[] memory){
        return pools[_ipt][_bst].LPA;
    }
}