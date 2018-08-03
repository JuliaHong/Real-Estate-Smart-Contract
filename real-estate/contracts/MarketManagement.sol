pragma solidity ^0.4.23;

contract MarketMangement{

    uint public availableRealEstate;
    uint public completedRealEstate;
    uint public allRealEstate;

    InfoForLedger[] RealEstateList;

    mapping (uint => bool) existenceCheck; //This is basically for finding out that RealEstate is already existing or not. (Need to find out new method cause it costs gas....but how...:()
    mapping (uint => InfoForLedger) InfoForLedgerByOriginalNumber; //This will help you find InfoForLedgr using OriginalNumber.


    event LOG_NewRealEstate(address seller, uint price, uint originalNumberOfRealEstate,uint statusOfRealEstate,uint indexOfRealEstate);
    event LOG_UpdatedStatus(uint statusOfRealEstate,address seller, uint price, uint originalNumberOfRealEstate,uint indexOfRealEstate);

    struct InfoForLedger{ //These informations of Real Estate are gonna be recorded on ethereum network. (cause It is important!)
        address owner;
        uint price;
        uint originalNumber; //Each real-estate has their own a 14-digit number managed by gorvernment.
        uint status; // 1 = forSale 2 = Sold out (!!!!!!IMPORTNANT!!!!!!!!)
    }

    struct InfoForDatabase{ //Unlike InfoForLedger, this will be recorded on mySQL or MongoDB.(cause It is considered less important!)

        //Since I didn't study mySQL or MongoDB I will leave empty for now.
        //I'm gonna manage data like pictures,address,and other informations of realEstate.

    }

    function uploadNewRealEstate(address _owner, uint _price, uint _originalNumber){

        uint index = RealEstateList.length;
        require(existenceCheck[index]!=true); //If that is true, It means it is already uploaded before.

        RealEstateList.push(InfoForLedger(msg.sender,_price,_originalNumber,1));
        InfoForLedgerByOriginalNumber[_originalNumber]=RealEstateList[index]; //so.. Now you can find LedgerInfo through index(0,1,2...) or 14-digit number!


        existenceCheck[index]=true; //As this is checked as true, you can't use this function again!
        availableRealEstate++;
        allRealEstate++;


        emit LOG_NewRealEstate(msg.sender,_price,_originalNumber,1,index);


    }

    function toggleStatus(uint _index){ //Still thinking between originalNumber and index.. but for now!
        require(existenceCheck[_index]==true); //If that is false, It means it doesn't exit. So there is nothing to toggle.
        require(msg.sender==RealEstateList[_index].owner); //OnlyOwner of realEstate can change status of realEstate!

        //To be sure... HERE IS STATUS MODE

        //  1  =  FOR SALE MODE
        //  2  =  SOLD OUT MODE



        if(RealEstateList[_index].status==1){//when this is sold to someone, we need to change this status to 2(SOLDOUT MODE).
         RealEstateList[_index].status=2;
         completedRealEstate++;
         availableRealEstate--;

          assert(allRealEstate==completedRealEstate+availableRealEstate); //just for check!

        }else{
            RealEstateList[_index].status=1; //So this realEstate is FOR SALE mode now! :D wow hehe
            completedRealEstate--;
            availableRealEstate++;

          assert(allRealEstate==completedRealEstate+availableRealEstate); //just for check!
        }

    }


    //function getRealEstateList() returns(InfoForLedger[]){
    //    return RealEstateList;            ****** THIS FUNCTION IS NOT AVAILABLE NOW ********
    // }

    function getRealEstateInfoByIndex(uint _index) returns (address _owner,uint _price,uint _originalNumber,uint _status) {
        require(existenceCheck[_index]==true);
        InfoForLedger info =RealEstateList[_index];

        return (info.owner,info.price,info.originalNumber,info.status);
    }




}
