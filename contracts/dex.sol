// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Exchange is ERC20 {
    address public tokenSwapAddress;

    constructor(address tokenSwapAddress_) ERC20("Exchange", "EXC") {
        tokenSwapAddress = tokenSwapAddress_;
    }

    function getReserve() public view returns (uint) {
        return ERC20(tokenSwapAddress).balanceOf(address(this));
    }

    function addLiquidity(uint amount_) public payable returns (uint) {
        uint liquidity;
        uint ethBalance = address(this).balance;
        uint tokenSwapReserve = getReserve();
        ERC20 tokenSwap = ERC20(tokenSwapAddress);

        require(amount_ > 0, "Amount must be greater than 0");
        require(msg.value > 0, "Must send ETH");

        if (tokenSwapReserve == 0) {
            tokenSwap.transferFrom(msg.sender, address(this), amount_);
            liquidity = ethBalance;
            _mint(msg.sender, liquidity);
        } else {
            uint ethReserve = ethBalance - msg.value;
            uint tokenSwapAmount = (msg.value * tokenSwapReserve) /
                (ethReserve);
            require(
                amount_ >= tokenSwapAmount,
                "DEX: Amount of tokens sent is less than the minimum tokens required"
            );
            tokenSwap.transferFrom(msg.sender, address(this), tokenSwapAmount);
            liquidity = (totalSupply() * msg.value) / ethReserve;
            _mint(msg.sender, liquidity);
        }
        return liquidity;
    }

    function removeLiquidity(uint amount_) public returns (uint, uint) {
        require(amount_ > 0, "DEX: amount should be greater than zero");
        uint ethReserve = address(this).balance;
        uint _totalSupply = totalSupply();
        uint ethAmount = (ethReserve * amount_) / _totalSupply;
        uint tokenSwapAmount = (getReserve() * amount_) / _totalSupply;
        _burn(msg.sender, amount_);
        payable(msg.sender).transfer(ethAmount);
        ERC20(tokenSwapAddress).transfer(msg.sender, tokenSwapAmount);
        return (ethAmount, tokenSwapAmount);
    }

    function getAmountExchange(
        uint256 inputAmount,
        uint256 inputReserve,
        uint256 outputReserve
    ) public pure returns (uint256) {
        require(
            inputAmount > 0,
            "DEX: input amount should be greater than zero"
        );
        require(
            inputReserve > 0 && outputReserve > 0,
            "DEX: input and output reserves should be greater than zero"
        );
        //fee = 3%
        uint256 inputAmountWithFee = inputAmount * 997;

        uint256 numerator = inputAmountWithFee * outputReserve;
        uint256 denominator = inputReserve * 1000 + inputAmountWithFee;
        uint256 outputAmount = numerator / denominator;
        return outputAmount;
    }

    function ethToTokenSwap(uint256 minToken_) public payable {
        uint256 tokenSwapReserve = getReserve();
        uint256 tokenSwapAmount = getAmountExchange(
            msg.value,
            address(this).balance - msg.value,
            tokenSwapReserve
        );
        require(
            tokenSwapAmount >= minToken_,
            "DEX: Amount of tokens received is less than the minimum tokens required"
        );
        ERC20(tokenSwapAddress).transfer(msg.sender, tokenSwapAmount);
    }

    function tokenSwapToEth(uint tokenSwapAmount_, uint minEth_) public {
        uint ethReserve = address(this).balance;
        uint ethAmount = getAmountExchange(
            tokenSwapAmount_,
            getReserve(),
            ethReserve
        );
        require(
            ethAmount >= minEth_,
            "DEX: Amount of ETH received is less than the minimum ETH required"
        );
        ERC20(tokenSwapAddress).transferFrom(
            msg.sender,
            address(this),
            tokenSwapAmount_
        );
        payable(msg.sender).transfer(ethAmount);
    }
}
