// SPDX-License-Identifier: MIT
pragma solidity >=0.8.13;

interface ISimpleStore {
    function store(uint256 val) external;

    function get() external returns (uint256);
}
