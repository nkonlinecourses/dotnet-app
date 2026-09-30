using Microsoft.AspNetCore.Mvc;
using OrderService.Models;
using OrderService.Services;
namespace OrderService.Controllers;
[ApiController]
[Route("api/[controller]")]
public class OrdersController(ProductClient productClient) : ControllerBase
{
    private static readonly List<Order> Orders = [];
    [HttpGet] public ActionResult<IEnumerable<Order>> GetOrders() => Ok(Orders);
    [HttpPost]
    public async Task<ActionResult<Order>> CreateOrder(CreateOrderRequest request)
    {
        if (request.Quantity <= 0) return BadRequest(new { message = "Quantity must be greater than zero" });
        var product = await productClient.GetProductAsync(request.ProductId);
        if (product is null) return BadRequest(new { message = $"Product {request.ProductId} does not exist" });
        var order = new Order { Id = Orders.Count + 1, ProductId = product.Id, ProductName = product.Name, Quantity = request.Quantity, UnitPrice = product.Price, TotalPrice = product.Price * request.Quantity };
        Orders.Add(order);
        return Created($"/api/orders/{order.Id}", order);
    }
}
