//SPDX-License-Identifier: MIT

pragma solidity 0.8.29;

event Transfer(address indexed from, address indexed to, uint256 value);

contract ManualToken {
    mapping(address => uint256) private s_balances;

    function name() external pure returns (string memory) {
        return "Manual Token";
    }

    function totalSupply() external pure returns (uint256) {
        return 100 ether;
    }

    function decimals() external pure returns (uint8) {
        return 18;
    }

    function balanceOf(address _owner) external view returns (uint256) {
        return s_balances[_owner];
    }

    function transfer(address _to, uint256 _amount) external returns (bool) {
        require(s_balances[msg.sender] >= _amount, "Insufficient balance");
        s_balances[msg.sender] -= _amount;
        s_balances[_to] += _amount;
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }
}
