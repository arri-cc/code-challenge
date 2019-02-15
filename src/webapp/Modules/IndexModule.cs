using System;
using Nancy;

namespace webapp.Modules
{
    public class IndexModule : NancyModule
    {
        public IndexModule()
        {
            Get("/", _ =>
            {
                return View["index", Environment.MachineName];
            });
        }
    }
}
