using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using ContosoCustomerService.Model;
using System.Collections.Generic;

namespace ContosoCustomerService
{
    public static class Orders
    {
        [FunctionName("Orders")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", "post", Route = null)] HttpRequest req,
            ILogger log)
        {
            List<Order> orders = new List<Order> {
                new Order() { ProductName = "Classic Frames", Description = "Stylish frames for modern eye glasses", Quantity = 1, Cost = 10.99 },
                new Order() { ProductName = "Classic gloves", Description = "Stylish gloves for modern hands", Quantity = 1, Cost = 20.99 },
                new Order() { ProductName = "Classic socks", Description = "Stylish socks for modern feet", Quantity = 1, Cost = 5.99 },
            };

            return new OkObjectResult(orders);
        }
    }
}
