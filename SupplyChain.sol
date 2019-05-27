pragma solidity ^0.5.0;


contract supplyChain
{

    enum Status{Created,Delivering,Delivered,Accepted,Declined}

    event OrderCreated(uint index,address indexed deliveryCompany,address indexed customer);
    event OrderDelivering(uint index,address indexed deliveryCompany,address indexed customer);
    event OrderDelivered(uint index,address indexed deliveryCompany,address indexed customer);

    Order[] orders;

    mapping (address=>uint[]) public selfOrders;

    struct Order
    {
        string title;
        string description;
        address supplier;
        address deliveryCompany;
        address customer;
        Status status;
    }

    function createOrder(string memory _title,string memory _description,address _deliveryCompany,address _customer)
    public
    {
        Order memory order = Order({
            title : _title,
            description : _description,
            supplier : msg.sender,
            deliveryCompany : _deliveryCompany,
            customer : _customer,
            status : Status.Created
        });
        uint index = orders.length;
        emit OrderCreated(index,_deliveryCompany,_customer);
        orders.push(order);
        selfOrders[msg.sender].push(index);
        selfOrders[_deliveryCompany].push(index);
        selfOrders[_customer].push(index);
    }
    
    function getSelfOrderLength(address _address) public view returns(uint)
    {
        return selfOrders[_address].length;
    }

    modifier OnlyCustomer(uint _index)
    {
        require(orders[_index].customer == msg.sender);
        _;
    }

    modifier onlyOrderDeliveryCompany(uint _index)
    {
        require(orders[_index].deliveryCompany==msg.sender);
        _;
    }

    modifier orderCreated(uint _index)
    {
        require(orders[_index].status==Status.Created);
        _;
    }

    modifier orderDelivering(uint _index)
    {
        require(orders[_index].status==Status.Delivering);
        _;
    }

    modifier orderDelivered(uint _index)
    {
        require(orders[_index].status==Status.Delivered);
        _;
    }
    
    function getOrderLength() public view returns (uint)
    {
        return orders.length;
    }

    function getOrder(uint _index) public view returns(string memory,string memory,address,address,address,Status)
    {
        Order memory order = orders[_index];
        return (order.title,order.description,order.supplier,order.deliveryCompany,order.customer,order.status);
    }

    function startDeliveringOrder(uint _index) public onlyOrderDeliveryCompany(_index) orderCreated(_index)
    {
        Order storage order = orders[_index];
        emit OrderDelivering(_index,order.supplier,order.customer);
        order.status = Status.Delivering;
    }

    function stopDelivering(uint _index) public onlyOrderDeliveryCompany(_index) orderDelivering(_index)
    {
        Order storage order = orders[_index];
        emit OrderDelivered(_index,order.supplier,order.customer);
        order.status = Status.Delivered;
    }

    function acceptOrder(uint _index) public OnlyCustomer(_index) orderDelivered(_index)
    {
        Order storage order = orders[_index];
        order.status = Status.Accepted;
    }

    function declineOrder(uint _index) public OnlyCustomer(_index) orderDelivered(_index)
    {
        Order storage order = orders[_index];
        order.status = Status.Declined;
    }

}