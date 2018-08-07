pragma solidity ^0.4.23;
import './MarketManagement.sol';
import './RealEstateSingleContract.sol';

contract RealEstateContractFactory is MarketManagement {

   //Realestate contract factory is designed to create user's contracts.

    address[] public newContracts; //Every new contracts will be stored here with address
    address public admin; //The one who published this contract,me.
    uint public numberOfContracts;

    event LOG_NewContractAddress(address theNewContract, address seller,uint price,uint originalNumber);

    constructor(){
        admin=msg.sender;
    }

    function createContract(address marketAddress,uint _index,uint8 _typeOfContract) external  { //index of RealEstate (need to think about using 14-digits original number)

        //only seller(owner of Real Estate) can make single contract.


        //Get informations of RealEstate which we are gonna make contract on.
        address RealEstateOwner;
        uint price;
        uint originalNumber;
        uint status;


        MarketManagement m = MarketManagement(marketAddress);



        (RealEstateOwner,price,originalNumber,status)=m.getRealEstateInfoByIndex(_index);

        require(msg.sender==RealEstateOwner); //Only owner of this realEstate can make contract!
        require(status==1); //Status of realEstate should be 1 which means it is FOR SALE MODE;

        address newContract = new RealEstateSingleContract(_index,msg.sender,price,originalNumber,status,_typeOfContract);
        newContracts.push(newContract);

        numberOfContracts++;

        emit LOG_NewContractAddress(newContract,msg.sender,price,originalNumber); //This is for interacting with web3 later.



    }



    function getNumberOfContracts() constant external returns(uint){


        return numberOfContracts;

    }



    function getContractAddressAtIndex(uint i) constant external returns(address contractAddress){
        return newContracts[i];
    }



    function getContractArray() constant external returns (address[] contractAddressArray){
        return newContracts;
    }



    function getAdminOfContract() constant external returns (address _admin){ //It doesn't mean owner of each realEstate, it means owner of this contract.
        return admin;
    }

}
