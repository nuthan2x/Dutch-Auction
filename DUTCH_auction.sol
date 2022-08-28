//SPDX-License-Identifier: MIT

pragma solidity >=0.8.16;

interface IERC721{
    function safeTransferFrom(address from,address to,uint tokenID) external;
    function transferFrom(address,address,uint) external;
}

contract DUTCH_auction{

    IERC721 public immutable MyNFT;
    uint public immutable nftID;

    address public seller;
    uint public startingprice;
    uint public discountRATE;
    uint public startat;
    uint public endAt;
    uint private duration = 7 days ;

    constructor(address _mynft,uint _nftID,uint _startingprice,uint _discountrate){

        startingprice = _startingprice;
        require(_startingprice > (_discountrate * duration ),"discountrate toohigh it dips below startingprice,set low discountrate");
        discountRATE = _discountrate; 
        startat= block.timestamp;
    
        MyNFT = IERC721(_mynft);
        nftID= _nftID;
        seller = msg.sender;

    }

    function currentprice() public view returns(uint){
        return startingprice - (discountRATE * (block.timestamp - startat));
    }

    function pay() external payable{
        require(block.timestamp < endAt);
        uint price = currentprice();

        require(msg.value >= price);
        MyNFT.safeTransferFrom(seller,msg.sender, price);

        if(msg.value - price >0){
            payable(msg.sender).transfer(msg.value - price);
        }

        selfdestruct(payable(seller));


    }
}
