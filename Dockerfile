# 1. IMAGEN BASE (SDK)
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src

# 2. RESTAURAR DEPENDENCIAS
# Fíjate que aquí usamos las rutas que me confirmaste: Carpeta/Archivo.csproj
COPY ["SistemaVetIng/SistemaVetIng.csproj", "SistemaVetIng/"]
RUN dotnet restore "SistemaVetIng/SistemaVetIng.csproj"

# 3. COPIAR CÓDIGO Y COMPILAR
COPY . .
WORKDIR "/src/SistemaVetIng"
RUN dotnet build "SistemaVetIng.csproj" -c $BUILD_CONFIGURATION -o /app/build

# 4. PUBLICAR (Generar los archivos finales)
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "SistemaVetIng.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# 5. IMAGEN FINAL (RUNTIME)
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=publish /app/publish .

# Render necesita saber qué puerto exponemos (8080 estándar para contenedores web)
ENV ASPNETCORE_HTTP_PORTS=8080
EXPOSE 8080

# El nombre del DLL debe coincidir con el nombre de tu proyecto
ENTRYPOINT ["dotnet", "SistemaVetIng.dll"]