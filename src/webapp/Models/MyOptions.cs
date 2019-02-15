using System;
namespace webapp.Models
{
    public class Options
    {
        public string CdnHost { get; set; }
        public string HealthCheckMsg { get; set; }
        public string MachineName => Environment.MachineName;
    }
}
