FROM microsoft/nanoserver:latest
MAINTAINER Peter J. Pouliot <peter@pouliot.net>

# $ProgressPreference: https://github.com/PowerShell/PowerShell/issues/2138#issuecomment-251261324
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# PATH isn't actually set in the Docker image, so we have to set it from within the container
RUN $newPath = ('C:\Redis;{0}' -f $env:PATH); \
	Write-Host ('Updating PATH: {0}' -f $newPath); \
# Nano Server does not have "[Environment]::SetEnvironmentVariable()"
	setx /M PATH $newPath;
# doing this first to share cache across versions more aggressively

ENV REDIS_VERSION 3.2.100
ENV REDIS_DOWNLOAD_URL https://github.com/MSOpenTech/redis/releases/download/win-${REDIS_VERSION}/Redis-x64-${REDIS_VERSION}.zip

RUN Write-Host ('Downloading {0} ...' -f $env:REDIS_DOWNLOAD_URL); \
	Invoke-WebRequest -Uri $env:REDIS_DOWNLOAD_URL -OutFile 'redis.zip'; \
	\
	Write-Host 'Expanding ...'; \
	Expand-Archive redis.zip -DestinationPath C:\Redis; \
	\
	Write-Host 'Verifying install ("redis-server --version") ...'; \
	redis-server --version; \
	\
	Write-Host 'Removing ...'; \
	Remove-Item redis.zip -Force

# disable Redis protected mode [1] as it is unnecessary in context of Docker
# (ports are not automatically exposed when running inside Docker, but rather explicitly by specifying -p / -P)
# [1]: https://github.com/antirez/redis/commit/edd4d555df57dc84265fdfb4ef59a4678832f6da
RUN (Get-Content C:\Redis\redis.windows.conf) \
	-Replace '^(bind)\s+.*$', '$1 0.0.0.0' \
	-Replace '^(protected-mode)\s+.*$', '$1 no' \
	| Set-Content C:\Redis\redis.docker.conf

# Note: Install Chocolatey
RUN \
    # Install Chocolatey and Packages
    Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')); \
    choco install openssh git wget curl rsync unzip winrar dotnet4.6.2 python3 ruby nodejs -Y ; \
    setx /m PATH "%PATH%;C:\Program Files\nodejs"; \
    refreshenv 
RUN \
    npm install -y yo generator-hubot ; \
    md c:\rak-hubot ;\
    cd c:\rak-hubot ;\
    yo hubot --owner='Peter J. Pouliot <peter@pouliot.net>' --name="Hubot" --description="Rakops Hubot" --adapter=campfire --defaults

VOLUME C:\\data
WORKDIR C:\\data

EXPOSE 6379
CMD ["redis-server.exe", "C:\\Redis\\redis.docker.conf"]
