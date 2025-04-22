namespace FlyNow.Domain.Entities
{
    public class Booking
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public User User { get; set; }
        public int FlightId { get; set; }
        public Flight Flight { get; set; }
        public DateTime BookingDate { get; set; } = DateTime.Now;
    }
}
