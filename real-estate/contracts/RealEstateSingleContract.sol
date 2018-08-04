pragma solidity ^0.4.23;
import './RealEstateContractFactory.sol';

contract RealEstateSingleContract{
    //Each of these contracts contain informations of every detail of contract


    address public buyer;
    address public owner;

    uint public priceOfRealEstate;
    uint public deposit;
    uint public balance;


    //statement of contract

    uint8 public contract_status =contractBeforeSigned;

    uint8 constant contractBeforeSigned =0;
    uint8 constant contractSigned_beforeDeposit=10; //Buyer signed deposit but didn't send the deposit yet;
    uint8 constant contractSigned_beforeBalance=20; //Buyer payed deposit but didn't send the balance yet;
    uint8 constant contractSigned_completed=100; // Buyer payed depoist and balance! EveryBody is happy :D
    uint8 constant contractSigned_cancelled =255; //After sending depoist, buyer changed mind. End of this contract.

    uint8 public contractType; //Monthly, Yearly, Buying

    uint8 constant montly =1; //Monthly
    uint8 constant yearly =2; // In Korean.. Jeon Sae!!!
    uint8 constant Buying =3;

    //Money Clock for payment



    uint depositDeadLine; //Can make this longer if seller confirms.
    uint balanceDeadLine; //Can make this longer if seller confirms.






//***************************** Modifier *****************************************



/*    modifier onlySeller{
       if(msg.sender != seller)
            revert();
        _;
    }*/

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

    constructor(uint _indexOfRealEstate,address seller,uint price,uint originalNumber,uint statusOfRealEstate) public {





    }




    function setBuyerAddress(address _buyerAddress){
        buyer=_buyerAddress;
    }


    function setPriceOfRealEstate(uint _priceOfRealEstate) external{
        //There should be modifier to confirm it is permitted by seller and buyer.

        priceOfRealEstate = _priceOfRealEstate;


    }

    function setDeadLine(uint _depositDeadLine, uint _balanceDeadLine) internal { //for example setDeadLine(5,40) means until 5days and 40days from now.

        depositDeadLine = now + _depositDeadLine*86400;
        balanceDeadLine = now + _balanceDeadLine*86400;



    }

    function setDeposit(uint _deposit) internal {
        deposit = _deposit;//how can I set this as priceOfRealEstate*0.05;
    }

    function getBalance() external {
        if(contract_status < contractSigned_beforeBalance){
            revert(); // if you didn't send deposit yet, you are not allowed to check the balance
        }
        balance = priceOfRealEstate - deposit;

    }


    function signToContract() payable external  {

        contract_status = contractSigned_beforeDeposit;


    }

    //functions to send deposit and balance to seller;

    function sendDeposit() payable onlyBuyer{
        require(msg.value==deposit);
        require( now <= depositDeadLine);

       // seller.transfer(msg.value);
        contract_status=contractSigned_beforeBalance;

    }

    function sendBalance() payable onlyBuyer{
        require(msg.value == balance);
        require( now <= balanceDeadLine);

       // seller.transfer(msg.value);
        contract_status = contractSigned_completed;
    }

    //function to cancel the contract : onlylimited when buyer already paid depoist

    function cancelContractBySeller() payable {





        require(msg.value == deposit);
        buyer.transfer(msg.value);
        contract_status = contractSigned_cancelled;


    }

    function cancelContractByBuyer() payable onlyBuyer {

        if (contract_status == contractSigned_beforeDeposit){
            require(msg.value == deposit);
            //seller.transfer(msg.value); //even if you didn't send deposit you need to send him depoist because you are the one who cancelled this contract.
            contract_status = contractSigned_cancelled;
        }
        else if (contract_status == contractSigned_beforeBalance){ //When buyer already payed deposit , seller doesn't need to give deposit back to buyer
            contract_status = contractSigned_cancelled;
        }

    }







}
