using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using api.Models;

namespace api.Data
{
    public class ApplicationDbContext : IdentityDbContext<Kullanici, IdentityRole<int>, int>
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
        {
        }

        public DbSet<Akademisyen> Akademisyenler { get; set; }
        public DbSet<Derslik> Derslikler { get; set; }
        public DbSet<Ders> Dersler { get; set; }
        public DbSet<KutuphaneMasasi> KutuphaneMasalari { get; set; }
        public DbSet<Etkinlik> Etkinlikler { get; set; }
        public DbSet<KayipEsya> KayipEsyalar { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<Kullanici>().ToTable("Kullanicilar");
            modelBuilder.Entity<IdentityRole<int>>().ToTable("Roller");
            modelBuilder.Entity<IdentityUserRole<int>>().ToTable("KullaniciRolleri");

            modelBuilder.Entity<Kullanici>()
                .HasIndex(k => k.OgrenciNo)
                .IsUnique();

            modelBuilder.Entity<Derslik>()
                .HasIndex(d => d.Ad)
                .IsUnique();

            modelBuilder.Entity<KutuphaneMasasi>()
                .HasIndex(m => m.MasaNo)
                .IsUnique();

            // Derslik veya akademisyen silinirse bağlı dersler sessizce silinmesin.
            modelBuilder.Entity<Ders>()
                .HasOne(d => d.Derslik)
                .WithMany(d => d.Dersler)
                .HasForeignKey(d => d.DerslikId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Ders>()
                .HasOne(d => d.Akademisyen)
                .WithMany(a => a.Dersler)
                .HasForeignKey(d => d.AkademisyenId)
                .OnDelete(DeleteBehavior.Restrict);

            // Kullanıcı silinince masa rezervasyonu boşa çıkar.
            modelBuilder.Entity<KutuphaneMasasi>()
                .HasOne(m => m.RezerveEdenKullanici)
                .WithMany(k => k.RezerveMasalar)
                .HasForeignKey(m => m.RezerveEdenKullaniciId)
                .OnDelete(DeleteBehavior.SetNull);

            modelBuilder.Entity<KayipEsya>()
                .HasOne(e => e.BildirenKullanici)
                .WithMany(k => k.BildirilenEsyalar)
                .HasForeignKey(e => e.BildirenKullaniciId)
                .OnDelete(DeleteBehavior.Cascade);
        }
    }
}
