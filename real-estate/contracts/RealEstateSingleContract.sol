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


    //For Buying function;

    uint public pre_deposit; //가계약금 , 통상 계약금의 10%
    uint public pre_balance; //중도금 , 매매 부동산의 40%
    bool public pre_deposit_Exist=false;
    bool public pre_balance_Exist=false;

    //so there are gonna be type of Buying

    uint8 public buyingType = 0;


    uint8 simpleBuying =1 ; //      Deposit => Balance
    uint8 preBalanceBuying =2; //   Deposit => Pre_Balance => Balance
    uint8 preDepositBuying =3; //   Pre_Deposit => Deposit => Pre_Balance => Balance

    // I decided to use buyingStatus cause I thought it was waste of type to make every status for each type of buying contract.
    // The way it works is really Simple.
    // In the case of simple buying , two transfers are needed by buyer. like sending deposit and sending balance;
    // In the case of pre-balance buying, three tranfers will be needed as well.
    // So I'm gonna use buyingStatus count parameter to know where contract status is according to their buying type.

    uint8 public buyingStatus;


    //For Yearly function;

    uint8 public contractMonthForYearly;

    //For Monthly function;

    uint public monthlyRent;
    uint public contractMonthForMonthly;
    uint public remainedMonth;
    uint public paidMonth=0; //ContractMonthForMonthly = remainedMonth+paidMonth; //maybe just for assert






    //statement of contract

    uint8 public contract_status =contractBeforeSigned;

    uint8 constant contractBeforeSigned =0;
    uint8 constant contractSigned_beforeDeposit=1; //Buyer signed deposit but didn't send the deposit yet;
    uint8 constant contract_completed=2; // Buyer payed depoist and balance! EveryBody is happy :D
    uint8 constant contract_cancelled =3; //After sending depoist, buyer changed mind. End of this contract.



    //statement of Buying

    uint8 constant contractSigned_beforeBalance=10; //Buyer payed deposit but didn't send the balance yet;

    //statement of Monthly

    uint8 constant contractSigned_payingRent=20;
    uint8 constant contractSigned_expired=30; //So, technically buyer finished their contract, owner should give back buyer's deposit.

    //statement of Yearly


    uint8 public contractType; //Monthly, Yearly, Buying

    uint8 constant monthly =1; //Monthly
    uint8 constant yearly =2; // In Korean.. Jeon Sae!!!
    uint8 constant buying=3;

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

    // STEP1. Set the buyer's ethereum address.
    function setBuyerAddress(address _buyerAddress){
        buyer=_buyerAddress;
    }



    ////////////////////////////////////////////////////////////////
    //                                                            //
    //STEP2. Follow the instruction according to your contractType//
    //                                                            //
    ////////////////////////////////////////////////////////////////


    //STEP3. If you finish setting for your contract, sign to contract.
    function signToContract() external onlyBuyer {
        require(contractType==buying);
        require(contract_status==0);

        contract_status = contractSigned_beforeDeposit;


    }

    //STEP5. Send Deposit to seller

    function sendDeposit() external payable onlyBuyer{
         require(msg.value==deposit);
        //require( now <= depositDeadLine);

        owner.transfer(address(this).balance);


        //differencitate contract_status by their contractType

        // + need to find which one is cheeper between if-else if and switch :)

        if ( contractType == buying ){

            contract_status=contractSigned_beforeBalance;
            balance = priceOfRealEstate-deposit;

        }
        else if ( contractType == monthly ){
            contract_status=contractSigned_payingRent;
        }
        else if ( contractType == yearly ){
            //contract_status = fa;ldjsf;jad;slfj;l;
        }

    }
//****************************** Functions for BUYING contract ************************************************************


    function setTypeOfBuying(uint8 _type) external {
        require(_type>=1 && _type<=3);
        buyingType = _type;
    }


    function setContractCondition(uint _pre_deposit, uint _pre_balance, uint _deposit,uint _balance) external onlyOwner {


        if(buyingType==simpleBuying){
            balance=_balance*10**18; //already converted to ether in the market management file.
            deposit = _deposit*10**18;

            //assert(priceOfRealEstate==balance+deposit);
        }else if (buyingType == preBalanceBuying){
            balance = _balance*10**18;
            pre_balance=_pre_balance*10**18;
            deposit = _deposit*10**18;

            //assert(priceOfRealEstate==balance+pre_balance+deposit);

        }else if (buyingType == preDepositBuying){
            balance = _balance*10**18;
            pre_balance=_pre_balance*10**18;
            pre_deposit=_pre_deposit*10**18;
            deposit = _deposit*10**18;

            //assert(priceOfRealEstate == balance+pre_deposit+pre_balance+deposit);
        }


    }




    function setDeadLine(uint _depositDeadLine, uint _balanceDeadLine) internal { //for example setDeadLine(5,40) means until 5days and 40days from now.

        depositDeadLine = now + _depositDeadLine*86400;
        balanceDeadLine = now + _balanceDeadLine*86400;


    }




    //function getDeposit() public onlyOwner{
      //  msg.sender.transfer(address(this).balance);
    //}


    //*********************** SEND MONEY FUNCTION ********************************
    // 1. It depends on what kind of buying type you are on. (simple,preDeposit,preBalance Type)
    // 2. You should type what kind of money do you wanna send.
    // 3. You must complete previous step to go next one.
    // 4. So ,
    //     1 = pre_deposit , 2 = deposit , 3 = pre_balance, 4 = balance

    function sendMoneyToBuyer(uint8 _payType) payable onlyBuyer{
        require(_payType >=1 && _payType <=4);

        if(buyingType == simpleBuying) {
            if(_payType==2){ //if buyer wants to pay deposit , buyingStatus should be 0 (never transfered before)
                require(buyingStatus ==0);
                require(msg.value == deposit);
                owner.transfer(address(this).balance);
                buyingStatus++; //means that you paid deposit.
            }
            else if(_payType==4){
                require(buyingStatus==1); // It means buyer should have already paid deposit.
                require(msg.value == balance);
                owner.transfer(address(this).balance);
                buyingStatus++; //So buyingStatus is 2 right now which means simpleBuying contract is "COMPLETED"
            }

        }

        else if (buyingType == preBalanceBuying){

            if(_payType==2){ //if buyer wants to pay deposit , buyingStatus should be 0 (never transfered before)
                require(buyingStatus ==0);
                require(msg.value == deposit);
                owner.transfer(address(this).balance);
                buyingStatus++; //means that you paid deposit.
            }
            else if(_payType==3){
                require(buyingStatus==1); // It means buyer should have already paid deposit.
                require(msg.value == pre_balance);
                owner.transfer(address(this).balance);
                buyingStatus++;
            }
            else if(_payType==4){
                require(buyingStatus==2);
                require(msg.value == balance);
                owner.transfer(address(this).balance);
                buyingStatus++; //So buyingStatus is 3 right now which means preBalanceBuying contract is "COMPLETED" woo hoo~><
            }



        }
        else if (buyingType == preDepositBuying){


            if (_payType==1){
							 	require(buyingStatus == 0);
								require(msg.value == pre_deposit);
								owner.transfer(address(this).balance);
								buyingStatus++;
            }
            else if(_payType==2){
                require(buyingStatus ==1);
                require(msg.value == deposit);
                owner.transfer(address(this).balance);
                buyingStatus++; //means that you paid deposit.
            }
            else if(_payType==3){
                require(buyingStatus==2); // It means buyer should have already paid deposit.
                require(msg.value == pre_balance);
                owner.transfer(address(this).balance);
                buyingStatus++;
            }
            else if(_payType==4){
                require(buyingStatus==3);
                require(msg.value == balance);
                owner.transfer(address(this).balance);
                buyingStatus++; //So buyingStatus is 4 right now which means preDepositBuying contract is "COMPLETED" woo hoo~><
            }



        }
    }

    //function to cancel the contract : onlylimited when buyer already paid depoist

    function cancelContractBySeller() payable {


        buyer.transfer(deposit);
        contract_status = contract_cancelled;


    }

    function cancelContractByBuyer() payable onlyBuyer {

        if (contract_status == contractSigned_beforeDeposit){
            require(msg.value == deposit);
            //seller.transfer(msg.value); //even if you didn't send deposit you need to send him depoist because you are the one who cancelled this contract.
            contract_status = contract_cancelled;
        }
        else if (contract_status == contractSigned_beforeBalance){ //When buyer already payed deposit , seller doesn't need to give deposit back to buyer
            contract_status = contract_cancelled;
        }

    }

//****************************** Function for Yearly(Jeon Sae) contract ************************************************************

    function setContractMonth(uint8 _month) external onlyOwner {

        contractMonthForYearly = _month;

    }



//****************************** Function for Monthly contract ************************************************************

    function setMonthlyContract(uint _rentMoney,uint _contractMonth) external onlyOwner{

        monthlyRent=_rentMoney*10**18; //wei  to ether
        contractMonthForMonthly=_contractMonth;
        remainedMonth=_contractMonth;


    }

    function payMonthlyRent() payable onlyBuyer{
        require(msg.value == monthlyRent);
        require(contract_status ==contractSigned_payingRent);

        owner.transfer(address(this).balance);
        remainedMonth--;
        paidMonth++;

        assert(contractSigned_payingRent == remainedMonth+paidMonth);

        if(paidMonth==contractMonthForMonthly){
            contract_status==contractSigned_expired; // As this contract is ended, owner should give back buyer deposit.
        }
    }

    function SendBackDeposit() payable external onlyOwner { //This is diffrent from cancelled contract because it is simply completed contract due to end of contract months.

        require(msg.value == deposit);
        require(contract_status == contractSigned_expired);

        buyer.transfer(address(this).balance);


        contract_status = contract_completed;


    }



}
