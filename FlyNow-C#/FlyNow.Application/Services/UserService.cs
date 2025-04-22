using BCrypt.Net;
using FlyNow.Application.DTOs;
using FlyNow.Application.Helpers;
using FlyNow.Application.Interfaces;
using FlyNow.Domain.Entities;
using FlyNow.Infrastructure;
using Microsoft.EntityFrameworkCore;

namespace FlyNow.Application.Services
{
    public class UserService : IUserService
    {
        private readonly FlyNowDbContext _context;

        public UserService(FlyNowDbContext context)
        {
            _context = context;
        }

        public async Task<User?> GetUserByEmailAsync(string email)
        {
            return await _context.Users.FirstOrDefaultAsync(u => u.Email == email);
        }

        public async Task<int> CreateUserAsync(CreateUserRequestDto userDto)
        {
            var user = new User
            {
                Username = userDto.FirstName,
                Email = userDto.Email,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(userDto.Password) // Hash the password before storing it
            };

            _context.Users.Add(user);
            await _context.SaveChangesAsync();
            return user.Id;
        }

        public async Task<bool> ChangePasswordAsync(ChangePasswordRequestDto dto)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == dto.Email);

            if (user == null)
            {
                return false;
            }

            user.PasswordHash = PasswordHasher.HashPassword(dto.NewPassword);

            _context.Users.Update(user);
            await _context.SaveChangesAsync();

            return true;
        }

        public async Task<bool> DeleteUserByEmailAsync(string email)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == email);

            if (user == null)
            {
                return false;
            }

            _context.Users.Remove(user);
            await _context.SaveChangesAsync();

            return true;
        }
    }
}