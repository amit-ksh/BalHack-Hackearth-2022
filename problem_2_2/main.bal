import ballerinax/java.jdbc;
import ballerina/sql;
import ballerina/io;

type Payment record {|
    int employee_id;
    int amount;
    string reason;
    string date;
|};

function addPayments(string dbFilePath, string paymentFilePath) returns error|int[] {
    json jsonPayload = check io:fileReadJson(paymentFilePath);
    table<Payment> payments = check jsonPayload.fromJsonWithType();
    jdbc:Client dbClient = check new (string`jdbc:h2:file:${dbFilePath}`, "root", "root");

    sql:ParameterizedQuery[] insertQueries =
        from var data in payments
        select `INSERT INTO Payment 
                (employee_id, amount, reason, date)
                VALUES 
                (${data.employee_id}, ${data.amount}, ${data.reason}, ${data.date})`;

    sql:ExecutionResult[] result = [];
    if insertQueries.length() != 0 {
        result = check dbClient->batchExecute(insertQueries);
    }

    int[] generatedIds = [];
    foreach var summary in result {
        generatedIds.push(<int>summary.lastInsertId);
    }
    check dbClient.close();

    return generatedIds;
}
