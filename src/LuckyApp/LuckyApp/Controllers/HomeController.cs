using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using LuckyApp.Models;
using Microsoft.Extensions.Options;

namespace LuckyApp.Controllers
{
    public class HomeController : Controller
    {
        public IActionResult Index([FromServices]IOptionsMonitor<MyOptions> options)
        {
            return View(options.CurrentValue);
        }
    }
}
