// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IPStorage.sol";
import "./GPStorage.sol";
import "./VaultStorage.sol";
import "./LPStorage.sol";

contract NPStorage is Ownable {
    uint256 constant RATIO_FACTOR = 1000000;

    uint32	public minRatio;
    uint32	public alpha; //FIXME negative alpha
    uint32  public raiseRatio;

    uint256 public auctionDuration;
    uint256 public raisingDuration;
    uint256 public minimumDuration;

    address public DGTToken;
    address public DGTBeneficiary;

    // Uniswap router and factory
    address public router;
    address public factory;

    IPStorage public _IPS;
    GPStorage public _GPS;
    LPStorage public _LPS;
    VaultStorage public _VTS;

    function setMinRatio(uint32 _minRatio) external onlyOwner {
        minRatio = _minRatio;
    }

    function setAlpha(uint32 _alpha) external onlyOwner {
        alpha = _alpha;
    }

    function setRaiseRatio(uint32 _raiseRatio) external onlyOwner {
        raiseRatio = _raiseRatio;
    }

    function setDuration(uint256 _auction, uint256 _raising, uint256 _duration) external onlyOwner {
        require(_auction > 0 && _raising > 0 && _duration >= 2 * _raising,
                "Wrong Duration");
        auctionDuration = _auction;
        raisingDuration = _raising;
        minimumDuration = _duration;
    }
}