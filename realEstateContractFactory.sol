pragma solidity ^0.4.19;

contract RealEstateContractFactory {

    //*Real estate contract factory is designed to create user's contracts.*

   //Basic informations of each contract will be stored in dynamic arrayl.

    address[] public newContracts; //Every new contracts will be stored here with address
    address[] public sellers ; //To manage whole seller at once.
    address public owner; //In thies case, it will be me(JUNG A:D),the one who published this contract.

    event LOG_NewContractAddress(address indexed theNewContract, address indexed seller);

    constructor(){
        owner=msg.sender;
    }

    function createContract() external  {
         uint contractNumber= newContracts.length;
         sellers.push(msg.sender);
         address newContract = new SingleContract(contractNumber);
         newContracts.push(newContract);


         LOG_NewContractAddress(newContract,msg.sender);
    }

    function getContractAddressAtIndex(uint i) constant external returns(address contractAddress){
        return newContracts[i];
    }

    function getSellerAddress(uint i) constant external returns (address sellerAddress){
        return sellers[i];
    }

    function getContractArray() constant external returns (address[] contractAddressArray){
        return newContracts;
    }

    function getSellerArray() constant external returns (address[] sellerAddressArray){
        return sellers;
    }

    function getOwner() constant external returns (address _owner){
        return owner;
    }

}


contract RealEstateSingleContract {
    //Each of these contracts contain informations of every detail of contract

    address public seller;
    address public buyer;
    address public owner;
    uint public priceOfRealEstate;

    uint public contractNumber;
    bytes32 public contractType; //Monthly, Yearly, Buying

    constructor (uint _contractNumber){
        contractNumber=_contractNumber;
        RealEstateContractFactory rcf = RealEstateContractFactory(msg.sender);
        seller=rcf.getSellerAddress(contractNumber);
        owner = rcf.getOwner();

    }




    function setBuyerAddress(address _buyerAddress){
        buyer=_buyerAddress;
    }


    function setPriceOfRealEstate(uint _priceOfRealEstate) external {
        //There should be modifier to confirm it is permitted by seller and buyer.

        priceOfRealEstate = _priceOfRealEstate;


    }


    function signToContract() payable external  {
        if(msg.value != priceOfRealEstate){
        revert();
        }
        setDeposit();
        seller.transfer(msg.value);

    }

    function setDeposit() internal {
        uint deposit = 10000;//how can I set this as priceOfRealEstate*0.05;


    }
    
