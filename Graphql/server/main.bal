import ballerina/graphql;
import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;




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
}
