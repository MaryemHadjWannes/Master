$(document).ready(function() {
    $('.buy-btn').click(function() {
        var product = $(this).siblings('h3').text();
        var price = $(this).siblings('p:last').text();
        var listItem = '' + product + ' - ' + price + '';
        $('#paidProductsList').append(listItem);
    });
});
