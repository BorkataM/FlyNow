using FlyNow.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;

namespace FlyNow.Infrastructure
{
    public class FlyNowDbContext : DbContext
    {
        public FlyNowDbContext(DbContextOptions<FlyNowDbContext> options) : base(options) { }

        public DbSet<User> Users { get; set; }
        public DbSet<Flight> Flights { get; set; }
        public DbSet<Booking> Bookings { get; set; }
        public DbSet<Ticket> Tickets { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<Flight>()
                .Property(f => f.Id)
                .ValueGeneratedOnAdd();
        }
    }
}
