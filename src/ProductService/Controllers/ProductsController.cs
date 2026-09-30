using Microsoft.AspNetCore.Mvc;
using ProductService.Models;
namespace ProductService.Controllers;
[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    private static readonly List<Product> Products =
    [
        new() { Id = 1, Name = "Laptop", Price = 1000 },
        new() { Id = 2, Name = "Monitor", Price = 300 },
        new() { Id = 3, Name = "Keyboard", Price = 50 }
    ];
    [HttpGet] public ActionResult<IEnumerable<Product>> GetProducts() => Ok(Products);
    [HttpGet("{id:int}")]
    public ActionResult<Product> GetProduct(int id)
    {
        var product = Products.FirstOrDefault(p => p.Id == id);
        return product is null ? NotFound(new { message = $"Product {id} not found" }) : Ok(product);
    }
}
