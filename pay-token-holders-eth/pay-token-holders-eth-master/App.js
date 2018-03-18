var ethers = require('ethers');
var Units = require('ethereumjs-units');
const ethPrice = require('eth-price');
var request = require('request');
var JSSoup = require('jssoup').default;
var warningEmail = "importantemail@importantemail.com"; // not implimented ask me how to.
///////////////////////////////////////

const tokenAdress = "0x02e12fedaea2a3f2213d049edd33eaf46cee37dd";//https://rinkeby.etherscan.io/token/0x02e12fedaea2a3f2213d049edd33eaf46cee37dd#balances
var mnemonic = "abandon parade book share load winter flee six tribe vintage poet swarm amazing bus tired";//https://iancoleman.io/bip39/
var network = ethers.providers.networks['homestead'];//'homestead', 'ropsten', 'rinkeby', 'kovan'
var wallet = ethers.Wallet.fromMnemonic(mnemonic);
wallet.provider = ethers.providers.getDefaultProvider(network);

//error logging / reporting
process.on('uncaughtException', function(err) {
    if(err.message === 'invalid value')
         log("[Send Error]: Not enough in balance to send...");
    else
         log("[Error]" + err);
    process.exit(1);
});

process.on('unhandledRejection', function(reason, p) {
    console.log('Unhandled Rejection at: Promise', p, 'reason:', reason);
    // application specific logging, throwing an error, or other logic here
  });

//log
function log(message){
    console.log(message);
    //send to email
    //store to file
    //write to DB
    //etc
}

//Send some ETH 
//send("0x0Fe18f369c7F34208922cAEBbd5d21E131E44692","0.0001", function(r){log(r);});
//
function send(address, amount){//
    // this convenience function to convert ether to wei.
    var amount = ethers.utils.parseEther(address);
    var sendPromise = wallet.send(address, amount);

    sendPromise.then(function(transactionHash) {
        log(transactionHash);
    });

    // These will query the network for appropriate values
    var options = {
        //gasLimit: 21000,
        //gasPrice: utils.bigNumberify("20000000000")
    };

    var promiseSend = wallet.send(address, amount, options);

    promiseSend.then(function(transaction) {
        log(transaction);
    });
}

//wallet infomation
//walletInfo(mnemonic,function(d){log(d);});
//
function walletInfo(mnemonic, callback){

    var balancePromise = wallet.getBalance();  
    balancePromise.then(function(balance) {
        var bal = Units.convert(balance.toNumber(), 'wei', 'eth')
        //or var amount = ethers.utils.parseEther('1.0');
        ethPrice('usd,btc').then(function(price){
            var oneEthUSD = parseFloat(price[0].split(":")[1].replace(" ","")).toFixed(1);
            var oneEthBTC = parseFloat(price[1].split(":")[1].replace(" ","")).toFixed(1);
            return(callback({Address:wallet.address,
                            USDvalue:oneEthUSD * bal,
                            BTCvalue:oneEthBTC * bal,
                            ETHvalue:bal}))
        });
        
    });
    
}

//Returns all address / amount for token holders
//getPayoutAddress(function(result){log(result);});
//getPayoutAddress(function(result){
//    log(result);
//});
//
function getPayoutAddress(callback){
    request("https://rinkeby.etherscan.io/token/generic-tokenholders2?a=" + tokenAdress + "&s=0&p=", function (error, response, body) {
        if(body != null){        
            //console.log(body);
            var soup = new JSSoup(body);
            var test = soup.findAll('table')
            test[0].contents.forEach(function(r){
                var rank = r.contents[0].nextElement._text;
                var address = r.contents[1].nextElement.nextElement.nextElement._text;
                var amount = r.contents[2].nextElement.nextElement.previousElement._text;
                return(callback({rank:rank,address:address,amount:amount}));
            });
        }
    });
}

//The main logic

main(function(bool){
    if(bool){
        log("Event done");
    }else
        log("Something messed up, check logs...");
})

//
function main(callback){
    walletInfo(mnemonic,function(d){
        if(d.ETHvalue == 0 ){ //
            log(d);
            var totalRequired = 1;
            getPayoutAddress(function(result){
                if(result.amount != "Quantity\n"){
                    //totalRequired = Number(result.amount) + totalRequired;
                    //console.log(totalRequired);
                    send(result.address,result.amount, 
                        function(r){
                            log(r);
                        });

                }
                
                //console.log(totalRequired);
                //return(callback(true));
            });
        }else{
            log("You dont have enough in your balance to proform this...");
            return(callback(false));
        }
    });
}