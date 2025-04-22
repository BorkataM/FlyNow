using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FlyNow.Application.DTOs
{
    public class PurchaseTicketRequest
    {
        public int FlightId { get; set; }
        public string Email { get; set; }
    }
}
