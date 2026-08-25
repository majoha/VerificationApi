using System.Security.Cryptography;

var builder = WebApplication.CreateBuilder(args);

var app = builder.Build();

var verifications = new List<Verification>();

app.MapGet("/", () => "API is running!");

app.MapPost("/createVerification", () =>
{
    RemoveExpiredCodes(verifications);

    // Generate a secure, unique 6-digit verification code
    string code;

    do
    {
        code = RandomNumberGenerator
            .GetInt32(100000, 1000000)
            .ToString();
    }
    while (verifications.Any(v => v.Code == code));

    var verification = new Verification
    {
        Code = code,
        Verified = false,
        ExpiresAt = DateTime.UtcNow.AddMinutes(5)
    };

    verifications.Add(verification);

    return Results.Ok(new
    {
        verification.Code,
        verification.ExpiresAt
    });
});

app.MapPost("/checkCode", (CheckRequest request) =>
{
    RemoveExpiredCodes(verifications);

    var verification = verifications
        .FirstOrDefault(v => v.Code == request.Code);

    if (verification == null || verification.Verified)
    {
        return Results.Ok(new
        {
            valid = false,
            message = "Code not found, expired, or already used."
        });
    }

    // Mark the verification as completed
    verification.Verified = true;

    return Results.Ok(new
    {
        valid = true
    });
});

static void RemoveExpiredCodes(List<Verification> verifications)
{
    verifications.RemoveAll(v => v.ExpiresAt <= DateTime.UtcNow);
}

app.Run();

record CheckRequest(string Code);

class Verification
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public string Code { get; set; } = "";

    public bool Verified { get; set; }

    public DateTime ExpiresAt { get; set; }
}