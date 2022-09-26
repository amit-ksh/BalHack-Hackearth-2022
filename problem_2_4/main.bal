import ballerinax/java.jdbc;
import ballerina/io;

type HighPayment record {
    readonly int payment_id;
    decimal amount;
    string employee_name;
};

function getHighPaymentEmployees(string dbFilePath, decimal amount) returns string[]|error {
    string[] res = [];
    table<HighPayment> key(payment_id) eTable = table [];
     do {
	    jdbc:Client jdbcClient = check new (string`jdbc:h2:file:${dbFilePath}`, "root", "root");

        stream<HighPayment, error?> resultStream =
                jdbcClient->query(`SELECT p.payment_id, p.amount, e.name as employee_name
                                    FROM Employee as e NATURAL JOIN Payment as p
                                    WHERE p.amount > ${amount}
                                    ORDER BY e.name;`
                                );

        // Iterates the result stream.
        check from var row in resultStream
            do {
                eTable.add(row);
            };

        io:println(eTable);
        foreach HighPayment e in eTable {
            res.push(e.employee_name);
        }

        // Closes the stream to release the resources.
        check resultStream.close();

        // Closes the JDBC client.
        check jdbcClient.close();

        return res;
    } on fail var e {
    	io:println(e.message());
        return res;
    }
}
