import ims/billionairehub;

# Client ID and Client Secret to connect to the billionaire API
configurable string clientId = "V5bhO97JalSWqUMcItOuKzhf1pca";
configurable string clientSecret = "eeXDwSQOfX_WZ2PMaD2rvOjyCTga";

public function getTopXBillionaires(string[] countries, int x) returns string[]|error {
    // Create the client connector
    billionairehub:Client cl = check new ({auth: {clientId, clientSecret}});
    
    billionairehub:Billionaire[] billionaires = [];
    foreach string country in countries {
        billionairehub:Billionaire[]|error result = cl->getBillionaires(country);
        if result is billionairehub:Billionaire[] {
            foreach var billionaire in result {
                billionaires.push(billionaire);
            }
        }
    }

    string[] topXBillionaires = from billionairehub:Billionaire b in billionaires
                            order by b.netWorth descending
                            limit x
                            select b.name;

    return topXBillionaires;
}
