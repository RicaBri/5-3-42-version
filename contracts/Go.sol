// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleRandomToken {
    // Public token parameters
    string public name;
    string public symbol;
    uint8 public constant decimals = 18;

    uint256 public totalSupply;

    // Balances and allowances
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // Standard ERC-20 events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // Custom errors for gas optimization
    error ERC20InvalidReceiver(address receiver);
    error ERC20InvalidSpender(address spender);
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);

    /**
     * @param _name  Token name
     * @param _symbol Token symbol
     * @param _initialSupply Initial supply in whole tokens (without decimals)
     */
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _initialSupply
    ) {
        name = _name;
        symbol = _symbol;

        uint256 supplyWithDecimals = _initialSupply * (10 ** uint256(decimals));
        totalSupply = supplyWithDecimals;

        // All tokens go to deployer
        balanceOf[msg.sender] = supplyWithDecimals;

        emit Transfer(address(0), msg.sender, supplyWithDecimals);
    }

    function _transfer(address _from, address _to, uint256 _value) internal {
        if (_to == address(0)) revert ERC20InvalidReceiver(address(0));
        
        uint256 fromBalance = balanceOf[_from];
        if (fromBalance < _value) revert ERC20InsufficientBalance(_from, fromBalance, _value);

        // Cannot underflow because we checked the balance above
        unchecked {
            balanceOf[_from] = fromBalance - _value;
        }
        balanceOf[_to] += _value;

        emit Transfer(_from, _to, _value);
    }

    // Standard transfer
    function transfer(address _to, uint256 _value) external returns (bool) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    // Approve spender
    function approve(address _spender, uint256 _value) external returns (bool) {
        if (_spender == address(0)) revert ERC20InvalidSpender(address(0));

        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // Transfer from another address using allowance
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool) {
        uint256 currentAllowance = allowance[_from][msg.sender];
        
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < _value) revert ERC20InsufficientAllowance(msg.sender, currentAllowance, _value);
            unchecked {
                allowance[_from][msg.sender] = currentAllowance - _value;
            }
        }

        _transfer(_from, _to, _value);
        return true;
    }
}