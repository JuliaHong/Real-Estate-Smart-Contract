pragma solidity ^0.4.23;
import './RealEstateContractFactory.sol';

contract RealEstateSingleContract{
    //Each of these contracts contain informations of every detail of contract


    address public buyer;
    address public owner;
    uint public originalNumber;
    uint public priceOfRealEstate;
    uint public statusOfRealEstate;
    uint public indexOfRealEstate;
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

    uint8 constant monthly =1; //Monthly
    uint8 constant yearly =2; // In Korean.. Jeon Sae!!!
    uint8 constant buying =3;

    //Money Clock for payment



    uint depositDeadLine; //Can make this longer if seller confirms.
    uint balanceDeadLine; //Can make this longer if seller confirms.






//***************************** Modifier *****************************************



    modifier onlyOwner{
       if(msg.sender != owner)
            revert();
        _;
    }

    modifier onlyBuyer{
        if(msg.sender !=buyer)
            revert();
        _;
    }


    //There are specific functions according to type of contract. (But why should I need to use modifier instead of requie statement? anyway..for now)


    modifier onlyMontly{
        if(contractType!=monthly)
            revert();
        _;

    }

    modifier onlyYearly{
        if(contractType!=yearly)
            revert();
        _;
    }

    modifier onlyBuying{
        if(contractType!=buying)
            revert();
        _;
    }

 //This modifier has a ability to fix contract if there is any mistake! but I'm not gonna leave it for now!

 //   modifier onlyAdmin{
 //       if(msg.sender !=admin)
 //           revert();
 //       _;
 //   }


//****************************** constructor ************************************************

    constructor(uint _indexOfRealEstate,address _seller,uint _price,uint _originalNumber,uint _statusOfRealEstate,uint8 typeOfContract) public {

        //get all the informations we need

       owner=_seller;
       priceOfRealEstate=_price;
       originalNumber=_originalNumber;
       statusOfRealEstate=_statusOfRealEstate; //It should be 1(FOR SALE MODE), maybe Im gonna make this one be in require.
       contractType = typeOfContract;
       indexOfRealEstate=_indexOfRealEstate;

       contract_status = contractBeforeSigned;


    }

//****************************** Functions Basic (For all type of contract) ************************************************


    function setBuyerAddress(address _buyerAddress){
        buyer=_buyerAddress;
    }



//****************************** Functions for BUYING contract ************************************************

    function setDeadLine(uint _depositDeadLine, uint _balanceDeadLine) internal { //for example setDeadLine(5,40) means until 5days and 40days from now.

        depositDeadLine = now + _depositDeadLine*86400;
        balanceDeadLine = now + _balanceDeadLine*86400;


    }

    function setDeposit(uint _deposit) external onlyOwner {
        deposit = deposit = _deposit * 10 ** 18; //wei => ether
        balance = priceOfRealEstate;
    }




    function signToBuyingContract() external onlyBuyer {
        require(contractType==buying);
        require(contract_status==0);

        contract_status = contractSigned_beforeDeposit;


    }

    //functions to send deposit and balance to seller;

    function sendDeposit() external payable onlyBuyer{
         require(msg.value==deposit);
        //require( now <= depositDeadLine);

        //owner.transfer(deposit);
        contract_status=contractSigned_beforeBalance;
        balance = priceOfRealEstate-deposit;

    }

    function getDeposit() public onlyOwner{
        msg.sender.transfer(address(this).balance);
    }


    function getBalance() external returns(uint) {

       return balance;

    }

    function sendBalance() onlyBuyer{
        //require(msg.value == balance);
        //require( now <= balanceDeadLine);

        owner.transfer(deposit);
        contract_status = contractSigned_completed;
    }

    //function to cancel the contract : onlylimited when buyer already paid depoist

    function cancelContractBySeller() payable {


        buyer.transfer(deposit);
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
