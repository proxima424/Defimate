
TODO::
1) Present MultiCall standards consist of sending JSON-RPC request for read-only functions.
   Try them for maybe sending some ether to different contracts all at once.
   Try them for changing multiple state variables of different contracts all at once.


SingleCall vs MultiCall :

SingleCall is sending just one JSON-RPC request to fetch the required data from the blockchain.
MultiCall consists of batching together multiple required data SingleCalls into one JSON-RPC request.

MultiCall is made possible through 