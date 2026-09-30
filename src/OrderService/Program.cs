using OrderService.Services;
var builder = WebApplication.CreateBuilder(args);
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddHealthChecks();
var productServiceUrl = builder.Configuration["ProductServiceUrl"] ?? "http://localhost:5001";
builder.Services.AddHttpClient<ProductClient>(client => client.BaseAddress = new Uri(productServiceUrl));
var app = builder.Build();
app.UseSwagger();
app.UseSwaggerUI();
app.MapControllers();
app.MapHealthChecks("/health");
app.Run();

public partial class Program { }
