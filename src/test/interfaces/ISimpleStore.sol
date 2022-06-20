// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

interface ISimpleStore {
    function store(uint256 val) external;

    function get() external returns (uint256);
}