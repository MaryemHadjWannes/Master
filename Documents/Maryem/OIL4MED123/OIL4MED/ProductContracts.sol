// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental SMTChecker;


// inherited contracts
import './Ownable.sol';
import './FarmerRole.sol';
import './MillManagerRole.sol';
import './ConsumerRole.sol';
import './ProductContract.sol';

/*enum ProdType { Olive, Oil } // Olive:0 , Oil:1
enum CreationCause { Extracting, Buying, Storing, Packaging } // Extracting: 0, Buying: 1, Storing: 2, packaging: 3
enum ActorCategory { Farmer, Mill, Consumer } // Farmer: 0, Mill: 1, Consumer: 2
*/


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