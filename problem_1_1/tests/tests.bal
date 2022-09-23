import ballerina/io;
import ballerina/test;

@test:Config {
    dataProvider: data,
    groups: ["sample"]
}
function allocateCubiclesTest(int[] input, int[] expected) returns error? {
    io:println("hello!");
    test:assertTrue(allocateCubicles(input) == expected);
}
