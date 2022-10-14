// SPDX-License-Identifier: MIT


// Implementation of Centralized Stablecoin by PattrickCollins but with additional extensive comments
// Copied from:
// https://github.com/smartcontractkit/defi-minimal/blob/main/contracts/stablecoins/CentralizedStableCoin.sol
// aka USDC

// This is considered an exogenous, centralized, anchored (pegged), fiat collateralized, low volitility coin

// Collateral: Exogenous
// Minting: Centralized
// Value: Anchored (Pegged to USD)
// Collateral Type: Fiat

// "Fiat Collateralized Stablecoin" 
// Or in simpler terms :: Keep $1 in pocket, and call mint()

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol"; 
import "@openzeppelin/contracts/access/Ownable.sol";



/// @notice The nomenclature of errors in this contract is excellent. Remember to follow these. 
/// @dev Check if long error names cost more.
/// @notice This errors are not used specifically in a function, but are embedded inside custom modifiers. Nice brother.

                            /////////////////////////EVENTS///////////////////////////////// 

error CentralizedStableCoin__NotMinter();                  // Reverts if address without minting authority tries to mint 
error CentralizedStableCoin__AddressBlacklisted();         // Reverts if blacklisted address tries to call functions
error CentralizedStableCoin__NotZeroAddress();
error CentralizedStableCoin__AmountMustBeMoreThanZero();   // Reverts incase of negative amount
error CentralizedStableCoin__ExceededMinterAllowance();    // Reverts if transfer amount more than allowance
error CentralizedStableCoin__BurnAmountExceedsBalance();   


/// @title  Centralized Stablecoin Implementation

/// @dev An extension of ERC20 Burnable and Ownable. 
// Its like calling all brother contracts to make a smart contract as Centralized as possible lol

contract CentralizedStableCoin is ERC20Burnable, Ownable {

                          //////////////////////////MAPPINGS//////////////////////////////////

    mapping(address => bool) internal s_blacklisted;                // Registry of all blacklisted addresses
    mapping(address => bool) internal s_minters;                    // Registry of authorized minter addresses
    mapping(address => uint256) internal s_minterAllowed;           // Registry of amount an address can mint

                         //////////////////////////EVENTS//////////////////////////////////

    event MinterConfigured(address indexed minter, uint256 minterAllowedAmount);  // Log of new minter assigned and the amount assigned
    event MinterRemoved(address indexed oldMinter);                               // Log when miniting roles taken from an address
    event Blacklisted(address indexed _account);                                  // Log of when an address is blacklisted
    event UnBlacklisted(address indexed _account);                                // Log of when an address is unblacklisted

                         //////////////////////////MODIFIERS//////////////////////////////////

    modifier onlyMinters() {                                  //Modifier For functions accessible only by address in the s_minters mapping
        if (!s_minters[msg.sender]) {
            revert CentralizedStableCoin__NotMinter();
        }
        _;
    }

    modifier notBlacklisted(address addressToCheck) {        //Modifier to check if the transfer isn't happening to a blacklisted address by checking in the s_blacklisted mapping
            revert CentralizedStableCoin__AddressBlacklisted();
        }
        _;
    }
                        //////////////////////////CONSTRUCTOR//////////////////////////////////


    /// @notice This function is executed when the contract is initially deployed
    /// @param initialSupply Amount of ERC20tokens to be brought into existence aka mint
    /// @notice This function allocates initialSupply to the contract deployer aka msg.sender
                      
    constructor(uint256 initialSupply) ERC20("CentralizedStablecoin", "CSC") {  
        _mint(msg.sender, initialSupply);
    }

                      //////////////////////////FUNCTIONS//////////////////////////////////
                      

    function mint(address _to, uint256 _amount)            
        external
        onlyMinters
        notBlacklisted(msg.sender)
        notBlacklisted(_to)
        returns (bool)
    {
        if (_to == address(0)) {
            revert CentralizedStableCoin__NotZeroAddress();
        }
        if (_amount <= 0) {
            revert CentralizedStableCoin__AmountMustBeMoreThanZero();
        }

        uint256 mintingAllowedAmount = s_minterAllowed[msg.sender];
        if (_amount > mintingAllowedAmount) {
            revert CentralizedStableCoin__ExceededMinterAllowance();
        }
        s_minterAllowed[msg.sender] = mintingAllowedAmount - _amount;
        _mint(msg.sender, mintingAllowedAmount);
        return true;
    }

    function burn(uint256 _amount) public override onlyMinters notBlacklisted(msg.sender) {
        uint256 balance = balanceOf(msg.sender);
        if (_amount <= 0) {
            revert CentralizedStableCoin__AmountMustBeMoreThanZero();
        }
        if (balance < _amount) {
            revert CentralizedStableCoin__BurnAmountExceedsBalance();
        }
        _burn(msg.sender, _amount);
    }

    /***************************/
    /* Minter settings */
    /***************************/

    function configureMinter(address minter, uint256 minterAllowedAmount)
        external
        onlyOwner
        returns (bool)
    {
        s_minters[minter] = true;
        s_minterAllowed[minter] = minterAllowedAmount;
        emit MinterConfigured(minter, minterAllowedAmount);
        return true;
    }

    function removeMinter(address minter) external onlyOwner returns (bool) {
        s_minters[minter] = false;
        s_minterAllowed[minter] = 0;
        emit MinterRemoved(minter);
        return true;
    }

    /***************************/
    /* Blacklisting Functions */
    /***************************/

    function isBlacklisted(address _account) external view returns (bool) {
        return s_blacklisted[_account];
    }

    function blacklist(address _account) external onlyOwner {
        s_blacklisted[_account] = true;
        emit Blacklisted(_account);
    }

    function unBlacklist(address _account) external onlyOwner {
        s_blacklisted[_account] = false;
        emit UnBlacklisted(_account);
    }

    /***************************/
    /* Blacklisting overrides */
    /***************************/

    function approve(address spender, uint256 value)
        public
        override
        notBlacklisted(msg.sender)
        notBlacklisted(spender)
        returns (bool)
    {
        super.approve(spender, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    )
        public
        override
        notBlacklisted(msg.sender)
        notBlacklisted(from)
        notBlacklisted(to)
        returns (bool)
    {
        super.transferFrom(from, to, value);
        return true;
    }

    function transfer(address to, uint256 value)
        public
        override
        notBlacklisted(msg.sender)
        notBlacklisted(to)
        returns (bool)
    {
        super.transfer(msg.sender, value);
        return true;
    }
}