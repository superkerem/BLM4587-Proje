using Microsoft.EntityFrameworkCore;
using api.Models;

namespace api.Data
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
        {
        }

        public DbSet<Kullanici> Kullanicilar { get; set; }
        public DbSet<Derslik> Derslikler { get; set; }
        public DbSet<KutuphaneMasasi> KutuphaneMasalari { get; set; }
        public DbSet<Etkinlik> Etkinlikler { get; set; }
        public DbSet<KayipEsya> KayipEsyalar { get; set; }
    }
}