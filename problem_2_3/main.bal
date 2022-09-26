import ballerinax/java.jdbc;
import ballerina/io;

type HighPayment record {
    string name;
    string department;
    decimal amount;
    string reason;
};

function getHighPaymentDetails(string dbFilePath, decimal  amount) returns HighPayment[]|error {
    HighPayment[] res = [];
     do {
	    jdbc:Client jdbcClient = check new (string`jdbc:h2:file:${dbFilePath}`, "root", "root");

        stream<HighPayment, error?> resultStream =
                jdbcClient->query(`SELECT e.name, e.department, p.amount, p.reason 
                                    FROM Employee as e NATURAL JOIN Payment as p 
                                    WHERE p.amount >= ${amount} 
                                    ORDER BY p.payment_id;`
                                );

        // Iterates the result stream.
        check from var row in resultStream
            do {
                io:println(row);
                res.push(row);
            };

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
