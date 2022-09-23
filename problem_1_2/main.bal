import ballerina/io;

type EmployeeInput record {|
    int id;
    int odometer_reading;
    decimal gallons;
    decimal gas_prices;
|};

type EmployeeOutput record {|
    int id;
    int gas_fill_up_count = 0;
    decimal total_fuel_cost = 0d;
    decimal total_gallons = 0d;
    int start_distance = 0;
    int end_distance = 0;
|};

function processFuelRecords(string inputFilePath, string outputFilePath) returns error? {
    EmployeeInput[] inStream = check io:fileReadCsv(inputFilePath);
    map<EmployeeOutput> employees = {};

    inStream.forEach(function(EmployeeInput e) {
        string id = string`${e.id}`;

        if employees[id] == () {
            employees[id] = {
                id: e.id,
                start_distance: e.odometer_reading
            };
        }
        
        employees[id].gas_fill_up_count = employees.get(id).gas_fill_up_count + 1;
        employees[id].total_fuel_cost = employees.get(id).total_fuel_cost + (e.gallons * e.gas_prices);
        employees[id].total_gallons = employees.get(id).total_gallons + e.gallons;
        employees[id].end_distance = e.odometer_reading;
    });

    string[][] outStream = [];
    employees.forEach(function (EmployeeOutput e) {
        outStream.push([
            string`${e.id}`,
            string`${e.gas_fill_up_count}`,
            string`${e.total_fuel_cost}`,
            string`${e.total_gallons}`,
            string`${e.end_distance - e.start_distance}`
        ]);
    });
    
    io:println(outStream);
    check io:fileWriteCsv(outputFilePath, outStream);
}
