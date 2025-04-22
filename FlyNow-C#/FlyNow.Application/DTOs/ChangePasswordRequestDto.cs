namespace FlyNow.Application.DTOs
{
    public class ChangePasswordRequestDto
    {
        public string Email { get; set; }
        public string NewPassword { get; set; }
    }
}
