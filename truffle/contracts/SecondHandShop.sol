pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;

contract SecondHandShop {
    
    event BuyProduct(address indexed buyer, uint256 productId); // Event
    event CreateProduct(address indexed creater, uint256 productId); // Event
    event ErrorProductNotAvailable(address indexed buyer, uint256 productId); // Event
    event ErrorNotEnoughMoney(address indexed buyer, uint256 productId); // Event
    
    struct Product {
        uint256 id;
        string name;
        uint256 price;
        ProductStatus productStatus;
        address seller;
        address buyer;
        string imgPath;
        string rating;
        string information;
    }
    
    enum ProductStatus {Available,Purchased,Unavailable}
    // presonal product have been purchase
    mapping (address => uint256[]) private userProducts;
    // product storage
    mapping(uint256 => Product) products;
    uint256[] productList;
    
    constructor() public {
        productCounter = 0;
        createProduct("Watch",5.0,"watch.png",'iWatch 3');
        createProduct("Camera",4.0,"camera.jpg",'Fujinon Camera');
    }

    uint256 productCounter;
    function getProductId() private returns(uint) { return ++productCounter; }
    
    function isEmpty(string memory _str) pure private returns(bool _isEmpty){
        bytes memory tempEmptyStringTest = bytes(_str); // Uses memory
        if (tempEmptyStringTest.length == 0) {
            return true;
        } else {
            return false;
        }
    }
    
    function createProduct (string memory _name,uint256 _price,string memory _imgPath,string memory _information) public payable returns(bool success) {
        require(!isEmpty(_name),"Name must not empty.");
        uint256 productId = getProductId();
        Product memory product = products[productId];
        product.id = productId;
        product.name = _name;
        product.information = _information;
        product.price = _price;
        product.productStatus = SecondHandShop.ProductStatus.Available;
        product.seller = msg.sender;
        product.imgPath = _imgPath;
        products[productId] = product;
        
        productList.push(productId);
        emit CreateProduct(msg.sender, product.id);
        return true;
    }
    
    function getAllProductList() public view returns(uint256[] memory _products){
        return productList;
    }
    
    function getProductById(uint256 _id) private view returns(Product memory product){
        return products[_id];
    }
    
    function getProductStrById(uint256 _id) public view returns(uint256 id,string memory name, uint256 price,string memory status,address seller,address buyer,string memory imgPath,string memory rating,string memory information ){
        Product memory c = products[_id];
        string memory statusTemp;
        if(c.productStatus == ProductStatus.Available){
            statusTemp = "Available";
        }else if(c.productStatus == ProductStatus.Purchased){
            statusTemp = "Purchased";
        }else if(c.productStatus == ProductStatus.Purchased){
            statusTemp = "Unavailable";
        }else{
            statusTemp = "unnamed";
        }

        return (c.id,c.name,c.price,statusTemp,c.seller,c.buyer,c.imgPath,c.rating,c.information);
    }
    
    function getMyProduct() public view returns(uint256[] memory product){
        return userProducts[msg.sender];
    }
    
    function buyProduct (uint256 _productId, string memory _rating) public payable returns(bool success){
        Product memory c = getProductById(_productId);
        if(c.productStatus != ProductStatus.Available){
            emit ErrorProductNotAvailable(msg.sender,_productId);
            msg.sender.transfer(msg.value);
            return false;
        }
        if(msg.value <= c.price){
            emit ErrorNotEnoughMoney(msg.sender,_productId);
            msg.sender.transfer(msg.value);
            return false;
        }
        
        c.buyer = msg.sender;
        c.rating = _rating;
        c.productStatus = SecondHandShop.ProductStatus.Purchased;
        products[_productId] = c;
        userProducts[msg.sender].push(c.id);
        emit BuyProduct(msg.sender,c.id);
        return true;
    }
}
