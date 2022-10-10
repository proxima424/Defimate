- This is a code which solves the problem of not having a random number in blockchain.

- What is a random number generator(RNG)?
It is a function which is used to generate rdandom number. 
It is random if and only if when run havong same parameters as input, it gives output that are not predictable.

- Let us understand why we can not have a truely random function.
Let us suppose that we have an RNG, and we add that function in our smart contract.
Calling that function will act as a transaction in ethereum blockchain. For that transaction to complete, every node has to come give the same output for that function when they compute that function which will never happen as the function will give a different number to every node computing that transaction.

- And suppose if we make a function that gives same output to every node, then it will not be random and hence predictable.

- One way to solve this problem is to use an oracle (mostly Chainlink)

- So we have come up to a solution that solves this problem. We created a function which gives a number that is unpredictable and serves as a random number and hence eliminates the use of an oracle.


- This function uses the fact that the hash of any future block is not known until that block is mined. You can refer to the consesys protocol of aProof of Stake to gain more clarity that why the hash of upcoming block is not known and cant be predicted.

- So it waits for the new block to arrive and uses its hash to serve in as a random number.
