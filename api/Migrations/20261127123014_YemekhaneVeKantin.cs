using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace api.Migrations
{
    /// <inheritdoc />
    public partial class YemekhaneVeKantin : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "MekanId",
                table: "Etkinlikler",
                type: "integer",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "KantinUrunleri",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    MekanId = table.Column<int>(type: "integer", nullable: false),
                    Ad = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: false),
                    Kategori = table.Column<string>(type: "character varying(30)", maxLength: 30, nullable: false),
                    Fiyat = table.Column<decimal>(type: "numeric(8,2)", precision: 8, scale: 2, nullable: false),
                    MevcutMu = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_KantinUrunleri", x => x.Id);
                    table.ForeignKey(
                        name: "FK_KantinUrunleri_Mekanlar_MekanId",
                        column: x => x.MekanId,
                        principalTable: "Mekanlar",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "YemekMenuleri",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Tarih = table.Column<DateOnly>(type: "date", nullable: false),
                    Corba = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: false),
                    AnaYemek = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: false),
                    YanYemek = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: true),
                    Tatli = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: true),
                    VejetaryenSecenek = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: true),
                    Kalori = table.Column<int>(type: "integer", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_YemekMenuleri", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Etkinlikler_MekanId",
                table: "Etkinlikler",
                column: "MekanId");

            migrationBuilder.CreateIndex(
                name: "IX_Etkinlikler_Tarih",
                table: "Etkinlikler",
                column: "Tarih");

            migrationBuilder.CreateIndex(
                name: "IX_KantinUrunleri_MekanId",
                table: "KantinUrunleri",
                column: "MekanId");

            migrationBuilder.CreateIndex(
                name: "IX_YemekMenuleri_Tarih",
                table: "YemekMenuleri",
                column: "Tarih",
                unique: true);

            migrationBuilder.AddForeignKey(
                name: "FK_Etkinlikler_Mekanlar_MekanId",
                table: "Etkinlikler",
                column: "MekanId",
                principalTable: "Mekanlar",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Etkinlikler_Mekanlar_MekanId",
                table: "Etkinlikler");

            migrationBuilder.DropTable(
                name: "KantinUrunleri");

            migrationBuilder.DropTable(
                name: "YemekMenuleri");

            migrationBuilder.DropIndex(
                name: "IX_Etkinlikler_MekanId",
                table: "Etkinlikler");

            migrationBuilder.DropIndex(
                name: "IX_Etkinlikler_Tarih",
                table: "Etkinlikler");

            migrationBuilder.DropColumn(
                name: "MekanId",
                table: "Etkinlikler");
        }
    }
}
