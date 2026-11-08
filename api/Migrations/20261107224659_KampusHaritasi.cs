using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace api.Migrations
{
    /// <inheritdoc />
    public partial class KampusHaritasi : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Dersler_Akademisyenler_AkademisyenId",
                table: "Dersler");

            migrationBuilder.DropForeignKey(
                name: "FK_Dersler_Derslikler_DerslikId",
                table: "Dersler");

            migrationBuilder.DropColumn(
                name: "Blok",
                table: "Derslikler");

            migrationBuilder.DropColumn(
                name: "Kat",
                table: "Derslikler");

            migrationBuilder.DropColumn(
                name: "MusaitMi",
                table: "Derslikler");

            migrationBuilder.AlterColumn<int>(
                name: "Kapasite",
                table: "Derslikler",
                type: "integer",
                nullable: true,
                oldClrType: typeof(int),
                oldType: "integer");

            migrationBuilder.AlterColumn<string>(
                name: "Ad",
                table: "Derslikler",
                type: "character varying(100)",
                maxLength: 100,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "character varying(20)",
                oldMaxLength: 20);

            migrationBuilder.AddColumn<int>(
                name: "MekanId",
                table: "Derslikler",
                type: "integer",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Not",
                table: "Derslikler",
                type: "character varying(200)",
                maxLength: 200,
                nullable: true);

            migrationBuilder.AlterColumn<int>(
                name: "DerslikId",
                table: "Dersler",
                type: "integer",
                nullable: true,
                oldClrType: typeof(int),
                oldType: "integer");

            migrationBuilder.AlterColumn<string>(
                name: "DersAdi",
                table: "Dersler",
                type: "character varying(150)",
                maxLength: 150,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "character varying(100)",
                oldMaxLength: 100);

            migrationBuilder.AlterColumn<int>(
                name: "AkademisyenId",
                table: "Dersler",
                type: "integer",
                nullable: true,
                oldClrType: typeof(int),
                oldType: "integer");

            migrationBuilder.AddColumn<string>(
                name: "Grup",
                table: "Dersler",
                type: "character varying(50)",
                maxLength: 50,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "Kod",
                table: "Dersler",
                type: "character varying(20)",
                maxLength: 20,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<bool>(
                name: "LabMi",
                table: "Dersler",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.CreateTable(
                name: "KullaniciDersleri",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    KullaniciId = table.Column<int>(type: "integer", nullable: false),
                    DersKodu = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_KullaniciDersleri", x => x.Id);
                    table.ForeignKey(
                        name: "FK_KullaniciDersleri_Kullanicilar_KullaniciId",
                        column: x => x.KullaniciId,
                        principalTable: "Kullanicilar",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Mekanlar",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Ad = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: true),
                    Tur = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    Enlem = table.Column<double>(type: "double precision", nullable: false),
                    Boylam = table.Column<double>(type: "double precision", nullable: false),
                    Geometri = table.Column<string>(type: "jsonb", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Mekanlar", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Sinavlar",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    DersKodu = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    Tur = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    Tarih = table.Column<DateOnly>(type: "date", nullable: false),
                    BaslangicSaati = table.Column<TimeOnly>(type: "time without time zone", nullable: false),
                    BitisSaati = table.Column<TimeOnly>(type: "time without time zone", nullable: false),
                    DerslikId = table.Column<int>(type: "integer", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Sinavlar", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Sinavlar_Derslikler_DerslikId",
                        column: x => x.DerslikId,
                        principalTable: "Derslikler",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Derslikler_MekanId",
                table: "Derslikler",
                column: "MekanId");

            migrationBuilder.CreateIndex(
                name: "IX_Dersler_Kod",
                table: "Dersler",
                column: "Kod");

            migrationBuilder.CreateIndex(
                name: "IX_KullaniciDersleri_KullaniciId_DersKodu",
                table: "KullaniciDersleri",
                columns: new[] { "KullaniciId", "DersKodu" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Sinavlar_DerslikId",
                table: "Sinavlar",
                column: "DerslikId");

            migrationBuilder.AddForeignKey(
                name: "FK_Dersler_Akademisyenler_AkademisyenId",
                table: "Dersler",
                column: "AkademisyenId",
                principalTable: "Akademisyenler",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_Dersler_Derslikler_DerslikId",
                table: "Dersler",
                column: "DerslikId",
                principalTable: "Derslikler",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_Derslikler_Mekanlar_MekanId",
                table: "Derslikler",
                column: "MekanId",
                principalTable: "Mekanlar",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Dersler_Akademisyenler_AkademisyenId",
                table: "Dersler");

            migrationBuilder.DropForeignKey(
                name: "FK_Dersler_Derslikler_DerslikId",
                table: "Dersler");

            migrationBuilder.DropForeignKey(
                name: "FK_Derslikler_Mekanlar_MekanId",
                table: "Derslikler");

            migrationBuilder.DropTable(
                name: "KullaniciDersleri");

            migrationBuilder.DropTable(
                name: "Mekanlar");

            migrationBuilder.DropTable(
                name: "Sinavlar");

            migrationBuilder.DropIndex(
                name: "IX_Derslikler_MekanId",
                table: "Derslikler");

            migrationBuilder.DropIndex(
                name: "IX_Dersler_Kod",
                table: "Dersler");

            migrationBuilder.DropColumn(
                name: "MekanId",
                table: "Derslikler");

            migrationBuilder.DropColumn(
                name: "Not",
                table: "Derslikler");

            migrationBuilder.DropColumn(
                name: "Grup",
                table: "Dersler");

            migrationBuilder.DropColumn(
                name: "Kod",
                table: "Dersler");

            migrationBuilder.DropColumn(
                name: "LabMi",
                table: "Dersler");

            migrationBuilder.AlterColumn<int>(
                name: "Kapasite",
                table: "Derslikler",
                type: "integer",
                nullable: false,
                defaultValue: 0,
                oldClrType: typeof(int),
                oldType: "integer",
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "Ad",
                table: "Derslikler",
                type: "character varying(20)",
                maxLength: 20,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "character varying(100)",
                oldMaxLength: 100);

            migrationBuilder.AddColumn<string>(
                name: "Blok",
                table: "Derslikler",
                type: "character varying(20)",
                maxLength: 20,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "Kat",
                table: "Derslikler",
                type: "character varying(10)",
                maxLength: 10,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<bool>(
                name: "MusaitMi",
                table: "Derslikler",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AlterColumn<int>(
                name: "DerslikId",
                table: "Dersler",
                type: "integer",
                nullable: false,
                defaultValue: 0,
                oldClrType: typeof(int),
                oldType: "integer",
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "DersAdi",
                table: "Dersler",
                type: "character varying(100)",
                maxLength: 100,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "character varying(150)",
                oldMaxLength: 150);

            migrationBuilder.AlterColumn<int>(
                name: "AkademisyenId",
                table: "Dersler",
                type: "integer",
                nullable: false,
                defaultValue: 0,
                oldClrType: typeof(int),
                oldType: "integer",
                oldNullable: true);

            migrationBuilder.AddForeignKey(
                name: "FK_Dersler_Akademisyenler_AkademisyenId",
                table: "Dersler",
                column: "AkademisyenId",
                principalTable: "Akademisyenler",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Dersler_Derslikler_DerslikId",
                table: "Dersler",
                column: "DerslikId",
                principalTable: "Derslikler",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }
    }
}
