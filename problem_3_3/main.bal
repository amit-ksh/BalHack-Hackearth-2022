import ballerina/http;

function findTheGiftSimple(string userID, string 'from, string to) returns Gift|error {
    // Write your answer here for Part A.
    // An `http:Client` is initialized for you. Please note that it does not include required security configurations.
    // A `Gift` record is initialized to make the given function compilable.
    final http:Client fifitEp = check new(
            url="https://localhost:9091/activities",
            auth = {
                tokenUrl: tokenEndpoint,
                clientId: clientId,
                clientSecret: clientSecret,
                clientConfig: {
                    secureSocket: {
                        cert: "./resources/public.crt"
                    }
                }
            },
            secureSocket = {
                cert: "./resources/public.crt"
            }
        );
    Activities activities = check fifitEp->get(string`/steps/user/${userID}/from/${'from}/to/${to}`);

    int totalScore = 0;
    foreach var act in activities.activities\-steps {
        totalScore += act.value;
    }

    string 'type = "";
    if totalScore >= PLATINUM_BAR {
        'type = "PLATINUM";
    } else if totalScore >= GOLD_BAR {
        'type = "GOLD";
    } else if totalScore >= SILVER_BAR {
        'type = "SILVER";
    } else {
        return error("No rewards!");
    }

    Gift gift = {
        eligible: true,
        score: totalScore,
        'from: 'from,
        to: to,
        details: {
            'type: <Types>'type, 
            message: string`Congratulations! You have won the ${'type} gift!`
        }
    };

    return gift;
}

function findTheGiftComplex(string userID, string 'from, string to) returns Gift|error {
    // Write your answer here for Part B.
    // Two `http:Client`s are initialized for you. Please note that they do not include required security configurations.
    // A `Gift` record is initialized to make the given function compilable.
    final http:Client fifitEp = check new(
            url="https://localhost:9091/activities",
            auth = {
                tokenUrl: tokenEndpoint,
                clientId: clientId,
                clientSecret: clientSecret,
                clientConfig: {
                    secureSocket: {
                        cert: "./resources/public.crt"
                    }
                }
            },
            secureSocket = {
                cert: "./resources/public.crt"
            }
        );
    final http:Client insureEveryoneEp = check new("https://localhost:9092/insurance",
            auth = {
                username: username,
                password: password
            },
            secureSocket = {
                cert: "./resources/public.crt"
            }
        );

    // {"user":{"name":"Joe Miden","display-name":"Joe","age":70,
    // "email":"joe.miden@zmail.com","state":"California","city":"SF",
    // "address":"450 R StLincoln, California(CA), 95648"}}
    map<User> result = check insureEveryoneEp->get(string`/user/${userID}`);
    Activities activities = check fifitEp->get(string`/steps/user/${userID}/from/${'from}/to/${to}`);

    int totalScore = 0;
    foreach var act in activities.activities\-steps {
        totalScore += act.value;
    }
    totalScore = totalScore / ((100-result.get("user").age)/10);

    string 'type = "";
    if totalScore >= PLATINUM_BAR {
        'type = "PLATINUM";
    } else if totalScore >= GOLD_BAR {
        'type = "GOLD";
    } else if totalScore >= SILVER_BAR {
        'type = "SILVER";
    } else {
        return error("No rewards!");
    }

    Gift gift = {
        eligible: true,
        score: totalScore,
        'from: 'from,
        to: to,
        details: {
            'type: <Types>'type, 
            message: string`Congratulations! You have won the ${'type} gift!`
        }
    };

    return gift;
}

type User record {|
    anydata name;
    anydata display\-name;
    int age;
    anydata email;
    anydata state;
    anydata city;
    anydata address;
|};

type Activities record {
    record {|
        string date;
        int value;
    |}[] activities\-steps;
};

type Gift record {
    boolean eligible;
    int score;
    # format yyyy-mm-dd
    string 'from;
    # format yyyy-mm-dd
    string to;
    record {|
        Types 'type;
        # message string: Congratulations! You have won the ${type} gift!;
        string message;
    |} details?;
};

enum Types {
    SILVER,
    GOLD,
    PLATINUM
}

const int SILVER_BAR = 5000;
const int GOLD_BAR = 10000;
const int PLATINUM_BAR = 20000;
