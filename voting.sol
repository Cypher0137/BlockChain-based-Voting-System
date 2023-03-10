//SPDX-Licence-Identifier : GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract Balance{
    // variables

    struct vote{
        address voterAdress;
        bool choice;
    }

    struct voter{
        string voterName;
        bool voted;
    }

    uint private countResult=0;
    uint public finalResult=0;

    uint public totalVoter=0;
    uint public totalVote=0;

    address public ballotOfficialAdress;
    string public ballotOfficialName;
    string public proposal;

    mapping(uint => vote) private votes;
    mapping(address => voter) public voterRegister;

    enum State { Created, Voting, Ended}

    State public state;

    // modifiers

    modifier condition(bool _condition){
        require (_condition);
        _;
    }

    modifier onlyOfficial(){
        require (msg.sender == ballotOfficialAdress);
        _;
    }

    modifier inState(State _state){
        require(state == _state);
        _;
    }

    // functions

    constructor(string memory _ballotOfficialName, string memory _proposal){
        ballotOfficialAdress = msg.sender;
        ballotOfficialName = _ballotOfficialName;
        proposal =_proposal;

        state = State.Created;
    }

    function addVoter(address _voterAdress, string memory _voterName) 
        public
        inState(State.Created)
        onlyOfficial
    {
        voter memory v;
        v.voterName = _voterName;
        v.voted= false;
        voterRegister[_voterAdress]= v;
        totalVoter++;
    }
    function startVote()
    public 
    inState(State.Created)
    onlyOfficial
    {
        state=State.Voting;
    }

    function doVote(bool _choice)
    public
    inState(State.Voting)
    returns (bool voted)
    {
        bool found = false;
        if(bytes(voterRegister[msg.sender].voterName).length!=0 && !voterRegister[msg.sender].voted){
            voterRegister[msg.sender].voted = true;
            vote memory v;
            v.voterAdress= msg.sender;
            v.choice = _choice;
            if(_choice){
                countResult++; 
            }
            votes[totalVoter]=v;
            totalVote++;
            found=true;
        }
        return found;
    }

    function endVote()
    public
    inState(State.Voting)
    onlyOfficial
    {
        state=State.Ended;
        finalResult = countResult;
    }
}