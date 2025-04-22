using FlyNow.Domain.Entities;

namespace FlyNow.Application.Interfaces
{
    public interface IFlightService
    {
        Task<List<Flight>> GetFlightsByAirportsAsync(string origin, string destination);
    }
}
