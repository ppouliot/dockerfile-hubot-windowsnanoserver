FROM microsoft/nanoserver:latest
MAINTAINER Peter J. Pouliot <peter@pouliot.net>

ENV NODEJS_VERSION 9.4.0

#SHELL ["powershell", "-command"]
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN \
    # Install NodeJS
    Invoke-WebRequest -Uri https://nodejs.org/dist/latest-v9.x/node-v$ENV:NODEJS_VERSION-win-x64.zip -Outfile c:\node-v$ENV:NODEJS_VERSION-win-x64.zip; \
    Expand-Archive -Path C:\node-v$ENV:NODEJS_VERSION-win-x64.zip -DestinationPath C:\ -Force; \
    Remove-Item -Path c:\node-v$ENV:NODEJS_VERSION-win-x64.zip -Confirm:$False; \
    Rename-Item -Path node-v$ENV:NODEJS_VERSION-win-x64 -NewName nodejs

# PATH isn't actually set in the Docker image, so we have to set it from within the container
RUN $newPath = ('C:\nodejs;{0}' -f $env:PATH); \
	Write-Host ('Updating PATH: {0}' -f $newPath); \
# Nano Server does not have "[Environment]::SetEnvironmentVariable()"
	setx /M PATH $newPath;

# Install Hubot and related npms
RUN \
    cmd /c 'C:\nodejs\npm.cmd install -g yo generator-hubot'; \
    md c:\hubot ;\
    cd c:\hubot ;\
    yo hubot --owner='Peter J. Pouliot <peter@pouliot.net>' --name="Hubot" --description="Hubot in NanonServer Container" --adapter=slack --defaults ; \
    cmd /c 'C:\nodejs\npm.cmd install \
    css-select \
    css-what \
    minimatch \
    uuid \
    hubot-jenkins-enhanced \
    hubot-github \
    hubot-ghe \
    hubot-ghe-backup-snapshot \
    hubot-ghe-external-auto \
    hubot-ghe-external \
    hubot-ghe-failure-recovery'; \
    cmd /c 'C:\nodejs\npm.cmd uninstall hubot-heroku-keepalive' ; \
    rm -Force c:\hubot\hubot-scripts.json

COPY external-scripts.json C:\\hubot\\external-scripts.json
COPY hubot-start.ps1 C:\\hubot\\hubot-start.ps1
COPY Dockerfile C:\\Dockerfile

EXPOSE 8080
WORKDIR C:\\hubot
CMD [".\\bin\\hubot", "--adapter slack"]
