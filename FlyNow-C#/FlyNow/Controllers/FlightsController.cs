using FlyNow.Application.DTOs;
using FlyNow.Domain.Entities;
using FlyNow.Infrastructure;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using FlyNow.Application.Interfaces;
using FluentValidation;
using FlyNow.Application.Services;

namespace FlyNow.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class FlightsController : ControllerBase
    {
        private readonly FlyNowDbContext _context;
        private readonly IFlightService _flightService;

        public FlightsController(FlyNowDbContext context, IFlightService flightService)
        {
            _context = context;
            _flightService = flightService;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<Flight>>> GetFlights()
        {
            return await _context.Flights.ToListAsync();
        }

        [HttpPost]
        public async Task<ActionResult<Flight>> CreateFlight(Flight flight)
        {
            _context.Flights.Add(flight);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetFlights), new { id = flight.Id }, flight);
        }

        [HttpGet("search")]
        public async Task<IActionResult> GetFlights([FromQuery] string origin, [FromQuery] string destination)
        {
            var flights = await _flightService.GetFlightsByAirportsAsync(origin, destination);

            if (flights == null || flights.Count == 0)
            {
                return NotFound("No flights found for the specified airports.");
            }

            return Ok(flights);
        }
    }

    [ApiController]
    [Route("api/[controller]")]
    public class UsersController : ControllerBase
    {
        private readonly IUserService _userService;
        private readonly IValidator<ChangePasswordRequestDto> _changePasswordValidator;

        public UsersController(IUserService userService, IValidator<ChangePasswordRequestDto> changePasswordValidator)
        {
            _userService = userService;
            _changePasswordValidator = changePasswordValidator;
        }

        [HttpGet]
        public async Task<IActionResult> GetUser([FromQuery] string email)
        {
            var user = await _userService.GetUserByEmailAsync(email);

            if (user == null)
            {
                return NotFound("User not found.");
            }

            return Ok(user);
        }

        [HttpPost("create-user")]
        public async Task<IActionResult> CreateUser([FromBody] CreateUserRequestDto dto)
        {
            var userId = await _userService.CreateUserAsync(dto);

            if (userId == -1)
            {
                return Conflict("A user with this email already exists.");
            }

            return Ok(new { id = userId });
        }

        [HttpPut("change-password")]
        public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequestDto dto)
        {
            var result = await _userService.ChangePasswordAsync(dto);

            if (result)
            {
                return Ok("Password changed successfully.");
            }

            return BadRequest("Failed to change password.");
        }

        [HttpDelete("delete-user")]
        public async Task<IActionResult> DeleteUser([FromQuery] string email)
        {
            var result = await _userService.DeleteUserByEmailAsync(email);

            if (result)
            {
                return Ok("User deleted successfully.");
            }

            return NotFound("User not found.");
        }
    }

    [ApiController]
    [Route("api/[controller]")]
    public class TicketsController : ControllerBase
    {
        private readonly FlyNowDbContext _context;  // Тук използваме FlyNowDbContext вместо ApplicationDbContext

        public TicketsController(FlyNowDbContext context)
        {
            _context = context;
        }

        [HttpPost("purchase")]
        public async Task<IActionResult> PurchaseTicket([FromBody] PurchaseTicketRequest request)
        {
            var flight = await _context.Flights.FirstOrDefaultAsync(f => f.Id == request.FlightId);
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == request.Email);

            if (flight == null || user == null)
            {
                return NotFound("Flight or user not found.");
            }

            var ticket = new Ticket
            {
                FlightId = flight.Id,
                UserId = user.Id,
                Price = flight.Price,
                PurchaseDate = DateTime.UtcNow
            };

            _context.Tickets.Add(ticket);
            await _context.SaveChangesAsync();

            return Ok(ticket);
        }

        [HttpGet("user-tickets/{userId}")]
        public async Task<IActionResult> GetTicketsByUserId(int userId)
        {
            var tickets = await _context.Tickets
                .Where(t => t.UserId == userId)
                .ToListAsync();

            if (tickets == null || tickets.Count == 0)
            {
                return NotFound("No tickets found for this user.");
            }

            return Ok(tickets);
        }
    }
}
