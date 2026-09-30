using System.Net;
using System.Net.Http.Json;
using OrderService.Models;
namespace OrderService.Services;
public class ProductClient(HttpClient httpClient)
{
    public async Task<Product?> GetProductAsync(int productId)
    {
        var response = await httpClient.GetAsync($"api/products/{productId}");
        if (response.StatusCode == HttpStatusCode.NotFound) return null;
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<Product>();
    }
}
