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
        public DbSet<Duyuru> Duyurular { get; set; }
        public DbSet<Mekan> Mekanlar { get; set; }
        public DbSet<KullaniciDersi> KullaniciDersleri { get; set; }
        public DbSet<Sinav> Sinavlar { get; set; }

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

            modelBuilder.Entity<Ders>()
                .HasOne(d => d.Derslik)
                .WithMany(d => d.Dersler)
                .HasForeignKey(d => d.DerslikId)
                .OnDelete(DeleteBehavior.SetNull);

            modelBuilder.Entity<Ders>()
                .HasOne(d => d.Akademisyen)
                .WithMany(a => a.Dersler)
                .HasForeignKey(d => d.AkademisyenId)
                .OnDelete(DeleteBehavior.SetNull);

            modelBuilder.Entity<Ders>()
                .HasIndex(d => d.Kod);

            modelBuilder.Entity<Mekan>()
                .Property(m => m.Tur)
                .HasConversion<string>()
                .HasMaxLength(20);

            modelBuilder.Entity<Mekan>()
                .Property(m => m.Geometri)
                .HasColumnType("jsonb");

            modelBuilder.Entity<Derslik>()
                .HasOne(d => d.Mekan)
                .WithMany(m => m.Derslikler)
                .HasForeignKey(d => d.MekanId)
                .OnDelete(DeleteBehavior.SetNull);

            modelBuilder.Entity<KullaniciDersi>()
                .HasOne(kd => kd.Kullanici)
                .WithMany(k => k.Dersleri)
                .HasForeignKey(kd => kd.KullaniciId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<KullaniciDersi>()
                .HasIndex(kd => new { kd.KullaniciId, kd.DersKodu })
                .IsUnique();

            modelBuilder.Entity<Sinav>()
                .Property(s => s.Tur)
                .HasConversion<string>()
                .HasMaxLength(20);

            modelBuilder.Entity<Sinav>()
                .HasOne(s => s.Derslik)
                .WithMany()
                .HasForeignKey(s => s.DerslikId)
                .OnDelete(DeleteBehavior.SetNull);

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

            modelBuilder.Entity<Duyuru>()
                .HasOne(d => d.Yazar)
                .WithMany(k => k.Duyurular)
                .HasForeignKey(d => d.YazarId)
                .OnDelete(DeleteBehavior.SetNull);
        }
    }
}
