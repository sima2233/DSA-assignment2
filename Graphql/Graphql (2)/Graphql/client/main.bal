import ballerina/io;
import ballerina/graphql;



type Employee record{|
    string employeeID;
    string firstname;
    string lastname;
    string jobTitle;
    int total_score;
    string supervisorName;
    |};


    type Objective record{|
    string ID;
    string objectiveName;
    string department;
    |};

    type KPI record{
    int id;
    string name;
    string unit;
    float value;
    int employeeId;
    int objectivesId;
};


public function main() returns error?{
    io:print("Welcome to the FCI Performance Management System. \n"+
    "Insert a number based on the operation you would like to perform \n"+
    "1. Create Department Objective \n"+
    "2. Delete Department Objective \n"+
    "3. View Employees Total Scores\n"+
    "4. Assign Employee to a supervisor \n");
    string choice = io:readln("Insert a number:");

    if(choice=="1"){
      string insid = io:readln("Enter Objective ID");
      string insname = io:readln("Enter Objective Name");
      string insdepartment = io:readln("Enter Objective Department");
     createObjective(insid,insname,insdepartment);
    }
    if(choice=="2"){
     string insid = io:readln("Enter Objective ID");
     deleteObjective(insid);
    }
    if(choice=="3"){
       viewEmployee();
       
        
    }
    if(choice=="4"){
       string insempID = io:readln("Enter Employee ID\n");
       string inssupervisor = io:readln("Enter Supervisor");
       assignEmployee(insempID,inssupervisor);
    }
    else{
        io:print("Invalid number!");
}
}

function handleResponse(http:Response response) {
    if (response.statusCode == http:STATUS_OK) {
        var payload = response.getJsonPayload();
        if (payload is json) {
            io:println(payload);
        } else {
            io:println("Invalid response format");
        }
    } else {
        io:println("Error: Received unexpected response: ", response);
    }
}
function assignEmployee(string insempID, string inssupervisor)   {
      graphql:Client cli = check new("http://localhost:9090");
}

function viewEmployee()returns Employee|error  {
       graphql:Client cli = check new("http://localhost:9090");
}

function deleteObjective(string insid) {
    graphql:Client cli = check new("http://localhost:9090");
}

function createObjective(string a,string b,string c)  {
    graphql:Client cli = check new("http://localhost:9090");
}


function createKPI(string a,string b,string c)  {
    graphql:Client cli = check new("http://localhost:9090");
}


function viewScore(string a,string b,string c)  {
    graphql:Client cli = check new("http://localhost:9090");
}


function gradeSupervisor(string a,string b,string c)  {
    graphql:Client cli = check new("http://localhost:9090");
}