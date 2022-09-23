function allocateCubicles(int[] requests) returns int[] {
    map<int> requestsMap = {};

    foreach int val in requests.sort() {
        requestsMap[string`${val}`] = val;
    }
    
    return requestsMap.toArray();
}
