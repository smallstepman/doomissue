FROM python:3.12-slim-bookworm

RUN apt-get update && apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:screencast' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile


# Copy uv executables from the specified container image layer
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Update system packages and install necessary tools in one step
RUN apt-get update && \
    apt-get install -y --no-install-recommends git && \
    uv tool install pyright && \
    rm -rf /var/lib/apt/lists/*

# Clone the specified repository
RUN git clone https://github.com/dbrtly/dagster-workspace /app/dagster-workspace
WORKDIR /app/dagster-workspace
RUN uv sync


EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
