import ballerina/graphql;
import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;


type KPI record{
    int id;
    string name;
    string unit;
    float value;
    int employeeId;
    int objectivesId;
};

type Employee record{|
    string employeeID;
    string firstname;
    string lastname;
    string jobTitle;
    int total_score;
    string supervisorName;
    |};


    type Objective record{|
    int ID;
    string objectiveName;
    string department;
    |};
    
    configurable string USER = ?;
    configurable string PASSWORD = ?;
    configurable string HOST = ?;
    configurable int PORT = ?;
    configurable string DATABASE = ?;

final mysql:Client dbClient = check new(host=HOST, user=USER, password=PASSWORD, port=PORT, database="fci_db");

service /graphql on new graphql:Listener(9090){

    //HOD Services
 remote function  createObjective(Objective id,Objective objectivename,Objective department) returns string|error{
   sql:ExecutionResult result = check dbClient->execute(`
        INSERT INTO objectives (ID, Department, Name )
        VALUES ( ${id}, ${objectivename}, ${department})`);
    int|string? lastInsertId = result.lastInsertId;
    if lastInsertId is int {
        return ("Successfully created objective!");
    } else {
        return error("Failed to create objective");
    }
 }

  remote function  deleteObjective(Objective id) returns string|error{
    sql:ExecutionResult result = check dbClient->execute(`
        DELETE FROM objectives WHERE ID = ${id}`);
    int? affectedRowCount = result.affectedRowCount;
    if affectedRowCount is int {
        return ("Successfully deleted objective!");

    } else {
        return error("Failed to delete objective.");
    }
  }
   resource function get viewEmployee() returns Employee[]|error{
      Employee[] employees = [];
    stream<Employee, error?> resultStream = dbClient->query(
        `SELECT * FROM employee`
    );
    check from Employee employee in resultStream
        do {
            employees.push(employee);
        };
    check resultStream.close();
    return employees;
      }

    remote function assignEmployee(Employee employeeID,Employee supervisorName) returns string|error{
        sql:ExecutionResult result = check dbClient->execute(`
        UPDATE employee SET
            Supervisor = ${supervisorName}
        WHERE employee_id = ${employeeID}`);
    int|string? lastInsertId = result.lastInsertId;
    if lastInsertId is int{
        return("Successfully assigned supervisor!");
    } else {
        return error("Failed to assign supervisor");
    }
    }
    //Supervisor services



    //Employee services


sql:ConnectionConfiguration sqlConfiguration = {
    connection: {
        host: "localhost",
        port:3306,
        auth: {
            username: "",
            password: ""
        },
        options: {
            sslEnabled: false,
            serverSelectionTimeout:5000
        }
    },
    databaseName: "fci_db"
};

sql:Client db = check new (sqlConfiguration);

configurable string KpiCollection = "KPI";
configurable string employeeCollection= "employee";
configurable string databaseName = "fci_db";


    @graphql:ServiceConfig {
    graphiql: {
        enabled: true,
    // Path is optional, if not provided, it will be dafulted to `/graphiql`.
    path: " "
    }
}
service / on new graphql:Listener(9000){

    remote function createKPI(KPI newKPI) returns error|string{
    map<json>  doc= <map<json>> newKPI.toJson();
        _= check db->insert(doc, KpiCollection, "");
        return string `${newKPI.name} added successfully`;
    } 

    
    remote function viewScores(string employeeID) returns KPI[]|error {
    map<json> query = { "employeeID": employeeID };
    map<json>[]|error results = db->find(doc, KpiCollection, filter=(value));

    if (results is map<json>[]) {
        KPI[] kpis = [];
        foreach map<json> doc in results {
            KPI kpi = check jsonutils:toRecord(doc, KPI);
            kpis.push(kpi);
        }
        return kpis;
    } 
    else {
        return error("Error occurred while retrieving KPI documents.");
    }

}

remote function gradeSupervisor(string employeeID, string supervisorID, float grade) returns string|error {
        map<json> query = { "employeeID": employeeID, "supervisorID": supervisorID };
        map<json> updateJson = { "$set": { "grade": grade } };
        
        // Update the grade in the collection
        sql:newResult|error Newresult = check db->update("EmployeeSupervisorRelation", updateJson, query);
     
        if (Newresult is error) {
            return error("Failed to grade the supervisor");
        } 
        else if (Newresult.modifiedCount > 0) {
            return "Grading Complete";
        } 
        else {
            return "Not Found";
        }
    }

}
