using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FlyNow.Domain.Entities
{
    public class Ticket
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public int FlightId { get; set; }
        public decimal Price { get; set; }
        public DateTime PurchaseDate { get; set; }
    }

}
