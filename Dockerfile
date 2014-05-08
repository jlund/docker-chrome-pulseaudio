FROM ubuntu:latest
MAINTAINER Joshua Lund

# Tell debconf to run in non-interactive mode
ENV DEBIAN_FRONTEND noninteractive

# Make sure the repository information is up to date
RUN apt-get update

# Install Chrome
RUN apt-get install -y ca-certificates wget
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -P /tmp/
RUN dpkg -i /tmp/google-chrome-stable_current_amd64.deb || true
RUN apt-get install -fy

# Install OpenSSH
RUN apt-get install -y openssh-server

# Create OpenSSH privilege separation directory
RUN mkdir /var/run/sshd

# Install Pulseaudio
RUN apt-get install -y pulseaudio

# Add the Chrome user that will run the browser
RUN adduser --disabled-password --gecos "Chrome User" --uid 5001 chrome

# Add SSH public key for the chrome user
RUN mkdir /home/chrome/.ssh
ADD id_rsa.pub /home/chrome/.ssh/authorized_keys
RUN chown -R chrome:chrome /home/chrome/.ssh

# Set up the launch wrapper
RUN echo 'export PULSE_SERVER="tcp:localhost:64713"' >> /usr/local/bin/chrome-pulseaudio-forward
RUN echo 'google-chrome --no-sandbox' >> /usr/local/bin/chrome-pulseaudio-forward
RUN chmod 755 /usr/local/bin/chrome-pulseaudio-forward

# Start SSH so we are ready to make a tunnel
ENTRYPOINT ["/usr/sbin/sshd",  "-D"]

# Expose the SSH port
EXPOSE 22
