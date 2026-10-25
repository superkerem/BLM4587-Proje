using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace api.Migrations
{
    /// <inheritdoc />
    public partial class InitialMobil : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Akademisyenler",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Ad = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    Soyad = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    Unvan = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    Email = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Akademisyenler", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Derslikler",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Ad = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    Blok = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    Kat = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: false),
                    Kapasite = table.Column<int>(type: "integer", nullable: false),
                    MusaitMi = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Derslikler", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Etkinlikler",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Baslik = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: false),
                    Aciklama = table.Column<string>(type: "text", nullable: false),
                    ToplulukAdi = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    Tarih = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    Konum = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Etkinlikler", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Kullanicilar",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Ad = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    Soyad = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    OgrenciNo = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true),
                    Email = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    SifreHash = table.Column<string>(type: "text", nullable: false),
                    Rol = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    KayitTarihi = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Kullanicilar", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Dersler",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    DersAdi = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    Gun = table.Column<int>(type: "integer", nullable: false),
                    BaslangicSaati = table.Column<TimeOnly>(type: "time without time zone", nullable: false),
                    BitisSaati = table.Column<TimeOnly>(type: "time without time zone", nullable: false),
                    DerslikId = table.Column<int>(type: "integer", nullable: false),
                    AkademisyenId = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Dersler", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Dersler_Akademisyenler_AkademisyenId",
                        column: x => x.AkademisyenId,
                        principalTable: "Akademisyenler",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Dersler_Derslikler_DerslikId",
                        column: x => x.DerslikId,
                        principalTable: "Derslikler",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "KayipEsyalar",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Baslik = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: false),
                    Aciklama = table.Column<string>(type: "text", nullable: false),
                    BulunanYer = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: false),
                    TeslimEdildiMi = table.Column<bool>(type: "boolean", nullable: false),
                    BulunmaTarihi = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    BildirenKullaniciId = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_KayipEsyalar", x => x.Id);
                    table.ForeignKey(
                        name: "FK_KayipEsyalar_Kullanicilar_BildirenKullaniciId",
                        column: x => x.BildirenKullaniciId,
                        principalTable: "Kullanicilar",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "KutuphaneMasalari",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    MasaNo = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    Kat = table.Column<int>(type: "integer", nullable: false),
                    Kapasite = table.Column<int>(type: "integer", nullable: false),
                    PrizVarMi = table.Column<bool>(type: "boolean", nullable: false),
                    DoluMu = table.Column<bool>(type: "boolean", nullable: false),
                    RezerveEdenKullaniciId = table.Column<int>(type: "integer", nullable: true),
                    RezervasyonBitis = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_KutuphaneMasalari", x => x.Id);
                    table.ForeignKey(
                        name: "FK_KutuphaneMasalari_Kullanicilar_RezerveEdenKullaniciId",
                        column: x => x.RezerveEdenKullaniciId,
                        principalTable: "Kullanicilar",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Dersler_AkademisyenId",
                table: "Dersler",
                column: "AkademisyenId");

            migrationBuilder.CreateIndex(
                name: "IX_Dersler_DerslikId",
                table: "Dersler",
                column: "DerslikId");

            migrationBuilder.CreateIndex(
                name: "IX_Derslikler_Ad",
                table: "Derslikler",
                column: "Ad",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_KayipEsyalar_BildirenKullaniciId",
                table: "KayipEsyalar",
                column: "BildirenKullaniciId");

            migrationBuilder.CreateIndex(
                name: "IX_Kullanicilar_Email",
                table: "Kullanicilar",
                column: "Email",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Kullanicilar_OgrenciNo",
                table: "Kullanicilar",
                column: "OgrenciNo",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_KutuphaneMasalari_MasaNo",
                table: "KutuphaneMasalari",
                column: "MasaNo",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_KutuphaneMasalari_RezerveEdenKullaniciId",
                table: "KutuphaneMasalari",
                column: "RezerveEdenKullaniciId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Dersler");

            migrationBuilder.DropTable(
                name: "Etkinlikler");

            migrationBuilder.DropTable(
                name: "KayipEsyalar");

            migrationBuilder.DropTable(
                name: "KutuphaneMasalari");

            migrationBuilder.DropTable(
                name: "Akademisyenler");

            migrationBuilder.DropTable(
                name: "Derslikler");

            migrationBuilder.DropTable(
                name: "Kullanicilar");
        }
    }
}
