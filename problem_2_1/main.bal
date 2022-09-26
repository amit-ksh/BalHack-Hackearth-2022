import ballerinax/java.jdbc;
import ballerina/sql;
import ballerina/io;

function addEmployee(string dbFilePath, string name, string city, string department, int age) returns int {
    do {
	    jdbc:Client dbClient = check new (string`jdbc:h2:file:${dbFilePath}`, "root", "root");

        sql:ParameterizedQuery addEmployeeQuery = `INSERT INTO Employee(name, city, department, age)
                                VALUES (${name}, ${city}, ${department}, ${age})`;

        sql:ExecutionResult result = check dbClient->execute(addEmployeeQuery);

        int generatedKey = <int> result.lastInsertId;

        check dbClient.close();

        return generatedKey;
    } on fail var e {
    	io:println(e.message());
        return -1;
    }
}
