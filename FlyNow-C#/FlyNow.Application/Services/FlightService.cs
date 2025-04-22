using FlyNow.Application.Interfaces;
using FlyNow.Domain.Entities;
using FlyNow.Infrastructure;
using Microsoft.EntityFrameworkCore;

namespace FlyNow.Application.Services
{
    public class FlightService : IFlightService
    {
        private readonly FlyNowDbContext _context;

        public FlightService(FlyNowDbContext context)
        {
            _context = context;
        }

        public async Task<List<Flight>> GetFlightsByAirportsAsync(string origin, string destination)
        {
            return await _context.Flights
                .Where(f => f.Origin.ToLower() == origin.ToLower() && f.Destination.ToLower() == destination.ToLower())
                .ToListAsync();
        }
    }
}
