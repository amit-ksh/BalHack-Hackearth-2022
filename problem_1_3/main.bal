import ballerina/io;

type FillUpEntry record {|
    readonly int employeeId;
    int odometerReading;
    decimal gallons;
    decimal gasPrice;
|};

type EmployeeFillUpSummary record {|
    readonly int employeeId;
    int gasFillUpCount = 0;
    decimal totalFuelCost = 0d;
    decimal totalGallons = 0d;
    int startDistance = 0;
    int endDistance = 0;
|};

function processFuelRecords(string inputFilePath, string outputFilePath) returns error? {
    json jsonPayload = check io:fileReadJson(inputFilePath);
    table<FillUpEntry> data = check jsonPayload.fromJsonWithType();
    map<EmployeeFillUpSummary> employees = {};

    data.forEach(function(FillUpEntry e) {
        string id = string`${e.employeeId}`;

        if employees[id] == () {
            employees[id] = {
                employeeId: e.employeeId,
                startDistance: e.odometerReading
            };
        }
        
        employees[id].gasFillUpCount = employees.get(id).gasFillUpCount + 1;
        employees[id].totalFuelCost = employees.get(id).totalFuelCost + (e.gallons * e.gasPrice);
        employees[id].totalGallons = employees.get(id).totalGallons + e.gallons;
        employees[id].endDistance = e.odometerReading;
    });

    json outJson = from 
                    var {employeeId, gasFillUpCount, totalFuelCost, totalGallons, endDistance, startDistance} 
                    in employees
                    select 
                        {employeeId, gasFillUpCount, totalFuelCost, totalGallons, totalMilesAccrued: endDistance - startDistance};


    check io:fileWriteJson(outputFilePath, outJson);
}
