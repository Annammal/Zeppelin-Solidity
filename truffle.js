module.exports = {
  networks: {
    development: {
      host: "10.0.0.18",
      port: 8545,
      gas: 6712388,
      gasPrice: 65000000000,
      network_id: "*" // Match any network id
    }
  }
};
