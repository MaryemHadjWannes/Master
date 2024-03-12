// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental SMTChecker;


// inherited contracts
import './Ownable.sol';
import './FarmerRole.sol';
import './MillManagerRole.sol';
import './ConsumerRole.sol';

enum ProdType { Olive, Oil } // Olive:0 , Oil:1
enum CreationCause { Extracting, Buying, Storing, Packaging } // Extracting: 0, Buying: 1, Storing: 2, packaging: 3
enum ActorCategory { Farmer, Mill, Consumer } // Farmer: 0, Mill: 1, Consumer: 2



// This contract manages product contracts and their interactions.
contract ProductContracts is Ownable,FarmerRole,MillManagerRole,ConsumerRole {

    enum ProductState
   {
    ProduceByFarmer,         // 0
    ForSaleByFarmer,         // 1
    PurchasedByMillManager,  // 2
    ShippedByFarmer,         // 3
    ReceivedByMillManager,   // 4
    ExtractedByMillManager,  // 5
    StoredByMillManager,     // 6
    PackageByMillManager,    // 7
    ForSaleByMillManager,    // 8
    PurchasedByConsumer      // 9
   }

   ProductState constant defaultState = ProductState.ProduceByFarmer;

    // Struct to store product details.
    struct prods {
        address product;
        address motherProduct;
        ProductState productState;
    }

    // Mapping to store product contracts.
    mapping(address => prods) public productsTab;

    // Instance of ProdFactory contract.
    ProdFactory prodFactory;

    // Constructor initializes the ProdFactory contract.
    constructor(){
        prodFactory= new ProdFactory();
    }


    // Events 

    event ProduceByFarmer(address product);         //1
    event ForSaleByFarmer(address product);         //2
    event PurchasedByMillManager(address product);  //3
    event ShippedByFarmer(address product);         //4
    event ReceivedByMillManager(address product);   //5
    event ExtractedByMillManager(address product);  //6
    event StoredByMillManager(address product);     //7
    event PackagedByMillManager(address product);   //8
    event ForSaleByMillManager(address product);    //9
    event PurchasedByConsumer(address product);     //10
 
    // Modifiers

    //Item State Modifiers
    modifier producedByFarmer(address _product) {
        require(productsTab[_product].productState == ProductState.ProduceByFarmer);
        _;
    }

    modifier forSaleByFarmer(address _product) {
        require(productsTab[_product].productState == ProductState.ForSaleByFarmer);
        _;
    }

    modifier purchasedByMillManager(address _product) {
        require(productsTab[_product].productState == ProductState.PurchasedByMillManager,"purchasedbyMillManager");
        _;
    }

    modifier shippedByFarmer(address _product) {
        require(productsTab[_product].productState == ProductState.ShippedByFarmer);
        _;
    }

    modifier receivedByMillManager(address _product) {
        require(productsTab[_product].productState == ProductState.ReceivedByMillManager);
        _;
    }

    modifier extractedByMillManager(address _product) {
        require(productsTab[_product].productState == ProductState.ExtractedByMillManager);
        _;
    }

    modifier packagedByMillManager(address _product) {
        require(productsTab[_product].productState == ProductState.PackageByMillManager);
        _;
    }

    modifier forSaleByMillManager(address _product) {
        require(productsTab[_product].productState == ProductState.ForSaleByMillManager);
        _;
    }

    modifier purchasedByConsumer(address _product) {
        require(productsTab[_product].productState == ProductState.PurchasedByConsumer);
        _;
    }



    // allows you to convert an address into a payable address
    function _make_payable(address x) internal pure returns (address payable) {
        return payable(address(uint160(x)));
    }


    function add2ProductsTab(address newProduct, address motherProduct) public {
        productsTab[newProduct].product = newProduct;
        productsTab[newProduct].motherProduct = motherProduct;
    }

    // Function to add a new product.
    function addOlive(address _initiatorUser,address _responderUser ,ProdType _productType, CreationCause _creatCause, 
    ActorCategory _ownerCateg, uint256 _initialQuantity, uint256 _remainingQuantity, 
    ProdFactory _prodFactory ) public 
    {
        // Create a new product using the ProdFactory contract.
        Product newProduct=  prodFactory.create( _initiatorUser, _responderUser, _productType, _creatCause, 
     _ownerCateg, _initialQuantity, _remainingQuantity, address(0),  _prodFactory);

        // Set the mother product address.
        newProduct.setMotherProd(address(newProduct));

        // Update product details in the mapping.
        add2ProductsTab(address(newProduct), address(newProduct));

        emit ProduceByFarmer(address(newProduct));

    }

    
    // Function to Extract Oil product from Olive product.
    function extractingProduct(address _initiatorUser,address _responderUser ,ProdFactory _prodFactory, 
    Product _motherProduct, uint256 _extractedquantity, ActorCategory _actor, uint256 _extractionPrice) public 
    {

        Product newProduct = _motherProduct.extract(_initiatorUser, _responderUser, _prodFactory,
         _motherProduct, _extractedquantity, _actor);

        // Update product details in the mapping.
        add2ProductsTab(address(newProduct), address(newProduct));

        emit ExtractedByMillManager(address(newProduct));

    }

    
    // Function to sell product.
    function sellingProduct(ProdFactory _prodFactory, Product _motherProduct, uint256 _soldQuantity,
    ActorCategory _actor, uint256 _sellingPrice) public 
    {
        // make Seller address payable
        address payable ownerAddressPayable = _make_payable(_motherProduct.initiatorUser()); 
        
        // transfer funds from Buyer to ProductOwner
        ownerAddressPayable.transfer(_sellingPrice);  // Warning : BMC: Insufficient funds happens here.

        Product newProduct = _motherProduct.sell(_motherProduct.initiatorUser(), msg.sender, _prodFactory, _motherProduct, _soldQuantity,
      _actor);

        // Update product details in the mapping.
        add2ProductsTab(address(newProduct), address(newProduct));

    }


    // Function to store product.
    function storingProduct(address _initiatorUser,address _responderUser, ProdFactory _prodFactory, Product _motherProduct, uint256 _storedQuantity,
    ActorCategory _actor, uint256 _storingPrice) public 
    {
        Product newProduct = _motherProduct.store(_initiatorUser, _responderUser, _prodFactory, _motherProduct, _storedQuantity,
      _actor);

        // Update product details in the mapping.
        add2ProductsTab(address(newProduct), address(newProduct));

        emit StoredByMillManager(address(newProduct));

    }


    // Function to package product.
    function packagingProduct(address _initiatorUser,address _responderUser, ProdFactory _prodFactory, Product _motherProduct, uint256 _packagedQuantity,
    ActorCategory _actor, uint256 _packagingPrice) public
    {
        Product newProduct = _motherProduct.store(_initiatorUser, _responderUser, _prodFactory, _motherProduct, _packagedQuantity,
      _actor);

        // Update product details in the mapping.
        add2ProductsTab(address(newProduct), address(newProduct));

        emit PackagedByMillManager(address(newProduct));

    }

}




//////////////////////////////////////////////////////////////////////////////////////////////////////




// Contract representing a product.
contract Product  is Ownable,FarmerRole,MillManagerRole,ConsumerRole {

    //Product Attributes
    address public initiatorUser; // first Owner
    address public responderUser; // Buyer
    address public productAddr;
    ProdType public productType;
    CreationCause public creatCause;
    ActorCategory public ownerCateg;
    uint256 public initialQuantity;  
    uint256 public remainingQuantity;
    address public  motherProd;
    ProdFactory public prodFactory;
    bool public confirmed = false;
    

    // Constructor to initialize the product.
    constructor(address _initiatorUser,address _responderUser,ProdType _productType,
     CreationCause _creatCause, ActorCategory _ownerCateg, uint256 _initialQuantity, 
     uint256 _remainingQuantity,address _motherProd, ProdFactory _prodFactory )  {
        
        require(_initialQuantity > 0, "Initial quantity must be greater than zero");

        //require();

        initiatorUser = _initiatorUser;
        responderUser = _responderUser;
        productAddr = address(this);
        productType = _productType;
        creatCause = _creatCause;
        ownerCateg = _ownerCateg;
        initialQuantity = _initialQuantity;
        remainingQuantity = _remainingQuantity;
        motherProd = _motherProd;
        prodFactory= _prodFactory ;

    }

    // Function to set the remaining product quantity.
    function setRemainingQuantity(uint256 _remainingQuantity) public {

        // Ensure that the remaining quantity is less than or equal to the initial quantity
        require(_remainingQuantity <= initialQuantity, "Remaining quantity cannot exceed initial quantity");

        remainingQuantity = _remainingQuantity;
    }


    // Function to set the mother product address.
    function setMotherProd(address  _motherProd) public{
        
        // Ensure that the mother address is not null
        assert(_motherProd != address(0)); //Warning: CHC: Assertion violation happens here.
        
        motherProd=_motherProd;
    }


    // Function to extract a product.
    function extract(address _initiatorUser,address _responderUser, ProdFactory _prodFactory, Product _motherProduct, uint256 _Extractedquantity,
    ActorCategory _actor) public returns (Product) 
    {
        // Ensure that the extracted quantity does not exceed the remaining quantity
        require(_Extractedquantity <= _motherProduct.remainingQuantity(), "Extracted quantity exceeds remaining quantity");
        
        // Create new Product using the ProdFactory Contract.
        Product newProduct = _prodFactory.create(_initiatorUser, _responderUser, ProdType.Oil, CreationCause.Extracting, _actor,
        _Extractedquantity, _Extractedquantity, _motherProduct.productAddr(), _prodFactory);


        // Deduct the extracted quantity from the remaining quantity of the motherProduct.
        _motherProduct.setRemainingQuantity(_motherProduct.remainingQuantity() - _Extractedquantity) ;

        // Ensure that the remaining quantity is always non-negative
        assert(_motherProduct.remainingQuantity() >= 0); // Warning: CHC: Assertion violation happens here.

        return (newProduct);

     }

    
    // Function to sell a product.
    function sell(address _initiatorUser,address _responderUser, ProdFactory _prodFactory, Product _motherProduct, uint256 _soldQuantity,
     ActorCategory _buyer) public returns (Product)
     {
        // Ensure that the seller and buyer are not null addresses
        require(_initiatorUser != address(0) && _responderUser != address(0), "Seller and buyer addresses cannot be null");
        // Ensure that the sold quantity is not zero
        require(_soldQuantity > 0, "Sold quantity must be greater than zero");
        // Ensure that the sold quantity does not exceed the remaining quantity
        require(_soldQuantity <= _motherProduct.remainingQuantity(), "Sold quantity exceeds remaining quantity");
        //
        
        if(isConsumer(msg.sender))
            require(_motherProduct.productType()==ProdType.Oil);

        if(isMillManager(msg.sender))
            require(_motherProduct.productType()==ProdType.Olive);
    
        // Create a new product using the ProdFactory contract.
        Product newProduct=  _prodFactory.create(_initiatorUser, _responderUser, _motherProduct.productType(), CreationCause.Buying, _buyer,
         _soldQuantity, _soldQuantity,  _motherProduct.productAddr(), _prodFactory);

        
        uint256 remainingQuantityBefore= _motherProduct.remainingQuantity();

        // Deduct the sold quantity from the remaining quantity of the motherProduct.
        _motherProduct.setRemainingQuantity(_motherProduct.remainingQuantity() - _soldQuantity);

        uint256 remainingQuantityAfter= _motherProduct.remainingQuantity();

        assert(remainingQuantityBefore < remainingQuantityAfter); 

        if(isConsumer(msg.sender))
            assert(newProduct.productType()==ProdType.Oil || newProduct.creatCause()==CreationCause.Buying );
        if(isMillManager(msg.sender))
            assert(newProduct.productType()==ProdType.Olive || newProduct.creatCause()==CreationCause.Buying );



        return (newProduct);

    }

    

    // Function to store a product.
    function store(address _initiatorUser,address _responderUser, ProdFactory _prodFactory, Product _motherProduct, uint256 _storedQuantity,
     ActorCategory _actor) public returns (Product) 
     {

        // Create a new product using the ProdFactory contract.
        Product newProduct=  _prodFactory.create(_initiatorUser, _responderUser, _motherProduct.productType(), CreationCause.Buying, _actor,
         _storedQuantity, _storedQuantity,  _motherProduct.productAddr(), _prodFactory);


        // Deduct the stored quantity from the remaining quantity of the motherProduct.
        _motherProduct.setRemainingQuantity(_motherProduct.remainingQuantity() - _storedQuantity);


        return (newProduct);

    } 


    // Function to package a product (Oil).
    function package(address _initiatorUser,address _responderUser, ProdFactory _prodFactory, Product _motherProduct, uint256 _packagedQuantity,
     ActorCategory _actor) public returns (Product)
     {
        
        // Create a new product using the ProdFactory contract.
        Product newProduct=  _prodFactory.create(_initiatorUser, _responderUser, ProdType.Oil, CreationCause.Packaging, _actor,
         _packagedQuantity, _packagedQuantity,  _motherProduct.productAddr(), _prodFactory);


        // Deduct the packaged quantity from the remaining quantity of the motherProduct.
        _motherProduct.setRemainingQuantity(_motherProduct.remainingQuantity() - _packagedQuantity);


        return (newProduct);

     }


    // Function for verification.     
    function verif(Product _product) public view {
        address owner = _product.initiatorUser() ; 
        if (isConsumer(owner) && _product.productType()==ProdType.Oil){
            assert(_product.initialQuantity() == _product.remainingQuantity() ); }
        
        if (_product.productType()==ProdType.Olive){
            assert(!(_product.creatCause()==CreationCause.Extracting) && !(_product.creatCause()==CreationCause.Storing) && !(_product.creatCause()==CreationCause.Packaging) ); }

        if (_product.productType()==ProdType.Oil && _product.creatCause()==CreationCause.Buying){
            assert(isConsumer(owner) || isMillManager(owner)) ; }

        if (_product.productType()==ProdType.Oil){
            assert(_product.creatCause()==CreationCause.Extracting || _product.creatCause()==CreationCause.Storing || _product.creatCause()==CreationCause.Packaging ||  _product.creatCause()==CreationCause.Buying); }
    

        assert( _product.initialQuantity() >= _product.remainingQuantity());

        // Créer une instance du contrat Product à partir de motherProd
        Product motherProductInstance = Product(_product.motherProd());

        if (motherProductInstance.productType() == ProdType.Oil){
            assert(_product.productType() == ProdType.Oil);
        }

        if(_product.creatCause()==CreationCause.Buying && isMillManager(owner)){
            assert(isFarmer(motherProductInstance.initiatorUser()) && motherProductInstance.ownerCateg() == ActorCategory.Farmer );
        }
        //enum ActorCategory { Farmer, Mill, Consumer } // Farmer: 0, Mill: 1, Consumer: 2
        if(_product.creatCause()==CreationCause.Buying && isConsumer(owner)){
            assert(isFarmer(motherProductInstance.initiatorUser()) && motherProductInstance.ownerCateg() == ActorCategory.Farmer || isMillManager(motherProductInstance.initiatorUser()) && motherProductInstance.ownerCateg() == ActorCategory.Mill);
        }

    }
}




//////////////////////////////////////////////////////////////////////////////////////////////////////



// Contract for creating product instances.
contract ProdFactory {

    // Function to create a new product instance.
    function create(address _initiatorUser, address _responderUser, ProdType _productType, 
    CreationCause _creatCause, ActorCategory _ownerCateg, uint256 _initialQuantity, 
    uint256 _remainingQuantity, address _motherProd,  ProdFactory _prodFactory) public returns (Product)    
    {

        Product product = new Product(_initiatorUser, _responderUser, _productType, _creatCause, 
         _ownerCateg, _initialQuantity, _remainingQuantity, _motherProd, _prodFactory);
        

        return (product);

    }

}