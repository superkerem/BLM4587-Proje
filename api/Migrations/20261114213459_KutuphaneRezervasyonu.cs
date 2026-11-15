using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace api.Migrations
{
    /// <inheritdoc />
    public partial class KutuphaneRezervasyonu : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_KutuphaneMasalari_Kullanicilar_RezerveEdenKullaniciId",
                table: "KutuphaneMasalari");

            migrationBuilder.DropIndex(
                name: "IX_KutuphaneMasalari_RezerveEdenKullaniciId",
                table: "KutuphaneMasalari");

            migrationBuilder.DropColumn(
                name: "DoluMu",
                table: "KutuphaneMasalari");

            migrationBuilder.DropColumn(
                name: "RezervasyonBitis",
                table: "KutuphaneMasalari");

            migrationBuilder.DropColumn(
                name: "RezerveEdenKullaniciId",
                table: "KutuphaneMasalari");

            migrationBuilder.CreateTable(
                name: "KutuphaneRezervasyonlari",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    MasaId = table.Column<int>(type: "integer", nullable: false),
                    KullaniciId = table.Column<int>(type: "integer", nullable: false),
                    Baslangic = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    Bitis = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    IptalEdildiMi = table.Column<bool>(type: "boolean", nullable: false),
                    BosaltildiMi = table.Column<bool>(type: "boolean", nullable: false),
                    OlusturmaTarihi = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_KutuphaneRezervasyonlari", x => x.Id);
                    table.ForeignKey(
                        name: "FK_KutuphaneRezervasyonlari_Kullanicilar_KullaniciId",
                        column: x => x.KullaniciId,
                        principalTable: "Kullanicilar",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_KutuphaneRezervasyonlari_KutuphaneMasalari_MasaId",
                        column: x => x.MasaId,
                        principalTable: "KutuphaneMasalari",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_KutuphaneRezervasyonlari_KullaniciId_Baslangic",
                table: "KutuphaneRezervasyonlari",
                columns: new[] { "KullaniciId", "Baslangic" });

            migrationBuilder.CreateIndex(
                name: "IX_KutuphaneRezervasyonlari_MasaId_Baslangic",
                table: "KutuphaneRezervasyonlari",
                columns: new[] { "MasaId", "Baslangic" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "KutuphaneRezervasyonlari");

            migrationBuilder.AddColumn<bool>(
                name: "DoluMu",
                table: "KutuphaneMasalari",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<DateTime>(
                name: "RezervasyonBitis",
                table: "KutuphaneMasalari",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "RezerveEdenKullaniciId",
                table: "KutuphaneMasalari",
                type: "integer",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_KutuphaneMasalari_RezerveEdenKullaniciId",
                table: "KutuphaneMasalari",
                column: "RezerveEdenKullaniciId");

            migrationBuilder.AddForeignKey(
                name: "FK_KutuphaneMasalari_Kullanicilar_RezerveEdenKullaniciId",
                table: "KutuphaneMasalari",
                column: "RezerveEdenKullaniciId",
                principalTable: "Kullanicilar",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);
        }
    }
}
