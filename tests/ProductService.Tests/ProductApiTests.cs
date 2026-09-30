using Microsoft.AspNetCore.Mvc.Testing;
using System.Net;
namespace ProductService.Tests;
public class ProductApiTests : IClassFixture<WebApplicationFactory<Program>> {
 private readonly HttpClient _client;
 public ProductApiTests(WebApplicationFactory<Program> factory) => _client = factory.CreateClient();
 [Fact] public async Task Get_Product_Returns_Ok() { var r=await _client.GetAsync("/api/products/1"); Assert.Equal(HttpStatusCode.OK,r.StatusCode); }
 [Fact] public async Task Health_Returns_Ok() { var r=await _client.GetAsync("/health"); Assert.Equal(HttpStatusCode.OK,r.StatusCode); }
}
