$(document).ready(function() {

    var web3 = new Web3('http://127.0.0.1:8545'); // Adresse de Ganache CLI

    // Récupérer l'adresse Ethereum du premier compte
    web3.eth.getAccounts().then(function(accounts) {
        var ethereumAddress = accounts[0];
        $('#ethereumAddress').text('Ethereum Address: ' + ethereumAddress);

        // Récupérer le solde du compte
        web3.eth.getBalance(ethereumAddress).then(function(balance) {
            var etherBalance = web3.utils.fromWei(balance, 'ether');
            $('#etherBalance').text('Ether Balance: ' + etherBalance + ' ETH');
        }).catch(console.error);
    }).catch(console.error);
    
    
    // Array to store the products
    var products = [];

    // Add Product Form Submit Event
    $('#addProductForm').submit(function(e) {
        e.preventDefault();

        // Get form values
        var productName = $('#productName').val();
        var productPrice = $('#productPrice').val();
        var productQuantity = $('#productQuantity').val();

        // Create product object
        var product = {
            name: productName,
            price: productPrice,
            quantity: productQuantity,
            forSale: false
        };

        // Add product to the array
        products.push(product);

        // Clear form inputs
        $('#productName').val('');
        $('#productPrice').val('');
        $('#productQuantity').val('');

        // Update the product list
        updateProductList();
    });

    // Update Product List
    function updateProductList() {
        // Clear the product list
        $('#productList').empty();

        // Loop through the products array and add each product to the list
        for (var i = 0; i < products.length; i++) {
            var product = products[i];

            // Create list item for the product
            var listItem = $('<li>').addClass('product-item');

            // Create product details
            var productDetails = $('<div>').addClass('product-details');
            productDetails.append($('<span>').text(product.name));
            productDetails.append($('<span>').text('Price: ' + product.price));
            productDetails.append($('<span>').text('Quantity: ' + product.quantity));

            // Create button to put product for sale
            var sellButton = $('<button>').addClass('btn btn-primary sell-button').text('For Sale');
            sellButton.attr('data-index', i);

            // Append product details and sell button to the list item
            listItem.append(productDetails);
            listItem.append(sellButton);

            // Append the list item to the product list
            $('#productList').append(listItem);
        }
    }

    // Sell Button Click Event
    $(document).on('click', '.sell-button', function() {
        var index = $(this).attr('data-index');

        // Toggle the forSale property of the product
        products[index].forSale = !products[index].forSale;

        // Update the product list
        updateProductList();
    });
});

