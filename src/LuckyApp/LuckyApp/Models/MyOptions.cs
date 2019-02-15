using System;
namespace LuckyApp.Models
{
    public class MyOptions
    {
        public string CdnHost { get; set; }
        public string HealthCheckMsg { get; set; }
        public string MachineName => Environment.MachineName;
    }
}
