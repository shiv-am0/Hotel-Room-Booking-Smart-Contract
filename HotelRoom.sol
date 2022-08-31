//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HotelRoom {
    //Below enumeration is used to know the vacancy of the Hotel Room
    enum Status { 
        VACANT, 
        OCCUPIED
    }
    Status public currentStatus;

    //Below event is used to log the details of the booking person
    event Occupy(address _occupant, uint _value);

    address payable public owner;
    address public bookedAddress; 

    constructor() {
        owner = payable(msg.sender);
        currentStatus = Status.VACANT;
    }

    //Below modifier checks if the room is vacant
    modifier onlyWhenVacant {
        require(currentStatus == Status.VACANT, "Currently Occupied");
        _;
    }

    //Below modifier checks if the amount of rther tranferred to owner is greater than the minimum cost
    modifier minimumCost(uint _cost) {
        require(msg.value >= _cost, "Not enough ether provided");
        _;
    }

    //Below modifier only allows the booked person to call the leave() function
    modifier ifSameAsBookedPerson(address _address) {
        require(_address == bookedAddress, "You can not call this function");
        _;
    }

    //Below modifier only allows to call leave() function if the room is already occupied
    modifier isAlreadyBooked() {
        require(currentStatus == Status.OCCUPIED, "Room is already vacant");
        _;
    }

    //Below function is executed only when the modifier conditions are met
    function book() payable public onlyWhenVacant minimumCost(0.5 ether){
        currentStatus = Status.OCCUPIED;
        //Transfer money to owner account and get the status and data sent and booking is confirm only if ether is sent successfully
        (bool sent, bytes memory data) = owner.call{value: msg.value}("");
        require(sent);
        //Call the event Occupy to have the details of the occupant
        bookedAddress = msg.sender;
        emit Occupy(msg.sender, msg.value);
    }

    //Below function is used to leave the hotel room
    function leave() public isAlreadyBooked ifSameAsBookedPerson(msg.sender) {
        currentStatus = Status.VACANT;
    }
}