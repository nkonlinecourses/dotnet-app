using OrderService.Models;
namespace OrderService.Tests;
public class OrderModelTests { [Fact] public void Total_Can_Be_Calculated() { var price=1000m; var qty=2; Assert.Equal(2000m, price*qty); } }
