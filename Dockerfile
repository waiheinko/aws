# Build stage
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["CI_CD/CI_CD.csproj", "CI_CD/"]
RUN dotnet restore "CI_CD/CI_CD.csproj"
COPY . .
RUN dotnet build "CI_CD/CI_CD.csproj" -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish "CI_CD/CI_CD.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS runtime
WORKDIR /app
EXPOSE 80

# Set the timezone to Singapore
ENV TZ=Asia/Singapore
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set the culture to en-US to ensure AM/PM format
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8

COPY --from=publish /app/publish .
ENV ASPNETCORE_ENVIRONMENT=Development
ENTRYPOINT ["dotnet", "CI_CD.dll"]