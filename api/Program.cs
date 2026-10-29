using System.Text;
using api.Data;
using api.Dtos;
using api.Models;
using api.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddOpenApi();

builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

// Web API'de cookie yok; bu yüzden AddIdentity yerine AddIdentityCore kullanılır.
builder.Services.AddIdentityCore<Kullanici>(options =>
    {
        options.Password.RequiredLength = 8;
        options.Password.RequireDigit = true;
        options.Password.RequireLowercase = true;
        options.Password.RequireUppercase = false;
        options.Password.RequireNonAlphanumeric = false;

        options.User.RequireUniqueEmail = true;

        options.Lockout.MaxFailedAccessAttempts = 5;
        options.Lockout.DefaultLockoutTimeSpan = TimeSpan.FromMinutes(5);
        options.Lockout.AllowedForNewUsers = true;

        options.SignIn.RequireConfirmedAccount = false;
    })
    .AddRoles<IdentityRole<int>>()
    .AddEntityFrameworkStores<ApplicationDbContext>()
    .AddSignInManager()
    .AddDefaultTokenProviders()
    .AddErrorDescriber<TurkceIdentityHatalari>();

var jwtBolumu = builder.Configuration.GetSection("Jwt");
var jwtAyarlari = jwtBolumu.Get<JwtAyarlari>() ?? new JwtAyarlari();

if (string.IsNullOrWhiteSpace(jwtAyarlari.Anahtar) || jwtAyarlari.Anahtar.Length < 32)
{
    throw new InvalidOperationException(
        "Jwt:Anahtar bulunamadı veya 32 karakterden kısa. README'deki 'dotnet user-secrets set \"Jwt:Anahtar\" ...' adımını uygulayın.");
}

builder.Services.Configure<JwtAyarlari>(jwtBolumu);
builder.Services.AddScoped<JwtServisi>();

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.MapInboundClaims = false;
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidIssuer = jwtAyarlari.Yayinci,
            ValidateAudience = true,
            ValidAudience = jwtAyarlari.Hedef,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtAyarlari.Anahtar)),
            ClockSkew = TimeSpan.FromMinutes(1),
            NameClaimType = "name",
            RoleClaimType = "role"
        };

        // Web projesindeki /Giris ve /ErisimEngellendi yönlendirmelerinin API karşılığı:
        // yönlendirme yerine 401 / 403 durum kodu ve Türkçe mesaj döner.
        options.Events = new JwtBearerEvents
        {
            OnChallenge = async context =>
            {
                context.HandleResponse();
                context.Response.StatusCode = StatusCodes.Status401Unauthorized;
                await context.Response.WriteAsJsonAsync(new HataYaniti("Bu işlem için giriş yapmalısınız."));
            },
            OnForbidden = async context =>
            {
                context.Response.StatusCode = StatusCodes.Status403Forbidden;
                await context.Response.WriteAsJsonAsync(new HataYaniti("Bu işlem için yetkiniz yok."));
            }
        };
    });

builder.Services.AddAuthorization(options =>
{
    options.AddPolicy(Politikalar.SadeceYonetici, policy => policy.RequireRole(Roller.Yonetici));
});

// Flutter uygulaması Chrome'da (web) çalışırken farklı bir porttan istek atar;
// tarayıcı buna CORS izni olmadan izin vermez. Sadece geliştirmede localhost'a izin verilir.
builder.Services.AddCors(options =>
{
    options.AddPolicy("GelistirmeCors", policy => policy
        .SetIsOriginAllowed(origin => new Uri(origin).Host == "localhost")
        .AllowAnyHeader()
        .AllowAnyMethod());
});

builder.Services.AddControllers()
    .ConfigureApiBehaviorOptions(options =>
    {
        // Data Annotations hataları mobil uygulamanın okuyabileceği tek biçimde döner.
        options.InvalidModelStateResponseFactory = context =>
        {
            var hatalar = context.ModelState
                .Where(alan => alan.Value!.Errors.Count > 0)
                .ToDictionary(
                    alan => string.IsNullOrEmpty(alan.Key) ? alan.Key : char.ToLowerInvariant(alan.Key[0]) + alan.Key[1..],
                    alan => alan.Value!.Errors.Select(h => h.ErrorMessage).ToArray());

            return new BadRequestObjectResult(new HataYaniti("Gönderilen bilgiler geçersiz.", hatalar));
        };
    });

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseHttpsRedirection();

if (app.Environment.IsDevelopment())
{
    app.UseCors("GelistirmeCors");
}

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

await RolVeYoneticiTohumlama.CalistirAsync(app.Services);

app.Run();
