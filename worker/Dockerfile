FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build

WORKDIR /src

# Copy project file and restore dependencies
COPY Worker.csproj .
RUN dotnet restore

# Copy source code and build
COPY . .
RUN dotnet publish -c Release -o /app/publish

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:7.0

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

WORKDIR /app

# Copy published application
COPY --from=build /app/publish .

# Set permissions
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Run the worker
ENTRYPOINT ["dotnet", "Worker.dll"]

