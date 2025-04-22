using FlyNow.Application.DTOs;
using FlyNow.Domain.Entities;

namespace FlyNow.Application.Interfaces
{
    public interface IUserService
    {
        Task<User?> GetUserByEmailAsync(string email);
        Task<int> CreateUserAsync(CreateUserRequestDto userDto);
        Task<bool> ChangePasswordAsync(ChangePasswordRequestDto dto);
        Task<bool> DeleteUserByEmailAsync(string email);
    }
}
