const SupplyChain = artifacts.require('SupplyChain');

contract('SupplyChain',async(accounts) =>{
    it('1. Create Order',async()=>{
        const instance = await SupplyChain.deployed();

        const supplier = accounts[0];
        const deliveryCompany = accounts[1];
        const customer = accounts[2];

        const title = 'books';
        const description = 'Dictionary';

        await instance.createOrder(title,description,deliveryCompany,customer);

        const order = await instance.getOrder(0);

        console.log(order);

        assert.equal(title,order[0],'Title is not correct ');
        assert.equal(description,order[1],'Title is not correct ');
        assert.equal(supplier,order[2],'Title is not correct ');
        assert.equal(deliveryCompany,order[3],'Title is not correct ');
        assert.equal(customer,order[4],'Title is not correct ');
        assert.equal(0,order[5],'Status is not correct');
    });


    it('2. Start Delivering Order',async()=>{
        const instance = await SupplyChain.deployed();

        const deliveryCompany = accounts[1];
        await instance.startDeliveringOrder( 0 , { from : deliveryCompany});
        const order = await instance.getOrder(0);

        assert.equal(1,order[5],'Status is not correct');
    });


    it('3. Stop Delivering Order',async()=>{
        const instance = await SupplyChain.deployed();

        await instance.stopDelivering( 0 , {from : accounts[1]});

        const order = await instance.getOrder(0);

        assert(2,order[5],'Status is not correct');
    });

    it('4. Accept Order',async()=>{
        const instance = await SupplyChain.deployed();

        await instance. acceptOrder( 0 , {from : accounts[2]});

        const order = await instance.getOrder(0);

        assert(3,order[5],'Status is not correct');
    });


    it('Customer cant decline accepted Order',async()=>{
        const instance = await SupplyChain.deployed();

        try{
            await instance.declineOrder(0);
        }catch(err){
            err.message,"Returned error: VM Exception while processing transaction: revert"
        };
    });
    
});