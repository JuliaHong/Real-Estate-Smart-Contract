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
         address newContract = new RealEstateSingleContract(contractNumber);
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
    uint public deposit;
    uint public balance;


    //statement of contract

    uint8 public contract_now =contractBeforeSigned;

    uint8 constant contractBeforeSigned =0;
    uint8 constant contractSigned_beforeDeposit=10; //Buyer signed deposit but didn't send the deposit yet;
    uint8 constant contractSigned_beforeBalance=20; //Buyer payed deposit but didn't send the balance yet;
    uint8 constant contractSigned_completed=100; // Buyer payed depoist and balance! EveryBody is happy :D
    uint8 constant contractSigned_cancelled =255; //After sending depoist, buyer changed mind. End of this contract.



    //Money Clock for payment



    uint depositDeadLine; //Can make this longer if seller confirms.
    uint balanceDeadLine; //Can make this longer if seller confirms.



    uint public contractNumber;
    bytes32 public contractType; //Monthly, Yearly, Buying

//***************************** Modifier *****************************************



    modifier onlySeller{
        if(msg.sender != seller)
            revert();
        _;
    }

    modifier onlyBuyer{
        if(msg.sender !=buyer)
            revert();
        _;
    }

    //This modifier has a ability to fix contract if there is any mistake!

    modifier onlyOwner{
        if(msg.sender !=owner)
            revert();
        _;
    }


//****************************** Functions ************************************************

    constructor (uint _contractNumber){
        contractNumber=_contractNumber;
        RealEstateContractFactory rcf = RealEstateContractFactory(msg.sender);
        seller=rcf.getSellerAddress(contractNumber);
        owner = rcf.getOwner();

    }




    function setBuyerAddress(address _buyerAddress){
        buyer=_buyerAddress;
    }


    function setPriceOfRealEstate(uint _priceOfRealEstate) external onlySeller {
        //There should be modifier to confirm it is permitted by seller and buyer.

        priceOfRealEstate = _priceOfRealEstate;


    }

    function setDeadLine(uint _depositDeadLine, uint _balanceDeadLine) onlySeller{ //for example setDeadLine(5,40) means until 5days and 40days from now.

        depositDeadLine = now + _depositDeadLine*86400;
        balanceDeadLine = now + _balanceDeadLine*86400;



    }

    function setDeposit(uint _deposit) internal onlySeller{
        deposit = _deposit;//how can I set this as priceOfRealEstate*0.05;
    }

    function getBalance() {
        if(contract_now < contractSigned_beforeBalance){
            revert(); // if you didn't send deposit yet, you are not allowed to check the balance
        }
        balance = priceOfRealEstate - deposit;

    }


    function signToContract() payable external  {

        contract_now = contractSigned_beforeDeposit;


    }

    //functions to send deposit and balance to seller;

    function sendDeposit() payable onlyBuyer{
        require(msg.value==deposit);
        require( now <= depositDeadLine);

        seller.transfer(msg.value);
        contract_now=contractSigned_beforeBalance;

    }

    function sendBalance() payable onlyBuyer{
        require(msg.value == balance);
        require( now <= balanceDeadLine);

        seller.transfer(msg.value);
        contract_now = contractSigned_completed;
    }

    //function to cancel the contract : onlylimited when buyer already paid depoist

    function cancelContractBySeller() payable onlySeller{





        require(msg.value == deposit);
        buyer.transfer(msg.value);
        contract_now = contractSigned_cancelled;


    }

    function cancelContractByBuyer() payable onlyBuyer {

        if (contract_now == contractSigned_beforeDeposit){
            require(msg.value == deposit);
            seller.transfer(msg.value); //even if you didn't send deposit you need to send him depoist because you are the one who cancelled this contract.
            contract_now = contractSigned_cancelled;
        }
        else if (contract_now == contractSigned_beforeBalance){ //When buyer already payed deposit , seller doesn't need to give deposit back to buyer
            contract_now = contractSigned_cancelled;
        }

    }







}
