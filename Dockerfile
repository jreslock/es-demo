FROM ubuntu:18.04

# Add a group and user, update and install packages
RUN addgroup --gid 4444 demo &&\
    adduser --uid 4444 --gid 4444 --shell /bin/bash --disabled-password --gecos "" demo &&\
    apt-get update -qq -y &&\
    apt-get install -qq -y \
    openssh-client \
    python3-dev \
    python-pip \
    unzip

# Set up packer and terraform
ADD https://releases.hashicorp.com/packer/1.3.2/packer_1.3.2_linux_amd64.zip /usr/local/bin/
ADD https://releases.hashicorp.com/terraform/0.11.10/terraform_0.11.10_linux_amd64.zip /usr/local/bin/
RUN unzip /usr/local/bin/terraform* -d /usr/local/bin/ &&\
    unzip /usr/local/bin/packer* -d /usr/local/bin/ &&\
    chmod +x /usr/local/bin/packer &&\
    chmod +x /usr/local/bin/terraform

# Switch to the demo user to install python packages
USER demo

RUN pip install --user awscli ansible
WORKDIR /home/demo
ENV PATH="/home/demo/.local/bin:$PATH"
CMD ["bash"]